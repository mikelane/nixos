{ pkgs, ... }: 

{
  programs.autojump.enable = true;

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


  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = false;
    syntaxHighlighting = {
      enable = true;
    };
    history = {
      size = 1000000;
      save = 1000000;
      ignoreAllDups = true;
    };

   initExtra = ''
      . "/etc/profiles/per-user/mikelane/etc/profile.d/hm-session-vars.sh"

      # Make zsh-autosuggestions up key work better
      zstyle '*:compinit' arguments -D -i -u -C -w
      bindkey "''${key[Up]}" up-line-or-search

      # Load the awscli completions
      complete -C '/etc/profiles/per-user/mikelane/bin/aws_completer' aws

      # Shell-GPT integration ZSH v0.1
      # Allows you to use ctrl-k to execute a generated shell command provided by sgpt
      _sgpt_zsh() {
      if [[ -n "$BUFFER" ]]; then
          _sgpt_prev_cmd=$BUFFER
          BUFFER+="⌛"
          zle -I && zle redisplay
          BUFFER=$(sgpt --shell -- "$_sgpt_prev_cmd")
          zle end-of-line
      fi
      }
      zle -N _sgpt_zsh
      bindkey ^k _sgpt_zsh
      # Shell-GPT integration ZSH v0.1
    '';

    shellAliases = {
      aws-connect-qa = "awsvpnclient start --config $HOME/workplace/rewst-qa-vpn-client-config.ovpn";
      cat = "bat";
      dcd= "docker compose -f $HOME/workplace/rewst-app/packages/engine/tests/.dev/docker-compose.yml down";
      dcu = "docker compose -f $HOME/workplace/rewst-app/packages/engine/tests/.dev/docker-compose.yml up -d";
      k = "kubectl";
      ls = "eza --icons --long --group-directories-first --classify --git --all --extended";
      # ls = "ls -ahHl --color=always --classify=always --group-directories-first";
      mk = "minikube";
      reta = "(cd $HOME/workplace/rewst-app/packages/engine; DATABASE_HOST=localhost DATABASE_PORT=15432 KAFKA_BROKER=127.0.0.1:19092 pytest -ra -n 24 -vv)";
      retax = "(cd $HOME/workplace/rewst-app/packages/engine; DATABASE_HOST=localhost DATABASE_PORT=15432 KAFKA_BROKER=127.0.0.1:19092 pytest -ra -n 24 -x -vv)";
      rets = "(cd $HOME/workplace/rewst-app/packages/engine; DATABASE_HOST=localhost DATABASE_PORT=15432 KAFKA_BROKER=127.0.0.1:19092 pytest -ra -vv)";
      update = "sudo nixos-rebuild switch --flake /etc/nixos/ && exec zsh";
      update_system = "cd ~/nixos-config && sudo nix flake update && update && cd -";
    };

    # Oh-My-Zsh has a lot of nice aliases and functions, so I enable it here. In NixOS, managing
    # the plugins with omz is less nice. So I do that with zplug below. I did have one issue where
    # omz wouldn't load and I was getting an error "compinit:489: bad math expression: operand expected 
    # at end of string". I removed the .zcompdump-nixos-5.9.zwc file and that error went away. The
    # .zcompcump-nixos-5.9.zwc file was recreated without issue and omz loaded after that.
    # 
    # See: https://github.com/ohmyzsh/ohmyzsh/issues/1495
    # oh-my-zsh = {
    #   enable = true;
    #   theme = "";
    # };

    zplug = {
      enable = true;
      plugins = [
        { name = "plugins/argocd"; tags = [ from:oh-my-zsh ]; }
        { name = "wting/autojump"; }
        { name = "lib/clipboard"; tags = [ from:oh-my-zsh ]; }
        { name = "plugins/colored-man-pages"; tags = [ from:oh-my-zsh ]; }
        { name = "lib/directories"; tags = [ from:oh-my-zsh ]; }
        { name = "junegunn/fzf"; }
        { name = "lib/functions"; tags = [ from:oh-my-zsh ]; }
        { name = "plugins/gh"; tags = [ from:oh-my-zsh ]; }
        { name = "davidde/git"; }
        { name = "lib/git"; tags = [ from:oh-my-zsh ]; }
        { name = "plugins/helm"; tags = [ from:oh-my-zsh ]; }
        { name = "plugins/minikube"; tags = [ from:oh-my-zsh ]; }
        { name = "plugins/npm"; tags = [ from:oh-my-zsh ]; }
        { name = "plugins/poetry"; tags = [ from:oh-my-zsh ]; }
        { name = "plugins/postgres"; tags = [ from:oh-my-zsh ]; }
        { name = "lib/spectrum"; tags = [ from:oh-my-zsh ]; }
        { name = "mstruebing/tldr"; }
        { name = "marlonrichert/zsh-autocomplete"; }
        { name = "zsh-users/zsh-autosuggestions"; }
        { name = "plugins/zsh-interactive-cd"; tags = [ from:oh-my-zsh ]; }
        { name = "laggardkernel/zsh-thefuck"; }
      ];
    };
  };
}
