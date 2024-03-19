{
  programs.autojump.enable = true;


  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
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

      OPENAI_API_KEY=$(cat /run/agenix/openai_api_key)
    '';

    # Oh-My-Zsh has a lot of handy aliases and functions. But it was giving me trouble, so I decided to
    # use zplug instead. The nice thing is that I can bring in any oh-my-zsh plugin I want and skip the
    # plugins I don't need.

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
