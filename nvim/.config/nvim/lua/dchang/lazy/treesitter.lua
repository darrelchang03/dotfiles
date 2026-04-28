return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").setup({
                prefer_git = true,
                ensure_installed = {
                    "vimdoc", "javascript", "typescript", "c", "lua", "rust", "java",
                    "jsdoc", "bash", "html", "tsx", "css", "json", "yaml", "toml",
                    "cpp", "python", "go", "query", "regex", "comment"
                },
                sync_install = false,
                auto_install = false,
                indent = { enable = true },
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = { "markdown" },
                },
            })

            vim.treesitter.language.register("templ", "templ")
        end
    },

    -- auto html tag
    {
        'windwp/nvim-ts-autotag',
        config = function()
            require('nvim-ts-autotag').setup({})
        end,
    },
    {
        'norcalli/nvim-colorizer.lua',
        config = function()
            require('colorizer').setup()
        end
    },
    {
        "SmiteshP/nvim-navic",
        dependencies = "neovim/nvim-lspconfig",
        config = function()
            require("nvim-navic").setup({
                icons = {
                    File = "󰈙 ", Module = " ", Namespace = "󰌗 ",
                    Package = "󰏖 ", Class = "󰌗 ", Method = "󰆧 ",
                    Property = " ", Field = "󰜢 ", Constructor = "󰆧 ",
                    Enum = "󰕘 ", Interface = "󰜢 ", Function = "󰊕 ",
                    Variable = "󰀫 ", Constant = "󰏿 ", String = "󰀬 ",
                    Number = "󰎠 ", Boolean = "󰨙 ", Array = "󰅪 ",
                    Object = "󰀬 ", Key = "󰌋 ", Null = "󰟢 ",
                    EnumMember = " ", Struct = "󰌗 ", Event = " ",
                    Operator = "󰆕 ", TypeParameter = "󰊄 ",
                },
                highlight = true,
                separator = " > ",
                depth_limit = 0,
                depth_limit_indicator = "..",
            })
        end,
    },
}
