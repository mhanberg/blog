---
layout: Blog.PostLayout
title: "Code BEAM America 2025"
date: 2025-03-11 01:00:00 EST
tags: [elixir, speaking, codebeam]
permalink: /:title/
---

My first conference of 2025 was [Code BEAM America](https://codebeamamerica.com) and I had the honor of attending with a great crew from DraftKings ([we're hiring!](https://careers.draftkings.com/jobs/jr10888/lead-software-engineer-elixir/)) and to give my second ever conference talk!

## On the Elixir community

Reflecting on this year's conference, I realized how comfortable I was the entire time. After 7 years in the Elixir community, I've accumulated a number for friends and acquaintences, something I really never expected from a work adjacent interest like a programming language.

At my first Elixir conference, [Lonestar Elixir 2020](https://web.archive.org/web/20200308234856/https://lonestarelixir.com/) (rough year, but also the year I "went pro" with Elixir), I had a couple of acquaintences from my new job at [Bleacher Report](https://bleacherreport.com/), but I hadn't really me them yet. I'm a pretty social guy, but traveling across the country to hang out with a bunch of strangers isn't really my comfort zone.

Luckily, I met folks like [Todd Resudek](https://supersimple.org/) who go out of their way to be friendly and introduce you to people they know. I've tried to embody this spirit myself at social gatherings ever since, and Code BEAM America 2025 was no exception.

## My talk

This year I gave an update on our progress with the [unified language server project](/ive-joined-the-official-elixir-lsp-team/).

We are a little more than 6 months into the project and it felt great to finally share how it's going and what to expect.

I spoke to a number of folks on what they're excited about with the project and had a blast exploring the possibilities of the next generation of Elixir tooling.

I'll update this with a link to the talk once it's available.

## The talks

I thoroughly enjoyed the talks I attended this year (I can admit I do enjoy the hallway track as well...) with a couple of notable talks.

### Jason Axelson - Choosing an effective testing structure

[Jason Axelson](https://www.linkedin.com/in/jasonaxelson/) gave a presentation on testing practices from which I almost broke neck from aggressively nodding the entire time.

One of his suggestions I believe is the most powerful: "Make your tests async" (paraphrased, I didn't write it down because of the aforementioned head banging).

The rationale is basically that by making your tests async, you are forced to iron out a lot of the concurrency kinks in your programs and it helps you really understand your codebase from the bottom up. Improving your own understanding of your codebases will pay dividends when it comes time to handle the unfortunate production incident or training juniors/new teammates.

Later on, I shared with Jason an [example repository](https://github.com/mhanberg/sandrabbit) I had made which demonstrates how to structure a Phoenix application that deals with singleton GenServers (global state) and still maintain async tests.

PS: Isn't it cool that at a conference you can watch a presentation and then later eat lunch (or drink beer) next to them and discuss it??

### Jeffrey Matthias and Aidan Obley - Crafting Fully Custom Code Generators

In this talk, [Jeffrey](https://www.linkedin.com/in/jeffreymatthias/) and [Aidan](https://www.linkedin.com/in/adobley/) cover how they use custom generators at [Mechanical Orchard](https://www.mechanical-orchard.com/) to help rebuild legacy programs in Elixir.

In their talk, Jeffrey notes (paraphrased) "Remember, this is _your_ app, you can name the folders what you want and place the files where you'd like".

I think this is an important thing to realize. I love that our community and frameworks have conventions, but sometimes I feel that folks become blinded to what they're "allowed" to do.

The default Phoenix generators might have a certain naming scheme or directory structure, but that doesn't mean it's the ordained way to structure your program (it's mostly superficial anyway.)

## See ya next time

I had a blast and I hope to catch ya at the next Code BEAM 👋

