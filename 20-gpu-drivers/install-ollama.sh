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
        # VIKTIG: Vanlig 'ollama' er IKKE bygget med Vulkan — CPU-fallback på Arc!
        # 'ollama-vulkan' (extra-repo) er bygget med Vulkan-backend for Intel/AMD.
        info "Installerer ollama-vulkan (Vulkan-backend for Intel Arc)..."
        sudo pacman -S --needed --noconfirm ollama-vulkan || \
            $AUR_HELPER -S --needed --noconfirm ollama-vulkan || \
            $AUR_HELPER -S --needed --noconfirm ollama
    else
        $AUR_HELPER -S --needed --noconfirm ollama
    fi
    log "Ollama installert"
else
    log "Ollama allerede installert: $(ollama --version 2>/dev/null)"
fi

# ── Ytelse + Vulkan-aktivering (systemd override) ────────────────────────────
if $HAS_ARC; then
    step "Konfigurerer Ollama for Intel Arc (Vulkan + ytelse)"
    sudo mkdir -p /etc/systemd/system/ollama.service.d
    sudo tee /etc/systemd/system/ollama.service.d/performance.conf >/dev/null <<'PERF'
[Service]
Environment="OLLAMA_VULKAN=1"
Environment="OLLAMA_KEEP_ALIVE=30m"
Environment="OLLAMA_FLASH_ATTENTION=1"
PERF
    sudo systemctl daemon-reload
    log "Vulkan aktivert + modell holdes i GPU i 30 min + flash attention"
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
    sudo pacman -S --needed --noconfirm docker docker-compose
    sudo systemctl enable --now docker
    sudo usermod -aG docker "$USER"
    log "Docker + Docker Compose installert"
else
    # Sørg for at compose også er på plass selv om docker finnes fra før
    sudo pacman -S --needed --noconfirm docker-compose
    log "Docker allerede installert (compose verifisert)"
    sudo systemctl enable --now docker
fi

# Vent til Docker er klar
sleep 2

# ── Open WebUI via Docker Compose ─────────────────────────────────────────────
info "Setter opp Open WebUI (docker compose)..."
OWUI_DIR="$HOME/docker/open-webui"
mkdir -p "$OWUI_DIR"

cat > "$OWUI_DIR/docker-compose.yml" <<'COMPOSE'
services:
  open-webui:
    image: ghcr.io/open-webui/open-webui:main
    container_name: open-webui
    network_mode: host          # Når Ollama direkte på 127.0.0.1:11434
    environment:
      - OLLAMA_BASE_URL=http://127.0.0.1:11434
      - RAG_EMBEDDING_ENGINE=ollama
      - RAG_EMBEDDING_MODEL=nomic-embed-text
      # Ytelses-fixes: slår av skjulte AI-bakgrunnskall
      - ENABLE_AUTOCOMPLETE_GENERATION=false
      - ENABLE_SEARCH_QUERY_GENERATION=false
      - ENABLE_RAG_HYBRID_SEARCH=false
    volumes:
      - open-webui:/app/backend/data
    restart: always

volumes:
  open-webui:
COMPOSE

if docker compose -f "$OWUI_DIR/docker-compose.yml" up -d 2>/dev/null; then
    log "Open WebUI kjører!"
    log "Åpne: http://localhost:8080"
else
    warn "Open WebUI starter etter reboot (Docker-gruppe krever ny innlogging)"
    warn "Kjør manuelt: cd $OWUI_DIR && docker compose up -d"
fi

# Lag hjelpescript
OWUI_SCRIPT="$HOME/.config/hypr/scripts/open-webui-start.sh"
mkdir -p "$HOME/.config/hypr/scripts"
cat > "$OWUI_SCRIPT" << 'EOF'
#!/bin/bash
COMPOSE_DIR="$HOME/docker/open-webui"
case "$1" in
    start)  docker compose -f "$COMPOSE_DIR/docker-compose.yml" up -d && echo "Open WebUI: http://localhost:8080" ;;
    stop)   docker compose -f "$COMPOSE_DIR/docker-compose.yml" down ;;
    update) docker compose -f "$COMPOSE_DIR/docker-compose.yml" pull && docker compose -f "$COMPOSE_DIR/docker-compose.yml" up -d ;;
    status) docker ps | grep open-webui ;;
    *)      docker compose -f "$COMPOSE_DIR/docker-compose.yml" up -d && echo "Open WebUI: http://localhost:8080" ;;
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
echo "  Open WebUI     : http://localhost:8080"
echo "  Start WebUI    : docker start open-webui"
echo "  Stopp WebUI    : docker stop open-webui"
echo ""
echo -e "${CYAN}Merk: Logg ut og inn igjen for Docker-gruppe å tre i kraft!${NC}"
echo ""
