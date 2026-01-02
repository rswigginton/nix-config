# AGENTS.md - NixOS Flake Configuration

## Overview

This is a NixOS flake-based configuration managing multiple hosts and users with home-manager. The configuration follows a modular pattern with separate system (NixOS) and user (home-manager) configurations.

## Essential Commands

### NixOS System Rebuild

```bash
# Rebuild and switch to new configuration (uses hostname to select)
sudo nixos-rebuild switch --flake .#<hostname>

# For current host (using shell abbreviations)
nrs    # Expands to: sudo nixos-rebuild switch --flake .#(uname -n)

# Test without making permanent
sudo nixos-rebuild test --flake .#<hostname>

# Build without switching
sudo nixos-rebuild build --flake .#<hostname>
```

**Available hosts:**
- `mimir` - Primary workstation with COSMIC desktop
- `nixos` - Secondary/generic NixOS host

### Home Manager

```bash
# Switch home configuration
home-manager switch --flake .#<user>@<host>

# Using shell abbreviation
hms    # Expands to: home-manager --flake . switch

# Example
home-manager switch --flake .#robert@mimir
```

**Available home configurations:**
- `robert@mimir`
- `robert@nixos`

### Flake Operations

```bash
# Update all inputs
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs

# Show flake outputs
nix flake show

# Check flake validity
nix flake check
```

## Project Structure

```
nix-config/
├── flake.nix              # Main flake definition with all inputs/outputs
├── flake.lock             # Locked dependency versions
│
├── hosts/                 # NixOS system configurations
│   ├── common/            # Shared host configuration
│   │   ├── default.nix    # Common packages, nix settings, home-manager setup
│   │   └── fish.nix       # System-level fish shell config
│   ├── mimir/             # Host-specific (mimir workstation)
│   │   ├── default.nix    # Imports common + configuration
│   │   ├── configuration.nix  # Host settings, packages, services
│   │   └── hardware-configuration.nix
│   └── nixos/             # Host-specific (nixos)
│       └── ...
│
├── home/                  # Home-manager user configurations
│   ├── common/            # Shared home config
│   │   └── default.nix    # Base nix settings for home-manager
│   ├── robert/            # User-specific configs
│   │   ├── home.nix       # Base home config (stateVersion, git identity)
│   │   ├── mimir.nix      # Per-host user config
│   │   └── nixos.nix      # Per-host user config
│   └── features/          # Optional feature modules
│       ├── cli/           # CLI tool configurations
│       │   ├── default.nix    # Imports all CLI modules + always-on tools
│       │   ├── fish.nix       # Fish shell (options.features.cli.fish)
│       │   ├── atuin.nix      # Shell history sync
│       │   ├── starship.nix   # Prompt
│       │   ├── neovim.nix     # Neovim + LazyVim
│       │   ├── git.nix        # Git config + lazygit
│       │   ├── fzf.nix
│       │   └── tmux.nix
│       └── desktop/       # Desktop application configs
│           ├── default.nix
│           ├── firefox.nix    # Firefox with policies/extensions
│           └── alacritty.nix
│
├── pkgs/                  # Custom package definitions
│   └── default.nix
│
└── overlays/              # Nixpkgs overlays
    └── default.nix        # additions, modifications, stable-packages, nur
```

## Configuration Patterns

### Adding a New Host

1. Create directory under `hosts/<hostname>/`
2. Create `default.nix`:
   ```nix
   { inputs, outputs, lib, config, pkgs, ... }:
   {
     imports = [
       ../common
       ./configuration.nix
     ];
     
     home-manager.users = {
       robert = import ../../home/robert/<hostname>.nix;
     };
   }
   ```
3. Create `configuration.nix` with host-specific settings
4. Create `hardware-configuration.nix` (use `nixos-generate-config`)
5. Add to `flake.nix` under `nixosConfigurations`
6. Create matching home config at `home/robert/<hostname>.nix`
7. Add to `flake.nix` under `homeConfigurations`

### Adding a New User

1. Create directory `home/<username>/`
2. Create `home.nix` with base config
3. Create per-host files `<hostname>.nix`
4. Add home-manager user in host's `default.nix`
5. Add to `homeConfigurations` in `flake.nix`

### Feature Module Pattern

Features use NixOS module options for enable/disable:

```nix
# In feature file (e.g., home/features/cli/fish.nix)
{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.cli.fish;
in {
  options.features.cli.fish.enable = mkEnableOption "enable fish shell";

  config = mkIf cfg.enable {
    programs.fish = {
      enable = true;
      # ... configuration
    };
  };
}
```

```nix
# In user config (e.g., home/robert/mimir.nix)
{
  imports = [
    ../features/cli
  ];
  
  features.cli = {
    fish.enable = true;
    atuin.enable = true;
    starship.enable = true;
    neovim.enable = true;
  };
}
```

### Overlay Pattern

Overlays are defined in `overlays/default.nix` and applied both:
- In `hosts/common/default.nix` for NixOS (system packages)
- In `flake.nix` homeConfigurations for standalone home-manager

Available overlays:
- `additions` - Custom packages from `pkgs/`
- `modifications` - Package overrides
- `stable-packages` - Access stable nixpkgs as `pkgs.stable.*`
- `nur` - Nix User Repository

## Naming Conventions

- **Hosts:** lowercase single names (`mimir`, `nixos`)
- **Feature modules:** `<category>/<feature>.nix` pattern
- **Options:** `features.<category>.<feature>.enable`
- **Files:** kebab-case for compound names (`hardware-configuration.nix`)

## Key Configuration Details

### Flake Inputs

- `nixpkgs` - nixos-unstable
- `nixpkgs-stable` - nixos-25.05 (accessible via `pkgs.stable.*`)
- `home-manager` - follows nixpkgs
- `nur` - Nix User Repository (for Firefox extensions)

### Default Shell

Fish shell is the default. System-level fish is in `hosts/common/fish.nix`, user-level in `home/features/cli/fish.nix`.

### Editor

Neovim with LazyVim. The `neovim.nix` feature:
- Installs neovim with required dependencies (LSPs, formatters)
- Auto-clones LazyVim starter config on first activation
- Manages neovim config externally in `~/.config/nvim` (not Nix-managed)

### Firefox

Firefox extensions are managed via policies (not home-manager programs.firefox.profiles), defined in `home/features/desktop/firefox.nix`. Extensions auto-install via `ExtensionSettings`.

## Common Shell Abbreviations

Defined in `home/features/cli/fish.nix`:

| Abbr | Expansion |
|------|-----------|
| `nrs` | `sudo nixos-rebuild switch --flake .#(uname -n)` |
| `hms` | `home-manager --flake . switch` |
| `nd` | `nix develop -c $SHELL` |
| `ns` | `nix shell` |
| `v`, `vi`, `vim` | `nvim` |
| `ls` | `eza` |
| `ll` | `eza -alhg` |
| `grep` | `rg` |

## Gotchas and Non-Obvious Patterns

1. **Home-manager integration:** This config uses the NixOS module integration (`home-manager.nixosModules.home-manager`), not standalone home-manager. The system rebuild also rebuilds home configs.

2. **useGlobalPkgs:** Home-manager uses system nixpkgs. Don't set `nixpkgs.config` in home modules - it's ignored.

3. **Backup conflicts:** `home-manager.backupFileExtension = "backup"` is set. Existing files that conflict get `.backup` suffix.

4. **State versions:** Don't change `stateVersion` values (`25.05`). They affect home-manager and NixOS state management.

5. **Duplicate packages:** Some packages appear in both system (`hosts/common/default.nix`) and user (`home/features/cli/default.nix`). System packages are preferred for CLI tools needed by root.

6. **LazyVim config:** The neovim config is NOT managed by Nix. LazyVim starter is cloned once and then managed manually in `~/.config/nvim`.

7. **Overlays applied twice:** Overlays must be defined in both system config AND in `homeConfigurations` in `flake.nix` for standalone home-manager usage.

## Validation

```bash
# Check flake syntax and evaluation
nix flake check

# Build without switching (dry run)
nixos-rebuild build --flake .#mimir

# Show what would change
nixos-rebuild dry-activate --flake .#mimir
```

## Trusted Users

The `robert` user is in `nix.settings.trusted-users`, allowing:
- Running `nix` commands without sudo
- Using binary caches
- Setting substituters
