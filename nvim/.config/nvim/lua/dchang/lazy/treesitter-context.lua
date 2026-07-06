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

        -- The context floats over the top of the window, so without this the
        -- cursor can end up hidden behind it. Keep the cursor `gap` visible
        -- lines below the context by scrolling the view when it gets too close.
        local gap = 8
        local function enforce_context_offset()
            local winid = vim.api.nvim_get_current_win()
            local ctx_win
            for _, w in ipairs(vim.api.nvim_list_wins()) do
                if vim.w[w].treesitter_context then
                    local cfg = vim.api.nvim_win_get_config(w)
                    if cfg.relative == "win" and cfg.win == winid then
                        ctx_win = w
                        break
                    end
                end
            end
            if not ctx_win then return end

            local ctx_height = vim.api.nvim_win_get_height(ctx_win)
            local overlap = ctx_height + gap + 1 - vim.fn.winline()
            if overlap > 0 then
                local view = vim.fn.winsaveview()
                view.topline = math.max(1, view.topline - overlap)
                vim.fn.winrestview(view)
            end
        end

        vim.api.nvim_create_autocmd({ "CursorMoved", "WinScrolled" }, {
            group = vim.api.nvim_create_augroup("TSContextOffset", {}),
            callback = function()
                -- schedule so the context window has updated for this cursor position
                vim.schedule(enforce_context_offset)
            end,
        })
    end,
}
