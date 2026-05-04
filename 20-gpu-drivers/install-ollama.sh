#!/bin/bash

# ============================================================
# install-ollama.sh
# Ollama (lokal LLM-motor) + Open WebUI (web-grensesnitt)
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
NC='\033[0m'

log()  { echo -e "${GREEN}[✓]${NC} $1"; }
info() { echo -e "${CYAN}[i]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err()  { echo -e "${RED}[✗]${NC} $1"; }
step() { echo -e "\n${BLUE}━━━ $1 ━━━${NC}"; }
ask()  { read -p "$(echo -e "${YELLOW}[?]${NC} $1 (j/n): ")" _ans; [[ "$_ans" =~ ^[jJ]$ ]]; }

AUR_HELPER="${1:-yay}"

echo ""
echo -e "${CYAN}  Ollama + Open WebUI — Lokal AI${NC}"
echo ""

# ── Ollama ────────────────────────────────────────────────────────────────────
step "Ollama — lokal LLM-motor"
info "Ollama laster og kjører LLM-modeller lokalt."
info "Støtter Intel Arc via Level Zero (krever Arc-drivere installert)."
echo ""

# Sjekk om Arc er tilstede for riktig Ollama-variant
HAS_ARC=false
if lspci | grep -qi "Arc\|DG2"; then
    HAS_ARC=true
    info "Intel Arc GPU oppdaget — bruker ollama med XPU-støtte"
fi

if ! command -v ollama &>/dev/null; then
    # Prøv AUR ollama-git for Arc-støtte, ellers vanlig ollama
    if $HAS_ARC; then
        info "Installerer ollama-git (Arc/XPU-støtte)..."
        $AUR_HELPER -S --needed --noconfirm ollama-git 2>/dev/null || \
            $AUR_HELPER -S --needed --noconfirm ollama
    else
        $AUR_HELPER -S --needed --noconfirm ollama
    fi
    log "Ollama installert"
else
    log "Ollama allerede installert: $(ollama --version 2>/dev/null)"
fi

# Aktiver og start Ollama service
step "Starter Ollama systemd-service"
systemctl --user enable --now ollama 2>/dev/null || \
    sudo systemctl enable --now ollama 2>/dev/null || \
    warn "Kunne ikke starte Ollama service automatisk"

sleep 2
if curl -s http://localhost:11434 &>/dev/null; then
    log "Ollama kjører på port 11434"
else
    warn "Ollama ser ikke ut til å kjøre ennå — start manuelt: ollama serve"
fi

# ── Startmodeller ─────────────────────────────────────────────────────────────
step "Last ned AI-modeller"
echo ""
echo -e "${YELLOW}Tilgjengelige startmodeller:${NC}"
echo "  1) qwen2.5:7b    — Smart og rask, anbefalt (~4.7 GB)"
echo "  2) llama3.2:3b   — Lynrask, bra for testing (~2.0 GB)"
echo "  3) qwen2.5:14b   — Kraftig, bedre svar (~9 GB)"
echo "  4) deepseek-r1:7b — Resonnering/AI-tenking (~4.7 GB)"
echo "  5) Ingen nå — last ned selv med: ollama pull <modell>"
echo ""
read -p "Velg modell (1-5): " model_choice

case $model_choice in
    1)
        info "Laster ned qwen2.5:7b (~4.7 GB)..."
        ollama pull qwen2.5:7b && log "qwen2.5:7b klar!" || warn "Nedlasting feilet"
        ;;
    2)
        info "Laster ned llama3.2:3b (~2 GB)..."
        ollama pull llama3.2:3b && log "llama3.2:3b klar!" || warn "Nedlasting feilet"
        ;;
    3)
        warn "qwen2.5:14b er ~9 GB"
        if ask "Er du sikker?"; then
            ollama pull qwen2.5:14b && log "qwen2.5:14b klar!" || warn "Nedlasting feilet"
        fi
        ;;
    4)
        info "Laster ned deepseek-r1:7b (~4.7 GB)..."
        ollama pull deepseek-r1:7b && log "deepseek-r1:7b klar!" || warn "Nedlasting feilet"
        ;;
    *)
        info "Hopper over modell-nedlasting"
        ;;
esac

# ── Open WebUI ────────────────────────────────────────────────────────────────
step "Open WebUI — web-grensesnitt"
echo ""
info "Open WebUI er et ChatGPT-lignende grensesnitt for Ollama."
info "Støtter RAG (chat med PDF-filer), websøk, multi-modell."
echo ""
echo -e "${YELLOW}Installasjonsmetode:${NC}"
echo "  1) Docker (anbefalt — enklest å oppdatere)"
echo "  2) pip i eget venv (ingen Docker nødvendig)"
echo "  3) Hopp over"
echo ""
read -p "Velg metode (1-3): " webui_choice

case $webui_choice in
    1)
        # Docker-metode
        step "Open WebUI via Docker"
        if ! command -v docker &>/dev/null; then
            info "Installerer Docker..."
            sudo pacman -S --needed --noconfirm docker
            sudo systemctl enable --now docker
            sudo usermod -aG docker "$USER"
            log "Docker installert — ny login nødvendig for docker-gruppen"
        else
            log "Docker allerede installert"
        fi

        info "Starter Open WebUI container..."
        docker run -d \
            --name open-webui \
            --restart always \
            --add-host=host.docker.internal:host-gateway \
            -p 3000:8080 \
            -v open-webui:/app/backend/data \
            ghcr.io/open-webui/open-webui:main

        if [[ $? -eq 0 ]]; then
            log "Open WebUI kjører!"
            log "Åpne: http://localhost:3000"
        else
            warn "Docker-oppstart feilet — prøv manuelt etter reboot"
        fi

        # Lag oppstartsscript
        OWUI_SCRIPT="$HOME/.config/hypr/scripts/open-webui-start.sh"
        cat > "$OWUI_SCRIPT" << 'EOF'
#!/bin/bash
# Start/stopp Open WebUI
case "$1" in
    start)  docker start open-webui ;;
    stop)   docker stop open-webui ;;
    status) docker ps | grep open-webui ;;
    *)      docker start open-webui && echo "Open WebUI: http://localhost:3000" ;;
esac
EOF
        chmod +x "$OWUI_SCRIPT"
        log "Oppstartsscript: $OWUI_SCRIPT"
        ;;

    2)
        # pip-metode
        step "Open WebUI via pip"
        OWUI_VENV="$HOME/.venvs/open-webui"

        sudo pacman -S --needed --noconfirm python python-pip

        if [[ ! -d "$OWUI_VENV" ]]; then
            python -m venv "$OWUI_VENV"
        fi

        source "$OWUI_VENV/bin/activate"
        pip install open-webui --quiet
        log "Open WebUI installert i: $OWUI_VENV"
        deactivate

        # Lag systemd user service
        mkdir -p "$HOME/.config/systemd/user"
        cat > "$HOME/.config/systemd/user/open-webui.service" << EOF
[Unit]
Description=Open WebUI
After=network.target

[Service]
Type=simple
ExecStart=$OWUI_VENV/bin/open-webui serve
Restart=on-failure
Environment=OLLAMA_BASE_URL=http://localhost:11434

[Install]
WantedBy=default.target
EOF
        systemctl --user enable --now open-webui
        log "Open WebUI service aktivert"
        log "Åpne: http://localhost:8080"
        ;;

    *)
        info "Hopper over Open WebUI"
        ;;
esac

# ── Oppsummering ──────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Ollama + Open WebUI Installert!${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Nyttige kommandoer:${NC}"
echo "  Ollama status    : curl http://localhost:11434"
echo "  Last ned modell  : ollama pull qwen2.5:7b"
echo "  List modeller    : ollama list"
echo "  Chat i terminal  : ollama run qwen2.5:7b"
echo ""
if [[ $webui_choice == "1" ]]; then
    echo "  Open WebUI       : http://localhost:3000"
    echo "  Start container  : docker start open-webui"
    echo "  Stopp container  : docker stop open-webui"
elif [[ $webui_choice == "2" ]]; then
    echo "  Open WebUI       : http://localhost:8080"
    echo "  Start service    : systemctl --user start open-webui"
    echo "  Stopp service    : systemctl --user stop open-webui"
fi
echo ""
