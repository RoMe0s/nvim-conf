-- Lua indent
-- Disable Tree-sitter indent for Lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.expandtab = true
    vim.b.disable_indentexpr = true  -- disables Tree-sitter indent
  end,
})

-- Relative line numbers
vim.opt.relativenumber = true

-- =========================
-- Basic Settings & Plugins
-- =========================

-- Disable netrw at the very start
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require('plugins')

-- =========================
-- Keybindings
-- =========================

-- Set <Space> as leader
vim.keymap.set('n', ' ', '<Nop>', { silent = true, remap = false })
vim.g.mapleader = ' '

-- LSP keybindings (set in on_attach as well)
local on_attach = function(_, bufnr)
  vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, { noremap=true, silent=true, buffer=bufnr })
end

-- Telescope
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })

-- Tab management (Bufferline)
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
-- map('n', '<A-h>', '<Cmd>BufferPrevious<CR>', opts)
-- map('n', '<A-l>', '<Cmd>BufferNext<CR>', opts)
-- map('n', '<A-q>', '<Cmd>BufferClose<CR>', opts)
-- map('n', '<A-,>', '<Cmd>BufferMovePrevious<CR>', opts)
-- map('n', '<A-.>', '<Cmd>BufferMoveNext<CR>', opts)

-- map('n', '<A-,>', '<Cmd>BufferMovePrevious<CR>', opts)
-- map('n', '<A-.>', '<Cmd>BufferMoveNext<CR>', opts)

-- Harpoon (file marking and quick navigation)
local harpoon = require("harpoon")
harpoon.setup()

-- basic telescope configuration
local conf = require("telescope.config").values
local function toggle_telescope(harpoon_files)
    local file_paths = {}
    for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
    end

    require("telescope.pickers").new({}, {
        prompt_title = "Harpoon",
        finder = require("telescope.finders").new_table({
            results = file_paths,
        }),
        previewer = conf.file_previewer({}),
        sorter = conf.generic_sorter({}),
    }):find()
end

vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
vim.keymap.set("n", "<leader>d", function() harpoon:list():remove() end)

vim.keymap.set("n", "<leader>h", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

vim.keymap.set("n", "<A-h>", function() harpoon:list():prev() end)
vim.keymap.set("n", "<A-l>", function() harpoon:list():next() end)
vim.keymap.set("n", "<A-q>", function()
  local bufname = vim.api.nvim_buf_get_name(0)
  harpoon:list():remove(bufname)
  vim.cmd("bd")
end)
-- map('n', '<A-h>', '<Cmd>bprevious<CR>', opts)
-- map('n', '<A-l>', '<Cmd>bnext<CR>', opts)
-- map('n', '<A-q>', '<Cmd>bdelete<CR>', opts)

-- File tree (nvim-tree)
vim.keymap.set('n', '<leader>ft', ':Oil<CR>', { noremap = true, silent = true })

-- vim.keymap.set('n', '<leader>ft', ':NvimTreeFindFile<CR>', { noremap = true, silent = true })
-- vim.keymap.set('n', '<leader>fq', ':NvimTreeClose<CR>', { noremap = true, silent = true })

-- Themery (colorscheme preview)
vim.keymap.set('n', '<leader>tt', ':Themery<CR>', { noremap = true, silent = true })

-- Trouble (diagnostics and symbols)
vim.keymap.set('n', '<leader>de', '<Cmd>:lua vim.diagnostic.open_float(0, {scope="line"})<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>dd', '<Cmd>Trouble diagnostics toggle focus=false filter.buf=0<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>ds', '<Cmd>Trouble symbols toggle focus=true<CR>', { noremap = true, silent = true })

-- Copilot
vim.keymap.set('i', '<M-d>', '<Plug>(copilot-dismiss)')
vim.keymap.set('i', '<M-a>', 'copilot#Accept("\\<CR>")', { expr = true, replace_keycodes = false })
vim.g.copilot_no_tab_map = true
vim.keymap.set('n', '<C-D>', ':Copilot disable<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-E>', ':Copilot enable<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-O>', ':CopilotChatToggle<CR>', { noremap = true, silent = true })

-- =========================
-- Treesitter
-- =========================

require('nvim-treesitter.configs').setup {
  ensure_installed = { 'c', 'lua', 'vim', 'vimdoc', 'query', 'elixir', 'heex' },
  sync_install = false,
  auto_install = true,
  ignore_install = { },
  highlight = {
    enable = true,
    disable = { },
    disable = function(lang, buf)
      local max_filesize = 100 * 1024 -- 100 KB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
    end,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true
  }
}

-- =========================
-- Completion (nvim-cmp)
-- =========================

local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
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
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  })
}

-- =========================
-- LSP Config
-- =========================

local capabilities = require('cmp_nvim_lsp').default_capabilities()

require('lspconfig')['elixirls'].setup {
  cmd = { '/home/romeos/elixir/elixir-ls/release/language_server.sh' },
  capabilities = capabilities,
  on_attach = on_attach
}

-- =========================
-- Plugin Setups
-- =========================

-- nvim-tree
-- require('nvim-tree').setup {
--   view = { adaptive_size = true }
-- }

-- Declare a global function to retrieve the current directory
function _G.get_oil_winbar()
  local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
  local dir = require("oil").get_current_dir(bufnr)
  if dir then
    return vim.fn.fnamemodify(dir, ":~")
  else
    -- If there is no current directory (e.g. over ssh), just show the buffer name
    return vim.api.nvim_buf_get_name(0)
  end
end

require('oil').setup({
        default_file_explorer = true,
        delete_to_trash = true,
        skip_confirm_for_simple_edits = true,
        view_options = {
          show_hidden = true,
          natural_order = true,
          is_always_hidden = function(name, _)
            return name == '..' or name == '.git'
          end,
        },
        win_options = {
          wrap = true,
          winbar = "%!v:lua.get_oil_winbar()",
        },
  keymaps = {
    ['Y'] = {
        desc = 'Copy filepath to system clipboard',
        callback = function ()
      require('oil.actions').copy_entry_path.callback()
      vim.fn.setreg("+", vim.fn.getreg(vim.v.register))
      print("Copied to clipboard: " .. vim.fn.getreg(vim.v.register))
        end,
    },
  }
})

-- harpoon
-- harpoon = require('harpoon')
-- harpoon.setup()
-- vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
-- vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

-- lualine
require('lualine').setup {
  options = {
    theme = 'auto'
  },
}

-- Comment.nvim
require('Comment').setup {
  toggler = {
    line = '<C-c>'
  },
  opleader = {
    line = '<C-C>'
  }
}

-- Use system clipboard
vim.opt.clipboard = 'unnamedplus'

-- CopilotChat
require("CopilotChat").setup {}

-- Themery (colorscheme preview)
require("themery").setup({
  themes = {
    {
      name = "Space vim light",
      colorscheme = "space_vim_theme",
      before = [[ vim.o.background = "light" ]],
    },
    {
      name = "Tokyonight light",
      colorscheme = "tokyonight-day",
      before = [[ vim.o.background = "light" ]],
    },
    {
      name = "Github light",
      colorscheme = "github_light",
      before = [[ vim.o.background = "light" ]],
    },
    {
      name = "Space vim dark",
      colorscheme = "space_vim_theme",
      before = [[ vim.o.background = "dark" ]],
    },
    {
      name = "Tokyonight dark",
      colorscheme = "tokyonight-night",
      before = [[ vim.o.background = "dark" ]],
    },
    {
      name = "Github dark",
      colorscheme = "github_dark",
      before = [[ vim.o.background = "dark" ]],
    },
    {
      name = "Cyberdream dark",
      colorscheme = "cyberdream",
      before = [[ vim.o.background = "dark" ]],
    },
    {
      name = "Murphy",
      colorscheme = "murphy",
      before = [[ vim.o.background = "dark" ]],
    },
    {
      name = "Wildcharm",
      colorscheme = "wildcharm",
      before = [[ vim.o.background = "dark" ]],
    },
    {
      name = "Retrobox",
      colorscheme = "retrobox",
      before = [[ vim.o.background = "dark" ]],
    },
    {
      name = "Slate",
      colorscheme = "slate",
      before = [[ vim.o.background = "dark" ]],
    },
  },
  liverPreview = true,
})

-- Trouble
require('trouble').setup {}

-- Telescope + Trouble integration
local actions = require("telescope.actions")
local open_with_trouble = require("trouble.sources.telescope").open
local add_to_trouble = require("trouble.sources.telescope").add
local telescope = require("telescope")
telescope.setup({
  defaults = {
    mappings = {
      i = { ["<M-t>"] = open_with_trouble },
      n = { ["<M-t>"] = open_with_trouble },
    },
  },
})

-- Spectre
vim.keymap.set('n', '<leader>sp', '<cmd>lua require("spectre").toggle()<CR>', {desc = "Toggle Spectre"})
vim.keymap.set('n', '<leader>sf', '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', {desc = "Search on current file"})

-- Indent lines
local highlight = {
    'RainbowRed',
    'RainbowYellow',
    'RainbowBlue',
    'RainbowOrange',
    'RainbowGreen',
    'RainbowViolet',
    'RainbowCyan',
}

local hooks = require 'ibl.hooks'
-- create the highlight groups in the highlight setup hook, so they are reset
-- every time the colorscheme changes
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
    vim.api.nvim_set_hl(0, 'RainbowRed', { fg = '#E06C75' })
    vim.api.nvim_set_hl(0, 'RainbowYellow', { fg = '#E5C07B' })
    vim.api.nvim_set_hl(0, 'RainbowBlue', { fg = '#61AFEF' })
    vim.api.nvim_set_hl(0, 'RainbowOrange', { fg = '#D19A66' })
    vim.api.nvim_set_hl(0, 'RainbowGreen', { fg = '#98C379' })
    vim.api.nvim_set_hl(0, 'RainbowViolet', { fg = '#C678DD' })
    vim.api.nvim_set_hl(0, 'RainbowCyan', { fg = '#56B6C2' })
end)

require('ibl').setup { indent = { highlight = highlight, char = '▏' } }

-- =========================
-- Diagnostics (optional)
-- =========================

-- Uncomment to enable inline diagnostics
-- vim.diagnostic.config({
--   virtual_text = {
--     source = "if_many",
--     prefix = '● ',
--   },
--   update_in_insert = true,
--   underline = true,
--   severity_sort = true,
--   float = {
--     focusable = false,
--     style = 'minimal',
--     border = 'rounded',
--     source = 'if_many',
--     header = '',
--     prefix = '',
--   },
-- })
-- vim.diagnostic.config({ virtual_lines = true })
-- vim.diagnostic.config({ virtual_text = true })
