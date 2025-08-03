---
title: "Lessons Learned: Fixing SSO Issues in a Multi-Node Spring Boot App"
date: 2025-08-03
draft: false
tags: ["spring-boot", "sso", "system-design"]
description: "Two issues I faced while implementing SSO in a Spring Boot app running on multiple Kubernetes pods, and how I fixed them."
---

Last week, I was assigned to implement **SSO (Single Sign-On)** for a project called **HappyClub**.  
The backend runs on **Java Spring Boot**, and locally everything worked just fine — smooth SSO redirect, valid tokens, no errors.

But as soon as I deployed to the staging environment (which runs 2 pods on Kubernetes), I hit **two painful issues**.  
I wasted quite a bit of time debugging because I didn’t read the Spring Security docs carefully at first 😅.

Here’s what happened and how I fixed them.

---

## Issue 1: Token rejected due to server clock drift

Everything worked on my local machine. But when deployed, every login attempt failed with this error:

```log
2025-07-29T08:10:16.531Z TRACE 1 --- [happy-club-api-staging] [nio-8080-exec-7]
.s.o.c.w.OAuth2LoginAuthenticationFilter : Failed to process authentication request

org.springframework.security.oauth2.core.OAuth2AuthenticationException:
[invalid_id_token] An error occurred while attempting to decode the Jwt:
The ID Token contains invalid claims: {iat=2025-07-29T08:14:01Z}
```

The root cause?  
The **server clock was behind by ~4 minutes** because the NTP service wasn’t properly synced.  
Since the token’s `iat` (issued-at) claim was ahead of the server time, Spring Security rejected it as invalid.

### How I solved it

1. **Reported the issue to the system team** so they could fix NTP syncing at the server level.  
   But I don’t want to rely only on infra — clock drift can always happen.

2. **Added a configurable clock skew in my Spring Security config.**  
   This way, even if there’s a slight drift, the app won’t break.  
   More importantly, I can control the allowed skew **per environment via config**, increasing or decreasing as needed.

```java
@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true)
public class SecurityConfig {

  @Value("${spring.security.oauth2.client.clock-skew-minutes}")
  private Long clockSkewMinutes;

  @Bean
  public SecurityFilterChain securityFilterChain(
      HttpSecurity http, ClientRegistrationRepository clientRegistrationRepository)
      throws Exception {

    OidcAuthorizationCodeAuthenticationProvider provider =
        new OidcAuthorizationCodeAuthenticationProvider(
            new DefaultAuthorizationCodeTokenResponseClient(), new OidcUserService());

    provider.setJwtDecoderFactory(clientRegistration -> {
      NimbusJwtDecoder jwtDecoder = NimbusJwtDecoder
          .withJwkSetUri(clientRegistration.getProviderDetails().getJwkSetUri())
          .build();
      jwtDecoder.setJwtValidator(new JwtTimestampValidator(Duration.ofMinutes(clockSkewMinutes)));
      return jwtDecoder;
    });

    http.authenticationProvider(provider);
    // ... other security config
    return http.build();
  }
}
```

✅ **Key takeaway:**  
Even if NTP is fixed, always configure clock skew so your app is resilient to small time drifts.

---

## Issue 2: Session lost when running multiple pods

After fixing Issue 1, I hit another problem.  
When running with 2 pods, users got redirected to SSO in a loop. Locally (1 pod), everything was fine.

### Why?

By default, Spring Security stores sessions **in-memory per node**.  
So after logging in, if the callback lands on a different pod, that pod won’t know about the session → Spring rejects the token → redirect loop.

### How I solved it

I externalized session storage to **Redis**, so all pods share the same session store.

```java
@Configuration
@EnableRedisHttpSession
public class SessionConfig {

  @Value("${spring.data.redis.host}")
  private String redisHost;

  @Value("${spring.data.redis.port}")
  private int redisPort;

  @Value("${spring.data.redis.password}")
  private String redisPassword;

  @Value("${spring.data.redis.database}")
  private int redisDatabase;

  @Bean
  public LettuceConnectionFactory connectionFactory(ClientResources clientResources) {
    RedisStandaloneConfiguration config = new RedisStandaloneConfiguration();
    config.setHostName(redisHost);
    config.setPort(redisPort);
    config.setPassword(redisPassword);
    config.setDatabase(redisDatabase);

    LettuceClientConfiguration clientConfig =
        LettuceClientConfiguration.builder()
            .clientOptions(ClientOptions.builder().build())
            .clientResources(clientResources)
            .build();

    return new LettuceConnectionFactory(config, clientConfig);
  }

  @Bean(destroyMethod = "shutdown")
  public ClientResources clientResources() {
    return DefaultClientResources.builder().build();
  }
}
```

`application.yml`:

```yaml
spring:
  data:
    redis:
      host: ${REDIS_HOST}
      port: ${REDIS_PORT}
      database: 1
      password: 123456
```

### Why Redis over JDBC?

- ⚡ **Performance:** Redis is in-memory and handles session reads/writes much faster than a relational DB.  
- 📈 **Scalability:** It’s built for distributed setups, perfect for multi-node environments.  
- 🔄 **Session sharing:** With Redis, sessions are immediately available to all pods.

✅ **Key takeaway:**  
If you already have a database and very low traffic, JDBC might be okay.  
But for most cases, Redis is the better choice for sharing sessions in a scalable way.

---

## Final thoughts

These two bugs taught me an important lesson:

Infrastructure issues will happen (like NTP drift) → so apps should be defensive.

When scaling horizontally, state should never live only in memory.

Both fixes turned out to be pretty small in terms of code.
But figuring out the root cause took much longer than it should have — mostly because I didn’t read the Spring Security docs carefully enough at first.

Hopefully, this saves someone else some debugging time!

