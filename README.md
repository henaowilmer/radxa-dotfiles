# Radxa Dotfiles

Configuración completa del entorno de desarrollo para Radxa y dispositivos ARM.
Basado en [Gentleman.Dots](https://github.com/Gentleman-Programming/Gentleman.Dots).

## Instalación Rápida

```bash
git clone https://github.com/YOUR_USER/radxa-dotfiles.git ~/dotfiles
cd ~/dotfiles && chmod +x install.sh && ./install.sh
```

O directamente:
```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USER/radxa-dotfiles/main/install.sh | bash
```

## Preview

```
  ____           _            
 |  _ \ __ _  __| |_  ____ _  
 | |_) / _` |/ _` \ \/ / _` | 
 |  _ < (_| | (_| |>  < (_| | 
 |_| \_\__,_|\__,_/_/\_\__,_| 
```

## Contenido

```
radxa-dotfiles/
├── install.sh                    # Script de instalación principal
├── config/
│   ├── fish/
│   │   └── config.fish           # Configuración de Fish shell
│   ├── starship/
│   │   └── starship.toml         # Prompt Starship
│   ├── nvim/
│   │   ├── init.lua              # Entry point
│   │   └── lua/
│   │       ├── config/
│   │       │   ├── lazy.lua      # LazyVim setup
│   │       │   ├── options.lua   # Opciones
│   │       │   └── keymaps.lua   # Keymaps
│   │       └── plugins/
│   │           ├── oil.lua       # File explorer
│   │           ├── colorscheme.lua
│   │           ├── ui.lua
│   │           └── ...
│   ├── tmux/
│   │   └── tmux.conf             # Configuración de tmux + TPM
│   └── lazygit/
│       └── config.yml
└── scripts/
    ├── android-ssh-setup.sh
    └── ...
```

## Herramientas Instaladas

### Shell & Prompt
| Herramienta | Descripción |
|-------------|-------------|
| **Fish** | Shell moderno y amigable |
| **Starship** | Prompt rápido y personalizable |
| **Tmux** | Terminal multiplexer con tema Kanagawa |

### Editor
| Herramienta | Descripción |
|-------------|-------------|
| **Neovim** | Editor con LazyVim |
| **Oil.nvim** | File explorer tipo buffer |
| **tree-sitter** | Syntax highlighting avanzado |

### CLI Tools
| Herramienta | Descripción |
|-------------|-------------|
| **zoxide** | cd inteligente (z) |
| **atuin** | Historial de shell mejorado |
| **fzf** | Fuzzy finder |
| **fd** | Find moderno |
| **ripgrep** | Grep ultrarrápido |
| **bat** | Cat con syntax highlighting |
| **lazygit** | TUI para Git |
| **carapace** | Autocompletions universales |
| **jq** | Procesador JSON |

### Lenguajes & Runtimes
| Herramienta | Descripción |
|-------------|-------------|
| **Volta** | Node.js version manager |
| **Bun** | JavaScript runtime rápido |
| **Rust/Cargo** | Lenguaje de sistemas |
| **Go** | Lenguaje de Google |
| **GCC** | Compilador C/C++ |

### Fonts
| Herramienta | Descripción |
|-------------|-------------|
| **Iosevka Term Nerd Font** | Font con iconos para terminal |

## Keybindings

### Fish Shell
- `Ctrl+r` - Buscar en historial (atuin)
- `Ctrl+t` - Fuzzy find archivos (fzf)
- `z <dir>` - Saltar a directorio (zoxide)

### Tmux (Prefix: `Ctrl+a`)
| Keybind | Acción |
|---------|--------|
| `v` | Split vertical |
| `d` | Split horizontal |
| `hjkl` | Navegar paneles |
| `Alt+g` | Ventana flotante (scratch) |
| `K` | Matar otras sesiones |
| `r` | Recargar config |
| `I` | Instalar plugins (TPM) |

### Neovim (Leader: `Space`)
| Keybind | Acción |
|---------|--------|
| `-` | Oil (file explorer) |
| `<leader>E` | Oil flotante |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Find buffers |
| `<leader>z` | Zen mode |
| `gpd` | Preview definition |
| `gpr` | Preview references |
| `Ctrl+hjkl` | Navegar splits/tmux |

### Lazygit
| Keybind | Acción |
|---------|--------|
| `lg` | Abrir lazygit (alias) |

## Personalización

### Cambiar shell por defecto
```bash
chsh -s $(which fish)
```

### Instalar herramienta específica
```bash
./install.sh  # Opción 4
```

### Solo actualizar dotfiles
```bash
./install.sh  # Opción 3
```

## Post-instalación

1. **Reiniciar terminal** o ejecutar `exec fish`
2. **Tmux**: Presionar `Ctrl+a` + `I` para instalar plugins
3. **Neovim**: Abrir `nvim` y esperar a que LazyVim instale plugins

## Requisitos

- Debian/Ubuntu (ARM64, ARMv7, o x86_64)
- Conexión a internet
- sudo access

## Créditos

- [Gentleman.Dots](https://github.com/Gentleman-Programming/Gentleman.Dots) - Configuración base
- [LazyVim](https://github.com/LazyVim/LazyVim) - Framework de Neovim
- [Kanagawa](https://github.com/rebelot/kanagawa.nvim) - Colorscheme

## Licencia

MIT
