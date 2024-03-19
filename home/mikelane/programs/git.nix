{
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
      "pytest-logs"
    ];
  };
}
