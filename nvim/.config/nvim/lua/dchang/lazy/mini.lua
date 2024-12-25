return {
    -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
    -- MINI SURROUND --
        -- Better Around/Inside textobjects
        --
        -- Examples:
        --  - va)  - [V]isually select [A]round [)]paren
        --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
        --  - ci'  - [C]hange [I]nside [']quote
        -- Not adding for now I dont know what it does
        -- require('mini.ai').setup { n_lines = 500 }

        -- Add/delete/replace surroundings (brackets, quotes, etc.)
        --
        -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
        -- - sd'   - [S]urround [D]elete [']quotes
        -- - sr)'  - [S]urround [R]eplace [)] [']
        -- require('mini.surround').setup()

    -- -- MINI STATUSLINE -- 
    --     local statusline = require 'mini.statusline'
    --     -- set use_icons to true if you have a Nerd Font
    --     statusline.setup { use_icons = vim.g.have_nerd_font }
    --     -- Don't show statusline because this replaces it
    --     vim.opt.showmode = false
    --     -- You can configure sections in the statusline by overriding their
    --     -- default behavior. For example, here we set the section for
    --     -- cursor location to LINE:COLUMN
    --     ---@diagnostic disable-next-line: duplicate-set-field
    --     statusline.section_location = function()
    --         return '%2l:%-2v'
    --     end

    -- MINI COMMENT --
        require('mini.comment').setup({
                -- Module mappings. Use `''` (empty string) to disable one.
                mappings = {
                    -- Toggle comment (like `gcip` - comment inner paragraph) for both
                    -- Normal and Visual modes
                    comment = 'gc',

                    -- Toggle comment on current line
                    comment_line = 'gcc',

                    -- Toggle comment on visual selection
                    comment_visual = 'gc',

                    -- Define 'comment' textobject (like `dgc` - delete whole comment block)
                    -- Works also in Visual mode if mapping differs from `comment_visual`
                    textobject = 'gc',
                },
        })

        -- ... and there is more!
        --  Check out: https://github.com/echasnovski/mini.nvim
    end,
}
