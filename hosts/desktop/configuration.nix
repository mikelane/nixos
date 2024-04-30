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
      ../../openrgb
      ../../rewst/nginx
      ../../rewst/hosts.nix
      ../../rewst/dnsmasq.nix
    ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "mikelane" "@wheel" ];
    auto-optimise-store = true;
  };

  hardware = {
    i2c.enable = true;
    keyboard.uhk.enable = true;

    nvidia = {

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

    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };

    pulseaudio.enable = false;
  };

  # Bootloader.
  boot = {
    kernelModules = [ "i2c-dev" "i2c-piix4" "igc" ];

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking.hostName = "desktop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
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
  };

  # Enable sound with pipewire.
  sound.enable = true;

  virtualisation.docker.enable = true;

  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = lib.mkForce pkgs.pinentry-qt;
    };

    tmux = {
      enable = true;
      clock24 = true;
    };

    mtr.enable = true;
    zsh.enable = true;
  };

  users = {
    defaultUserShell = pkgs.zsh;
    users.mikelane = {
      isNormalUser = true;
      description = "mikelane";
      extraGroups = [ "networkmanager" "wheel" "docker" "input" ];
    };
  };
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "nix-2.15.3"
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    shells = with pkgs; [ zsh ];

    shellAliases = {
      pbcopy = "xclip -sel clip";
      pbpaste = "xclip -selection clipboard -o";
    };

    pathsToLink = [ "~/.zsh/completions" ];

    systemPackages = with pkgs; [
      age
      curl
      gcc
      git
      git-credential-1password
      glibc
      glxinfo
      (jetbrains.plugins.addPlugins jetbrains.datagrip [ "github-copilot" ])
      (jetbrains.plugins.addPlugins jetbrains.idea-ultimate [ "github-copilot" ])
      jetbrains.jdk
      (jetbrains.plugins.addPlugins jetbrains.pycharm-professional [ "github-copilot" "nixidea" ])
      (jetbrains.plugins.addPlugins jetbrains.webstorm [ "github-copilot" ])
      jetbrains-toolbox
      openrgb-with-all-plugins
      openssl
      pciutils
      wget
      xclip
    ];

    variables = {
      EDITOR = "nvim";
      HOSTNAME = "desktop";
      FART = "9001";
    };
  };

  age.secrets = {
    openai_api_key = {
      file = ../../secrets/openai_api_key.age;
      owner = "mikelane";
      group = "wheel";
      mode = "440";
    };
  };

  fonts.packages = with pkgs; [
    nerdfonts
  ];

  # List services that you want to enable:
  services = {
    blueman.enable = true; # pair and manage bluetooth devices
    openssh.enable = true; # Enable the OpenSSH daemon.

    pipewire = {
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

    printing.enable = true; # Enable CUPS to print documents.

    udev.extraRules = ''
      SUBSYSTEM=="input", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="612[0-7]", GROUP="input", MODE="0660"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="612[0-7]", TAG+="uaccess"
      KERNEL=="hidraw*", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="612[0-7]", TAG+="uaccess"
    '';

    displayManager.sddm.enable = true;
    xserver = {
      # Load nvidia driver for Xorg and Wayland
      enable = true;

      # Configure keymap in X11
      xkb = {
        layout = "us";
        variant = "";
      };

      videoDrivers = [ "nvidia" ];

      # Enable the KDE Plasma Desktop Environment.
      desktopManager.plasma5.enable = true;
    };
  };

  security = {
    pam.loginLimits = [{
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "65536";
    }];

    # NOTE: You must copy these files from github:RewstApp/infrastructure/development/certs
    #  to be in the same directory as the configuration.nix file in order for these certs
    #  to be added properly. They will get concatenated into /etc/ssl/certs/ca-certificates.crt
    # Ref: https://search.nixos.org/options?channel=unstable&show=security.pki.certificateFiles&from=0&size=50&sort=relevance&type=packages&query=security.pki.certificateFiles
    pki.certificateFiles = [
      ../../rewst/nginx/certs/trust-root-ca.pem
    ];

    polkit.enable = true;
    rtkit.enable = true;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}

