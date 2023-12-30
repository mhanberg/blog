---
layout: Blog.PostLayout
title: "Better Terminal Git Diffs"
date: 2020-08-12 09:00:00 -04:00
categories: post
permalink: /:title/
---

Normally, our terminal git diffs look like this.

![ normal git diff ](https://res.cloudinary.com/mhanberg/image/upload/v1597177346/normal-git-diff.png){: .bg-transparent }

Let's improve our experience by adding syntax highlighting!

To accomplish this, we're going to replace the pager that git uses with a tool called [delta](https://github.com/dandavison/delta). Add the following to `~/.gitconfig`.

```
[core]
  pager = "delta"
```

Let's see what our git diffs look like now.

![git diff using delta as the pager](https://res.cloudinary.com/mhanberg/image/upload/v1597174958/git-diff-delta.png){: .bg-transparent}

This looks great, but I think we can do even better. Let's configure `delta` to use the same theme as our terminal. `delta` uses [bat](https://github.com/sharkdp/bat/) for syntax highlighting, so we can use any theme that `bat` can use.

Grab your theme (you'll have to find a TextMate/Sublime Text version of it), copy it into `~/.config/bat/themes`, and add the following option to your pager configuration.

```
[core]
  pager = "delta --theme='Forest Night'"
```

Now, the highlighting blends seamlessly with the rest of my development experience.

![git diff using delta as the pager](https://res.cloudinary.com/mhanberg/image/upload/v1597175033/delta-git-diff-with-theme.png){: .bg-transparent}

One last improvement you can make is to use the same diff colors that your theme uses. I copied them from the theme file and added the following options to my pager configuration.

```
[core]
  pager = "delta --plus-color=\"#333B2F\" --minus-color=\"#382F32\" --theme='Forest Night'"
```

![git diff using delta as the pager](https://res.cloudinary.com/mhanberg/image/upload/v1597175171/delta-git-diff-with-theme-with-diff-color.png){: .bg-transparent}

Okay, now that our diffs look good, we can finally get back to work 😄.
