return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },

    config = function()
        --     -- Don't show statusline because this replaces it
        vim.opt.showmode = false

        local function diagnostics_mode()
            if _G.show_warnings then
                return ""  -- icon for "full diagnostics" (you can change this)
            else
                return ""  -- icon for "errors only"
            end
        end
        require('lualine').setup {
            options = {
                icons_enabled = true,
                -- Other themes here
                -- https://github.com/nvim-lualine/lualine.nvim/blob/master/THEMES.md
                -- auto will generate a theme based on colortheme
                theme = 'auto',
                component_separators = { left = '', right = ' ' },
                section_separators = { left = '', right = '' },
                disabled_filetypes = {
                    statusline = {},
                    winbar = {},
                },
                ignore_focus = {},
                always_divide_middle = true,
                always_show_tabline = true,
                globalstatus = false,
                refresh = {
                    statusline = 100,
                    tabline = 100,
                    winbar = 100,
                }
            },
            sections = {
                lualine_a = { 'mode' },
                lualine_b = { 'branch', 'diff', 'diagnostics' },
                lualine_c = { 'filename'},
                lualine_x = { diagnostics_mode, 'encoding', 'fileformat', 'filetype' },
                lualine_y = { 'progress' },
                lualine_z = { 'location' }
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = { 'filename' },
                lualine_x = { 'location' },
                lualine_y = {},
                lualine_z = {}
            },
            tabline = {},
            winbar = {},
            inactive_winbar = {},
            extensions = {}
        }

        -- Make lualine transparent
        vim.api.nvim_set_hl(0, 'lualine_c_normal', { bg = 'NONE', fg = '#FFFFFF' }) -- Adjust fg as needed
        -- vim.api.nvim_set_hl(0, 'lualine_a_normal', { bg = 'NONE' })
        -- vim.api.nvim_set_hl(0, 'lualine_b_normal', { bg = 'NONE' })
        -- vim.api.nvim_set_hl(0, 'lualine_x_normal', { bg = 'NONE' })
        -- vim.api.nvim_set_hl(0, 'lualine_y_normal', { bg = 'NONE' })
        -- vim.api.nvim_set_hl(0, 'lualine_z_normal', { bg = 'NONE' })


    end

}
