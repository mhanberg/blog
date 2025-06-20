---
layout: Blog.PostLayout
title: "Using Agenix with Home Manager"
date: 2025-06-09 01:00:00 EST
permalink: /:title/
tags: [nix, home-manager, agenix]
---

> [!tip]
> This article is part of the Agenix series
> - [Getting Started with Agenix](/getting-started-with-agenix)
> - 👉 **Using Agenix with Home Manager**
> - [Using Agenix with devShells](/using-agenix-with-devshells)

[Home Manager](https://github.com/nix-community/home-manager) (also styled as home-manager) allows you to configure your programs and configuration with Nix code, similar to NixOS modules.

Just like NixOS modules, we can use [Agenix](https://github.com/ryantm/agenix) to encrypt and store secrets without exposing them to our git repository.

## Install home-manager

Let's start with a basic home-manager configuration to our flake from last time (sans the NixOS configuration, for brevity).

```diff
{
  description = "Agenix example for home-manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
+   home-manager = {
+     url = "github:nix-community/home-manager";
+     inputs.nixpkgs.follows = "nixpkgs";
+   };
    agenix.url = "github:ryantm/agenix";
  };

  outputs = {
    self,
    nixpkgs,
+   home-manager
    agenix,
  }: let
    pkgs = nixpkgs.legacyPackages.aarch64-linux;
  in {
    devShells.aarch64-linux.default = pkgs.mkShell {
      packages = [
        agenix.packages.aarch64-linux.default
      ];
    };
+   homeManager."mitchell@nixos" = home-manager.lib.homeManagerConfiguration {
+     inhert pkgs;
+     modules = [];
+   };
  };
}
```

## Agenix homeManagerModule

The Agenix module is responsible for decrypting and installing your secrets at runtime.

```diff
{
  description = "Agenix example for home-manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix.url = "github:ryantm/agenix";
  };
 
  outputs = {
    self,
    nixpkgs,
    home-manager
    agenix,
  }: let
    pkgs = nixpkgs.legacyPackages.aarch64-linux;
  in {
    devShells.aarch64-linux.default = pkgs.mkShell {
      packages = [
        agenix.packages.aarch64-linux.default
      ];
    };
    homeManager."mitchell@nixos" = home-manager.lib.homeManagerConfiguration {
      inhert pkgs;
      modules = [
+       agenix.homeManagerModules.default
      ];
    };
   };
}
```

## Configure your secrets recipients

You can reference the section we described [last time](/getting-started-with-agenix/#5-configure-the-secrets-recipients).

This time, we're going to encrypt a file called `api-keys.age`.

## Create your secrets file

Create your secrets file by running `agenix -e api-keys.age` in the same directory as `secrets.nix`. Fill it with the following environment variables.

```bash
export SERVICE_A_API_KEY=foo
export SERVICE_B_API_KEY=bar
export SERVICE_C_API_KEY=baz
```

## Use your secrets

We want these environment variables to be available in our shell, so we're going to export them in our zsh configuration.

Let's start with a basic home-manager module that enables zsh.

```diff
{
  description = "Agenix example for home-manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix.url = "github:ryantm/agenix";
  };
 
  outputs = {
    self,
    nixpkgs,
    home-manager
    agenix,
  }: let
    pkgs = nixpkgs.legacyPackages.aarch64-linux;
  in {
    devShells.aarch64-linux.default = pkgs.mkShell {
      packages = [
        agenix.packages.aarch64-linux.default
      ];
    };
    homeManager."mitchell@nixos" = home-manager.lib.homeManagerConfiguration {
      inhert pkgs;
      modules = [
        agenix.homeManagerModules.default
+       ({...}: {
+         home.stateVersion = "25.11";
+         home.username = "mitchell";
+         home.homeDirectory = "/home/mitchell";
+         programs.zsh = {
+           enable = true;
+           initContent = ''
+           '';
+         }
+       })
      ];
    };
   };
}
```

Now we can configure our age secret and use its path in our zsh configuration.

```diff
{
  description = "Agenix example for home-manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix.url = "github:ryantm/agenix";
  };
 
  outputs = {
    self,
    nixpkgs,
    home-manager
    agenix,
  }: let
    pkgs = nixpkgs.legacyPackages.aarch64-linux;
  in {
    devShells.aarch64-linux.default = pkgs.mkShell {
      packages = [
        agenix.packages.aarch64-linux.default
      ];
    };
    homeManager."mitchell@nixos" = home-manager.lib.homeManagerConfiguration {
      inhert pkgs;
      modules = [
        agenix.homeManagerModules.default
-       ({...}: {
+       ({config, ...}: {
+          age.secrets = {
+            api-keys.file = ./api-keys.age;
+          };
          programs.zsh = {
            enable = true;
            initContent = ''
+             eval $(cat ${config.age.secrets.api-keys.path})
            '';
          }
        })
      ];
    };
   };
}
```

Those environment variables are now exported in your `.zshrc` file!

While being an unconventional use case (for API secrets like these, you would probably use them directly in a derivation for a script or a program), this this fully demonstrates how you can use Agenix with home-manager.

## Next Time

Home Manager is a good way to store global machine secrets like this for a particular user, but doesn't allow you to handle project level secrets.

Next time we'll se how we can utilize Agenix with devShells.

## Full Example

### flake.nix

```nix
{
  description = "Agenix example for home-manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix.url = "github:ryantm/agenix";
  };
 
  outputs = {
    self,
    nixpkgs,
    home-manager
    agenix,
  }: let
    pkgs = nixpkgs.legacyPackages.aarch64-linux;
  in {
    devShells.aarch64-linux.default = pkgs.mkShell {
      packages = [
        agenix.packages.aarch64-linux.default
      ];
    };
    homeConfigurations."mitchell@nixos" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        agenix.homeManagerModules.default
        ({config, ...}: {
          home.stateVersion = "25.11";
          home.username = "mitchell";
          home.homeDirectory = "/home/mitchell";

          age.secrets = {
            api-keys.file = ./api-keys.age;
          };
          programs.zsh = {
            enable = true;
            initContent = ''
              eval "$(cat ${config.age.secrets.api-keys.path})"
            '';
          };
        })
      ];
    };
  };
}
```

### secrets.nix

```nix
let
  local = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP55ETmYHSCjtvDZ/SDoHDTblYZPD2XDmObLMQvc+9xR mitchell@nixos";
  remote = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII5SFrZIaTh42TWQKSXeGRhBZ5CAvJWoJov+eiaUbwxa root@nixos";
in {
  "api-keys.age".publicKeys = [local remote]; 
}
```
