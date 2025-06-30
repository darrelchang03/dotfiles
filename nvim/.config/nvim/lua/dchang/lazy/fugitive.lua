return {
    "tpope/vim-fugitive",
    config = function()
        vim.keymap.set("n", "<leader>gs", vim.cmd.Git)

        local dchang_Fugitive = vim.api.nvim_create_augroup("dchang_Fugitive", {})

        local autocmd = vim.api.nvim_create_autocmd
        autocmd("BufWinEnter", {
            group = dchang_Fugitive,
            pattern = "*",
            callback = function()
                if vim.bo.ft ~= "fugitive" then
                    return
                end

                local bufnr = vim.api.nvim_get_current_buf()
                vim.keymap.set("n", "<leader>p", function()
                    vim.cmd.Git('push')
                end, {buffer = bufnr, remap = false, desc = '[Fugitive]: Push to upstream'})

                -- rebase always
                vim.keymap.set("n", "<leader>P", function()
                    vim.cmd.Git({'pull',  '--rebase'})
                end, {buffer = bufnr, remap = false, desc = '[Fugitive]: Pull with rebase'})

                -- NOTE: It allows me to easily set the branch i am pushing and any tracking
                -- needed if i did not set the branch up correctly
                vim.keymap.set("n", "<leader>t", ":Git push -u origin ", {buffer = bufnr, remap = false, desc = '[Fugitive]: Push to branch'});
            end,
        })


        vim.keymap.set("n", "gf", "<cmd>diffget //2<CR>", { desc = '[Fugitive]: Pick left diff' })
        vim.keymap.set("n", "gh", "<cmd>diffget //3<CR>", { desc = '[Fugitive]: Pick right diff' })
    end
}
