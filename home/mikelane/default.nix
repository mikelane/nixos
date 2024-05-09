{ config, pkgs, pkgs-stable, ... }:

{
  imports = [
    ../../rewst
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
      ZPLUG_PROTOCOL = "SSH";
      # LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ pkgs.openssl.out ];
      PKG_CONFIG_PATH = "${pkgs.lib.makeLibraryPath [ pkgs.openssl.dev ]}/pkgconfig";
      PATH = "$HOME/.krew/bin:${pkgs.kubernetes}/bin:$PATH";
      KREW_ROOT = "$HOME/.krew";
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

    packages = [
      pkgs._1password
      pkgs._1password-gui
      pkgs.alacritty
      pkgs.autojump
      pkgs.audacity
      pkgs.awscli2 
      pkgs.bat
      pkgs.btop
      pkgs.busybox
      pkgs.caffeine-ng
      pkgs.ddcutil
      pkgs.dnsutils
      pkgs.discord
      pkgs.dmidecode
      pkgs.eza
      pkgs.firefox
      pkgs.fortune
      pkgs.fzf
      pkgs.fzf-zsh
      pkgs.fzf-git-sh
      pkgs.gh
      pkgs.google-chrome
      pkgs.home-manager
      pkgs.ipfetch
      pkgs.isort
      pkgs.jq
      pkgs.kate
      pkgs.krew
      pkgs.kubectl
      pkgs.kubernetes
      pkgs.less
      pkgs.lolcat
      pkgs.lshw
      pkgs.lsof
      pkgs.moreutils
      pkgs.neo-cowsay
      pkgs.neofetch
      pkgs.nix-output-monitor
      pkgs.nix-prefetch-git
      pkgs.nix-prefetch-github
      pkgs.nixpkgs-fmt
      pkgs.nnn
      pkgs.nodePackages_latest.pnpm
      pkgs.nodePackages_latest.npm
      pkgs.nodePackages_latest.yarn
      pkgs.nodePackages_latest."@antfu/ni"
      pkgs.p7zip
      pkgs.pandoc
      pkgs.pre-commit
      pkgs.prettyping
      pkgs.prusa-slicer
      pkgs.pyenv
      pkgs.python312Full
      pkgs.python312Packages.jupyterlab
      pkgs.python312Packages.pip
      pkgs.python312Packages.setuptools
      pkgs.python312Packages.wheel
      pkgs.python312Packages.ptpython
      pkgs.python312Packages.pydantic
      pkgs.python312Packages.std2
      pkgs.ripgrep
      pkgs.ruff
      pkgs.shell-gpt
      pkgs.shellcheck
      pkgs.slack
      pkgs.smenu
      pkgs.starship
      pkgs.stern
      pkgs.thefuck
      pkgs.tldr
      pkgs.uhk-agent
      pkgs.unzip
      pkgs.usbutils
      pkgs.xz
      pkgs.zip
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

