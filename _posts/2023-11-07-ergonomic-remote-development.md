---
layout: Blog.PostLayout
title: "Ergonomic Remote Development"
date: 2023-11-07 08:00:00 -05:00
updated: 2024-06-04 08:00:00 -05:00
categories: post
permalink: /:title/
---

I recently built a new PC (you can see the specs on my [/uses](/uses) page!) and installed Linux on it.

The way I have been using it mostly has been through an SSH connection, even though its sitting underneath my desk, plugged into my monitor, and all my peripherals plugged into a nifty USB hub splitter thing!

I simply couldn't live without the macOS desktop environment. I have so much muscle memory for all of the shortcuts and have so many apps that I use that enhance my workflow.

I have never remotely developed for this long before, so I quickly ran into a bunch of papercuts for which I was able to easily find bandaids.

## Tailscale

When you are going to be SSHing into a remote computer, you need to know the IP address of the computer.

[Tailscale](https://tailscale.com/) makes this super easy. You install Tailscale on your local computer and on the remote computer, and they both joing your "tailnet".

Now, you have a static IP address that only other computers on your tailnet can access!

```bash
$ ssh mitchell@<remote ip>

Welcome to Ubuntu 23.10 (GNU/Linux 6.5.0-10-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

6 updates can be applied immediately.
To see these additional updates run: apt list --upgradable

*** System restart required ***
Last login: Tue Nov  7 07:24:00 2023 from <local ip>
```

## Clipboard

You'll want to make sure that you can still copy/paste to/from your host computer's clipboard (or 'pasteboard' as macOS calls it) from within TUI applications like Vim/Tmux and in shell scripts.

### TUI Apps

If you are using a modern terminal emulator (I use [Ghostty](https://mitchellh.com/ghostty)), you most likely have clipboard working already for TUI applications, as long as they support the appropriate terminal features.

I use [Nvim](https://neovim.io/), which does not [currently](https://github.com/neovim/neovim/pull/25872) support the OSC-52 terminal feature that enables system clipboard communication, but I use Nvim inside [tmux](https://github.com/tmux/tmux), which does!

And luckily, Nvim has a tmux 'clipboard provider' which is how Nvim actually communicates to the "outside" clipboard.

If you don't use tmux and use Vim/Nvim, there are plenty of [plugins](https://github.com/ojroques/vim-oscyank) that implement it!

### Scripting

The way that I have implemented scripting to my local clipboard is to again use SSH!

Since your computers are using Tailscale and are on the same tailnet, this means that your local computer also has a nice and static IP address that you can use.

Here is an example:

```sh
$ ssh mitchell@<local ip> pbpaste \
  | some-local-command \
  | ssh mitchell@<local ip> pbcopy
```

Here, we remotely run the `pbpaste` command (which, along with `pbpaste`, are the macOS scripting utilities for using the system clipboard), pipe the ouput into a local command, and then pipe it into `ssh`, which will send it to the `pbcopy` command on our local computer.

Now, you can easily wrap that up in an alias or a shell script.

## Opening your web browser

If you are used to opening web pages with utilities like the GitHub CLI [gh](https://cli.github.com/), you'll notice that those don't work anymore. This is because (on Linux), the tool is (most likely) running `xdg-open`, which is similar to the `open` command on macOS.

You are running this on the remote computer, which is not logged into a desktop environment, and has no web browser.

Well, we can easily fix this again with SSH!

What I did was write a shell script called `xdg-open` and put it in my `$PATH`. This way, tools like `gh` will actually call my script instead of the built-in `xdg-open`.

My script looks like this:

```bash
#!/usr/bin/env bash

function main() {
	local ip
	local uri

	uri="$1"
	if [[ ! -z "$SSH_CONNECTION" ]]; then
		ip="$(echo "$SSH_CONNECTION" | awk '{ print $1 }')"

		ssh "mitchell@$ip" open "$uri"
	else
		xdg-open "$uri"
	fi
}

main "$@"
```

We check the `$SSH_CONNECTION` environment variable to see if we are in an SSH session.

If we are _not_, we just call `xdg-open` as usual. This is helpful in case we log onto our PC like a normal person.

If we _are_, then we parse our local IP address out of the `$SSH_CONNECTION` variable and run the `open` command remotely using `ssh`.


## Web Development

Now, if you are a web developer, you typically will be starting a local web server and previewing your site or app in the browser. This gets a little tricky when your browser and web server are not on the same computer!

### Tailscale

Luckily, tailscale comes to the rescue again!

With tailscale, you can create a reverse proxy served over `https` with your existing free plan.


```bash
$ tailscale serve https / http://localhost:4000
```

This will create a reverse proxy that is only available inside your tailnet!

If you want to show off your beautiful website to a client or coworker, you can run `tailscale funnel 443 on`, which will make your reverse proxy available outside of your tailnet.

### SSH Port Forwarding

You can also just tack on some options to the `ssh` command instead of using Tailscale

```bash
$ ssh mitchell@<remote ip> -L 4999:localhost:4999
```

## Signing Git Commits

I sign my `git` commits using the [1Password](https://1password.com/) SSH agent. This allows me to use an SSH key (instead of a GPG key) and to authorize the usage of the key with Touch ID on my Mac.

As you can imagine, when I went commit my first code on my new PC, I thought I had found a utter road block that would stop this new workflow from continuing.


Luckily, you can actually _forward_ your SSH agent when you make and SSH connection. This is typically for when you are machine hopping and have to `ssh` to a remote machine from inside an `ssh` connection, so that you don't have to install your keys on your local computer and the first remote computer.

And, this also works for 1Password Git Commit signing!

Just add an entry in your `~/.ssh/config` for your PC to allow forwarding on your local computer:

```ssh
Host <remote ip>
  ForwardAgent yes
```

And on the PC, configure the IdentityAgent to use 1Password. I don't actually remember if this is necessary, but when writing this post, I found this config and I don't remember writing it, so it must be  important!
 
```ssh
Host *
  IdentityAgent ~/.1password/agent.sock
```


## Conclusion

And there we have it! 

Now you should be able to develop remotely and not even be able to tell the difference, except for the sheer speed of your overpowered new PC!
