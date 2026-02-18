-- UI plugins configuration
-- Based on Gentleman.Dots

local mode = {
    "mode",
    fmt = function(s)
        local mode_map = {
            ["NORMAL"] = "N",
            ["O-PENDING"] = "N?",
            ["INSERT"] = "I",
            ["VISUAL"] = "V",
            ["V-BLOCK"] = "VB",
            ["V-LINE"] = "VL",
            ["V-REPLACE"] = "VR",
            ["REPLACE"] = "R",
            ["COMMAND"] = "!",
            ["SHELL"] = "SH",
            ["TERMINAL"] = "T",
            ["EX"] = "X",
            ["S-BLOCK"] = "SB",
            ["S-LINE"] = "SL",
            ["SELECT"] = "S",
            ["CONFIRM"] = "Y?",
            ["MORE"] = "M",
        }
        return mode_map[s] or s
    end,
}

return {
    -- Todo comments
    { "folke/todo-comments.nvim", version = "*" },

    -- Which-key
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            preset = "classic",
            win = { border = "single" },
        },
    },

    -- Lualine (statusline)
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        requires = { "nvim-tree/nvim-web-devicons", opt = true },
        opts = {
            options = {
                theme = "kanagawa",
                icons_enabled = true,
            },
            sections = {
                lualine_a = {
                    {
                        "mode",
                        icon = ">",
                    },
                },
            },
            extensions = {
                "quickfix",
                {
                    filetypes = { "oil" },
                    sections = {
                        lualine_a = { mode },
                        lualine_b = {
                            function()
                                local ok, oil = pcall(require, "oil")
                                if not ok then
                                    return ""
                                end
                                local path = vim.fn.fnamemodify(oil.get_current_dir(), ":~")
                                return path .. " %m"
                            end,
                        },
                    },
                },
            },
        },
    },

    -- Incline (floating filename)
    {
        "b0o/incline.nvim",
        event = "BufReadPre",
        priority = 1200,
        config = function()
            require("incline").setup({
                window = { margin = { vertical = 0, horizontal = 1 } },
                hide = {
                    cursorline = true,
                },
                render = function(props)
                    local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
                    if vim.bo[props.buf].modified then
                        filename = "[+] " .. filename
                    end

                    local ok, devicons = pcall(require, "nvim-web-devicons")
                    if ok then
                        local icon, color = devicons.get_icon_color(filename)
                        return { { icon, guifg = color }, { " " }, { filename } }
                    end
                    return { { filename } }
                end,
            })
        end,
    },

    -- Zen mode
    {
        "folke/zen-mode.nvim",
        cmd = "ZenMode",
        opts = {
            plugins = {
                gitsigns = true,
                tmux = true,
                kitty = { enabled = false, font = "+2" },
            },
        },
        keys = { { "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen Mode" } },
    },

    -- Snacks (dashboard and utilities)
    {
        "folke/snacks.nvim",
        keys = {
            {
                "<leader>fb",
                function()
                    Snacks.picker.buffers()
                end,
                desc = "Find Buffers",
            },
        },
        opts = {
            notifier = {},
            picker = {
                exclude = {
                    ".git",
                    "node_modules",
                },
                matcher = {
                    fuzzy = true,
                    smartcase = true,
                    ignorecase = true,
                    filename_bonus = true,
                },
            },
            dashboard = {
                sections = {
                    { section = "header" },
                    { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
                    { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
                    { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
                    { section = "startup" },
                },
                preset = {
                    header = [[
  ____           _            
 |  _ \ __ _  __| |_  ____ _  
 | |_) / _` |/ _` \ \/ / _` | 
 |  _ < (_| | (_| |>  < (_| | 
 |_| \_\__,_|\__,_/_/\_\__,_| 
                              
    ]],
                    keys = {
                        { icon = " ", key = "ff", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
                        { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
                        { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
                        { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
                        { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
                        { icon = " ", key = "s", desc = "Restore Session", section = "session" },
                        { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
                        { icon = " ", key = "q", desc = "Quit", action = ":qa" },
                    },
                },
            },
        },
    },
}
