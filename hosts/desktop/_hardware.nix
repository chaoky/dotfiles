{ config
, lib
, pkgs
, modulesPath
, ...
}:
let
  # lazy mount
  mediaOptions = [
    "noauto"
    "x-systemd.automount"
    "x-systemd.idle-timeout=600"
    "x-systemd.device-timeout=5"
    "nofail"
  ];
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/12a56770-bf7f-4526-b5f1-520f3ecd555b";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/665B-A1CC";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/48ff442b-b818-4db4-b38c-1ca563e53e11"; }
  ];

  fileSystems."/media/sally" = {
    device = "/dev/disk/by-uuid/cc728bcb-e549-46f4-b270-af37d56dd6cc";
    fsType = "ext4";
    options = mediaOptions;
  };

  fileSystems."/media/mid" = {
    device = "/dev/disk/by-uuid/9bc40148-085c-4396-aa41-39abf1e8b379";
    fsType = "ext4";
    options = mediaOptions;
  };

  fileSystems."/media/old_and_slow" = {
    device = "/dev/disk/by-uuid/A41A22F51A22C3E0";
    fsType = "ntfs";
    options = mediaOptions;
  };

  networking.useDHCP = lib.mkDefault true;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  hardware.keyboard.qmk.enable = true;

  # Nvidia stuff
  # nvidia-open 595 doesn't compile against kernel 7.2 yet
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_7_1;
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.production;
  };
}
