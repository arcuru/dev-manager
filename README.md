## Status: abandoned

This was intended to be a better way of managing flake configs in a central repo, effectively home-manager but for flake environments.
I wanted to fix problems I saw in flake-parts, particularly how annoying it is to configure devshells.

I still think this is a better way to do it, however I've lost interest in building this out.

# dev-manager

Manage a dev environment using Nix Flakes.
This would supercede pre-commit-hooks.nix, treefmt-nix, etc. by combining all flake configs into a single repo.
Basically it is a more standard way of implementing devenv.sh.
