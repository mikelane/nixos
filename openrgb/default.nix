{ pkgs, lib, ... }:
let
  default-rgb = pkgs.writeScriptBin "default-rgb" ''
    #!/bin/sh
    ${pkgs.openrgb-with-all-plugins}/bin/openrgb -c FC6600
  '';
in
{
  config = {
    services.udev.packages = [ pkgs.openrgb-with-all-plugins ];
    boot.kernelModules = [ "i2c-dev" ];
    hardware.i2c.enable = true;

    systemd.services.default-rgb = {
      description = "default-rgb";
      path = [ "/run/current-system/sw/" ]; # Fix empty PATH to find qt plugins
      serviceConfig = {
        ExecStart = "${default-rgb}/bin/default-rgb";
        Type = "oneshot";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
