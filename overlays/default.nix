{ inputs, ... }: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev:
    {
      # Override claude-code with the latest version from claude-code-nix
      claude-code = inputs.claude-code-nix.packages.${final.stdenv.hostPlatform.system}.default;
    };

  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };

  # NUR overlay for firefox extensions and other community packages
  nur = inputs.nur.overlay;
}
