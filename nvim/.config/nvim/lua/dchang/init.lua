require("dchang.set")
require("dchang.remap")
require("dchang.lazy_init")

local augroup = vim.api.nvim_create_augroup
local yank_group = augroup('HighlightYank', {})
local autocmd = vim.api.nvim_create_autocmd
local dchang = augroup('ThePrimeagen', {})

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
        local opts = { buffer = e.buf }

        -- Attach `nvim-navic` if the LSP client supports document symbols
        local client = vim.lsp.get_client_by_id(e.data.client_id)
        if client.server_capabilities.documentSymbolProvider then
            require("nvim-navic").attach(client, e.buf)
            -- Add breadcrumbs to the top of the window with nvin-navic
            vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
            vim.api.nvim_set_hl(0, "WinBar", { bg = "NONE", fg = "#FFFFFF" }) -- Adjust fg as needed
            vim.api.nvim_set_hl(0, "WinBarNC", { bg = "NONE", fg = "#AAAAAA" }) -- Non-current window
        end

        vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
        vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
        vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
        vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
        vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
        vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
        vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
        vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
        vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
        vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    end
})
