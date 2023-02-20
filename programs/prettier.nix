{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.programs.prettier;

  # FIXME: Move to central lib, we'll want to do this for all file types
  yaml = {
    generate = name: value:
      pkgs.callPackage ({
        runCommand,
        remarshal,
      }:
        runCommand name {
          nativeBuildInputs = [remarshal];
          value = builtins.toJSON value;
          passAsFile = ["value"];
        } ''
          json2yaml "$valuePath" "$out"
          sed -i '1s/^/# DO NOT EDIT!!\n/' "$out"
        '') {};

    type = with lib.types; let
      valueType =
        nullOr (oneOf [
          bool
          int
          float
          str
          path
          (attrsOf valueType)
          (listOf valueType)
        ])
        // {
          description = "YAML value";
        };
    in
      valueType;
  };
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
