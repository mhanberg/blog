---
layout: Blog.PostLayout
title: "Compiling C with Zig"
date: 2025-06-13 01:00:00 EST
permalink: /:title/
tags: [c, zig, nix]
---

I'm relatively new to systems programming, having not done any since college (go [Boilermakers!](https://cs.purdue.edu)), and back then we weren't really taught anything about build systems.

I think the most we did was manually calling `gcc` or were given a Makefile that no one comprehended... or was that just me 🤔.

I recently read through [Modern C](https://www.manning.com/books/modern-c) by Jens Gustedt and I'm currently reading through [Tiny C Projects](https://www.manning.com/books/tiny-c-projects) by Dan Gookin (did you know he wrote the very first "For Dummies" book??). A little unusual for me, I'm actually trying to code the exercises, which has brought me to C build systems.

I was perfectly fine compiling my tiny projects with `clang -Wall greeter.c -o greeter`, but since I'm also infected with the [Nix mind virus](/uses/#development), I wanted to be able to package it up in a [Nix flake](https://nixos.wiki/wiki/flakes).

This lead me to a conundrum. I wasn't sure how to share the build configuration between the nix-less project and the Nix flake. 

The correct thing to do is to learn [CMake](https://cmake.org/) and `make`, but I'm also interested in [Zig](https://ziglang.org) and planned on doing these tiny C projects in Zig as well, so might as well try it out.

> [!caution]
> This article isn't meant to imply this is the best course of action, if that wasn't already clear by me saying I'm new to this whole thing.

## build.zig

This resulting `build.zig` is more or less the generated file from `zig init`, minus all the comments and anything related to tests.

Really, all we need to do is add an executable to the build graph, add a C source file, and link libc.

Now, we can run `zig build run` to run our code in one step!

```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // the main event 👇
    const exe = b.addExecutable(.{ .name = "chapter2", .target = target, .optimize = optimize });
    exe.addCSourceFile(.{ .file = .{ .src_path = .{ .owner = b, .sub_path = "./main.c" } } });
    exe.linkLibC();

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
```

## Nix

As a bonus, we'll check out the Nix flake. With this, we can run our code in one step with `nix run .#chapter2`.

### flake.nix

```nix
{
  description = "Tiny C Projects";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = {nixpkgs, ...}: let
    inherit (nixpkgs) lib;
    systems = [
      "aarch64-darwin"
      "x86_64-darwin"
      "x86_64-linux"
      "aarch64-linux"
    ];
    perSystem = func: lib.genAttrs systems (system: func {pkgs = nixpkgs.legacyPackages.${system};});
  in {
    packages = perSystem ({pkgs, ...}: {
      chapter2 = pkgs.callPackage ./chapter2/package.nix {};
    });
    devShells = perSystem ({pkgs, ...}: {
      default = pkgs.mkShell {
        packages = with pkgs; [
          zig_0_14
          zls
          clang-tools
          clang
        ];
      };
    });
  };
}
```

### package.nix

Each chapter has its own separate `package.nix` file.

All you have to do is include `zig.hook` in `nativeBuildInputs`. This configures all the standard phases to instead call the relevant Zig commands.

```nix
{
  pkgs,
  zig,
  ...
}:
pkgs.stdenv.mkDerivation {
  name = "chapter2";
  version = "0.1.0";
  src = ./.;
  nativeBuildInputs = [
    zig.hook
    pkgs.zig_0_14
  ];
}
```
