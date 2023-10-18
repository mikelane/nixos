{ config, pkgs, inputs, ... }:

# home-manager.users.mikelane.nix.package

{
  imports = [
    ./shell/zsh.nix
    inputs.nixvim.homeManagerModules.nixvim
  ];
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "mikelane";
  home.homeDirectory = "/home/mikelane";

  # set cursor size and dpi for 4k monitor
  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 172;
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.

  # nix = {
  #   package = pkgs.nix;
  # };

  nixpkgs.config = {
    allowUnfree = true;
  };

  home.packages = with pkgs; [
    (callPackage ./scripts/dump-qa-db.nix {})

    _1password
    _1password-gui
    alacritty
    autojump
    awscli2
    inputs.awsvpnclient.packages.x86_64-linux.awsvpnclient
    bat
    btop
    dnsutils
    discord
    dmidecode
    envsubst
    eza
    firefox
    fortune
    fzf
    fzf-zsh
    fzf-git-sh
    gh
    google-chrome
    helmfile
    ipfetch
    jetbrains-toolbox
    jq
    k9s
    kate
    kubectl
    (wrapHelm kubernetes-helm { plugins = [ kubernetes-helmPlugins.helm-diff ]; })
    less
    lolcat
    lshw
    minikube
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
    pgcli
    postgresql_14
    ripgrep
    shell_gpt
    slack
    starship
    thefuck
    uhk-agent
    unzip
    usbutils
    xz
    zip
  ];

  programs.git = {
    enable = true;
    aliases = {
      branch-name = "!git rev-parse --abbrev-ref HEAD";
      ec = "config --global -e";
      up = "!git pull --rebase --prune $@ && git submodule update --init --recursive";
      cm = "!git add -A && git commit -m";
      save = "!git add -A && git commit -m 'SAVEPOINT'";
      undo = "reset HEAD~1 --mixed";
      amend = "commit --amend";
      co = "checkout";
      ci = "commit -v";
      cia = "commit -v -a";
      cob = "checkout -b";
      fa = "fetch --all";
      st = "status";
      w = "whatchanged";
      hist = "log --graph --pretty=format:'%C(yellow)%h%Creset | %d | %Cgreen%ad%Creset | by %C(bold blue)%an%Creset | %s%d' --date=short";
    };
    ignores = [
      ".env"
      ".envrc"
      ".direnv"
      ".devenv"
      ".idea"
    ];
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

  programs.nixvim = {
    globals.mapleader = ",";
    enable = true;

    vimAlias = true;
    viAlias = true;

    extraConfigVim = ''
      let g:NERDSpaceDelims = 1
    '';

    extraPackages = with pkgs; [
      nodePackages.typescript
      nodePackages.typescript-language-server
      ripgrep
    ];

    options = {
      cursorline = true;
      number = true;
      expandtab = true;
      mouse = "a";
      scrolloff = 4; # keeps lines above and below
      shiftwidth = 2;
      smartcase = true;
      splitbelow = true;
      splitright = true;
      smartindent = true;
      tabstop = 2;
    };

    colorschemes.gruvbox.enable = true;

    extraPlugins = with pkgs.vimPlugins; [
      vim-nix
      nerdcommenter
    ];

    plugins = {
      coq-nvim = {
        enable = true;
        autoStart = "shut-up";
        installArtifacts = true;
      };

      gitsigns.enable = true;

      lsp = {
        enable = true;
        servers = {
          bashls.enable = true;
          pyright.enable = true;
          jsonls.enable = true;
          eslint.enable = true;
          tsserver.enable = true;
          rnix-lsp.enable = true;

          pylsp = {
            enable = true;
            settings = {
              plugins = {
                black.enabled = true;
                isort.enabled = true;
              };
            };
          };
        };
      };

      lsp-lines.enable = true;
      lspsaga.enable = true;
      neogit.enable = true;
      telescope.enable = true;

      treesitter = {
        enable = true;
        nixGrammars = true;
        indent = true;
        ensureInstalled = "all";
      };

      treesitter-context.enable = true;
    };
  };

  programs.alacritty = {
    enable = true;
    settings = {
      import = [ pkgs.alacritty-theme.gruvbox_dark ];
      scrolling = {
        history = 100000;
        multiplier = 3;
        faux_multiplier = 3;
        auto_scroll = true;
      };
      font = {
        normal = {
          family = "VictorMono Nerd Font Mono";
          style = "Regular";
        };
        italic = {
          family = "VictorMono Nerd Font Mono";
          style = "Italic";
        };
        bold = {
          family = "VictorMono Nerd Font Mono";
          style = "Bold";
        };
        bold_italic = {
          family = "VictorMono Nerd Font Mono";
          style = "Bold Italic";
        };
      };
    };
  };


  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
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
  home.sessionVariables = {
    EDITOR = "vim";
    AWS_PAGER = "bat --plain --paging=auto --language=json --theme=TwoDark";
    AWS_DEFAULT_OUTPUT = "json";
    OPENAI_API_KEY = "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";
    ZPLUG_PROTOCOL = "SSH";
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ pkgs.openssl.out ];
    PKG_CONFIG_PATH = "${pkgs.lib.makeLibraryPath [ pkgs.openssl.dev ]}/pkgconfig";
    MINIKUBE_CLUSTER_IP = "192.168.49.2";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

