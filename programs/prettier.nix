{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.programs.prettier;
  inherit (import ../generators.nix {inherit pkgs lib;}) yaml;
in {
  options.programs.prettier = {
    enable = lib.mkEnableOption "prettier";
    settings = lib.mkOption {
      type = yaml.type;
      default = {};
      description = lib.mdDoc "Configuration written to .prettierrc.yaml.";
      example = lib.literalExpression ''
        {
          printWidth = 80;
        }
      '';
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.nodePackages.prettier;
      description = "prettier package";
    };
  };

  config = lib.mkIf cfg.enable {
    files.".prettierrc.yaml" = lib.mkIf (cfg.settings != {}) {
      source = yaml.generate "prettier-config" cfg.settings;
    };
    packages = [cfg.package];
  };
}
