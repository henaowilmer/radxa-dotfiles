#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# android-ssh-autostart.sh
# Script para configurar automáticamente SSH desde Android al boot
# Se ejecuta como servicio systemd
# ═══════════════════════════════════════════════════════════════

LOGFILE="$HOME/.local/log/android-ssh.log"
mkdir -p "$(dirname "$LOGFILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOGFILE"
}

log "=== Iniciando configuración automática de SSH Android ==="

# Esperar a que el sistema esté listo
sleep 5

MAX_ATTEMPTS=30
ATTEMPT=0

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    ATTEMPT=$((ATTEMPT + 1))
    log "Intento $ATTEMPT/$MAX_ATTEMPTS: Buscando dispositivo Android..."
    
    # Iniciar servidor adb
    adb start-server 2>&1 | tee -a "$LOGFILE"
    
    # Verificar si hay dispositivos conectados
    DEVICES=$(adb devices 2>/dev/null | grep -w "device" | wc -l)
    
    if [ "$DEVICES" -gt 0 ]; then
        log "Dispositivo Android detectado"
        
        # Configurar reverse port forwarding
        if adb reverse tcp:2222 tcp:22 2>&1 | tee -a "$LOGFILE"; then
            log "SUCCESS: SSH disponible en Android puerto 2222"
            
            # Mantener conexión activa verificando periódicamente
            while true; do
                sleep 60
                if ! adb devices | grep -qw "device"; then
                    log "Dispositivo desconectado, reiniciando..."
                    break
                fi
            done
            
            # Reiniciar el proceso si se desconecta
            ATTEMPT=0
        else
            log "Error al configurar port forwarding"
        fi
    else
        log "No se detectó dispositivo, reintentando en 10 segundos..."
        sleep 10
    fi
done

log "ERROR: No se pudo configurar la conexión después de $MAX_ATTEMPTS intentos"
exit 1
