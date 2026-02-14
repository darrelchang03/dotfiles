return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"stevearc/conform.nvim",
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-cmdline",
		"hrsh7th/nvim-cmp",
		"L3MON4D3/LuaSnip",
		"saadparwaiz1/cmp_luasnip",
		"j-hui/fidget.nvim",
	},

	config = function()
		require("conform").setup({
			formatters_by_ft = {},
		})
		local cmp = require("cmp")
		local cmp_lsp = require("cmp_nvim_lsp")
		local capabilities = vim.tbl_deep_extend(
			"force",
			{},
			vim.lsp.protocol.make_client_capabilities(),
			cmp_lsp.default_capabilities()
		)

		require("fidget").setup({})
		require("mason").setup()
		require("mason-lspconfig").setup({
			ensure_installed = {
				"lua_ls",
				"tailwindcss",
				"eslint",
				"pyright",
			},
			---@type boolean | string[] | { exclude: string[] }
			automatic_installation = {},
			handlers = {
				function(server_name) -- default handler (optional)
					require("lspconfig")[server_name].setup({
						capabilities = capabilities,
					})
				end,

				zls = function()
					local lspconfig = require("lspconfig")
					lspconfig.zls.setup({
						root_dir = lspconfig.util.root_pattern(".git", "build.zig", "zls.json"),
						settings = {
							zls = {
								enable_inlay_hints = true,
								enable_snippets = true,
								warn_style = true,
							},
						},
					})
					vim.g.zig_fmt_parse_errors = 0
					vim.g.zig_fmt_autosave = 0
				end,
				["lua_ls"] = function()
					local lspconfig = require("lspconfig")
					lspconfig.lua_ls.setup({
						capabilities = capabilities,
						settings = {
							Lua = {
								runtime = { version = "Lua 5.1" },
								diagnostics = {
									globals = { "bit", "vim", "it", "describe", "before_each", "after_each" },
								},
							},
						},
					})
				end,
				["eslint"] = function()
					local lspconfig = require("lspconfig")
					local lsp = vim.lsp
					lspconfig.eslint.setup({
						capabilities = capabilities,
						on_attach = function(client, bufnr)
							vim.api.nvim_buf_create_user_command(bufnr, "LspEslintFixAll", function()
								client:request_sync("workspace/executeCommand", {
									command = "eslint.applyAllFixes",
									arguments = {
										{
											uri = vim.uri_from_bufnr(bufnr),
											version = lsp.util.buf_versions[bufnr],
										},
									},
								}, nil, bufnr)
							end, {})
						end,
					})
				end,
				["pyright"] = function()
					local function set_python_path(command)
						local path = command.args
						local clients = vim.lsp.get_clients({
							bufnr = vim.api.nvim_get_current_buf(),
							name = "pyright",
						})
						for _, client in ipairs(clients) do
							if client.settings then
								client.settings.python = vim.tbl_deep_extend(
									"force",
									client.settings.python --[[@as table]],
									{ pythonPath = path }
								)
							else
								client.config.settings = vim.tbl_deep_extend(
									"force",
									client.config.settings,
									{ python = { pythonPath = path } }
								)
							end
							client:notify("workspace/didChangeConfiguration", { settings = nil })
						end
					end
					local lspconfig = require("lspconfig")
					lspconfig.pyright.setup({
						on_attach = function(client, bufnr)
							vim.api.nvim_buf_create_user_command(bufnr, "LspPyrightOrganizeImports", function()
								local params = {
									command = "pyright.organizeimports",
									arguments = { vim.uri_from_bufnr(bufnr) },
								}

								-- Using client.request() directly because "pyright.organizeimports" is private
								-- (not advertised via capabilities), which client:exec_cmd() refuses to call.
								-- https://github.com/neovim/neovim/blob/c333d64663d3b6e0dd9aa440e433d346af4a3d81/runtime/lua/vim/lsp/client.lua#L1024-L1030
								---@diagnostic disable-next-line: param-type-mismatch
								client.request("workspace/executeCommand", params, nil, bufnr)
							end, {
								desc = "Organize Imports",
							})
							vim.api.nvim_buf_create_user_command(bufnr, "LspPyrightSetPythonPath", set_python_path, {
								desc = "Reconfigure pyright with the provided python path",
								nargs = 1,
								complete = "file",
							})
						end,

						capabilities = capabilities,
						settings = {
							python = {
								analysis = {
									diagnosticSeverityOverrides = {
										reportUnusedExpression = "none",
									},
								},
							},
						},
					})
				end,
			},
		})

		local cmp_select = { behavior = cmp.SelectBehavior.Select }

		cmp.setup({
			snippet = {
				expand = function(args)
					require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
				end,
			},
			mapping = cmp.mapping.preset.insert({
				["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
				["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
				["<C-y>"] = cmp.mapping.confirm({ select = true }),
				["<CR>"] = cmp.mapping.confirm({ select = true }),
				["<C-Space>"] = cmp.mapping.complete(),
			}),
			sources = cmp.config.sources({
				{ name = "nvim_lsp" },
				{ name = "luasnip" }, -- For luasnip users.
			}, {
				{ name = "buffer" },
			}),
		})

		vim.diagnostic.config({
			-- update_in_insert = true,
			virtual_text = {
				--severity = vim.diagnostic.severity.ERROR,
			},
			signs = {
				--severity = vim.diagnostic.severity.ERROR,
			},
			underline = {
				--severity = vim.diagnostic.severity.ERROR,
			},
			float = {
				focusable = false,
				style = "minimal",
				border = "rounded",
				source = "if_many",
				header = "",
				prefix = "",
			},
		})
	end,
}
