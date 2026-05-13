#!/bin/bash

# ============================================================
# install-ollama.sh
# Ollama (lokal LLM-motor) + Open WebUI via Docker
# Laster ned alle 4 anbefalte modeller automatisk
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

AUR_HELPER="${1:-yay}"

echo ""
echo -e "${CYAN}  Ollama + Open WebUI — Lokal AI${NC}"
echo ""

# ── Ollama ────────────────────────────────────────────────────────────────────
step "Ollama — lokal LLM-motor"

HAS_ARC=false
if lspci | grep -qi "Arc\|DG2"; then
    HAS_ARC=true
    info "Intel Arc GPU oppdaget — bruker ollama med XPU-støtte"
fi

if ! command -v ollama &>/dev/null; then
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

# Start Ollama service
step "Starter Ollama service"
systemctl --user enable --now ollama 2>/dev/null || \
    sudo systemctl enable --now ollama 2>/dev/null || \
    warn "Kunne ikke starte Ollama service automatisk"

sleep 3
if curl -s http://localhost:11434 &>/dev/null; then
    log "Ollama kjører på port 11434"
else
    warn "Ollama kjører ikke ennå — starter manuelt..."
    ollama serve &>/dev/null &
    sleep 3
fi

# ── Alle 4 modeller ───────────────────────────────────────────────────────────
step "Laster ned alle AI-modeller"
info "Dette tar litt tid (~21 GB totalt)"
echo ""

MODELS=(
    "qwen2.5:7b"
    "llama3.2:3b"
    "qwen2.5:14b"
    "deepseek-r1:7b"
)

MODEL_INFO=(
    "qwen2.5:7b     — Smart og rask (~4.7 GB)"
    "llama3.2:3b    — Lynrask, bra for testing (~2.0 GB)"
    "qwen2.5:14b    — Kraftig, bedre svar (~9.0 GB)"
    "deepseek-r1:7b — Resonnering/AI-tenking (~4.7 GB)"
)

for i in "${!MODELS[@]}"; do
    info "Laster ned ${MODEL_INFO[$i]}..."
    if ollama pull "${MODELS[$i]}"; then
        log "${MODELS[$i]} klar!"
    else
        warn "${MODELS[$i]} feilet — kan lastes ned manuelt: ollama pull ${MODELS[$i]}"
    fi
done

# ── Open WebUI via Docker ─────────────────────────────────────────────────────
step "Open WebUI via Docker"
info "Installerer Docker..."

if ! command -v docker &>/dev/null; then
    sudo pacman -S --needed --noconfirm docker
    sudo systemctl enable --now docker
    sudo usermod -aG docker "$USER"
    log "Docker installert"
else
    log "Docker allerede installert"
    sudo systemctl enable --now docker
fi

# Vent til Docker er klar
sleep 2

info "Starter Open WebUI container..."
docker run -d \
    --name open-webui \
    --restart always \
    --add-host=host.docker.internal:host-gateway \
    -p 3000:8080 \
    -v open-webui:/app/backend/data \
    ghcr.io/open-webui/open-webui:main 2>/dev/null

if docker ps | grep -q open-webui; then
    log "Open WebUI kjører!"
    log "Åpne: http://localhost:3000"
else
    warn "Open WebUI starter etter reboot (Docker-gruppe krever ny innlogging)"
fi

# Lag hjelpescript
OWUI_SCRIPT="$HOME/.config/hypr/scripts/open-webui-start.sh"
mkdir -p "$HOME/.config/hypr/scripts"
cat > "$OWUI_SCRIPT" << 'EOF'
#!/bin/bash
case "$1" in
    start)  docker start open-webui && echo "Open WebUI: http://localhost:3000" ;;
    stop)   docker stop open-webui ;;
    status) docker ps | grep open-webui ;;
    *)      docker start open-webui && echo "Open WebUI: http://localhost:3000" ;;
esac
EOF
chmod +x "$OWUI_SCRIPT"
log "Hjelpescript: $OWUI_SCRIPT"

# ── Oppsummering ──────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Ollama + Open WebUI Installert!${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Modeller installert:${NC}"
ollama list 2>/dev/null || echo "  kjør 'ollama list' etter reboot"
echo ""
echo -e "${YELLOW}Kommandoer:${NC}"
echo "  Ollama status  : curl http://localhost:11434"
echo "  Chat terminal  : ollama run qwen2.5:7b"
echo "  Open WebUI     : http://localhost:3000"
echo "  Start WebUI    : docker start open-webui"
echo "  Stopp WebUI    : docker stop open-webui"
echo ""
echo -e "${CYAN}Merk: Logg ut og inn igjen for Docker-gruppe å tre i kraft!${NC}"
echo ""
