require("dchang.set")
require("dchang.remap")
require("dchang.lazy_init")

local augroup = vim.api.nvim_create_augroup
local yank_group = augroup('HighlightYank', {})
local autocmd = vim.api.nvim_create_autocmd
local dchang = augroup('dchang', {})

autocmd('TextYankPost', {
    group = yank_group,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 40,
        })
    end,
})

autocmd('LspAttach', {
    group = dchang,
    callback = function(e)

        -- Disabled in favor of nvim-treesitter-context (sticky context lines);
        -- uncomment (along with the plugin spec in dchang/lazy/treesitter.lua) to switch back
        -- -- Attach `nvim-navic` if the LSP client supports document symbols
        -- local client = vim.lsp.get_client_by_id(e.data.client_id)
        -- if client.server_capabilities.documentSymbolProvider then
        --     require("nvim-navic").attach(client, e.buf)
        --     -- Add breadcrumbs to the top of the window with nvin-navic
        --     vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
        --     vim.api.nvim_set_hl(0, "WinBar", { bg = "NONE", fg = "#FFFFFF" })   -- Adjust fg as needed
        --     vim.api.nvim_set_hl(0, "WinBarNC", { bg = "NONE", fg = "#AAAAAA" }) -- Non-current window
        -- end
        vim.keymap.set("n", "gd", function()
            vim.lsp.buf.definition({
                on_list = function(options)
                    local item = options.items[1]
                    if not item then return end
                    -- Open the definition in a split to the right...
                    vim.cmd("rightbelow vsplit " .. vim.fn.fnameescape(item.filename))
                    vim.api.nvim_win_set_cursor(0, { item.lnum, math.max(item.col - 1, 0) })
                    vim.cmd("normal! zz")
                    -- ...but leave the cursor on the original buffer.
                    vim.cmd("wincmd p")
                end,
            })
        end, { desc = "Go to definition in a vertical split, keep cursor on original", buffer = e.buf })
        vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Show hover information", buffer = e.buf })
        vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol,
            { desc = "Search workspace symbols", buffer = e.buf })
        vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float,
            { desc = "Show diagnostics in a floating window", buffer = e.buf })
        vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, { desc = "Trigger code action", buffer = e.buf })
        vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, { desc = "Show references", buffer = e.buf })
        vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, { desc = "Rename symbol", buffer = e.buf })
        vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, { desc = "Signature help", buffer = e.buf })
        vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = 1 }) end, { desc = "Go to next diagnostic", buffer = e.buf })
        vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = -1}) end, { desc = "Go to previous diagnostic", buffer = e.buf })

    end
})


