{ pkgs, inputs, ... }:

{
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
}
