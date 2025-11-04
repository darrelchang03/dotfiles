return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                -- A list of parser names, or "all"
                ensure_installed = {
                    "vimdoc", "javascript", "typescript", "c", "lua", "rust", "java",
                    "jsdoc", "bash", "html", "tsx", "css", "json", "yaml", "toml",
                    "cpp", "python", "go", "query", "regex", "comment"
                },

                -- Install parsers synchronously (only applied to `ensure_installed`)
                sync_install = false,

                -- Automatically install missing parsers when entering buffer
                -- Recommendation: set to false if you don"t have `tree-sitter` CLI installed locally
                auto_install = false,

                indent = {
                    enable = true
                },

                highlight = {
                    -- `false` will disable the whole extension
                    enable = true,
                    --[[
                    disable = function(lang, buf)
                        if lang == "html" then
                            print("disabled")
                            return true
                        end

                        local max_filesize = 1000 * 1024 -- 1000 KB
                        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                        if ok and stats and stats.size > max_filesize then
                            vim.notify(
                                "File larger than 100KB treesitter disabled for performance",
                                vim.log.levels.WARN,
                                { title = "Treesitter" }
                            )
                            return true
                        end
                    end,
                    ]]--

                    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
                    -- Set this to `true` if you depend on "syntax" being enabled (like for indentation).
                    -- Using this option may slow down your editor, and you may see some duplicate highlights.
                    -- Instead of true it can also be a list of languages
                    additional_vim_regex_highlighting = { "markdown" },
                },
                textobjects = {
                    move = {
                        enable = true,
                        set_jumps = false, -- you can change this if you want.
                        goto_next_start = {
                            --- ... other keymaps
                            ["]b"] = { query = "@code_cell.inner", desc = "next code block" },
                        },
                        goto_previous_start = {
                            --- ... other keymaps
                            ["[b"] = { query = "@code_cell.inner", desc = "previous code block" },
                        },
                    },
                    select = {
                        enable = true,
                        lookahead = true, -- you can change this if you want
                        keymaps = {
                            --- ... other keymaps
                            ["ib"] = { query = "@code_cell.inner", desc = "in block" },
                            ["ab"] = { query = "@code_cell.outer", desc = "around block" },
                        },
                    },
                    swap = { -- Swap only works with code blocks that are under the same
                        -- markdown header
                        enable = true,
                        swap_next = {
                            --- ... other keymap
                            ["<leader>sbl"] = "@code_cell.outer",
                        },
                        swap_previous = {
                            --- ... other keymap
                            ["<leader>sbh"] = "@code_cell.outer",
                        },
                    },
                }
            })

            local treesitter_parser_config = require("nvim-treesitter.parsers").get_parser_configs()
            treesitter_parser_config.templ = {
                install_info = {
                    url = "https://github.com/vrischmann/tree-sitter-templ.git",
                    files = { "src/parser.c", "src/scanner.c" },
                    branch = "master",
                },
            }

            vim.treesitter.language.register("templ", "templ")
        end
    },

    {
        "theHamsta/nvim-treesitter-pairs",
        config = function()
            require("nvim-treesitter.configs").setup({
                pairs = {
                    enable = true,
                    highlight_pair_events = { 'CursorMoved' }, -- Highlight pairs on cursor move
                    highlight_self = true,                     -- Highlight the opening/closing pair under the cursor
                },
            })
        end
    },

    {
        "SmiteshP/nvim-navic",
        dependencies = "neovim/nvim-lspconfig", -- Ensure LSP is available
        config = function()
            require("nvim-navic").setup({
                -- Optional: Customize icons or settings
                icons = {
                    File = "󰈙 ",
                    Module = " ",
                    Namespace = "󰌗 ",
                    Package = "󰏖 ",
                    Class = "󰌗 ",
                    Method = "󰆧 ",
                    Property = " ",
                    Field = "󰜢 ",
                    Constructor = "󰆧 ",
                    Enum = "󰕘 ",
                    Interface = "󰜢 ",
                    Function = "󰊕 ",
                    Variable = "󰀫 ",
                    Constant = "󰏿 ",
                    String = "󰀬 ",
                    Number = "󰎠 ",
                    Boolean = "󰨙 ",
                    Array = "󰅪 ",
                    Object = "󰀬 ",
                    Key = "󰌋 ",
                    Null = "󰟢 ",
                    EnumMember = " ",
                    Struct = "󰌗 ",
                    Event = " ",
                    Operator = "󰆕 ",
                    TypeParameter = "󰊄 ",
                },
                highlight = true,
                separator = " > ",
                depth_limit = 0,
                depth_limit_indicator = "..",
            })
        end,
    },

    {
        'windwp/nvim-ts-autotag',
        config = function()
            require('nvim-ts-autotag').setup({
                -- Optional configurations can be added here
            })
        end,
    }
}
