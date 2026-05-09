#!/bin/bash

# ============================================================
# kitty-dropdown-init.sh
# Kjøres av kitty ved oppstart av hdrop dropdown terminal
#
# Fikser: 13 tomme linjer øverst i terminalen
# Årsak:  zsh/p10k printer newlines ved oppstart som
#         akkumuleres og ser ut som tomme linjer
# ============================================================

# Clear skjermen (fjerner blank linjer fra zsh/p10k startup)
printf '\033[2J\033[H'

# Start interaktiv bash
exec "${SHELL:-/bin/bash}"
