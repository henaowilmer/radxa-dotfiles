-- Lazy.nvim configuration
-- Based on Gentleman.Dots

-- Spell-checking
vim.opt.spell = true
vim.opt.spelllang = { "en" }

-- Define the path to the lazy.nvim plugin
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- Check if the lazy.nvim plugin is not already installed
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath
    })
end

-- Prepend the lazy.nvim path to the runtime path
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

-- Fix copy and paste in WSL
vim.opt.clipboard = "unnamedplus"
if vim.fn.has("wsl") == 1 then
    vim.g.clipboard = {
        name = "win32yank",
        copy = {
            ["+"] = "win32yank.exe -i --crlf",
            ["*"] = "win32yank.exe -i --crlf",
        },
        paste = {
            ["+"] = "win32yank.exe -o --lf",
            ["*"] = "win32yank.exe -o --lf",
        },
        cache_enabled = false,
    }
end

-- Setup lazy.nvim
require("lazy").setup({
    spec = {
        -- Add LazyVim and import its plugins
        { "LazyVim/LazyVim", import = "lazyvim.plugins" },

        -- Editor plugins
        { import = "lazyvim.plugins.extras.editor.harpoon2" },
        { import = "lazyvim.plugins.extras.editor.mini-files" },
        { import = "lazyvim.plugins.extras.editor.snacks_picker" },

        -- Formatting plugins
        { import = "lazyvim.plugins.extras.formatting.prettier" },

        -- Linting plugins
        { import = "lazyvim.plugins.extras.linting.eslint" },

        -- Language support plugins
        { import = "lazyvim.plugins.extras.lang.json" },
        { import = "lazyvim.plugins.extras.lang.markdown" },

        -- Coding plugins
        { import = "lazyvim.plugins.extras.coding.mini-surround" },
        { import = "lazyvim.plugins.extras.editor.mini-diff" },

        -- Utility plugins
        { import = "lazyvim.plugins.extras.util.mini-hipatterns" },

        -- Import custom plugins
        { import = "plugins" },
    },
    defaults = {
        lazy = false,
        version = false,
    },
    install = { colorscheme = { "kanagawa", "habamax" } },
    checker = { enabled = true },
    performance = {
        rtp = {
            disabled_plugins = {
                "gzip",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
})
