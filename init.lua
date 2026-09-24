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

-- Leader must be set before lazy loads plugins
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.softtabstop = -1 -- follow shiftwidth
vim.opt.shiftwidth = 0 -- follow tabstop
vim.opt.undofile = true -- keep undo history after closing a file
vim.opt.ignorecase = true
vim.opt.smartcase = true -- case-sensitive search only when the pattern has capitals
vim.opt.scrolloff = 8
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.updatetime = 250
vim.opt.signcolumn = "yes"

-- WSL clipboard
vim.g.clipboard = {
	name = "WslClipboard",
	copy = {
		["+"] = "clip.exe",
		["*"] = "clip.exe",
	},
	paste = {
		["+"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
		["*"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
	},
	cache_enabled = 0,
}
vim.opt.clipboard = "unnamedplus"

vim.diagnostic.config({
	virtual_text = true, -- show errors at the end of the line
	severity_sort = true,
	float = { border = "rounded" },
})

-- Plugins
require("lazy").setup({
	spec = {
		-- Colorschemes (only tokyonight loads at startup; `:colorscheme gruvbox` etc. still works)
		{ "folke/tokyonight.nvim", lazy = false, priority = 1000 },
		{ "rose-pine/neovim", name = "rose-pine", lazy = true },
		{ "ellisonleao/gruvbox.nvim", lazy = true },

		-- Navigation
		{ "nvim-telescope/telescope.nvim", branch = "master", dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		} },
		{ "ThePrimeagen/harpoon", branch = "harpoon2", dependencies = { "nvim-lua/plenary.nvim" } },
		{ "mbbill/undotree" },
		{ "folke/which-key.nvim", event = "VeryLazy", opts = {} }, -- shows available keys after you press <leader>

		-- Syntax
		{ "nvim-treesitter/nvim-treesitter", branch = "main", build = ":TSUpdate" },

		-- LSP, completion, formatting
		{ "mason-org/mason.nvim", lazy = false, opts = {} }, -- :Mason installs language servers/formatters
		{ "neovim/nvim-lspconfig" },
		{ "lopi-py/luau-lsp.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
		{ "hrsh7th/nvim-cmp" },
		{ "hrsh7th/cmp-nvim-lsp" },
		{ "hrsh7th/cmp-buffer" },
		{ "hrsh7th/cmp-path" },
		{ "saadparwaiz1/cmp_luasnip" },
		{ "L3MON4D3/LuaSnip" },
		{ "stevearc/conform.nvim" },

		-- Editing / git
		{ "numToStr/Comment.nvim", opts = {} },
		{ "lewis6991/gitsigns.nvim", opts = {} },

		{ "ThePrimeagen/vim-be-good" },
	},
	checker = { enabled = true, notify = false },
})

-- Colorscheme
require("tokyonight").setup({
	transparent = true,
	styles = {
		sidebars = "transparent",
		floats = "transparent",
	},
	on_highlights = function(hl, c)
		hl["@keyword.import.rust"] = { fg = c.orange }
		hl.Function = { fg = c.red }
		hl["@function"] = { fg = c.red }
		hl["@function.call"] = { fg = c.red }
		hl["@function.method"] = { fg = c.red }
		hl["@function.method.call"] = { fg = c.red }
	end,
})
vim.cmd("colorscheme tokyonight-moon")

-- General keymaps
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Undotree" })
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "File explorer" })
vim.keymap.set("n", "<leader>py", ":!python3 %<CR>", { desc = "Run python file" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic" })
vim.keymap.set("n", "<leader><leader>", "<C-^>", { desc = "Alternate file" })
vim.keymap.set("n", "<leader>o", "<C-o>", { desc = "Jump back" })
vim.keymap.set("n", "<leader>i", "<C-i>", { desc = "Jump forward" })

-- Telescope
local telescope = require("telescope")
telescope.setup({})
telescope.load_extension("fzf")

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fs", function()
	builtin.grep_string({ use_regex = false })
end, { desc = "Grep word under cursor" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<leader>/", builtin.current_buffer_fuzzy_find, { desc = "Search buffer" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })

-- Harpoon 2
local harpoon = require("harpoon")
harpoon:setup({ settings = { save_on_toggle = true } }) -- q/Esc in the menu also saves edits

-- All harpoon keys act on the active list; <leader>H switches it
local harpoon_list_name = nil -- nil = default list
local function harpoon_list() return harpoon:list(harpoon_list_name) end

vim.keymap.set("n", "<leader>a", function() harpoon_list():add() end, { desc = "Harpoon add file" })
vim.keymap.set("n", "<leader>h", function() harpoon.ui:toggle_quick_menu(harpoon_list()) end, { desc = "Harpoon menu" })
for i = 1, 5 do
	vim.keymap.set("n", "<leader>" .. i, function() harpoon_list():select(i) end, { desc = "Harpoon file " .. i })
end
vim.keymap.set("n", "<leader>H", function()
	vim.ui.select({ "default", "server", "client", "shared" }, { prompt = "Harpoon list" }, function(choice)
		if choice then
			harpoon_list_name = choice ~= "default" and choice or nil
			print("Harpoon list: " .. choice)
		end
	end)
end, { desc = "Harpoon switch list" })

-- Treesitter
require("nvim-treesitter").install({ "rust", "lua", "python", "vim", "bash", "json", "markdown", "luau" })
vim.api.nvim_create_autocmd("FileType", {
	callback = function(args)
		pcall(vim.treesitter.start, args.buf)
	end,
})

-- Formatting (F3 or on save)
require("conform").setup({
	formatters_by_ft = {
		luau = { "stylua" },
		lua = { "stylua" },
		python = { "ruff_format" },
		rust = { "rustfmt" },
	},
	format_on_save = { timeout_ms = 1000, lsp_format = "fallback" },
})

-- LSP
-- Built-in LSP keymaps you get for free: grr = references, gri = implementation,
-- grn = rename, gra = code action, gO = document symbols, K = hover, <C-s> (insert) = signature help
vim.lsp.config("*", {
	capabilities = require("cmp_nvim_lsp").default_capabilities(),
})

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "LSP actions",
	callback = function(event)
		local function map(keys, fn, desc)
			vim.keymap.set("n", keys, fn, { buffer = event.buf, desc = desc })
		end

		map("gd", vim.lsp.buf.definition, "Go to definition")
		map("gD", vim.lsp.buf.declaration, "Go to declaration")
		map("go", vim.lsp.buf.type_definition, "Go to type definition")
		map("gs", vim.lsp.buf.signature_help, "Signature help")
		map("<F2>", vim.lsp.buf.rename, "Rename")
		vim.keymap.set({ "n", "x" }, "<F3>", function()
			require("conform").format({ async = true, lsp_format = "fallback" })
		end, { buffer = event.buf, desc = "Format" })
		map("<F4>", vim.lsp.buf.code_action, "Code action")
	end,
})

-- Roblox / Luau: luau-lsp.nvim manages Roblox types and regenerates sourcemap.json with rojo
require("luau-lsp").setup({
	platform = { type = "roblox" },
	sourcemap = {
		enabled = true,
		autogenerate = true,
		rojo_project_file = "default.project.json",
	},
})

-- Only start servers that are actually installed (install more with :Mason)
for _, server in ipairs({ "pyright", "rust_analyzer", "gleam", "ocamllsp" }) do
	local cmd = vim.lsp.config[server] and vim.lsp.config[server].cmd
	if type(cmd) == "table" and vim.fn.executable(cmd[1]) == 1 then
		vim.lsp.enable(server)
	end
end

-- Completion
local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
	sources = {
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "path" },
		{ name = "buffer", keyword_length = 3 },
	},
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-n>"] = cmp.mapping.select_next_item(),
		["<C-p>"] = cmp.mapping.select_prev_item(),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
	}),
	experimental = {
		ghost_text = true,
	},
})
