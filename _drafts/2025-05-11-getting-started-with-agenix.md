---
layout: Blog.PostLayout
title: "Getting Started with Agenix"
date: 2025-05-11 01:00:00 EST
permalink: /:title/
tags: [nix, nixos, agenix]
---

[NixOS modules](https://nixos.wiki/wiki/NixOS_modules) make it easy to configure many services with a consistent interface (the Nix language), but configuring confidential options like passwords and API keys this way has two major problems.

- Secrets should not be committed to source control in plain text.
- Values and files used in NixOS modules are copied to the [nix store](https://nix.dev/manual/nix/2.28/store/), which is globally readable.

[Agenix](https://github.com/ryantm/agenix) is a [Nix](https://nixos.org) package and CLI utility that allows you to encrypt files to store secrets in your repository and then be able to decrypt them at runtime, giving access to your services.

The key here is that these secrets are decrypted to temporary directories with limited filesystem permissions and are kept out of the nix store.

Let's see what it looks like to use Agenix in these contexts through a Nix flake.

> [!note]
> These examples show the system as "aarch64-linux" since I am using them in a virtual machine on my Apple Silicon laptop

## NixOS Modules

Let's build out an example that configures [PiHole](https://pi-hole.net/) as an OCI container whose secrets are provided by an environment file.

### 1. Add it as an input

```diff
{
  description = "Agenix example for NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
+   agenix.url = "github:ryantm/agenix";
  };
}
```

### 2. Add the CLI tool to your package in your devShell

The `agenix` CLI tool is what we use to edit our secrets locally.

Now, you can enter your devShell with `nix develop` and have access to the `agenix` utility.

```diff
{
  description = "Agenix example for NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    agenix.url = "github:ryantm/agenix";
  };

- outputs = { self, nixpkgs }: {
+ outputs = { self, nixpkgs, agenix }: let
+   pkgs = nixpkgs.legacyPackages.aarch64-linux;
+ in {
+   devShells.aarch64-linux.default = pkgs.mkShell {
+     packages = [
+       agenix.packages.aarch64-linux.default
+     ];
    };
  };
}
```

### 3. NixOS configuration

Let's add the basic NixOS configuration before adding anything Agenix specific.

```diff
{
  description = "Agenix example for NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    agenix.url = "github:ryantm/agenix";
  };

  outputs = { self, nixpkgs, agenix }: let
    pkgs = nixpkgs.legacyPackages.aarch64-linux;
  in {
    devShells.aarch64-linux.default = pkgs.mkShell {
      packages = [
        agenix.packages.aarch64-linux.default
      ];
    };
+   nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
+     system = "aarch64-linux";
+     modules = [
+       ./configuration.nix
+     ];
+   };
}
```

### 4. Add the Agenix module

The Agenix module is responsible for decrypting and installing your secrets at runtime.

```diff
{
  description = "Agenix example for NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    agenix.url = "github:ryantm/agenix";
  };

  outputs = { self, nixpkgs, agenix }: let
    pkgs = nixpkgs.legacyPackages.aarch64-linux;
  in {
    devShells.aarch64-linux.default = pkgs.mkShell {
      packages = [
        agenix.packages.aarch64-linux.default
      ];
    };
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        ./configuration.nix
+       agenix.nixosModules.default
      ];
    };
}
```

### 5. Configure the secrets recipients

Agenix controls who can decrypt which secret with a `secrets.nix` file. This file contains the public keys used to _encrypt_ the data, which also determines which private keys can _decrypt_ the data.

With Agenix, the decryption will happen with the deployed servers ssh keys that are stored in `/etc/ssh`, so here we make `remote` equal to the public key at `/etc/ssh/ssh_host_ed25519_key.pub`

We also set a `local` key, which is your local computer's ssh public key. This one is used by the `agenix` CLI utility to encrypt and decrypt the secrets during development

> [!important]
> If you are collaborating with other people, you will need to either add everyone's public keys to this file, or share a public/private key pair through something like [1Password](https://developer.1password.com/docs/ssh/agent/).
>
> If you add a new public key, you'll need to have to rekey the files using an existing public key with `agenix --rekey`.

We then configure the `pihole.age` file use use these two public keys.

> [!note]
> As you can see by the hostname at the end of each public key, these are both on the same system. That's okay, but a little confusing. If you only try to use `local`, which is stored in `~/.ssh/`, when you attempt to run `nixos-rebuild`, you'll get an error from Agenix saying it couldn't find the right identity file to decrypt

```nix
let
  local = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP55ETmYHSCjtvDZ/SDoHDTblYZPD2XDmObLMQvc+9xR mitchell@nixos";
  remote = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII5SFrZIaTh42TWQKSXeGRhBZ5CAvJWoJov+eiaUbwxa root@nixos";
in {
  "pihole.age".publicKeys = [local remote]; 
}
```

### 6. Create your secrets file

Create your secrets file by running `agenix -e pihole.age` in the same directory as `secrets.nix`. Fill it with the following environment variables.

```bash
FTLCONF_webserver_api_password=password
```

If you try to read this file without decrypting it, you'll see something like this:

```
age-encryption.org/v1
-> ssh-ed25519 piHZrQ PuyA20t9WXtsZ7EoFS2gYLOgIsDwxtf4eC3nObAReC4
QxeIZNSg8wOzdVAFWKWgFWiXsYpdNRfGLx8wUSP/qDk
-> ssh-ed25519 rglX5A Y1yMBwhebYIL4feWALoFykp0WIWC8hsMtEVQDCgRoyo
zHbuGsYqgdGDdWjiuEjjgEift36XAEksGPAIYbsQnQc
--- w9m5TVJois69mM1HFXbPdmd9zp4DbzYEnmctmU3zGXA
�s�ކ�ٙq���J�d��M�
����Iț����k��r��������!��H/�����M"ҧ2�,W`fs
```

### 7. Pass the secrets path to a service

Now that we have an encrypted secrets file, we can give the path to the (eventually) decrypted file to the NixOS module. Let's add our PiHole service to our configuration, then add the secrets path.

> [!note]
> Here we're using an inline NixOS module, which is just a function. You can move this to its own file and import it like the `configuration.nix` module.

```diff
{
  description = "Agenix example for NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    agenix.url = "github:ryantm/agenix";
  };

  outputs = {
    self,
    nixpkgs,
    agenix,
  }: let
    pkgs = nixpkgs.legacyPackages.aarch64-linux;
  in {
    devShells.aarch64-linux.default = pkgs.mkShell {
      packages = [
        agenix.packages.aarch64-linux.default
      ];
    };
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";

      modules = [
        ./configuration.nix
        agenix.nixosModules.default
+       ({...}: {
+         virtualisation.oci-containers.containers = {
+           pi-hole = {
+             image = "pihole/pihole:latest";
+             volumes = [
+               "/var/lib/pihole:/etc/pihole"
+             ];
+             hostname = "pihole";
+             ports = [
+               "53:53/tcp"
+               "53:53/udp"
+               "3001:80/tcp"
+               "443:443/tcp"
+             ];
+           };
+         };
+       })
      ];
    };
  };
}
```

Now we can tell the Agenix NixOS module about our encrypted files

```diff
{
  description = "Agenix example for NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    agenix.url = "github:ryantm/agenix";
  };

  outputs = {
    self,
    nixpkgs,
    agenix,
  }: let
    pkgs = nixpkgs.legacyPackages.aarch64-linux;
  in {
    devShells.aarch64-linux.default = pkgs.mkShell {
      packages = [
        agenix.packages.aarch64-linux.default
      ];
    };
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";

      modules = [
        ./configuration.nix
        agenix.nixosModules.default
-       ({...}: {
+       ({config, ...}: {
+         age.secrets = {
+           pihole.file = ./pihole.age;
+         };
          virtualisation.oci-containers.containers = {
            pi-hole = {
              image = "pihole/pihole:latest";
              volumes = [
                "/var/lib/pihole:/etc/pihole"
              ];
+             environmentFiles = [
+               config.age.secrets.pihole.path
+             ];
              hostname = "pihole";
              ports = [
                "53:53/tcp"
                "53:53/udp"
                "3001:80/tcp"
                "443:443/tcp"
              ];
            };
          };
        })
      ];
    };
  };
}
```

## Next Time

We built a NixOS module that consumes runtime secrets through a decrypted file that we keep encrypted at rest in our project.

Next time we'll see how we can utilize Agenix with [home-manager](https://home-manager.dev/manual/23.05/index.html)!

## Full Example

### flake.nix

```nix
{
  description = "Agenix example for NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    agenix.url = "github:ryantm/agenix";
  };

  outputs = {
    self,
    nixpkgs,
    agenix,
  }: let
    pkgs = nixpkgs.legacyPackages.aarch64-linux;
  in {
    devShells.aarch64-linux.default = pkgs.mkShell {
      packages = [
        agenix.packages.aarch64-linux.default
      ];
    };
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";

      modules = [
        ./configuration.nix
        agenix.nixosModules.default
        ({config, ...}: {
          age.secrets = {
            pihole.file = ./pihole.age;
          };
          virtualisation.oci-containers.containers = {
            pi-hole = {
              image = "pihole/pihole:latest";
              volumes = [
                "/var/lib/pihole:/etc/pihole"
              ];
              environmentFiles = [
                config.age.secrets.pihole.path
              ];
              hostname = "pihole";
              ports = [
                "53:53/tcp"
                "53:53/udp"
                "3001:80/tcp"
                "443:443/tcp"
              ];
            };
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
  "pihole.age".publicKeys = [local remote]; 
}
```
