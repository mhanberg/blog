{
  description = "Mitchell Hanberg's blog";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    agenix-shell.url = "github:aciceri/agenix-shell";
    agenix.url = "github:ryantm/agenix";
  };

  outputs = inputs @ {
    flake-parts,
    agenix,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.agenix-shell.flakeModules.default
      ];
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      agenix-shell = {
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
        devShells = let
          buildPackages = with pkgs; [
            beam.packages.erlang_27.erlang
            beam.packages.erlang_27.elixir_1_17
            netlify-cli
          ];
          devPackages = with pkgs; [
            just
            nodejs_18
            nodePackages.typescript-language-server
            tailwindcss-language-server
            prettierd
            backblaze-b2
            agenix.packages.${system}.default
          ];
        in {
          netlify = pkgs.mkShell {
            packages = buildPackages;
          };
          default = pkgs.mkShell {
            packages = buildPackages ++ devPackages;
            # The Nix packages provided in the environment
            shellHook = ''
              source ${lib.getExe config.agenix-shell.installationScript}
            '';
          };
        };
      };
    };
}
