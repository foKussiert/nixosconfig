{pkgs, ...}:

let
  flavor = "mocha";
  accent = "mauve";
in
 {
   catppuccin = {
     enable = true;
     inherit flavor accent;
   };
  
  environment.systemPackages = [
    (pkgs.catppuccin-kde.override {
      flavour = [ flavor ];
      accents = [ accent ];
    })
  ];
 }
  
