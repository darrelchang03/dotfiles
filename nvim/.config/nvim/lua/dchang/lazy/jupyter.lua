return {
  -- Jupytext converts notebooks into md/qmd files
  {
    "GCBallesteros/jupytext.nvim",
    -- lazy.nvim will call require("jupytext").setup(opts) automatically
    opts = {
      style = "hydrogen",
      output_extension = "auto",
      force_ft = nil,
      custom_language_formatting = {
        python = {
          extension = "qmd",
          style = "quarto",
          force_ft = "quarto",
        },
      },
    },
    -- If needed, make it non-lazy:
    -- lazy = false,
  },

  -- Otter: LSP for embedded code blocks in md/qmd
  {
    "jmbuhr/otter.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    ft = { "markdown", "quarto" }, -- load only when needed
    opts = {},                     -- pass setup opts here if you have any
    config = function(_, opts)
      require("otter").setup(opts)

      -- Activate per-buffer when these filetypes open
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown", "quarto" },
        callback = function()
          require("otter").activate({
            "python",
            "r",
            "bash",
            "lua",
            "html",
          }, true) -- enable auto root detection
        end,
      })
    end,
  },
}

