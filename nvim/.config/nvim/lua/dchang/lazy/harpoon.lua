return {
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local harpoon = require("harpoon")

            -- REQUIRED
            harpoon:setup()
            -- REQUIRED

            vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end, { desc = '[Harpoon]: Append current file' })
            vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = '[Harpoon]: Open explorer list' })

            vim.keymap.set("n", "<C-j>", function() harpoon:list():select(1) end, { desc = '[Harpoon]: Jump to first' })
            vim.keymap.set("n", "<C-k>", function() harpoon:list():select(2) end, { desc = '[Harpoon]: Jump to second' })
            vim.keymap.set("n", "<C-l>", function() harpoon:list():select(3) end, { desc = '[Harpoon]: Jump to third' })
            vim.keymap.set("n", "<C-h>", function() harpoon:list():select(4) end, { desc = '[Harpoon]: Jump to fourth' })

            -- Toggle previous & next buffers stored within Harpoon list
            vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end, { desc = '[Harpoon]: IDK' })
            vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end, { desc = '[Harpoon]: IDKlol' })
        end
    }
}
