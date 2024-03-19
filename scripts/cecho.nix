{ pkgs }:

pkgs.writeShellApplication {
  name = "cecho";
  text = ''
    cecho() {
      local resetColor="\e[0m"
      case "$1" in
        black) color="\e[0;30m";;
        red) color="\e[0;31m";;
        green) color="\e[0;32m";;
        yellow) color="\e[0;33m";;
        blue) color="\e[0;34m";;
        magenta) color="\e[0;35m";;
        cyan) color="\e[0;36m";;
        lightgray) color="\e[0;37m";;
        darkgray) color="\e[1;30m";;
        lightred) color="\e[1;31m";;
        lightgreen) color="\e[1;32m";;
        lightyellow) color="\e[1;33m";;
        lightblue) color="\e[1;34m";;
        lightmagenta) color="\e[1;35m";;
        lightcyan) color="\e[1;36m";;
        white) color="\e[1;37m";;
        *) color="";; # Default to no color
      esac
      shift # Remove the first argument, which is the color
      echo -e "''${color}$*''${resetColor}" # Print the message in the chosen color
    }

    if [ "$#" -lt 2 ]; then
      echo "Usage: cecho COLOR MESSAGE"
      exit 1
    fi

    cecho "$@"
  '';
}
