# nixosconfig

NixOS-Konfiguration für den Host `kuss`. Flake-basiert, home-manager als NixOS-Modul.

## System

- NixOS 26.05, einzelne Pakete aus `nixos-unstable`
- Bootloader: systemd-boot (EFI)
- Netzwerk: NetworkManager
- Zeitzone: Europe/Berlin, Tastaturlayout: `de`
- Audio: PipeWire mit PulseAudio-Kompatibilität

### Desktop

- Hyprland (Wayland)
- KDE Plasma 6
- Login-Manager: SDDM
- Lockscreen: hyprlock
- App-Starter: rofi
- Terminal: Ghostty
- Dateimanager: yazi

### Pakete

Firefox, Zen Browser, Discord, VSCodium, Git, Vim, wget, bat, JDK 21, Maven, Steam, GameMode.
Aus `nixos-unstable`: `claude-code`.

### Theme

Catppuccin (Flavor `mocha`, Akzent `mauve`) für System und KDE.
Hyprland, hyprlock und rofi verwenden eigene Farben (Schwarz/Rot).

## Struktur

```
flake.nix                         Inputs und Systemdefinition
flake.lock                        Gepinnte Versionen der Inputs
home.nix                          home-manager-Grundeinstellungen
hosts/kuss/configuration.nix      Host-spezifisch: Boot, Netzwerk, Benutzer
hosts/kuss/hardware-configuration.nix
modules/default.nix               Importiert alle Module
modules/nix.nix                   Flakes und nix-command aktivieren
modules/desktop.nix               Plasma 6, SDDM, Tastaturlayout
modules/hyprland.nix              Hyprland, hyprlock, rofi, Schriften, Tastenkürzel
modules/theme.nix                 Catppuccin
modules/audio.nix                 PipeWire
modules/packages.nix              Systemweite Pakete
modules/gaming.nix                Steam, GameMode
```

Neue Module werden in `modules/default.nix` eingetragen.

## Flake-Inputs

| Input              | Quelle                                   |
|--------------------|------------------------------------------|
| `nixpkgs`          | nixos-26.05                              |
| `nixpkgs-unstable` | github:NixOS/nixpkgs/nixos-unstable      |
| `home-manager`     | github:nix-community/home-manager/release-26.05 |
| `catppuccin`       | github:catppuccin/nix/release-26.05      |
| `zen-browser`      | github:0xc000022070/zen-browser-flake    |

## Verwendung

System bauen und aktivieren:

```
sudo nixos-rebuild switch --flake ~/nixos#kuss
```

Inputs aktualisieren:

```
nix flake update
sudo nixos-rebuild switch --flake ~/nixos#kuss
```

Auf einem anderen Rechner muss `hosts/kuss/hardware-configuration.nix` durch die eigene ersetzt werden (`nixos-generate-config`).

## Tastenkürzel (Hyprland)

```
SUPER + Enter              Terminal (Ghostty)
SUPER + D                  rofi
SUPER + B                  Zen Browser
SUPER + E                  yazi
SUPER + L                  Bildschirm sperren
SUPER + Q                  Fenster schließen
SUPER + F                  Vollbild
SUPER + V                  Floating umschalten
SUPER + R                  Resize-Modus (Pfeiltasten, Esc/Enter beendet)
SUPER + M                  Hyprland beenden
SUPER + Pfeiltasten        Fokus wechseln
SUPER + SHIFT + Pfeile     Fenster verschieben
SUPER + 1-5                Workspace wechseln
SUPER + SHIFT + 1-5        Fenster auf Workspace verschieben
SUPER + linke Maustaste    Fenster ziehen
SUPER + rechte Maustaste   Fenstergröße ändern
```
