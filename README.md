# Radxa Cubie A7Z - Dotfiles

Configuración completa del entorno de desarrollo para Radxa Cubie A7Z.
Restaura todo con un solo comando después de flashear la SD.

## Instalación Rápida

```bash
git clone https://github.com/TU_USUARIO/radxa-dotfiles.git ~/dotfiles
cd ~/dotfiles && chmod +x install.sh && ./install.sh
```

O directamente:
```bash
curl -fsSL https://raw.githubusercontent.com/TU_USUARIO/radxa-dotfiles/main/install.sh | bash
```

## Contenido

```
dotfiles/
├── install.sh              # Script de instalación principal
├── bashrc                  # Configuración de bash con aliases
├── config/
│   ├── nvim/
│   │   └── init.lua       # Configuración de Neovim
│   ├── tmux/
│   │   └── tmux.conf      # Configuración de tmux
│   └── lazygit/
│       └── config.yml     # Configuración de lazygit
└── scripts/
    ├── android-ssh-setup.sh      # Conexión SSH manual
    ├── android-ssh-autostart.sh  # Servicio automático
    └── android-ssh.service       # Systemd service
```

## Herramientas Instaladas

| Herramienta | Descripción |
|-------------|-------------|
| **opencode** | AI coding assistant |
| **nvim** | Neovim - editor de texto |
| **lazygit** | TUI para git |
| **tmux** | Terminal multiplexer |
| **bun** | JavaScript runtime |
| **fzf** | Fuzzy finder |
| **ripgrep** | Búsqueda rápida |

## SSH desde Android por USB

### Configuración Manual
```bash
android-ssh  # o: ~/.local/bin/android-ssh-setup.sh
```

### Desde Android (Termux)
```bash
ssh radxa@localhost -p 2222
```

### Servicio Automático
El servicio `android-ssh.service` configura la conexión automáticamente al conectar el USB.

```bash
# Ver estado
sudo systemctl status android-ssh

# Ver logs
cat ~/.local/log/android-ssh.log
```

## Aliases Útiles

### Git
- `gs` - git status
- `ga` - git add
- `gc` - git commit
- `gp` - git push
- `lg` - lazygit

### Navegación
- `ll` - ls -alFh
- `..` - cd ..
- `mkcd dir` - mkdir + cd

### Herramientas
- `v` - nvim
- `t` - tmux
- `oc` - opencode

### Sistema
- `sysinfo` - información del sistema
- `temp` - temperatura CPU
- `update` - actualizar sistema

## Tmux

Prefix: `Ctrl+a`

| Keybind | Acción |
|---------|--------|
| `\|` | Split vertical |
| `-` | Split horizontal |
| `hjkl` | Navegar paneles |
| `Alt+1-5` | Ir a ventana |
| `r` | Recargar config |

## Neovim

Leader: `Space`

| Keybind | Acción |
|---------|--------|
| `<leader>w` | Guardar |
| `<leader>q` | Salir |
| `<leader>e` | Explorador |
| `Ctrl+hjkl` | Navegar splits |
| `Shift+hl` | Cambiar buffer |

## Requisitos Android

1. Activar **Opciones de desarrollador**
2. Activar **Depuración USB**
3. Autorizar la conexión cuando aparezca el popup

## Personalización

Edita los archivos según tus preferencias y vuelve a ejecutar:
```bash
./install.sh  # Opción 3: Solo configurar dotfiles
```

## Licencia

MIT
