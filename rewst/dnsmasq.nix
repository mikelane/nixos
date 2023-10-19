{
  services.dnsmasq = {
    enable = true;
    alwaysKeepRunning = true;
    settings.server = [
      "/prod.rewst/10.10.0.2"
      "/qa.rewst/192.168.0.2"
      "8.8.8.8"
      "8.8.4.4"
    ];
  };
}
