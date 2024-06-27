---
layout: Blog.PostLayout
title: "Validate and transform your data with Schematic"
date: 2024-06-19 01:00:00 -04:00
permalink: /:title/
---

I've recently seen talk of similar libraries to [Schematic](https://github.com/mhanberg/schematic) so I figured I'd share my take on the problem space!

## Schematic

Schematic is a library for validating and transforming data in Elixir, similar to [Ecto Changesets]() and [Norm]().

I created Schematic while developing the [GenLSP]() library, which I developed to build [Next LS](). I needed to be able to consume and produce data structures described by the Language Server Protocol JSON Schema specification, which describes data in terms of basic scalar types and certain compound types, similar to algebraic datatypes (union and sum types).

I wanted a library that was very expressible, compose-able, and lends itself to code generation.
