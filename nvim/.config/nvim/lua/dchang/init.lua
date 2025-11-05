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
        local opts = { buffer = e.buf }

        -- Attach `nvim-navic` if the LSP client supports document symbols
        local client = vim.lsp.get_client_by_id(e.data.client_id)
        if client.server_capabilities.documentSymbolProvider then
            require("nvim-navic").attach(client, e.buf)
            -- Add breadcrumbs to the top of the window with nvin-navic
            vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
            vim.api.nvim_set_hl(0, "WinBar", { bg = "NONE", fg = "#FFFFFF" })   -- Adjust fg as needed
            vim.api.nvim_set_hl(0, "WinBarNC", { bg = "NONE", fg = "#AAAAAA" }) -- Non-current window
        end
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition", buffer = e.buf })
        vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Show hover information", buffer = e.buf })
        vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol,
            { desc = "Search workspace symbols", buffer = e.buf })
        vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float,
            { desc = "Show diagnostics in a floating window", buffer = e.buf })
        vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, { desc = "Trigger code action", buffer = e.buf })
        vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, { desc = "Show references", buffer = e.buf })
        vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, { desc = "Rename symbol", buffer = e.buf })
        vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, { desc = "Signature help", buffer = e.buf })
        vim.keymap.set("n", "[d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic", buffer = e.buf })
        vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic", buffer = e.buf })

        local opts = { buffer = e.buf }
    end
})


