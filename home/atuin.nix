{ ... }: {
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
      style = "full";
      inline_height = "20";
      filter_mode = "session-preload";
    };
  };
}
