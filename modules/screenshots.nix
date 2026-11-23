{ ... }:
{
  home-manager.users.kuss = {
    services.flameshot = {
      enable = true;
      settings = {
        General = {
        useGrimAdapter = true;
        disableGrimWarning= true;
	disabledTrayIcon = true;
        };
      };
    };
  };
}
