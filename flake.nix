{
  description = "A slightly opinionated cli tool for managing SPDX licenses and copyright headers in your projects ";
  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1"; # tracks nixpkgs unstable branch
    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
    devenv.url = "github:ramblurr/nix-devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    inputs@{
      self,
      devenv,
      devshell,
      ...
    }:
    devenv.lib.mkFlake ./. {
      inherit inputs;
      withOverlays = [
        devshell.overlays.default
        devenv.overlays.default
      ];
      package =
        pkgs:
        pkgs.writeShellApplication (
          let
            script = ./spdx;
          in
          {
            name = "spdx";
            runtimeInputs = [
              pkgs.babashka-unwrapped
              pkgs.git
            ];
            text = ''
              exec ${pkgs.babashka-unwrapped}/bin/bb ${script} "$@"
            '';
            checkPhase = ''
              ${pkgs.clj-kondo}/bin/clj-kondo --config '{:linters {:namespace-name-mismatch {:level :off}}}' --lint ${script}
            '';
          }
        );

      app = pkgs: {
        meta.description = "A slightly opinionated cli tool for managing SPDX licenses and copyright headers in your projects ";
        type = "app";
        program = "${self.packages.${pkgs.system}.default}/bin/spdx";
      };

      devShell =
        pkgs:
        pkgs.devshell.mkShell {
          imports = [
            devenv.capsules.base
            devenv.capsules.clojure
          ];
          packages = [
            pkgs.clj-kondo
            pkgs.babashka-unwrapped
            pkgs.git
            self.packages.${pkgs.system}.default
          ];
        };

      treefmtConfig = {
        programs = {
          nixfmt.enable = true;
          cljfmt.enable = true;
        };
      };
    };
}
