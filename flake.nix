{
  description = "Manage a dev environment using Nix Flakes.";
  outputs = {self, ...}: {
    lib = {
      inherit (import ./lib.nix) mkOutputs;
    };

    # flakeModule for use with https://github.com/hercules-ci/flake-parts
    flakeModule = ./flake-module.nix;
  };
}
