{ pkgs, inputs, ... }:

{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
  ];

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
}