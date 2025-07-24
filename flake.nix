{
  description = "A slightly opinionated cli tool for managing SPDX licenses and copyright headers in your projects ";
  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1"; # tracks nixpkgs unstable branch
    flakelight.url = "github:nix-community/flakelight";
  };
  outputs =
    {
      self,
      flakelight,
      ...
    }:
    flakelight ./. {
      package =
        pkgs:
        pkgs.writeShellApplication (
          let
            script = ./spdx;
          in
          {
            name = "spdx";
            runtimeInputs = [
              pkgs.babashka
              pkgs.git
            ];
            text = ''
              exec ${pkgs.babashka}/bin/bb ${script} $@
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
      devShell.packages =
        pkgs: with pkgs; [
          clj-kondo
          babashka
          git
          self.packages.${pkgs.system}.default
        ];

      flakelight.builtinFormatters = false;
      formatters = pkgs: {
        "*.nix" = "${pkgs.nixfmt}/bin/nixfmt";
        "*.clj" = "${pkgs.cljfmt}/bin/cljfmt fix";
      };
    };
}
