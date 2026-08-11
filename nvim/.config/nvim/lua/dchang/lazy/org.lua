return {
    -- Base Org Mode Plugin
    {
        'nvim-orgmode/orgmode',
        event = 'VeryLazy',
        config = function()
            -- Setup orgmode
            local org = require('orgmode')

            org.setup({
                org_agenda_files = '~/org/**/*',
                org_default_notes_file = '~/org/refile.org',
            })
            -- Experimental LSP support
            vim.lsp.enable('org')
        end,
    },
    -- Org Roam
    {
        "chipsenkbeil/org-roam.nvim",
        tag = "0.2.0",
        dependencies = {
            {
                "nvim-orgmode/orgmode",
                tag = "0.7.0",
            },
        },
        config = function()
            require("org-roam").setup({
                directory = "~/org",
                -- optional
                org_files = {
                    -- "~/another_org_dir",
                    -- "~/some/folder/*.org",
                    -- "~/a/single/org_file.org",
                }
            })
        end
    }

}
