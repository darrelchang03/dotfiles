function ColorMyPencils(color)
    color = color or "nightfox"
    vim.cmd.colorscheme(color)

    -- Set transparent background for windows and floating windows
    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    vim.api.nvim_set_hl(0, 'NormalNC', { bg = 'NONE' })
    --    vim.api.nvim_set_hl(0, 'StatusLine', { bg = 'NONE' }) -- Change fg color if needed
    --    vim.api.nvim_set_hl(0, 'StatusLineNC', { bg = 'NONE' }) -- Non-current statusline
    --    vim.api.nvim_set_hl(0, 'TabLine', { bg = 'NONE' })
    --    vim.api.nvim_set_hl(0, 'TabLineFill', { bg = 'NONE' })
    --    vim.api.nvim_set_hl(0, 'TabLineSel', { bg = 'NONE' })
    --
    -- vim.api.nvim_set_hl(0, 'Normal', { bg = 'NONE' })
    -- vim.api.nvim_set_hl(0, 'Comment', { bg = 'NONE' })
    -- vim.api.nvim_set_hl(0, 'Constant', { bg = 'NONE' })
    -- vim.api.nvim_set_hl(0, 'Special', { bg = 'NONE' })
    -- vim.api.nvim_set_hl(0, 'Identifier', { bg = 'NONE' })
    -- vim.api.nvim_set_hl(0, 'Statement', { bg = 'NONE' })
    -- vim.api.nvim_set_hl(0, 'PreProc', { bg = 'NONE' })
    -- vim.api.nvim_set_hl(0, 'Type', { bg = 'NONE' })
    -- vim.api.nvim_set_hl(0, 'Underlined', { bg = 'NONE' })
    -- vim.api.nvim_set_hl(0, 'Todo', { bg = 'NONE' })
    -- vim.api.nvim_set_hl(0, 'String', { bg = 'NONE' })
    -- vim.api.nvim_set_hl(0, 'Function', { bg = 'NONE' })
    -- vim.api.nvim_set_hl(0, 'Conditional', { bg = 'NONE' })
    -- vim.api.nvim_set_hl(0, 'Repeat', { bg = 'NONE' })
    -- vim.api.nvim_set_hl(0, 'Operator', { bg = 'NONE' })
    -- vim.api.nvim_set_hl(0, 'Structure', { bg = 'NONE' })
    -- vim.api.nvim_set_hl(0, 'NonText', { bg = 'NONE' })
    -- vim.api.nvim_set_hl(0, 'SignColumn', { bg = 'NONE' })
    -- vim.api.nvim_set_hl(0, 'CursorLine', { bg = 'NONE' })
    -- vim.api.nvim_set_hl(0, 'CursorLineNr', { bg = 'NONE' })
    -- vim.api.nvim_set_hl(0, 'StatusLine', { bg = 'NONE' })
    -- vim.api.nvim_set_hl(0, 'StatusLineNC', { bg = 'NONE' })
    -- vim.api.nvim_set_hl(0, 'EndOfBuffer', { bg = 'NONE' })

    -- vim.api.nvim_set_hl(0, 'LineNr', { bg = 'NONE' })
end

return {
    {
        "EdenEast/nightfox.nvim",
        enabled = true,
        lazy = false,
        priority = 1000,
        options = {
            transparent = true,
            -- https://github.com/EdenEast/nightfox.nvim?tab=readme-ov-file#colorblind
            colorblind = {
                enable = false,        -- Enable colorblind support
                simulate_only = false, -- Only show simulated colorblind colors and not diff shifted
                severity = {
                    protan = 0.7,      -- Severity [0,1] for protan (red)
                    deutan = 0.3,      -- Severity [0,1] for deutan (green)
                    tritan = 0,        -- Severity [0,1] for tritan (blue)
                },
            },
            style = {
                comments = "italic",
            }
        },
        init = function()
            -- Other Themes Listed Here
            -- https://github.com/EdenEast/nightfox.nvim?tab=readme-ov-file#nightfox-1
            ColorMyPencils('nightfox')
        end
    },
}
