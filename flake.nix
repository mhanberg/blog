{
  description = "Mitchell Hanberg's blog";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [];
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = {pkgs, ...}: {
        devShells = {
          default = pkgs.mkShell {
            # The Nix packages provided in the environment
            packages = with pkgs; [
              beam.packages.erlang_27.erlang
              beam.packages.erlang_27.elixir_1_17
              nodejs_18
              netlify-cli
              nodePackages.typescript-language-server
              tailwindcss-language-server
              prettierd
              netlify-cli
              backblaze-b2
            ];
          };
        };
      };
    };
}
