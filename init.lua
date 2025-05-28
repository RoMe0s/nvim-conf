-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require('plugins')

-- map leader to <Space>
vim.keymap.set('n', ' ', '<Nop>', { silent = true, remap = false })
vim.g.mapleader = ' '

require('nvim-treesitter.configs').setup {
  -- A list of parser names, or 'all' (the five listed parsers should always be installed)
  ensure_installed = { 'c', 'lua', 'vim', 'vimdoc', 'query', 'elixir', 'heex' },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,

  -- List of parsers to ignore installing (or 'all')
  ignore_install = { },

  ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
  -- parser_install_dir = '/some/path/to/store/parsers', -- Remember to run vim.opt.runtimepath:append('/some/path/to/store/parsers')!

  highlight = {
    enable = true,

    -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
    -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
    -- the name of the parser)
    -- list of language that will be disabled
    disable = { },
    -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
    disable = function(lang, buf)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
            return true
        end
    end,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },

  indent = {
    -- change this to false
    enable = true
  }
}

local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup {
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      luasnip.lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  window = {
    -- completion = cmp.config.window.bordered(),
    -- documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.locally_jumpable(1) then
        luasnip.jump(1)
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
    -- ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    -- ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources(
    {
      { name = 'nvim_lsp' },
      { name = 'luasnip' }, -- For luasnip users.
    }
  )
}

-- Set up lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities()

local on_attach = function(_, bufnr)
  vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, { noremap=true, silent=true, buffer=bufnr })
end

-- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
require('lspconfig')['elixirls'].setup {
  cmd = { '/home/romeos/elixir/elixir-ls/release/language_server.sh' },
  capabilities = capabilities,
  on_attach = on_attach
}

-- Files search
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
-- Search over files
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
-- List buffers
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })


-- Tab management
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Move to previous/next
map('n', '<A-j>', '<Cmd>BufferPrevious<CR>', opts)
map('n', '<A-l>', '<Cmd>BufferNext<CR>', opts)
-- Close buffer
map('n', '<A-q>', '<Cmd>BufferClose<CR>', opts)
-- Reorder tabs
map('n', '<A-,>', '<Cmd>BufferMovePrevious<CR>', opts)
map('n', '<A-.>', '<Cmd>BufferMoveNext<CR>', opts)

-- File tree
require('nvim-tree').setup {
  view = { adaptive_size = true }
}

vim.keymap.set('n', '<leader>ft', ':NvimTreeFindFile<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>fq', ':NvimTreeClose<CR>', { noremap = true, silent = true })

-- Statusline
require('lualine').setup {
  options = {
    -- theme = 'onelight'
    theme = 'auto'
  }
}

-- Comment
require('Comment').setup {
  toggler = {
    ---Line-comment toggle keymap
    line = '<C-c>'
  },
  ---LHS of operator-pending mappings in NORMAL and VISUAL mode
  opleader = {
    ---Line-comment keymap
    line = '<C-C>'
  }
}

-- use system clipboard
vim.opt.clipboard = 'unnamedplus'

-- Copilot
vim.keymap.set('i', '<M-d>', '<Plug>(copilot-dismiss)')
vim.keymap.set('i', '<M-a>', 'copilot#Accept("\\<CR>")', { expr = true, replace_keycodes = false })
vim.g.copilot_no_tab_map = true

vim.keymap.set('n', '<C-D>', ':Copilot disable<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-E>', ':Copilot enable<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-O>', ':CopilotChatToggle<CR>', { noremap = true, silent = true })

require("CopilotChat").setup {
  -- See Configuration section for options
}

-- Colorschemes preview
require("themery").setup({
  themes = {
    "space_vim_theme",
    "shine",
    "murphy",
    "onedark",
  },
  themes = {
    {
      name = "Space vim dark",
      colorscheme = "space_vim_theme",
      before = [[
        vim.o.background = "dark"
      ]],
    },
    {
      name = "Space vim light",
      colorscheme = "space_vim_theme",
      before = [[
        vim.o.background = "light"
      ]],
    },
    {
      name = "Cyberdream dark",
      colorscheme = "cyberdream",
      before = [[
        vim.o.background = "dark"
      ]],
    },
    {
      name = "Murphy",
      colorscheme = "murphy",
      before = [[
	vim.o.background = "dark"
      ]],
    },
  },
  liverPreview = true,
})

-- Errors
require('trouble').setup {}
-- Show	diagnostics in Trouble
vim.keymap.set('n', '<leader>dd', '<Cmd>Trouble diagnostics toggle focus=false filter.buf=0<CR>', { noremap = true, silent = true })
-- Show	symbols list in Trouble
vim.keymap.set('n', '<leader>ds', '<Cmd>Trouble symbols toggle focus=true<CR>', { noremap = true, silent = true })

-- Open Telescope results in Trouble
local actions = require("telescope.actions")
local open_with_trouble = require("trouble.sources.telescope").open

-- Use this to add more results without clearing the trouble list
local add_to_trouble = require("trouble.sources.telescope").add

local telescope = require("telescope")

telescope.setup({
  defaults = {
    mappings = {
      i = { ["<c-t>"] = open_with_trouble },
      n = { ["<c-t>"] = open_with_trouble },
    },
  },
})
