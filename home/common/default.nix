{ config, lib, outputs, pkgs, ... }: {
  # When useGlobalPkgs is enabled, nixpkgs config should be set at the system level
  # not in home-manager modules
  
  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
    };
  };
}
