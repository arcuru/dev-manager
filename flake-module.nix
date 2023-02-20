# A module to use with flake-parts
# See https://flake.parts
{
  lib,
  self,
  flake-parts-lib,
  ...
}: {
  options = {
    perSystem = flake-parts-lib.mkPerSystemOption ({
      config,
      pkgs,
      ...
    }: {
      options.dev-manager = lib.mkOption {
        description = lib.mdDoc ''
          dev-manager configuration.
        '';
        type = lib.types.submoduleWith {
          modules = (import ./lib.nix).allModules pkgs;
        };
      };
      config = {
        # formatter = lib.mkDefault cfg.formatter;
      };
    });
  };
}
