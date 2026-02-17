-- ═══════════════════════════════════════════════════════════════
-- Neovim Configuration - Radxa Cubie A7Z
-- Configuración minimalista optimizada para ARM
-- ═══════════════════════════════════════════════════════════════

-- ───────────────────────────────────────────────────────────────
-- Opciones básicas
-- ───────────────────────────────────────────────────────────────
local opt = vim.opt

-- Números de línea
opt.number = true
opt.relativenumber = true

-- Indentación
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.autoindent = true

-- Búsqueda
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Apariencia
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.colorcolumn = "100"

-- Comportamiento
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.splitright = true
opt.splitbelow = true
opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.updatetime = 250
opt.timeoutlen = 300
opt.completeopt = "menuone,noselect"

-- ───────────────────────────────────────────────────────────────
-- Keymaps
-- ───────────────────────────────────────────────────────────────
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local keymap = vim.keymap.set

-- Guardar y salir rápido
keymap("n", "<leader>w", ":w<CR>", { desc = "Guardar" })
keymap("n", "<leader>q", ":q<CR>", { desc = "Salir" })
keymap("n", "<leader>x", ":x<CR>", { desc = "Guardar y salir" })

-- Navegación entre splits
keymap("n", "<C-h>", "<C-w>h", { desc = "Ir a split izquierdo" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Ir a split inferior" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Ir a split superior" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Ir a split derecho" })

-- Redimensionar splits
keymap("n", "<C-Up>", ":resize +2<CR>", { desc = "Aumentar altura" })
keymap("n", "<C-Down>", ":resize -2<CR>", { desc = "Reducir altura" })
keymap("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Reducir ancho" })
keymap("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Aumentar ancho" })

-- Buffers
keymap("n", "<S-l>", ":bnext<CR>", { desc = "Siguiente buffer" })
keymap("n", "<S-h>", ":bprevious<CR>", { desc = "Buffer anterior" })
keymap("n", "<leader>bd", ":bdelete<CR>", { desc = "Cerrar buffer" })

-- Mover líneas en visual mode
keymap("v", "J", ":m '>+1<CR>gv=gv", { desc = "Mover línea abajo" })
keymap("v", "K", ":m '<-2<CR>gv=gv", { desc = "Mover línea arriba" })

-- Mantener visual al indentar
keymap("v", "<", "<gv", { desc = "Indentar izquierda" })
keymap("v", ">", ">gv", { desc = "Indentar derecha" })

-- Limpiar búsqueda
keymap("n", "<Esc>", ":noh<CR>", { desc = "Limpiar highlight búsqueda" })

-- Explorador de archivos (netrw)
keymap("n", "<leader>e", ":Explore<CR>", { desc = "Explorador" })

-- Terminal
keymap("n", "<leader>t", ":terminal<CR>", { desc = "Abrir terminal" })
keymap("t", "<Esc>", "<C-\\><C-n>", { desc = "Salir de modo terminal" })

-- Copiar ruta del archivo
keymap("n", "<leader>cp", ':let @+=expand("%:p")<CR>', { desc = "Copiar ruta absoluta" })
keymap("n", "<leader>cf", ':let @+=expand("%")<CR>', { desc = "Copiar ruta relativa" })

-- ───────────────────────────────────────────────────────────────
-- Autocmds
-- ───────────────────────────────────────────────────────────────
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight al copiar
augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
    group = "YankHighlight",
    callback = function()
        vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
    end,
})

-- Quitar comentario automático en nueva línea
autocmd("FileType", {
    pattern = "*",
    callback = function()
        vim.opt_local.formatoptions:remove({ "c", "r", "o" })
    end,
})

-- Recordar posición del cursor
autocmd("BufReadPost", {
    pattern = "*",
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- ───────────────────────────────────────────────────────────────
-- Colorscheme básico
-- ───────────────────────────────────────────────────────────────
vim.cmd([[
    colorscheme habamax
    
    " Mejoras al colorscheme
    hi Normal guibg=NONE ctermbg=NONE
    hi LineNr guifg=#5c6370
    hi CursorLineNr guifg=#61afef gui=bold
    hi CursorLine guibg=#2c323c
    hi Visual guibg=#3e4452
    hi ColorColumn guibg=#2c323c
]])

-- ───────────────────────────────────────────────────────────────
-- Netrw (explorador de archivos integrado)
-- ───────────────────────────────────────────────────────────────
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_browse_split = 4
vim.g.netrw_altv = 1
vim.g.netrw_winsize = 25

-- ───────────────────────────────────────────────────────────────
-- Statusline simple
-- ───────────────────────────────────────────────────────────────
opt.laststatus = 2
opt.statusline = " %f %m%r%h%w%= %y [%l/%L] "
