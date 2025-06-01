---
layout: Blog.PostLayout
title: "Using Agenix with devShells"
date: 2025-06-16 01:00:00 EST
permalink: /:title/
tags: [nix, devshell, agenix]
---

> [!tip]
> This article is part of the Agenix series
> - [Getting Started with Agenix](/getting-started-with-agenix)
> - [Using Agenix with Home Manager](/using-agenix-with-home-manager)
> - 👉 **Using Agenix with devShells**

[Nix](https://nixos.org) with [Flakes](https://zero-to-nix.com/concepts/flakes/) allows you to easily centralize project environments and setup right in your repository. Often, your README will tell the reader "get an API key for FOOSERVICE from a teammate"

Just like NixOS modules and [home-manager](https://github.com/nix-community/home-manager), we can use [Agenix](https://github.com/ryantm/agenix) to encrypt and store secrets without exposing them to our git repository.

## 1. flake-parts

The easiest way to use Agenix with devShells is to use the [agenix-shell](https://flake.parts/options/agenix-shell) module for [flake-parts](https://flake.parts/index.html).

Let's start with a basic flake using flake-parts.

```diff
{
  description = "Agenix example for devShells";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
+   flake-parts.url = "github:hercules-ci/flake-parts";
  };

- outputs = { self, nixpkgs }:
+ outputs = { self, nixpkgs, flake-parts }: 
+   flake-parts.lib.mkFlake {inherit inputs;} {
+     imports = [];
+     systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
+     perSystem = { pkgs, ... }: {
+       devShells.default = pkgs.mkShell {
+         packages = [];
+       };
+     };
+   }
+ };
}
```

## 2. Add Agenix and agenix-shell

Lets add flake-parts and the agenix-shell module.

```diff
{
  description = "Agenix example for devShells";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
+   agenix.url = "github:ryantm/agenix";
+   agenix-shell.url = "github:aciceri/agenix-shell";
  };

- outputs = { self, nixpkgs, flake-parts }:
+ outputs = { self, nixpkgs, flake-parts, agenix, agenix-shell }: 
    flake-parts.lib.mkFlake {inherit inputs;} {
-     imports = [];
+      imports = [
+        agenix-shell.flakeModules.default
+      ];
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
-      perSystem = { pkgs, ... }: {
+      perSystem = { pkgs, config, lib ... }: {
        devShells.default = pkgs.mkShell {
-         packages = [];
+         packages = [agenix.packages.${system}.default];
+         shellHook = ''
+           source ${lib.getExe config.agenix-shell.installationScript}
+         '';
        };
      };
    }
  };
}
```

## 3. Configure your secrets recipients

You can reference the section we described [last time](/getting-started-with-agenix/#5-configure-the-secrets-recipients).

This time, we're going to encrypt a file called `api-keys.age`.

## 4. Create your secrets files

Create your secrets files by running `agenix -e <key-name>.age` in the same directory as `secrets.nix`. Fill them in with the relevant values.

```
# service-a-api-key.age
foo
```

## 5. Use your secrets 

```diff
{
  description = "Agenix example for devShells";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    agenix.url = "github:ryantm/agenix";
    agenix-shell.url = "github:aciceri/agenix-shell";
  };

  outputs = { self, nixpkgs, flake-parts, agenix, agenix-shell }: 
    flake-parts.lib.mkFlake {inherit inputs;} {
       imports = [
         agenix-shell.flakeModules.default
       ];
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
+     agenix-shell = {
+       secrets = {
+         SERVICE_A_API_KEY.file = ./service-a-api-key.age;
+         SERVICE_B_API_KEY.file = ./service-b-api-key.age;
+         SERVICE_C_API_KEY.file = ./service-c-api-key.age;
+       };
+     };
       perSystem = { pkgs, config, lib ... }: {
        devShells.default = pkgs.mkShell {
          packages = [agenix.packages.${system}.default];
          shellHook = ''
            source ${lib.getExe config.agenix-shell.installationScript}
          '';
        };
      };
    }
  };
}
```

Your local project secrets are now available when you enter your devShell with `nix develop`.

## Wrapping Up

Agenix seemed complicated to me at first, but once I got it set up up in the three usual scenarios (NixOS, home-manager, and devShells), its simplicity came to light.

I hope this series helps you take advantage of Agenix as well.

## Full Example

### flake.nix

```nix
{
  description = "Agenix example for devShells";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    agenix.url = "github:ryantm/agenix";
    agenix-shell.url = "github:aciceri/agenix-shell";
  };

  outputs = { self, nixpkgs, flake-parts, agenix, agenix-shell }: 
    flake-parts.lib.mkFlake {inherit inputs;} {
       imports = [
         agenix-shell.flakeModules.default
       ];
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      agenix-shell = {
        secrets = {
          SERVICE_A_API_KEY.file = ./service-a-api-key.age;
          SERVICE_B_API_KEY.file = ./service-b-api-key.age;
          SERVICE_C_API_KEY.file = ./service-c-api-key.age;
        };
      };
       perSystem = { pkgs, config, lib ... }: {
        devShells.default = pkgs.mkShell {
          packages = [agenix.packages.${system}.default];
          shellHook = ''
            source ${lib.getExe config.agenix-shell.installationScript}
          '';
        };
      };
    }
  };
}
```

### secrets.nix

```nix
let
  local = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP55ETmYHSCjtvDZ/SDoHDTblYZPD2XDmObLMQvc+9xR mitchell@nixos";
  remote = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII5SFrZIaTh42TWQKSXeGRhBZ5CAvJWoJov+eiaUbwxa root@nixos";
in {
  "service-a-api-key.age".publicKeys = [local remote]; 
  "service-b-api-key.age".publicKeys = [local remote]; 
  "service-c-api-key.age".publicKeys = [local remote]; 
}
```
