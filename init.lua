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

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 3 
vim.opt.softtabstop = 3
vim.opt.shiftwidth = 3
vim.cmd("hi Normal guibg=NONE ctermbg=NONE")
vim.cmd("hi NonText guibg=NONE ctermbg=NONE")
vim.opt.rtp:prepend(lazypath)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.opt.rtp:append(vim.fn.stdpath("config"))

require("lazy").setup({
	spec = {
		{"folke/tokyonight.nvim", lazy = false, priority = 1000, opts = {},},
		{'nvim-telescope/telescope.nvim', version = '0.1.8', dependencies = { 'nvim-lua/plenary.nvim' }},
		{"nvim-treesitter/nvim-treesitter", version = '*', build = ":TSUpdate"},
		{"ThePrimeagen/harpoon"},
		{"neovim/nvim-lspconfig", version = "*", config = function()
			local lspconfig = require("lspconfig")
			lspconfig.pyright.setup{}
			require("lsp.luau")

		end},
		{"mbbill/undotree"},
		{"hrsh7th/nvim-cmp"},
		{"hrsh7th/cmp-nvim-lsp"},
		{"VonHeikemen/lsp-zero.nvim"},
		{"numToStr/Comment.nvim",
		opts = {}
	},
	{"jmcantrell/vim-virtualenv"},
	{"ThePrimeagen/vim-be-good"},
	{"L3MON4D3/LuaSnip"}
},
checker = { enabled = true },
})
-- add mappings 
vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)
vim.keymap.set('n', '<leader>pv', vim.cmd.Ex)
vim.keymap.set('n', '<leader>py', ":!python3 %<CR>", {noremap = true, silent=false })

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files)
vim.keymap.set('n', '<leader>fs', function()
	builtin.grep_string({
		use_regex = false
	})
end)
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>/', builtin.current_buffer_fuzzy_find)
vim.keymap.set('n', '<leader>fb', builtin.buffers)

local harpoon = require('harpoon.ui')

vim.keymap.set('n', '<leader>a', function () require('harpoon.mark').add_file()end)
vim.keymap.set('n', '<leader>1', function () harpoon.nav_file(1) end)
vim.keymap.set('n', '<leader>2', function () harpoon.nav_file(2) end)
vim.keymap.set('n', '<leader>3', function () harpoon.nav_file(3) end)
vim.keymap.set('n', '<leader>4', function () harpoon.nav_file(4) end)
vim.keymap.set('n', '<leader>5', function () harpoon.nav_file(5) end)
vim.keymap.set('n', '<leader>h', function () harpoon.toggle_quick_menu() end)

local configs = require("nvim-treesitter.configs")
configs.setup({
	ensure_installed = {"lua", "python", "vim", "bash", "json", "markdown", "luau"},
	sync_install = false,
	auto_install = true,
	highlight = { enable = true, additional_vim_regex_highlighting = false },
})

require("tokyonight").setup({
	transparent = true,
	styles = {
		sidebars = "transparent",
		floats = "transparent"
	}
})

vim.cmd("colorscheme tokyonight")
-- NOTE: to make any of this work you need a language server.
-- If you don't know what that is, watch this 5 min video:
-- https://www.youtube.com/watch?v=LaS32vctfOY

-- Reserve a space in the gutter
vim.opt.signcolumn = 'yes'

-- Add cmp_nvim_lsp capabilities settings to lspconfig
-- This should be executed before you configure any language server
local lspconfig_defaults = require('lspconfig').util.default_config
lspconfig_defaults.capabilities = vim.tbl_deep_extend(
	'force',
	lspconfig_defaults.capabilities,
	require('cmp_nvim_lsp').default_capabilities()
)

-- This is where you enable features that only work
-- if there is a language server active in the file
vim.api.nvim_create_autocmd('LspAttach', {
	desc = 'LSP actions',
	callback = function(event)
		local opts = {buffer = event.buf}

		vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
		vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
		vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
		vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
		vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
		vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
		vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
		vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
		vim.keymap.set({'n', 'x'}, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
		vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
	end,
})
--snippets
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "sourcemap.json",
  callback = function()
    for _, client in pairs(vim.lsp.get_active_clients()) do
      if client.name == "luau_lsp" then
        client.stop()
        vim.defer_fn(function()
          vim.cmd("edit") -- reload buffer to reattach LSP
        end, 100)
      end
    end
  end,
})

-- You'll find a list of language servers here:
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
-- These are example language servers. 
require('lspconfig').gleam.setup({})
require('lspconfig').ocamllsp.setup({})

local cmp = require('cmp')

cmp.setup({
	sources = {
		{ name = 'nvim_lsp' },
	},
	snippet = {
		expand = function(args)
			require('luasnip').lsp_expand(args.body) -- Use only LuaSnip
		end,
	},
	mapping = cmp.mapping.preset.insert({
		-- Add keybindings for navigation and selection
		['<C-n>'] = cmp.mapping.select_next_item(),
		['<C-p>'] = cmp.mapping.select_prev_item(),
		['<CR>'] = cmp.mapping.confirm({ select = true }), -- Confirm selection
	}),
})

-- --lua lsp not working rn
-- require'lspconfig'.lua_ls.setup {
-- 	on_init = function(client)
-- 		if client.workspace_folders then
-- 			local path = client.workspace_folders[1].name
-- 			if path ~= vim.fn.stdpath('config') and (vim.loop.fs_stat(path..'/.luarc.json') or vim.loop.fs_stat(path..'/.luarc.jsonc')) then
-- 				return
-- 			end
-- 		end
--
-- 		client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
-- 			runtime = {
-- 				-- Tell the language server which version of Lua you're using
-- 				-- (most likely LuaJIT in the case of Neovim)
-- 				version = 'LuaJIT'
-- 			},
-- 			-- Make the server aware of Neovim runtime files
-- 			workspace = {
-- 				checkThirdParty = false,
-- 				library = {
-- 					vim.env.VIMRUNTIME
-- 					-- Depending on the usage, you might want to add additional paths here.
-- 					-- "${3rd}/luv/library"
-- 					-- "${3rd}/busted/library",
-- 				}
-- 				-- or pull in all of 'runtimepath'. NOTE: this is a lot slower and will cause issues when working on your own configuration (see https://github.com/neovim/nvim-lspconfig/issues/3189)
-- 				-- library = vim.api.nvim_get_runtime_file("", true)
-- 			}
-- 		})
-- 	end,
-- 	settings = {
-- 		Lua = {}
-- 	}
-- }

require('lspconfig').anakin_language_server.setup{
	cmd = { vim.fn.expand("~/anakin-language-server/anakinls")},
	filetypes = { "python" },
	settings = {
		anakin = { 
			diagnostics = { 
				enabled = true,
				disable = {},
				enable = { 
					"ImportStarNotPermitted",
					"UndefinedExport",
					"UndefinedLocal",
					"UndefinedName",
					"DuplicateArgument",
					"MultiValueRepeatedKeyLiteral",
					"MultiValueRepeatedKeyVariable",
					"FutureFeatureNotDefined",
					"LateFutureImport",
					"ReturnOutsideFunction",
					"YieldOutsideFunction",
					"ContinueOutsideLoop",
					"BreakOutsideLoop",
					"TwoStarredExpressions",
					"TooManyExpressionsInStarredAssignment",
					"ForwardAnnotationSyntaxError",
					"RaiseNotImplemented",
					"StringDotFormatExtraPositionalArguments",
					"StringDotFormatExtraNamedArguments",
					"StringDotFormatMissingArgument",
					"StringDotFormatMixingAutomatic",
					"StringDotFormatInvalidFormat",
					"PercentFormatInvalidFormat",
					"PercentFormatMixedPositionalAndNamed",
					"PercentFormatUnsupportedFormat",
					"PercentFormatPositionalCountMismatch",
					"PercentFormatExtraNamedArguments",
					"PercentFormatMissingArgument",
					"PercentFormatExpectedMapping",
					"PercentFormatExpectedSequence",
					"PercentFormatStarRequiresSequence"
				}
			}
		}
	}
}
