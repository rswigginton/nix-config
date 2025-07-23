{ 
  config,
  lib,
  ... 
}: 
with lib; let
  cfg = config.features.cli.atuin;
in {
  options.features.cli.atuin.enable = mkEnableOption "enable atuin";

  config = mkIf cfg.enable {
    programs.atuin = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      settings = {
        sync_address = "https://api.atuin.sh";
        sync_frequency = "5m";
        auto_sync = true;
        search_mode = "fuzzy";
      };
    };
  };
}

