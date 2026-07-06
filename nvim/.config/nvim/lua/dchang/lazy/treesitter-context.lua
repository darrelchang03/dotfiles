return {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
        require("treesitter-context").setup({
            enable = true,
            max_lines = 0,           -- unlimited: show the whole nesting chain
            line_numbers = true,     -- respects number/relativenumber
            mode = "cursor",         -- context follows cursor position
            trim_scope = "outer",
        })

        -- Underline the last context line so it reads as a divider from real code
        vim.api.nvim_set_hl(0, "TreesitterContextBottom", { underline = true, sp = "Grey" })

        vim.keymap.set("n", "[c", function()
            require("treesitter-context").go_to_context(vim.v.count1)
        end, { silent = true, desc = "[TS-Context]: Jump to enclosing context line" })
    end,
}
