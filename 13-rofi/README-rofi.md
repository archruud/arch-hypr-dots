# 🚀 Rofi Installasjon - adi1090x Collection

Komplett installasjon av adi1090x's Rofi collection med Type-2 Launcher, Type-3 Powermenu og Clipboard Manager.

## 📦 Hva Du Får

Fra **[adi1090x/rofi](https://github.com/adi1090x/rofi)** GitHub repo:

- **Launchers** - 7 forskjellige typer, hver med 15 styles (105 launchers!)
  - Type-1: Fullscreen Grid
  - **Type-2: Kompakt launcher** ⭐ (din standard)
  - Type-3: Grid med sidebar
  - Type-4: Minimal
  - Type-5: Card style
  - Type-6: Drawer style
  - Type-7: Android style

- **Powermenus** - 6 forskjellige typer med styles
  - Type-1: Classic
  - Type-2: Modern
  - **Type-3: Style-2** ⭐ (din standard)
  - Type-4: Card style
  - Type-5: Minimal
  - Type-6: Android style

- **Applets** - For integrasjon med status bars
  - Volume, Battery, Backlight, MPD, Screenshot, etc.

- **Clipboard Manager** - Custom tema med cliphist

## 🎯 Installasjon

```bash
chmod +x install-rofi-adi1090x.sh
./install-rofi-adi1090x.sh
```

## 📋 Hva Skjer Ved Installasjon?

1. **Installerer pakker:**
   - rofi
   - wl-clipboard
   - cliphist
   - git

2. **Cloner adi1090x/rofi repository** til /tmp

3. **Kjører setup.sh** (fra adi1090x)
   - Installerer fonts
   - Lager automatisk backup av eksisterende konfigurasjon
   - Kopierer alle themes til ~/.config/rofi/

4. **Konfigurerer:**
   - Type-2 launcher som standard
   - Powermenu type-3 style-2
   - Clipboard manager tema

5. **Rydder opp** temp files

## 🔧 Hyprland Konfigurasjon

Legg til i `~/.config/hypr/hyprland.conf`:

```bash
# ═══════════════════════════════════════════════════════════════════════════
#  ROFI KONFIGURASJON
# ═══════════════════════════════════════════════════════════════════════════

# Rofi Launcher
$menu = killall rofi || $HOME/.config/rofi/launchers/type-2/launcher.sh

# Rofi Powermenu
$powermenu = $HOME/.config/rofi/powermenu/type-3/powermenu.sh

# Rofi Clipboard
bind = $mainMod, V, exec, cliphist list | rofi -dmenu -theme ~/.config/rofi/clipboard.rasi -p "Clipboard" | cliphist decode | wl-copy

# Keybinds
bind = $mainMod, A, exec, $menu
bind = $mainMod, X, exec, $powermenu

# Clipboard daemon (autostart)
exec-once = wl-paste --type text --watch cliphist store
exec-once = wl-paste --type image --watch cliphist store
```

## ⌨️ Tastatursnarveier

| Shortcut | Funksjon |
|----------|----------|
| `Super + A` | Åpne Rofi launcher (type-2) |
| `Super + V` | Åpne clipboard manager |
| `Super + X` | Åpne powermenu (type-3 style-2) |

## 🎨 Endre Styles

### Launcher Type-2

```bash
# Rediger launcher script
nano ~/.config/rofi/launchers/type-2/launcher.sh

# Endre denne linjen:
theme='style-1'

# Tilgjengelige styles: style-1 til style-15
```

**Noen populære styles:**
- `style-1` - Klassisk
- `style-2` - Modern
- `style-3` - Minimalistisk
- `style-4` - Kompakt
- `style-5` - Card style

### Powermenu Type-3

```bash
# Rediger powermenu script
nano ~/.config/rofi/powermenu/type-3/powermenu.sh

# Endre denne linjen:
theme='style-2'

# Tilgjengelige styles: style-1 til style-5
```

### Endre Farger

#### Launcher Farger

```bash
# Rediger colors.rasi
nano ~/.config/rofi/launchers/type-2/shared/colors.rasi

# Endre color scheme:
@import "~/.config/rofi/colors/catppuccin.rasi"

# Tilgjengelige color schemes:
# - adapta.rasi
# - arc.rasi
# - catppuccin.rasi
# - dracula.rasi
# - everforest.rasi
# - gruvbox.rasi
# - nord.rasi
# - onedark.rasi
# - tokyonight.rasi
# ... og mange flere!
```

#### Powermenu Farger

```bash
# Rediger powermenu colors
nano ~/.config/rofi/powermenu/type-3/shared/colors.rasi

# Endre color scheme på samme måte som launcher
```

#### Bruke Wallust Farger

Hvis du vil bruke dine egne farger fra wallust:

```bash
# Kopier din wallust color fil
cp ~/.config/waybar/wallust/colors-waybar.css ~/.config/rofi/colors/wallust.rasi

# Endre launcher colors.rasi til å peke på wallust
nano ~/.config/rofi/launchers/type-2/shared/colors.rasi
# Endre til: @import "~/.config/rofi/colors/wallust.rasi"
```

## 🔍 Test Installasjon

```bash
# Test Rofi direkte
rofi -show drun

# Test Type-2 Launcher
~/.config/rofi/launchers/type-2/launcher.sh

# Test Powermenu Type-3
~/.config/rofi/powermenu/type-3/powermenu.sh

# Test Clipboard
cliphist list | rofi -dmenu -theme ~/.config/rofi/clipboard.rasi
```

## 📁 Fil Struktur

```
~/.config/rofi/
├── launchers/
│   ├── type-1/
│   ├── type-2/          # Din standard launcher
│   │   ├── launcher.sh
│   │   ├── style-1.rasi til style-15.rasi
│   │   └── shared/
│   │       └── colors.rasi
│   ├── type-3/ til type-7/
│
├── powermenu/
│   ├── type-1/
│   ├── type-2/
│   ├── type-3/          # Din standard powermenu
│   │   ├── powermenu.sh
│   │   ├── style-1.rasi til style-5.rasi
│   │   └── shared/
│   │       └── colors.rasi
│   ├── type-4/ til type-6/
│
├── applets/
│   ├── type-1/ til type-4/
│
├── colors/
│   ├── adapta.rasi
│   ├── catppuccin.rasi
│   ├── dracula.rasi
│   ├── nord.rasi
│   └── ... (mange flere)
│
├── clipboard.rasi       # Custom clipboard tema
├── config.rasi
└── scripts/
```

## 🎯 Brukseksempler

### Bytte Mellom Launcher Typer

```bash
# Bytt til type-1
nano ~/.config/hypr/hyprland.conf
# Endre: $menu = killall rofi || $HOME/.config/rofi/launchers/type-1/launcher.sh

# Bytt til type-3
$menu = killall rofi || $HOME/.config/rofi/launchers/type-3/launcher.sh
```

### Prøv Forskjellige Powermenus

```bash
# Test type-1
~/.config/rofi/powermenu/type-1/powermenu.sh

# Test type-2
~/.config/rofi/powermenu/type-2/powermenu.sh

# Når du finner en du liker, oppdater hyprland.conf
$powermenu = $HOME/.config/rofi/powermenu/type-X/powermenu.sh
```

## 🐛 Feilsøking

### Rofi starter ikke

```bash
# Sjekk rofi versjon
rofi -version

# Test med feilsøking
rofi -show drun -no-lazy-grab

# Sjekk konfigurasjon
cat ~/.config/rofi/config.rasi
```

### Fonts ser rare ut

```bash
# Oppdater font cache
fc-cache -fv

# Sjekk om Nerd Fonts er installert
fc-list | grep -i nerd
```

### Clipboard fungerer ikke

```bash
# Sjekk om cliphist kjører
ps aux | grep cliphist

# Start clipboard daemon manuelt
wl-paste --type text --watch cliphist store &
wl-paste --type image --watch cliphist store &

# Test clipboard
echo "test" | wl-copy
cliphist list
```

### Powermenu mangler ikoner

Installer Font Awesome eller Nerd Fonts:

```bash
sudo pacman -S ttf-font-awesome ttf-nerd-fonts-symbols
fc-cache -fv
```

## 💡 Tips & Tricks

### Hurtigtaster for Forskjellige Launchers

Du kan ha flere launchers på forskjellige keys:

```bash
bind = $mainMod, A, exec, ~/.config/rofi/launchers/type-2/launcher.sh
bind = $mainMod SHIFT, A, exec, ~/.config/rofi/launchers/type-1/launcher.sh
bind = $mainMod, D, exec, ~/.config/rofi/launchers/type-3/launcher.sh
```

### Bruke Rofi Applets

adi1090x har mange applets for volume, brightness, etc:

```bash
# Volume applet
~/.config/rofi/applets/type-1/volume.sh

# Battery applet
~/.config/rofi/applets/type-1/battery.sh

# Screenshot applet
~/.config/rofi/applets/type-1/screenshot.sh
```

### Random Style ved Oppstart

I launcher.sh eller powermenu.sh, uncomment random style selection:

```bash
# Uncomment denne linjen:
# theme="style-$((RANDOM % 15 + 1))"
```

## 📝 Notater

- adi1090x's repo oppdateres regelmessig
- Backup av din gamle konfigurasjon ligger i ~/.config/rofi.bak.XXXXXX
- Alle themes er fully customizable
- Color schemes kan endres globalt eller per launcher/powermenu
- Clipboard manager bruker ditt custom tema

## 🔗 Ressurser

- [adi1090x/rofi GitHub](https://github.com/adi1090x/rofi)
- [Rofi Documentation](https://github.com/davatorium/rofi)
- [Rofi Wiki](https://github.com/davatorium/rofi/wiki)

---

**Laget for Archruud's Hyprland setup** 🚀
