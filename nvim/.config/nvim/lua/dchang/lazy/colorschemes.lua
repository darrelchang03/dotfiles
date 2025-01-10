function ColorMyPencils(color)
    color = color or "nightfox"
    vim.cmd.colorscheme(color)

    -- Set transparent background for windows and floating windows
    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    vim.api.nvim_set_hl(0, 'NormalNC', { bg = 'NONE' })
end

--#ffffff

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
                -- Enable colorblind support
                enable = false,
                -- Only show simulated colorblind colors and not diff shifted
                simulate_only = false,                 severity = {
                    protan = 0.7,      -- Severity [0,1] for protan (red)
                    deutan = 0.3,      -- Severity [0,1] for deutan (green)
                    tritan = 0,        -- Severity [0,1] for tritan (blue)
                },
            },
            style = {
                comments = "italic",
                sidebars = "transparent",
                floats = "transparent",
            }
        },
        init = function()
        -- Other Themes Listed Here
    -- https://github.com/EdenEast/nightfox.nvim?tab=readme-ov-file#nightfox-1
            ColorMyPencils('nightfox')
        end
    },
}
