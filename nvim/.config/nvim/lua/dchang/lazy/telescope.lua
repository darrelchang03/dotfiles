return {
    "nvim-telescope/telescope.nvim",

    tag = "0.1.5",

    dependencies = {
        "nvim-lua/plenary.nvim",
        { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },

    config = function()
        require('telescope').setup({
            defaults = {
                file_ignore_patterns = { "node_modules/" },
            }
        })

        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = 'Telescope search files' })
        vim.keymap.set('n', '<C-p>', builtin.git_files, { desc = 'Telescope search git files' })
        vim.keymap.set('n', '<leader>pws', function()
            local word = vim.fn.expand("<cword>")
            builtin.grep_string({ search = word })
        end, { desc = 'Telescope [w]ord [s]earch' })
        vim.keymap.set('n', '<leader>pWs', function()
            local word = vim.fn.expand("<cWORD>")
            builtin.grep_string({ search = word })
        end, { desc = 'Telescope big [W]ord [s]earch' })
        vim.keymap.set('n', '<leader>ps', function()
            builtin.grep_string({ search = vim.fn.input("Grep > ") })
        end, { desc = 'Telescope Grep [p]roject [s]earch for word' })
        vim.keymap.set('n', '<leader>vh', builtin.help_tags, { desc = 'Telescope search [v]im [h]elp tags' })
        vim.keymap.set('n', '<leader>vk', builtin.keymaps, { desc = 'Telescope search [v]im [k]eymaps' })

        vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "none" })
        vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = "none" })
        vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = "none" })
        vim.api.nvim_set_hl(0, "TelescopePromptBorder", { bg = "none" })
        vim.api.nvim_set_hl(0, "TelescopePromptTitle", { bg = "none" })
        vim.api.nvim_set_hl(0, "TelescopeResultsTitle", { bg = "none" })
        vim.api.nvim_set_hl(0, "TelescopePreviewTitle", { bg = "none" })
    end
}
