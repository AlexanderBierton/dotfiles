-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- ========================================================================== --
-- ==                            PLUGIN SETUP                              == --
-- ========================================================================== --
require("lazy").setup({

	-- [1] THE GHOST TEXT & COMPLETION
	{
		"saghen/blink.cmp",
		-- build = "cargo build --release",
		build = function()
			require("blink.cmp").build():wait(60000)
		end,
		dependencies = {
			"saghen/blink.lib",
			"rafamadriz/friendly-snippets",
			-- Add this little bridge plugin so Avante can talk to Blink!
			"Kaiser-Yang/blink-cmp-avante",
		},
		opts = {
			keymap = {
				preset = "default",
				["<CR>"] = { "accept", "fallback" },
				["<Tab>"] = { "select_next", "fallback" },
				["<S-Tab>"] = { "select_prev", "fallback" },
				["<Up>"] = { "select_prev", "fallback" },
				["<Down>"] = { "select_next", "fallback" },
			},
			appearance = { use_nvim_cmp_as_default = true, nerd_font_variant = "mono" },
			completion = {
				ghost_text = { enabled = false },
				menu = { draw = { columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } } } },
			},
			-- This is the new bit tha needs:
			sources = {
				-- Tell Blink to include Avante in the default list of places to look
				default = { "avante", "lsp", "path", "snippets", "buffer" },
				providers = {
					avante = {
						module = "blink-cmp-avante",
						name = "Avante",
						opts = {},
					},
				},
			},
		},
	},

	-- [2] THE AI GHOST TEXT (Minuet)
	{
		"milanglacier/minuet-ai.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("minuet").setup({
				provider = "gemini",
				throttle = 900,
				debounce = 200,
				provider_options = {
					gemini = {
						model = "gemini-2.5-flash",
					},
				},
				virtualtext = {
					auto_trigger_ft = { "*" },
					keymap = {
						accept = "<C-y>",
						accept_line = "<C-l>",
						next = "<C-j>", -- Swapped from ] to j
						prev = "<C-k>", -- Swapped from [ to k (Thy Escape key is free again!)
						dismiss = "<C-e>",
					},
				},
			})
		end,
	},

	-- [3] THE FANCY UI (Noice & Notifications)
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
		opts = {
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
				},
			},
			presets = {
				bottom_search = true,
				command_palette = true,
				long_message_to_split = true,
				inc_rename = false,
				lsp_doc_border = false,
			},
		},
	},

	-- [4] LSP & MASON (The Brains)
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"saghen/blink.cmp",
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
		},
		config = function()
			require("mason").setup()
			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls", "clangd", "ts_ls", "eslint" },
			})
			local capabilities = require("blink.cmp").get_lsp_capabilities()
			vim.lsp.config("lua_ls", { capabilities = capabilities })
			vim.lsp.enable("lua_ls")

			-- Setup lua
			local clangd_caps = vim.deepcopy(capabilities)
			clangd_caps.offsetEncoding = { "utf-16" }

			-- Setup C/C++
			vim.lsp.config("clangd", { capabilities = clangd_caps })
			vim.lsp.enable("clangd")

			-- Setup Typescript
			vim.lsp.config("ts_ls", { capabilities = capabilities })
			vim.lsp.enable("ts_ls")

			-- Setup ESLint
			vim.lsp.config("eslint", {
				capabilities = capabilities,
				on_attach = function(client, bufnr)
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = bufnr,
						-- We use a callback so it waits until the exact moment of saving
						callback = function()
							-- pcall silently catches errors so thy saves are never blocked!
							pcall(vim.cmd, "EslintFixAll")
						end,
					})
				end,
			})
			vim.lsp.enable("eslint")
		end,
	},

	-- [5] TELESCOPE & TREESITTER (The Essentials)
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{ "<leader>ff", "<cmd>lua require('telescope.builtin').find_files()<cr>", desc = "Find files" },
			{ "<leader>fg", "<cmd>lua require('telescope.builtin').live_grep()<cr>", desc = "Live grep" },
			{ "<leader>fb", "<cmd>lua require('telescope.builtin').buffers()<cr>", desc = "Buffers" },
			{ "<leader>fh", "<cmd>lua require('telescope.builtin').help_tags()<cr>", desc = "Help tags" },
			{ "<C-p>", "<cmd>lua require('telescope.builtin').git_files()<cr>", desc = "Git files" },
			{
				"<leader>fs",
				function()
					require("telescope.builtin").grep_string({ search = vim.fn.input("Grep > ") })
				end,
				desc = "Grep string",
			},
		},
		config = function()
			require("telescope").setup({
				defaults = {
					file_ignore_patterns = {
						"node_modules",
						"venv",
						"%.git/",
						"%.sst/",
						"%.DS_Store",
					},
				},
				pickers = {
					find_files = { follow = true, hidden = true },
				},
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "master",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"rust",
					"javascript",
					"typescript",
					"c",
					"cpp",
					"lua",
					"vim",
					"vimdoc",
					"query",
					"markdown",
					"markdown_inline",
				},
				sync_install = false,
				auto_install = true,
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
				},
			})
		end,
	},

	-- [6] THE THEME
	{
		"ellisonleao/gruvbox.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			-- Force the dark variant for the true Gruvbox experience
			vim.o.background = "dark"

			require("gruvbox").setup({
				contrast = "hard", -- Gives thee that deep, punchy background
			})

			vim.cmd.colorscheme("gruvbox")
		end,
	},

	-- [7] THE CURSOR KILLER (Avante.nvim)
	{
		"yetone/avante.nvim",
		event = "VeryLazy",
		lazy = false,
		version = false, -- always pull the latest features
		opts = {
			provider = "gemini",
			providers = {
				gemini = {
					model = "gemini-2.5-flash", -- Speedy and smart for inline edits
				},
			},
		},
		-- Avante needs to compile a small rust binary for token counting
		build = "make",
		dependencies = {
			"stevearc/dressing.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-tree/nvim-web-devicons",
			{
				-- This makes the Avante chat look beautiful with proper markdown rendering
				"MeanderingProgrammer/render-markdown.nvim",
				opts = {
					file_types = { "markdown", "Avante" },
				},
				ft = { "markdown", "Avante" },
			},
		},
	},

	-- [8] THY OTHER TOOLS (The "Mac to Linux" migration)
	{
		"windwp/nvim-autopairs",
		config = function()
			require("nvim-autopairs").setup({})
		end,
	},
	{
		"windwp/nvim-ts-autotag",
		config = function()
			require("nvim-ts-autotag").setup({})
		end,
	},
	{
		"mbbill/undotree",
		keys = { { "<leader>u", "<cmd>UndotreeToggle<cr>", desc = "Undotree Toggle" } },
	},
	{ "lewis6991/gitsigns.nvim" },
	{
		"romgrk/barbar.nvim",
		event = "BufReadPost",
		config = function()
			vim.g.barbar_auto_setup = false
			require("barbar").setup({
				animation = true,
				clickable = true,
			})
			local opts = { noremap = true, silent = true }
			vim.keymap.set("n", "<S-Tab>", "<Cmd>BufferPrevious<CR>", opts)
			vim.keymap.set("n", "<Tab>", "<Cmd>BufferNext<CR>", opts)
			vim.keymap.set("n", "<Leader>x", "<Cmd>BufferClose<CR>", opts)
		end,
	},
	{
		"christoomey/vim-tmux-navigator",
		keys = {
			{ "<C-h>", "<cmd>TmuxNavigateLeft<CR>", desc = "Tmux left" },
			{ "<C-l>", "<cmd>TmuxNavigateRight<CR>", desc = "Tmux right" },
			{ "<C-j>", "<cmd>TmuxNavigateDown<CR>", desc = "Tmux down" },
			{ "<C-k>", "<cmd>TmuxNavigateUp<CR>", desc = "Tmux up" },
		},
	},
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({})
		end,
	},
	{
		"nvim-tree/nvim-tree.lua",
		keys = { { "<leader>e", "<cmd>NvimTreeFocus<cr>", desc = "NvimTree Focus" } },
		-- Also load when starting with a directory (e.g. `nvim .`) so we can auto-open the tree
		event = "VimEnter",
		cond = function()
			return vim.fn.argc() == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1
		end,
		dependencies = { "nvim-tree/nvim-web-devicons", "b0o/nvim-tree-preview.lua" },
		config = function()
			vim.opt.termguicolors = true
			local HEIGHT_RATIO = 0.6
			local WIDTH_RATIO = 0.5
			require("nvim-tree").setup({
				update_focused_file = {
					enable = true,
					update_root = false,
				},
				sort = { sorter = "case_sensitive" },
				view = {
					relativenumber = true,
					float = {
						enable = true,
						open_win_config = function()
							local screen_w = vim.opt.columns:get()
							local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
							local window_w = screen_w * WIDTH_RATIO
							local window_h = screen_h * HEIGHT_RATIO
							return {
								border = "rounded",
								relative = "editor",
								row = ((vim.opt.lines:get() - window_h) / 2) - vim.opt.cmdheight:get(),
								col = (screen_w - window_w) / 2,
								width = math.floor(window_w),
								height = math.floor(window_h),
							}
						end,
					},
				},
				renderer = { group_empty = true },
				actions = { open_file = { quit_on_open = true } },
				filters = { git_ignored = false },
				on_attach = function(bufnr)
					local api = require("nvim-tree.api")
					api.config.mappings.default_on_attach(bufnr)
					local function opts(desc)
						return {
							desc = "nvim-tree: " .. desc,
							buffer = bufnr,
							noremap = true,
							silent = true,
							nowait = true,
						}
					end
					local preview = require("nvim-tree-preview")
					vim.keymap.set("n", "P", preview.watch, opts("Preview (Watch)"))
					vim.keymap.set("n", "<Esc>", preview.unwatch, opts("Close Preview/Unwatch"))
					vim.keymap.set("n", "<C-f>", function()
						return preview.scroll(4)
					end, opts("Scroll Down"))
					vim.keymap.set("n", "<C-b>", function()
						return preview.scroll(-4)
					end, opts("Scroll Up"))
					vim.keymap.set("n", "<Tab>", preview.node_under_cursor, opts("Preview"))
				end,
			})
			-- Auto-open tree when started with a directory (e.g. `nvim .`)
			if vim.fn.argc() == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
				vim.defer_fn(function()
					vim.cmd.cd(vim.fn.argv(0))
					require("nvim-tree.api").tree.open()
				end, 0)
			end
		end,
	},
	{
		"nvimtools/none-ls.nvim",
		event = "BufReadPre",
		dependencies = { "jay-babu/mason-null-ls.nvim" },
		config = function()
			require("mason-null-ls").setup({
				automatic_installation = true,
				ensure_installed = {
					"prettierd",
					"black",
					"mypy",
					"ruff",
					"gofmt",
					"goimports-reviser",
					"golangci-lint",
					"gomodifytags",
					"impl",
					"stylua",
				},
			})
			local null_ls = require("null-ls")
			local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
			null_ls.setup({
				default_timeout = 5000,
				sources = {
					null_ls.builtins.formatting.stylua,
					null_ls.builtins.formatting.prettierd,
					null_ls.builtins.formatting.gofmt,
					null_ls.builtins.formatting.goimports_reviser,
					null_ls.builtins.diagnostics.golangci_lint,
					null_ls.builtins.code_actions.gomodifytags,
					null_ls.builtins.code_actions.impl,
					null_ls.builtins.formatting.black.with({
						condition = function(utils)
							return utils.root_has_file({ "pyproject.toml", "setup.cfg" })
								or vim.fn.executable("black") == 1
						end,
					}),
					null_ls.builtins.diagnostics.mypy.with({
						condition = function()
							return vim.fn.executable("mypy") == 1
						end,
					}),
				},
				on_attach = function(client, bufnr)
					if client:supports_method("textDocument/formatting") then
						vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
						vim.api.nvim_create_autocmd("BufWritePre", {
							group = augroup,
							buffer = bufnr,
							callback = function()
								vim.lsp.buf.format({ async = false })
							end,
						})
					end
				end,
			})
		end,
	},
	{ "jay-babu/mason-null-ls.nvim" },
	{
		"ray-x/lsp_signature.nvim",
		event = "LspAttach",
		config = function()
			require("lsp_signature").setup({})
		end,
	},
	{ "b0o/nvim-tree-preview.lua" },
})

-- ========================================================================== --
-- ==                            POST-INSTALL                              == --
-- ========================================================================== --
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.shiftwidth = 4

-- LSP Diagnostic Keybinds
-- Space + v + d = View Diagnostic (pops open the error message)
vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, { desc = "View Diagnostic" })

-- It's also dead handy to jump between errors quickly!
-- [d = go to previous error
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous Diagnostic" })
-- ]d = go to next error
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
vim.keymap.set("n", "<leader>lr", "<cmd>LspRestart<cr>", { desc = "Restart LSP (Flush RAM)" })

-- ========================================================================== --
-- ==                            LSP KEYBINDS                              == --
-- ========================================================================== --
-- This tells Neovim to wait until a Language Server is actually attached to the
-- file before wiring up these specific shortcuts.
vim.api.nvim_create_autocmd("LspAttach", {
	desc = "LSP actions",
	callback = function(event)
		local opts = { buffer = event.buf, remap = false }

		-- Jump to definition using Telescope (brilliant for monorepos)
		vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<cr>", opts)

		-- Find everywhere this function/variable is used
		vim.keymap.set("n", "gr", "<cmd>Telescope lsp_references<cr>", opts)

		-- Hover documentation (Shift + K)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

		-- Rename a variable across the whole project
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
	end,
})
