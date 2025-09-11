{
  description = "Mitchell Hanberg's blog";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    agenix-shell.url = "github:aciceri/agenix-shell";
    agenix.url = "github:ryantm/agenix";
    beam-flakes = {
      url = "github:elixir-tools/nix-beam-flakes";
      inputs.flake-parts.follows = "flake-parts";
    };
  };

  outputs = inputs @ {
    flake-parts,
    agenix,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.agenix-shell.flakeModules.default
        inputs.beam-flakes.flakeModule
      ];
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      agenix-shell = {
        # identityPaths = [
        #   "$HOME/.ssh/id_ed25519"
        #   "$HOME/.ssh/id_rsa"
        # ];

        secrets = {
          GOODREADS_KEY.file = ./secrets/GOODREADS_KEY.age;
          NETLIFY_AUTH_TOKEN.file = ./secrets/NETLIFY_AUTH_TOKEN.age;
          NETLIFY_SITE_ID.file = ./secrets/NETLIFY_SITE_ID.age;
        };
      };
      perSystem = {
        pkgs,
        config,
        lib,
        ...
      }: {
        beamWorkspace = {
          enable = true;
          devShell = {
            enable = false;
            languageServers.elixir = false;
            languageServers.erlang = false;
          };
          versions = {
            elixir = "1.18.4";
            erlang = "28.0.1";
          };
        };
        devShells = let
          buildPackages = with pkgs; [
            # beam.packages.erlang_28.erlang
            # beam.packages.erlang_28.elixir_1_18
            netlify-cli
          ];
          devPackages = with pkgs; [
            just
            nodejs_20
            nodePackages.typescript-language-server
            tailwindcss-language-server
            prettierd
            backblaze-b2
            agenix.packages.${system}.default
            bun
            unzip
            zip
          ];
        in {
          netlify = pkgs.mkShell {
            packages = config.beamWorkspace.devShell.packages ++ buildPackages;
          };
          default = pkgs.mkShell {
            packages = config.beamWorkspace.devShell.packages ++ buildPackages ++ devPackages;
            # The Nix packages provided in the environment
            shellHook = ''
              source ${lib.getExe config.agenix-shell.installationScript}
              export MIX_BUN_PATH="${pkgs.bun}/bin/bun"
            '';
          };
        };
      };
    };
}
