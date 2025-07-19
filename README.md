# My Personal Blog by haodq4

This repository contains the source code for my personal blog, built with **Hugo**. This blog is deployed automatically to GitHub Pages.

---

## How to Add and Publish New Posts

To add a new blog post and get it live on your blog, follow these steps:

### 1. Create a New Post

Use the Hugo CLI command to generate a new Markdown file for your post. Replace `new-post.md` with your desired file name (e.g., `my-first-article.md`).

```cmd
hugo new posts/new-post.md
```

### 2. Build and publish your post

Once you've finished editing your post, you'll need to rebuild the website and push the changes to GitHub.

- Build your post to the `public` folder: This command generates the static HTML files from your new post and other content.

```cmd
hugo --minify
```

- Check Locally (Optional but Recommended): Run the Hugo development server locally to preview how your new post looks before publishing. Access `http://localhost:1313/` in your browser.
```cmd
hugo server -D
```

- Publish to GitHub: Add all your changes (including the new post and the built files in the `public/` directory), commit them, and push them to GitHub.
```cmd
git add .
git commit -m "Add new post: new-post and update public/"
git push origin main
```

After the git push command completes, GitHub Pages will automatically update your blog. This process might take a few minutes.
