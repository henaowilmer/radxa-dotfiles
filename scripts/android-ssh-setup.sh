#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# android-ssh-setup.sh
# Configura conexión SSH desde Android a Radxa por USB
# ═══════════════════════════════════════════════════════════════

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[*]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[X]${NC} $1"; }

SSH_PORT=${SSH_PORT:-22}
ANDROID_PORT=${ANDROID_PORT:-2222}

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  Configuración SSH desde Android a Radxa por USB"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Verificar si adb está instalado
if ! command -v adb &> /dev/null; then
    log_error "adb no está instalado. Ejecuta: sudo apt install adb"
    exit 1
fi

# Iniciar servidor adb
log_info "Iniciando servidor ADB..."
adb start-server 2>/dev/null

# Verificar dispositivos conectados
log_info "Buscando dispositivos Android..."
DEVICES=$(adb devices | grep -w "device" | wc -l)

if [ "$DEVICES" -eq 0 ]; then
    log_error "No se detectó ningún dispositivo Android"
    echo ""
    echo "Asegúrate de:"
    echo "  1. El cable USB está conectado"
    echo "  2. 'Depuración USB' está activada en tu Android"
    echo "  3. Has autorizado la conexión en tu Android"
    echo ""
    exit 1
fi

log_info "Dispositivo Android detectado!"
adb devices -l | grep -w "device"
echo ""

# Configurar reverse port forwarding
log_info "Configurando reverse port forwarding..."
log_info "Android:$ANDROID_PORT -> Radxa:$SSH_PORT"

if adb reverse tcp:$ANDROID_PORT tcp:$SSH_PORT; then
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  Configuración exitosa!${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Para conectarte desde tu Android:"
    echo ""
    echo "  En Termux:"
    echo "    ssh $(whoami)@localhost -p $ANDROID_PORT"
    echo ""
    echo "  En una app SSH (JuiceSSH, Termius, etc.):"
    echo "    Host: localhost"
    echo "    Puerto: $ANDROID_PORT"
    echo "    Usuario: $(whoami)"
    echo ""
else
    log_error "Error al configurar port forwarding"
    exit 1
fi
