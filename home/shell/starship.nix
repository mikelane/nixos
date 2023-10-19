{
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      # Below is useful if you use the AWS_PROFILE env value
      # aws = {
      #   force_display = true;
      #   symbol = "AWS:";
      #   profile_aliases = {
      #     rewst-dev = "dev";
      #     rewst-prod-us = "prod-us";
      #     rewst-prod-eu = "prod-eu";
      #     rewst-qa = "qa";
      #     rewst-roc = "roc";
      #     rewst-staging = "staging";
      #   };
      # };
      character = {
        success_symbol = "[➜](bold green) ";
        error_symbol = "[➜](bold red) ";
      };
      directory = {
        truncate_to_repo = false;
        truncation_length = 5;
        truncation_symbol = ".../";
        before_repo_root_style = "gray";
        repo_root_style = "bold cyan";
      };
      git_metrics.disabled = false;
      kubernetes.disabled = true;
      nix_shell = {
        disabled = false;
        symbol = "❄️";
      };
      status.disabled = false;
      time.disabled = false;
    };
  };
}
