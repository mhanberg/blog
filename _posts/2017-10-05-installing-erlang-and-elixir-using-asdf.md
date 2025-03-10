---
layout: Blog.PostLayout
title: Installing Erlang and Elixir with asdf
date: 2017-10-05 11:30:00 -04:00
updated: 2021-02-18 11:30:00 -04:00
categories: post
desc: asdf is a multi-language version manager, making it an ideal choice for managing Erlang and Elixir versions. A guide on installing asdf, Erlang, and Elixir.
permalink: /post/2017/10/05/installing-erlang-and-elixir-using-asdf/
---

**Let's set the scene**

_You've been fully entrenched in the Ruby and Rails world for 10 months_

_You've just tied a bow on your latest side project_

_You're already bored and excited to start something new_

_For the sake of this post, you work on a mac_

So you've decided to mess around with Elixir! Nice choice, let's get started.

---

## What is Erlang?

> Erlang is a programming language used to build massively scalable soft real-time systems with requirements on high availability. Some of its uses are in telecoms, banking, e-commerce, computer telephony and instant messaging. Erlang's runtime system has built-in support for concurrency, distribution and fault tolerance.

## What is Elixir?

> Elixir is a dynamic, functional language designed for building scalable and maintainable applications.
>
> Elixir leverages the Erlang VM, known for running low-latency, distributed and fault-tolerant systems, while also being successfully used in web development and the embedded software domain.

Since you are coming from a Ruby background, you know how valuable using a version manager like [rbenv](https://github.com/rbenv/rbenv) or [rvm](https://github.com/rvm/rvm) can be. Since we are going to be installing two different programming language platforms, let's find a solution that can handle all of our needs.

## What is asdf?

> _extendable version manager_
>
> Supported languages include Ruby, Node.js, Elixir and more. Supporting a new language is as simple as this plugin API.

[asdf](https://github.com/asdf-vm/asdf) allows us to use one tool to manage both Elixir and Erlang, and the next time I'm working on a Ruby project, I will probably switch over to using it as well.

We can easily install asdf using [Homebrew](https://brew.sh/).

```shell
$ brew install asdf coreutils curl git
```

The next important bit is at the bottom of the output stating that you will need to initialize asdf whenever you start your shell session. I ran the following command to add that line to my .zshrc file, but you should add it to the approriate rc file for your shell.

```shell
$ echo 'source $(brew --prefix asdf)/asdf.sh' >> .zshrc
```

## Installing Erlang and Elixir

We're almost there! Since asdf relies on language plugins, we have to add those now and any dependencies they might require.

```shell
$ brew install autoconf
$ asdf plugin add erlang

$ brew install unzip
$ asdf plugin add elixir
```

Now we want to install the actual languages. The syntax for this is `asdf install <language> <version>`, so we can do the following.

```shell
$ asdf install erlang 23.2.5

$ asdf install elixir 1.11.3
```

If you want to see a list of available versions for each langauge, you can run the command `asdf list all <language>`

Let's make sure that they were successfully installed, running the following commands should produce this output.

```shell
$ source ~/.zshrc

$ which erl
/Users/mitchell/.asdf/shims/erl

$ which elixir
/Users/mitchell/.asdf/shims/elixir
```

asdf has the concepts of global versions and a local versions, but we are going to focus on the local version concept.

Once we navigate into the directory of our project, we can set the version of Erlang and Elixir that we want it to use.

```shell
$ cd ~/my-elixir-project
$ asdf local erlang 23.2.5
$ asdf local elixir 1.11.3

# Set them globally
$ asdf global erlang 23.2.5
$ asdf global elixir 1.11.3
```

This will add to (or create if there isn't one already) the `.tools-version` file in the root of your project folder. It should now resemble this.

```
erlang 23.2.5
elixir 1.11.3
```

Boom! You are now ready to get started with Elixir. Checking the version of Elixir should now confirm that your project can find and use it.

```shell
$ elixir --version
Erlang/OTP 23 [erts-11.1.7] [source] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:1] [hipe]

Elixir 1.11.3 (compiled with Erlang/OTP 21)
```
