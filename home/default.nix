{ config, pkgs, inputs, ... }:

{
  imports = [
    ../rewst
    ./shell
    ./programs
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home = {
    username = "mikelane";
    homeDirectory = "/home/mikelane";

    # You can also manage environment variables but you will have to manually
    # source
    #
    #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  /etc/profiles/per-user/mikelane/etc/profile.d/hm-session-vars.sh
    #
    # if you don't want to manage your shell through Home Manager.
    sessionVariables = {
      EDITOR = "nvim";
      AWS_PAGER = "bat --plain --paging=auto --language=json --theme=TwoDark";
      AWS_DEFAULT_OUTPUT = "json";
      OPENAI_API_KEY = "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";
      ZPLUG_PROTOCOL = "SSH";
      LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ pkgs.openssl.out ];
      PKG_CONFIG_PATH = "${pkgs.lib.makeLibraryPath [ pkgs.openssl.dev ]}/pkgconfig";
      MINIKUBE_CLUSTER_IP = "192.168.49.2";
    };

    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through 'home.file'.
    file = {
      # # Building this configuration will create a copy of 'dotfiles/screenrc' in
      # # the Nix store. Activating the configuration will then make '~/.screenrc' a
      # # symlink to the Nix store copy.
      # ".screenrc".source = dotfiles/screenrc;

      # # You can also set the file content immediately.
      # ".gradle/gradle.properties".text = ''
      #   org.gradle.console=verbose
      #   org.gradle.daemon.idletimeout=3600000
      # '';
    };

    packages = with pkgs; [
      _1password
      _1password-gui
      alacritty
      autojump
      audacity
      bat
      btop
      dnsutils
      discord
      dmidecode
      eza
      firefox
      fortune
      fzf
      fzf-zsh
      fzf-git-sh
      gh
      google-chrome
      ipfetch
      jetbrains-toolbox
      jq
      kate
      less
      lolcat
      lshw
      moreutils
      neo-cowsay
      neofetch
      nix-output-monitor
      nixpkgs-fmt
      nnn
      nodePackages_latest.pnpm
      nodePackages_latest.npm
      nodePackages_latest.yarn
      nodePackages_latest."@antfu/ni"
      p7zip
      ripgrep
      shell_gpt
      slack
      starship
      thefuck
      tldr
      uhk-agent
      unzip
      usbutils
      xz
      zip
    ];

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "23.05"; # Please read the comment before changing.
  };

  # set cursor size and dpi for 4k monitor
  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 172;
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
    config = {
      load_dotenv = true;
      disable_stdin = true;
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

