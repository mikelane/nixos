# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

#### NOTE! ####
# If you run into a situation where the result is "No space left on device, there were errors while switching"
# Run this to ensure a build of the current config can be carried out:
# sudo nixos-rebuild build
# 
# Then do a garbage collection to remove old system generations with this:
# sudo nix-collect-garbage -d
#
# See: https://discourse.nixos.org/t/what-to-do-with-a-full-boot-partition/2049/11
##############

{ config, lib, pkgs, helix, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./openrgb
      ./rewst/nginx
    ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "mikelane" "@wheel" ];
    auto-optimise-store = true;
  };

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;
    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    powerManagement.enable = false;
    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Do not disable this unless your GPU is unsupported or if you have a good reason to.
    open = true;

    prime = {
      sync.enable = true;

      amdgpuBusId = "PCI:18:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

  # hardware.nvidia.forceFullCompositionPipeline = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # 192.168.9.112  qa.c9xkwgfwwjv3.us-east-2.rds.amazonaws.com
  networking.extraHosts = '' 
    127.0.0.1   api.local.rewst.io
    127.0.0.1   app.local.rewst.io
    127.0.0.1   engine.local.rewst.io
    192.168.49.2   api.minikube.rewst.io
    192.168.49.2   app.minikube.rewst.io
    192.168.49.2   engine.minikube.rewst.io
    192.168.49.2   grafana.minikube.rewst.io
    192.168.49.2   kafka-ui.minikube.rewst.io
    192.168.49.2   kiali.minikube.rewst.io
    192.168.49.2   grafana.local.rewst.io
    192.168.49.2   kafka-ui.local.rewst.io
    192.168.49.2   kiali.local.rewst.io
    192.168.2.40   qa.c9xkwgfwwjv3.us-east-2.rds.amazonaws.com
    '';

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

  boot.kernelModules = [ "i2c-dev" "i2c-piix4" ];
  hardware.i2c.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  virtualisation.docker.enable = true;

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mikelane = {
    isNormalUser = true;
    description = "mikelane";
    extraGroups = [ "networkmanager" "wheel" "docker" "input" ];
  };

  # Enable the rules uhk needs in order to run
  hardware.keyboard.uhk.enable = true;

  services.udev.extraRules = ''
    SUBSYSTEM=="input", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="612[0-7]", GROUP="input", MODE="0660"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="612[0-7]", TAG+="uaccess"
    KERNEL=="hidraw*", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="612[0-7]", TAG+="uaccess"
  '';

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    shells = with pkgs; [ zsh ];

    systemPackages = with pkgs; [
      curl
      gcc
      git
      git-credential-1password
      glxinfo
      openrgb-with-all-plugins
      openssl
      pciutils
      vim
      wget
      xclip
    ];

    variables = {
      EDITOR = "nvim";
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # NOTE: You must copy these files from github:RewstApp/infrastructure/development/certs
  #  to be in the same directory as the configuration.nix file in order for these certs
  #  to be added properly. They will get concatenated into /etc/ssl/certs/ca-certificates.crt
  # Ref: https://search.nixos.org/options?channel=unstable&show=security.pki.certificateFiles&from=0&size=50&sort=relevance&type=packages&query=security.pki.certificateFiles
  security.pki.certificateFiles = [
  ];

  security.pam.loginLimits = [{
    domain = "*";
    type = "soft";
    item = "nofile";
    value = "65536";
  }];

  # List services that you want to enable:
  security.polkit.enable = true;
  services.blueman.enable = true; # pair and manage bluetooth devices

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  environment.shellAliases = {
    pbcopy = "xclip -sel clip";
    pbpaste = "xclip -selection clipboard -o";
  };

  environment.pathsToLink = [ "~/.zsh/completions" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}

