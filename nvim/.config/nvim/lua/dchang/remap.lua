-- Define the alert function
local function alert(message, delay)
    vim.cmd('echo "' .. message .. '"')
    vim.defer_fn(function()
        vim.cmd('echo ""') -- Clear the message
    end, delay)            -- Delay in milliseconds
end

vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Moves lines easier
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")

-- Recenter when navigating
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- paste without losing paste register
vim.keymap.set("x", "<leader>p", [["_dp]])

-- Remap Y and P to be system clipboard versions of v and p
vim.keymap.set({ "n", "v" }, "Y", '"+y', { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "P", '"+p', { noremap = true, silent = true })
-- vim.keymap.set({ "n", "v" }, "D", '"+d', { noremap = true, silent = true })

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

vim.keymap.set("n", "<leader>mr", "<cmd>CellularAutomaton make_it_rain<CR>");

-- ehhhh
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")

vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- substitute current word
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

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
end, { silent = true })

vim.keymap.set("n", "<leader>vpp", "<cmd>e ~/.dotfiles/nvim/.config/nvim/lua/dchang/lazy/<CR>");

vim.keymap.set("n", "<leader>r", function()
    vim.cmd("so")
    alert("Sourced current file", 2000)
end)

_G.show_warnings = false

function _G.toggle_warnings()
  _G.show_warnings = not _G.show_warnings
  if _G.show_warnings then
    vim.diagnostic.config({
      virtual_text = true,
      signs = true,
      underline = true,
    })
    -- print("Diagnostics: showing warnings")
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
    -- print("Diagnostics: showing errors only")
  end
end

vim.keymap.set('n', '<space>tw', toggle_warnings, { desc = "Toggle warnings" })
