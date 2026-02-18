-- Colorscheme configuration
-- Based on Gentleman.Dots

return {
    {
        "rebelot/kanagawa.nvim",
        priority = 1000,
        lazy = false,
        config = function()
            require("kanagawa").setup({
                compile = false,
                undercurl = true,
                commentStyle = { italic = true },
                functionStyle = {},
                keywordStyle = { italic = true },
                statementStyle = { bold = true },
                typeStyle = {},
                transparent = true,
                dimInactive = false,
                terminalColors = true,
                colors = {
                    palette = {},
                    theme = {
                        wave = {},
                        lotus = {},
                        dragon = {},
                        all = {
                            ui = {
                                bg_gutter = "none",
                                bg_sidebar = "none",
                                bg_float = "none",
                            },
                        },
                    },
                },
                overrides = function(colors)
                    return {
                        LineNr = { bg = "none" },
                        NormalFloat = { bg = "none" },
                        FloatBorder = { bg = "none" },
                        FloatTitle = { bg = "none" },
                        TelescopeNormal = { bg = "none" },
                        TelescopeBorder = { bg = "none" },
                        LspInfoBorder = { bg = "none" },
                    }
                end,
                theme = "wave",
                background = {
                    dark = "wave",
                    light = "lotus",
                },
            })
        end,
    },
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        opts = {
            flavour = "mocha",
            transparent_background = true,
            term_colors = true,
        },
    },
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "kanagawa",
        },
    },
}
