# KDE Plasma 6 desktop with SDDM login screen.
{
  services = {
    xserver = {
      enable = true;
      xkb = {
        layout = "de";
        variant = "";
      };
    };

    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;

    # Touchpad
    libinput.enable = true;
  };
}
