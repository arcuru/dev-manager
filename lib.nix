let
  # Combine all the modules and inject the given nixpkgs
  allModules = pkgs: [
    {
      _module.args = {
        pkgs = pkgs;
        lib = pkgs.lib;
      };
    }
    ./options.nix
    ./programs
  ];

  # Evaluate all the modules to make outputs.
  mkOutputs = pkgs: configuration: let
    mod = pkgs.lib.evalModules {
      modules = [configuration] ++ allModules pkgs;
    };
  in
    # Return the build outputs in the config
    mod.config;
in {inherit allModules mkOutputs;}
