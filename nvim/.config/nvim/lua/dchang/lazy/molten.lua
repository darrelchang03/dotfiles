return {
    {
        "benlubas/molten-nvim",
        --version = "^1.0.0", -- use version <2.0.0 to avoid breaking changes
        enabled = false,
        dependencies = { "3rd/image.nvim" },
        build = ":UpdateRemotePlugins",
        init = function()
            -- this is an example, not a default. Please see the readme for more configuration options
            vim.g.molten_image_provider = "image.nvim"
            vim.g.molten_output_win_max_height = 20
            vim.g.molten_virt_text_output = true
            vim.g.molten_virt_lines_off_by_1 = true
            vim.g.molten_auto_open_output = false
            vim.g.molten_enter_output_behavior = "open_and_enter"
            vim.g.molten_output_show_more = true
            vim.g.molten_virt_text_max_lines = 10
            vim.g.molten_tick_rate = 150
            vim.g.molten_output_virt_lines = true
            vim.g.molten_wrap_output = false

            vim.keymap.set(
                "n",
                "<leader>me",
                ":MoltenEvaluateOperator<CR>",
                { desc = "[Molten] Evaluate operator", silent = true }
            )
            vim.keymap.set(
                "n",
                "<leader>os",
                ":noautocmd MoltenEnterOutput<CR>",
                { desc = "[Molten] Output show", silent = true }
            )
            vim.keymap.set("n", "<leader>oh", ":MoltenHideOutput<CR>", { desc = "[Molten] Output hide", silent = true })
            vim.keymap.set(
                "n",
                "<leader>rr",
                ":MoltenReevaluateCell<CR>",
                { desc = "[Molten] Reevaluate Cell", silent = true }
            )
            vim.keymap.set(
                "v",
                "<leader>r",
                ":<C-u>MoltenEvaluateVisual<CR>gv",
                { desc = "[Molten] Evalute visual", silent = true }
            )
            vim.keymap.set("n", "<leader>md", ":MoltenDelete<CR>", { desc = "[Molten] Delete cell", silent = true })

            vim.keymap.set("n", "<leader>ip", function()
                local venv = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
                if venv ~= nil then
                    -- in the form of /home/benlubas/.virtualenvs/VENV_NAME
                    venv = string.match(venv, "/.+/(.+)")
                    vim.cmd(("MoltenInit %s"):format(venv))
                else
                    vim.cmd("MoltenInit python3")
                end
            end, { desc = "Initialize Molten for python3", silent = true })

            -- point neovim to venv for molten
            vim.g.python3_host_prog = vim.fn.expand("~/.virtualenvs/neovim/bin/python3")
        end,
    },
    {
        "3rd/image.nvim", -- display images in kitty terminal
        dependencies = {
            {
                "nvim-treesitter/nvim-treesitter",
                build = ":TSUpdate",
                config = function()
                    require("nvim-treesitter.configs").setup({
                        ensure_installed = { "markdown" },
                        highlight = { enable = true },
                    })
                end,
            },
            --[[
            {
                "vhyrro/luarocks.nvim",
                priority = 1001,
                opts = {
                    rocks = { "magick" },
                },
            },
            --]]
        },
        config = function()
            require("image").setup({
                backend = "kitty",
                integrations = {
                    markdown = {
                        enabled = true,
                        clear_in_insert_mode = true,
                        only_render_image_at_cursor = false,
                    },
                },                                        -- do whatever you want with image.nvim's integrations
                max_width = 125,                          -- tweak to preference
                max_height = 20,                          -- ^
                max_height_window_percentage = math.huge, -- this is necessary for a good experience
                max_width_window_percentage = math.huge,
                window_overlap_clear_enabled = true,
                window_overlap_clear_ft_ignore = { "" },
                tmux_show_only_in_active_window = true,
                kitty_method = "normal"
            })
        end,
    },
    {
        "GCBallesteros/jupytext.nvim",
        config = function()
            require("jupytext").setup({
                style = "markdown",
                output_extension = "md",
                force_ft = "markdown",
                custom_language_formatting = {
                    python = {
                        extension = "md",
                        style = "markdown",
                        force_ft = "markdown", -- you can set whatever filetype you want here
                    },
                },
            })
        end,
        -- Depending on your nvim distro or config you may need to make the loading not lazy
        -- lazy=false,
    },
    {
        "jmbuhr/otter.nvim",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
        opts = {},
        ft = { "markdown", "quarto" },
        config = function()
            local otter = require("otter")
            otter.activate(languages, completion, diagnostics, tsquery)
        end,
    },
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        ft = { "markdown" },
        build = function()
            vim.fn["mkdp#util#install"]()
        end,
    },
    {
        "quarto-dev/quarto-nvim",
        ft = { "quarto", "markdown" },
        dependencies = {
            "nvim-lspconfig",
            "jmbuhr/otter.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        ft = { "quarto", "markdown" },
        config = function()
            local quarto = require("quarto")
            quarto.setup({
                debug = true,
                lspFeatures = {
                    -- NOTE: put whatever languages you want here:
                    enabled = true,
                    languages = { "r", "python", "rust" },
                    chunks = "curly", -- curly or all
                    diagnostics = {
                        enabled = true,
                        triggers = { "BufWritePost" },
                    },
                    completion = {
                        enabled = true,
                    },
                },
                codeRunner = {
                    enabled = true,
                    default_method = "molten",
                },
            })

            -- Quarto runner keymaps (nice sugar on top of molten)
            local runner = require("quarto.runner")
            vim.keymap.set("n", "<leader>rc", runner.run_cell, { desc = "run cell", silent = true })
            vim.keymap.set("n", "<leader>ra", runner.run_above, { desc = "run cell and above", silent = true })
            vim.keymap.set("n", "<leader>rA", runner.run_all, { desc = "run all cells", silent = true })
            vim.keymap.set("n", "<leader>rl", runner.run_line, { desc = "run line", silent = true })
            vim.keymap.set("v", "<leader>r", runner.run_range, { desc = "run visual range", silent = true })
            vim.keymap.set("n", "<leader>RA", function()
                runner.run_all(true)
            end, { desc = "run all cells (all langs)", silent = true })

            vim.keymap.set("n", "<leader>ip", function()
                local venv = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
                if venv ~= nil then
                    -- in the form of /home/benlubas/.virtualenvs/VENV_NAME
                    venv = string.match(venv, "/.+/(.+)")
                    vim.cmd(("MoltenInit %s"):format(venv))
                else
                    vim.cmd("MoltenInit python3")
                end
            end, { desc = "Initialize Molten for python3", silent = true })
        end,
    },

    -- Optional: treesitter textobjects for jumping/selecting code blocks in markdown
    -- (Requires nvim-treesitter)
    { "nvim-treesitter/nvim-treesitter-textobjects" },
}
