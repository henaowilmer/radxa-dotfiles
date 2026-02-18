-- Keymaps configuration
-- Based on Gentleman.Dots

local keymap = vim.keymap.set

-- Map Ctrl+b in insert mode to delete to the end of the word
keymap("i", "<C-b>", "<C-o>de")

-- Map Ctrl+c to escape
keymap({ "i", "n", "v" }, "<C-c>", [[<C-\><C-n>]])

-- Tmux Navigation (if nvim-tmux-navigation is available)
local ok, nvim_tmux_nav = pcall(require, "nvim-tmux-navigation")
if ok then
    keymap("n", "<C-h>", nvim_tmux_nav.NvimTmuxNavigateLeft)
    keymap("n", "<C-j>", nvim_tmux_nav.NvimTmuxNavigateDown)
    keymap("n", "<C-k>", nvim_tmux_nav.NvimTmuxNavigateUp)
    keymap("n", "<C-l>", nvim_tmux_nav.NvimTmuxNavigateRight)
    keymap("n", "<C-\\>", nvim_tmux_nav.NvimTmuxNavigateLastActive)
    keymap("n", "<C-Space>", nvim_tmux_nav.NvimTmuxNavigateNext)
end

-- Oil keymap
keymap("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- Delete all buffers but the current one
keymap(
    "n",
    "<leader>bq",
    '<Esc>:%bdelete|edit #|normal`"<Return>',
    { desc = "Delete other buffers" }
)

-- Disable some default keymaps
vim.api.nvim_set_keymap("i", "<A-j>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<A-k>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<A-j>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<A-k>", "<Nop>", { noremap = true, silent = true })

-- Save with Ctrl+s
vim.api.nvim_set_keymap("n", "<C-s>", ":lua SaveFile()<CR>", { noremap = true, silent = true })

-- Delete all marks
keymap("n", "<leader>md", function()
    vim.cmd("delmarks!")
    vim.cmd("delmarks A-Z0-9")
    vim.notify("All marks deleted")
end, { desc = "Delete all marks" })

-- Custom save function
function SaveFile()
    if vim.fn.empty(vim.fn.expand("%:t")) == 1 then
        vim.notify("No file to save", vim.log.levels.WARN)
        return
    end

    local filename = vim.fn.expand("%:t")
    local success, err = pcall(function()
        vim.cmd("silent! write")
    end)

    if success then
        vim.notify(filename .. " Saved!")
    else
        vim.notify("Error: " .. err, vim.log.levels.ERROR)
    end
end
