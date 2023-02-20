{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption types;

  # Type definition for a basic file
  fileType = types.attrsOf (types.submodule (
    {name, ...}: {
      options = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = lib.mdDoc "Whether this file should be linked";
        };
        target = mkOption {
          type = types.str;
          description = lib.mdDoc "Path to target file relative to the repo base.";
        };
        source = mkOption {
          type = types.path;
          description = lib.mdDoc "Path to the source file";
        };
      };

      config = {
        target = lib.mkDefault name;
      };
    }
  ));
in {
  options = {
    files = mkOption {
      description = lib.mdDoc "Attribute set of files to link into the repo.";
      default = {};
      type = fileType;
    };

    # formatter = mkOption {
    #   type = types.package;
    #   description = lib.mdDoc "Output package containing all formatting options";
    #   readOnly = true;
    # };

    shellHook = mkOption {
      type = types.str;
      description = lib.mdDoc "A bash snippet that sets up the devshell.";
      readOnly = true;
    };

    packages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = lib.mdDoc "The set of packages to be added to the devshell.";
    };

    mkShell = mkOption {
      description = lib.mdDoc "Wrapped mkShell function that adds dev-manager options.";
      readOnly = true;
      default = {
        shellHook ? "",
        packages ? [],
        ...
      } @ attrs: let
        rest = builtins.removeAttrs attrs [
          "shellHook"
          "packages"
        ];
      in
        pkgs.mkShell {
          shellHook = lib.concatStrings [config.shellHook shellHook];
          packages = config.packages ++ packages;
        }
        // rest;
    };
  };
  config = let
    # Filter out unused files
    filteredFiles = lib.filterAttrs (n: f: f.enable) config.files;

    # Bash snippet that links all the cfg.files into the repo.
    # TODO: I think, for a repo, it's probably better to copy files instead of linking
    # Avoids issues with bootstrapping, and makes it easier to work with without flakes.
    # Could make it configurable if desired, adding an option to the file type.
    # So by default, you'll generate and then add the file to git.
    # Also should be easy to add a check that will monitor for changed files
    linkFiles =
      ''
        echo "linking files";

        function linkFile() {
          local source="$1"
          local target="$2"

          if readlink $target >/dev/null && [[ $(readlink $target) == $source ]]; then
            echo 1>&2 "$target: file up to date"
          else
            echo 1>&2 "$target: updating $PWD repo"

            [ -L $target ] && unlink $target

            if [ -e $target ]; then
              echo 1>&2 "$target: Error! file exists"
            else
              ln -s "$source" "$target"
            fi
          fi
        }
      ''
      + lib.concatStrings (
        lib.mapAttrsToList (n: v: ''
          linkFile ${
            lib.escapeShellArgs [
              v.source
              v.target
            ]
          }
        '')
        filteredFiles
      );
  in {
    # TODO: This should be a bash script that runs all the configured formatters
    # formatter = pkgs.writeShellScriptBin "formatter" ''
    #   echo "formatter running"
    # '';

    shellHook = ''
      ${linkFiles}
    '';
  };
}
