---
title: "Large-Scale System Design"
date: 2025-07-19
draft: false
tags: ["dev", "system-design"]
description: "How do you design a distributed system powerful enough to serve millions of users?
This article shares the core principles and techniques of system design for large-scale applications."
---

Designing a system for 10 users is very different from designing one for 10 million.

Scaling isn’t just about “adding more servers” — it’s an architectural challenge: where the data flows, how it’s processed, and how the system holds under pressure.

In this article, I’ll share a step-by-step approach to building a scalable system — not through formulas or dogma, but through real-world design thinking shaped by hands-on experience.


## 1. Start with a Single Server

In the early stage, the entire system often runs on a single machine.

The backend app, web server, database, and static files — everything lives together.  
It's simple, easy to deploy, and good enough for testing features or demo purposes.

![Single server diagram](/images/post2/single-server.png)

### Pros:
- Quick to set up and get running  
- No infrastructure management needed  
- No need to split anything yet  

### Cons:
- Hard to scale when traffic grows  
- One failure can bring down the whole system  
- Not ideal if you need to scale components independently  

A single server is fine while the system is small.  
But once traffic increases — or you need better performance and reliability — you'll need to start breaking things apart.

