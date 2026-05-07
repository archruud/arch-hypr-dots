#!/bin/bash

# ============================================================
# install-intel-arc.sh
# Intel Arc A730M — AI/ML Drivere og biblioteker
# Kun for Medion Erazer Major X10
# GPU: Intel Arc A730M 12GB (DG2/Alchemist) + Iris Xe iGPU
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
VENV_DIR="$HOME/.venvs/intel-ai"

echo ""
echo -e "${CYAN}  Intel Arc A730M — AI/ML Drivere${NC}"
echo -e "${CYAN}  Medion Erazer Major X10${NC}"
echo ""

# ── Kernel-parameter for xe-driver ───────────────────────────────────────────
step "Kernel-parametere for Arc A730M (xe-driver)"
info "Arc A730M (DG2) bruker ny 'xe' kernel-driver."
info "Iris Xe iGPU beholder 'i915' driveren."
echo ""

BOOT_PARAMS="xe.force_probe=56a0 i915.force_probe=!56a0"

# Sjekk bootloader
if [[ -f /boot/loader/entries/*.conf ]] 2>/dev/null; then
    BOOT_ENTRY=$(ls /boot/loader/entries/*.conf | head -1)
    if ! grep -q "xe.force_probe" "$BOOT_ENTRY"; then
        warn "Legger til kernel-parametere i bootloader..."
        sudo sed -i "s/^options.*/& $BOOT_PARAMS/" "$BOOT_ENTRY"
        log "Kernel-parametere lagt til: $BOOT_ENTRY"
    else
        log "Kernel-parametere allerede satt"
    fi
elif [[ -f /etc/default/grub ]]; then
    if ! grep -q "xe.force_probe" /etc/default/grub; then
        sudo sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\"/GRUB_CMDLINE_LINUX_DEFAULT=\"$BOOT_PARAMS /" /etc/default/grub
        sudo grub-mkconfig -o /boot/grub/grub.cfg
        log "GRUB oppdatert med kernel-parametere"
    else
        log "Kernel-parametere allerede satt i GRUB"
    fi
else
    warn "Bootloader ikke oppdaget automatisk."
    warn "Legg til manuelt: $BOOT_PARAMS"
fi

# ── Compute Runtime og Level Zero ─────────────────────────────────────────────
step "Intel Compute Runtime + Level Zero"
info "Grunnlag for all GPU-akselerert AI på Intel Arc."

ARC_PACKAGES=(
    intel-compute-runtime   # OpenCL + Level Zero runtime
    level-zero-headers      # Level Zero API headers
    level-zero-loader       # Level Zero loader
    intel-gmmlib            # Grafikkminne-bibliotek
    ocl-icd                 # OpenCL ICD loader
    clinfo                  # Vis OpenCL-info
)

sudo pacman -S --needed --noconfirm "${ARC_PACKAGES[@]}"
log "Compute Runtime installert"

# ── Intel Graphics Compiler (bin — sparer 30-60 min!) ────────────────────────
step "Intel Graphics Compiler"
info "Bruker forhåndsbygd bin-pakke (sparer 30-60 min kompileringstid)"

if ! pacman -Q intel-graphics-compiler &>/dev/null && ! pacman -Q intel-graphics-compiler-bin &>/dev/null; then
    $AUR_HELPER -S --needed --noconfirm intel-graphics-compiler-bin
    log "intel-graphics-compiler-bin installert"
else
    log "Intel Graphics Compiler allerede installert"
fi

# ── XPU Manager ───────────────────────────────────────────────────────────────
step "Intel XPU Manager (GPU-monitor)"
if ! pacman -Q intel-xpu-smi-bin &>/dev/null; then
    $AUR_HELPER -S --needed --noconfirm intel-xpu-smi-bin
    log "intel-xpu-smi-bin installert"
else
    log "XPU Manager allerede installert"
fi

# ── Render-gruppe ─────────────────────────────────────────────────────────────
step "Legger bruker til render-gruppen"
if ! groups "$USER" | grep -q render; then
    sudo usermod -aG render "$USER"
    log "Bruker $USER lagt til render-gruppen"
    warn "Du må logge ut og inn igjen for at dette skal gjelde"
else
    log "Bruker er allerede i render-gruppen"
fi

# ── Python venv ───────────────────────────────────────────────────────────────
step "Python AI virtualenv: $VENV_DIR"

sudo pacman -S --needed --noconfirm python python-pip python-virtualenv

if [[ ! -d "$VENV_DIR" ]]; then
    python -m venv "$VENV_DIR"
    log "Venv opprettet: $VENV_DIR"
else
    log "Venv eksisterer allerede: $VENV_DIR"
fi

source "$VENV_DIR/bin/activate"
pip install --upgrade pip --quiet
log "pip oppdatert"

# ── PyTorch XPU (~2-3 GB) ────────────────────────────────────────────────────
step "PyTorch XPU (Intel Arc GPU-støtte)"
echo ""
warn "PyTorch XPU er ~2-3 GB nedlasting."
if ask "Installer PyTorch med Intel XPU-støtte?"; then
    info "Installerer PyTorch 2.x med XPU..."
    pip install torch torchvision torchaudio \
        --index-url https://download.pytorch.org/whl/xpu \
        --quiet
    log "PyTorch XPU installert"

    # Verifiser
    python -c "import torch; print('PyTorch:', torch.__version__); print('XPU tilgjengelig:', torch.xpu.is_available())" 2>/dev/null && \
        log "PyTorch XPU verifisert!" || warn "PyTorch XPU-test feilet — prøv etter reboot"
else
    info "Hopper over PyTorch XPU"
fi

# ── Intel Extension for PyTorch ───────────────────────────────────────────────
if pip show torch &>/dev/null; then
    step "Intel Extension for PyTorch (IPEX)"
    if ask "Installer Intel Extension for PyTorch (IPEX) — ~500 MB?"; then
        pip install intel-extension-for-pytorch --quiet
        log "IPEX installert"
    fi
fi

# ── AI/ML biblioteker ─────────────────────────────────────────────────────────
step "AI/ML biblioteker"
info "Installerer nyttige AI-biblioteker i venv..."

BASE_AI_PACKAGES=(
    transformers        # Hugging Face modeller — LLM, BERT, Whisper
    diffusers           # Stable Diffusion og andre diffusjonsmodeller
    accelerate          # Multi-device / GPU-agnostisk trening
    numpy               # Numerisk beregning — grunnlag for alt
    scipy               # Vitenskapelig beregning
    pillow              # Bildebehandling
    tqdm                # Progress bars
    matplotlib          # Plotting og visualisering
    pandas              # Dataanalyse
    scikit-learn        # Klassisk ML
    openai              # OpenAI-kompatibel API-klient (funker med lokal server)
    langchain           # RAG-pipeline og LLM-agenter
    langchain-community # LangChain community-pakker
    sentence-transformers  # Embedding-modeller
    huggingface-hub     # Last ned modeller fra Hugging Face
    datasets            # Hugging Face datasett
    tokenizers          # Rask tokenisering
    safetensors         # Sikker modell-lagring
    einops              # Tensor-operasjoner for ML
    requests            # HTTP-klient
)

pip install "${BASE_AI_PACKAGES[@]}" --quiet
log "AI/ML biblioteker installert"

# ── llama-cpp-python ──────────────────────────────────────────────────────────
step "llama-cpp-python (GGUF-modeller i Python)"
if ask "Installer llama-cpp-python — kjør GGUF-modeller direkte?"; then
    CMAKE_ARGS="-DGGML_SYCL=on -DCMAKE_C_COMPILER=icx -DCMAKE_CXX_COMPILER=icpx" \
        pip install llama-cpp-python --quiet 2>/dev/null || \
        pip install llama-cpp-python --quiet
    log "llama-cpp-python installert"
fi

# ── Jupyter ───────────────────────────────────────────────────────────────────
step "Jupyter Notebook"
if ask "Installer Jupyter Notebook — interaktiv AI-utvikling?"; then
    pip install jupyter ipykernel notebook jupyterlab --quiet
    python -m ipykernel install --user --name=intel-ai --display-name="Intel AI (Arc A730M)"
    log "Jupyter installert med intel-ai kernel"
fi

# ── Aktiveringsscript ─────────────────────────────────────────────────────────
step "Lager aktiveringsscript"

ACTIVATE_SCRIPT="$HOME/.config/hypr/scripts/activate-intel-ai.sh"
cat > "$ACTIVATE_SCRIPT" << EOF
#!/bin/bash
# Aktiver Intel AI venv
# Bruk: source activate-intel-ai.sh
# Eller: . ~/.config/hypr/scripts/activate-intel-ai.sh

export VENV_DIR="$VENV_DIR"
source "\$VENV_DIR/bin/activate"

echo "✓ Intel AI venv aktivert: \$VENV_DIR"
echo "  Python: \$(python --version)"
echo "  Deaktiver: deactivate"
EOF
chmod +x "$ACTIVATE_SCRIPT"
log "Aktiveringsscript: $ACTIVATE_SCRIPT"

# ── Verifisering ──────────────────────────────────────────────────────────────
step "Verifiserer Intel Arc installasjon"
echo ""
info "Compute Runtime:"
clinfo 2>/dev/null | grep -E "Platform|Device Type|Device Name" | head -6 || warn "clinfo feiler — reboot kan hjelpe"

echo ""
info "Level Zero:"
ls /dev/dri/ 2>/dev/null && log "/dev/dri/ finnes" || warn "/dev/dri/ ikke funnet"

deactivate 2>/dev/null || true

echo ""
log "Intel Arc A730M AI-driver installasjon fullført!"
echo ""
echo -e "${YELLOW}Neste steg:${NC}"
echo "  1. Reboot: sudo reboot"
echo "  2. Aktiver venv: source ~/.venvs/intel-ai/bin/activate"
echo "  3. Test PyTorch: python -c \"import torch; print(torch.xpu.is_available())\""
echo "  4. GPU-status: xpu-smi"
echo ""
