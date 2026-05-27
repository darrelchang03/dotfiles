-- Define the alert function
local function alert(message, delay)
    vim.cmd('echo "' .. message .. '"')
    vim.defer_fn(function()
        vim.cmd('echo ""') -- Clear the message
    end, delay)            -- Delay in milliseconds
end

vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = 'Go to vim netrw file expolorer' })

-- Moves lines easier
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("n", "J", "mzJ`z")
-- Recenter when navigating
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
-- Scroll with arrow keys
vim.keymap.set("n", "<Up>", "<C-u>zz")
vim.keymap.set("n", "<Down>", "<C-d>zz")
-- Make scroll speed faster

-- Change tabs with leader <number>
for i = 1, 8 do
    vim.keymap.set({ "n", "t" }, "<Leader>" .. i, "<Cmd>tabnext " .. i .. "<CR>", {
        desc = "Go to tab " .. i,
        silent = true,
    })
end

-- Remember the last-used tab
vim.g.lasttab = 1
vim.api.nvim_create_autocmd("TabLeave", {
    callback = function()
        vim.g.lasttab = vim.fn.tabpagenr()
    end,
})

-- Alternate tabs
vim.keymap.set({ "n", "t" }, "<Leader><Tab>", function()
    vim.cmd("tabnext" .. vim.g.lasttab)
end, { desc = "Go to last-used tab", silent = true })

-- paste without losing paste register
vim.keymap.set("x", "<leader>p", [["_dp]])
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

vim.keymap.set({ "n", "v" }, "Y", '"+y', { noremap = true, silent = true, desc = 'Copy to system clipboard' })
-- vim.keymap.set({ "n", "v" }, "P", '"+p', { noremap = true, silent = true })
-- vim.keymap.set({ "n", "v" }, "D", '"+d', { noremap = true, silent = true })


vim.keymap.set("n", "<leader>mr", "<cmd>CellularAutomaton make_it_rain<CR>", { desc = 'Make it rain' });

vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>", { desc = 'Tmux sessionizer' })
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { desc = 'Format using lsp' })

vim.keymap.set("n", "<M-j>", "<cmd>cnext<CR>zz", { desc = 'Go next in quick fix list' })
vim.keymap.set("n", "<M-k>", "<cmd>cprev<CR>zz", { desc = 'Go back/prev in quick fix list' })

vim.keymap.set("n", "<leader>j", "<cmd>lnext<CR>zz", { desc = 'Go next in location list' })
vim.keymap.set("n", "<leader>k", "<cmd>lprev<CR>zz", { desc = 'Go back/prev in location list' })

-- substitute current word
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
    { desc = 'Substitute word under cursor' })

-- Toggle execute permissions
vim.keymap.set("n", "<leader>x", function()
    -- Get the file permissions
    local filepath = vim.fn.expand('%')
    local handle = io.popen('ls -l ' .. filepath)
    local result = handle:read("*a")
    handle:close()

    -- Check if the file has execute permission for the user
    if result:match("^.-x") then
        -- File has execute permission, so remove it
        vim.cmd("silent !chmod -x " .. filepath)
        alert("Removed execute permissions from current file", 3000)
    else
        -- File doesn't have execute permission, so add it
        vim.cmd("silent !chmod +x " .. filepath)
        alert("Added execute permissions to current file", 3000)
    end
end, { silent = true, desc = 'Add execute permissions to current file' })

vim.keymap.set("n", "<leader>vpp", "<cmd>e ~/.dotfiles/nvim/.config/nvim/lua/dchang/lazy/<CR>",
    { desc = 'Go to vim config files' });

vim.keymap.set("n", "<leader>o", function()
    vim.cmd("so")
    alert("Sourced current file", 2000)
end, { desc = 'Source current file' })
vim.keymap.set({ "n", "v" }, "<leader>O", function()
    vim.cmd("source " .. vim.env.MYVIMRC)
    vim.notify("Config reloaded")
end, { desc = "Reload config" })

vim.keymap.set({ "n", "v", "x" }, "<leader>r", ":edit!<CR>", { desc = "Reload current buffer " })

_G.show_warnings = false

function _G.toggle_warnings()
    _G.show_warnings = not _G.show_warnings
    if _G.show_warnings then
        vim.diagnostic.config({
            virtual_text = true,
            signs = true,
            underline = true,
        })
        print("Diagnostics: showing warnings")
    else
        vim.diagnostic.config({
            virtual_text = {
                severity = vim.diagnostic.severity.ERROR,
            },
            signs = {
                -- severity = vim.diagnostic.severity.ERROR,
            },
            underline = {
                -- severity = vim.diagnostic.severity.ERROR,
            },
        })
        print("Diagnostics: showing errors only")
    end
end

vim.keymap.set('n', '<space>tw', toggle_warnings, { desc = "Toggle warnings" })
