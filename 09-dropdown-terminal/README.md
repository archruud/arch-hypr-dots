# 09-dropdown-terminal — hdrop (Valgfritt alternativ)

> **Merk:** Denne modulen er **kommentert ut** i `install-order.conf` og kjøres
> ikke automatisk. Standard dropdown terminal er nå **JaKooLit Dropterminal**
> (filer i `25-scripts-and-files/scripts/`).
>
> hdrop ligger her som et alternativ du kan aktivere manuelt.

---

## Hva er hdrop?

hdrop er en enkel dropdown terminal toggle for Hyprland installert fra AUR.
Fordelen er at den er lett og enkel. Ulempen er at den ikke følger deg
mellom arbeidsområder slik JaKooLit sin versjon gjør.

---

## Installer hdrop manuelt

```bash
yay -S hdrop-git
```

---

## Legg til i hyprland.conf

Legg til disse linjene manuelt i `~/.config/hypr/hyprland.conf`:

```ini
### AUTOSTART ###
exec-once = ~/.config/hypr/scripts/hdrop-init.sh

### KEYBINDINGS ###
# Toggle dropdown terminal
bind = $mainMod SHIFT, RETURN, exec, hdrop -f -h 35 -w 75 -p top -g 57 kitty --class kitty_top -e ~/.config/hypr/scripts/kitty-dropdown-init.sh

# Endre størrelse på dropdown terminal
binde = $mainMod SHIFT, left,  exec, ~/.config/hypr/scripts/hdrop-resize.sh left
binde = $mainMod SHIFT, right, exec, ~/.config/hypr/scripts/hdrop-resize.sh right
binde = $mainMod SHIFT, up,    exec, ~/.config/hypr/scripts/hdrop-resize.sh up
binde = $mainMod SHIFT, down,  exec, ~/.config/hypr/scripts/hdrop-resize.sh down

# Window rules
windowrule = float on, match:class ^(kitty_top)$
windowrule = animation slidefadevert, match:class ^(kitty_top)$
```

---

## Kopier scripts manuelt

```bash
cp hdrop-init.sh          ~/.config/hypr/scripts/
cp hdrop-resize.sh        ~/.config/hypr/scripts/
cp kitty-dropdown-init.sh ~/.config/hypr/scripts/
chmod +x ~/.config/hypr/scripts/hdrop-init.sh
chmod +x ~/.config/hypr/scripts/hdrop-resize.sh
chmod +x ~/.config/hypr/scripts/kitty-dropdown-init.sh
```

---

## Aktiver i automatisk installasjon

For å inkludere hdrop i `run-install.sh`, fjern kommentaren i `install-order.conf`:

```
# 09-dropdown-terminal   ← fjern # her
```

---

## Filer i denne mappen

| Fil | Beskrivelse |
|---|---|
| `install-dropdown-terminal.sh` | Installerer hdrop-git fra AUR |
| `hdrop-init.sh` | Starter hdrop ved oppstart med riktig timing |
| `hdrop-resize.sh` | Resizer hdrop med toppen låst |
| `kitty-dropdown-init.sh` | Starter kitty uten tomme linjer |
