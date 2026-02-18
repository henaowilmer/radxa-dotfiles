-- Disabled plugins
-- Disable heavy plugins that may not work well on ARM devices

return {
    -- Disable bufferline (use incline instead)
    {
        "akinsho/bufferline.nvim",
        enabled = false,
    },
}
