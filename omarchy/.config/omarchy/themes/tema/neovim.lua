return {
    {
        "bjarneo/aether.nvim",
        branch = "v2",
        name = "aether",
        priority = 1000,
        opts = {
            transparent = false,
            colors = {
                -- Background colors
                bg = "#1C3C52",
                bg_dark = "#1C3C52",
                bg_highlight = "#95aebf",

                -- Foreground colors
                -- fg: Object properties, builtin types, builtin variables, member access, default text
                fg = "#3fafef",
                -- fg_dark: Inactive elements, statusline, secondary text
                fg_dark = "#3fafef",
                -- comment: Line highlight, gutter elements, disabled states
                comment = "#95aebf",

                -- Accent colors
                -- red: Errors, diagnostics, tags, deletions, breakpoints
                red = "#BD5B3D",
                -- orange: Constants, numbers, current line number, git modifications
                orange = "#da927c",
                -- yellow: Types, classes, constructors, warnings, numbers, booleans
                yellow = "#ccbd63",
                -- green: Comments, strings, success states, git additions
                green = "#5A6442",
                -- cyan: Parameters, regex, preprocessor, hints, properties
                cyan = "#0388B4",
                -- blue: Functions, keywords, directories, links, info diagnostics
                blue = "#00397B",
                -- purple: Storage keywords, special keywords, identifiers, namespaces
                purple = "#003E82",
                -- magenta: Function declarations, exception handling, tags
                magenta = "#006ade",
            },
        },
        config = function(_, opts)
            require("aether").setup(opts)
            vim.cmd.colorscheme("aether")

            -- Enable hot reload
            require("aether.hotreload").setup()
        end,
    },
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "aether",
        },
    },
}
