-- =========================
-- 🌟 keybindings summary 🌟
-- =========================
-- <space>         : leader key
-- <leader>f       : telescope find files
-- <leader>g       : telescope live grep
-- <leader>b       : telescope buffers
-- <a-t>           : telescope open with trouble
-- =========================
-- <leader>h       : harpoon quick menu
-- <a-a>           : harpoon add file
-- <a-d>           : harpoon remove file
-- <a-1>           : harpoon select file 1
-- <a-2>           : harpoon select file 2
-- <a-3>           : harpoon select file 3
-- <a-4>           : harpoon select file 4
-- <a-5>           : harpoon select file 5
-- <a-h>           : harpoon previous file
-- <a-l>           : harpoon next file
-- <a-q>           : harpoon remove current & close buffer
-- =========================
-- <leader>o       : oil file tree
-- y (in oil)      : copy filepath to system clipboard
-- =========================
-- <leader>t       : themery colorscheme picker
-- =========================
-- <leader>d       : trouble diagnostics (buffer)
-- <leader>s       : trouble symbols
-- =========================
-- <a-d> (insert)  : copilot dismiss
-- <a-a> (insert)  : copilot accept
-- <c-d>           : copilot disable
-- <c-e>           : copilot enable
-- <c-o>           : copilotchat toggle
-- =========================
-- <leader>s       : spectre search in file
-- =========================
-- <c-c>           : comment.nvim toggle line (normal)
-- <c-C>           : comment.nvim toggle line (visual)
-- =========================
-- <tab>           : nvim-cmp next completion/snippet
-- <s-tab>         : nvim-cmp previous completion/snippet
-- <c-space>       : nvim-cmp completion menu
-- <c-e>           : nvim-cmp abort completion
-- <cr>            : nvim-cmp confirm completion

-- =========================
-- 📝 lua indent settings
-- =========================
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'lua',
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.expandtab = true
    vim.b.disable_indentexpr = true  -- disables tree-sitter indent
  end
})

-- 📏 relative line numbers
vim.opt.relativenumber = true

-- =========================
-- ⚙️ basic settings & plugins
-- =========================
-- disable netrw at the very start
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require('plugins')

-- =========================
-- 🎹 keybindings
-- =========================

-- set <space> as leader
vim.keymap.set('n', ' ', '<Nop>', { silent = true, noremap = true })
vim.g.mapleader = ' '

-- =========================
-- 🦾 LSP config (lspconfig, cmp_nvim_lsp)
-- =========================
local on_attach = function(_, bufnr)
  vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, { noremap = true, silent = true, buffer = bufnr, desc = 'LSP: go to definition' })
end

local capabilities = require('cmp_nvim_lsp').default_capabilities()

require('lspconfig')['elixirls'].setup {
  cmd = { '/home/romeos/elixir/elixir-ls/release/language_server.sh' },
  capabilities = capabilities,
  on_attach = on_attach
}

-- =========================
-- 🔭 telescope 🔭
-- =========================
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>f', builtin.find_files, { desc = 'Telescope: find files', noremap = true, silent = true })
vim.keymap.set('n', '<leader>g', builtin.live_grep, { desc = 'Telescope: live grep', noremap = true, silent = true })
vim.keymap.set('n', '<leader>b', builtin.buffers, { desc = 'Telescope: buffers', noremap = true, silent = true })

-- telescope + trouble integration
local open_with_trouble = require('trouble.sources.telescope').open
local telescope = require('telescope')
telescope.setup({
  defaults = {
    mappings = {
      i = { ['<A-t>'] = open_with_trouble },
      n = { ['<A-t>'] = open_with_trouble }
    }
  }
})

-- =========================
-- ⚓ harpoon ⚓
-- =========================
local harpoon = require('harpoon')
harpoon.setup()

vim.keymap.set('n', '<leader>h', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = 'Harpoon: quick menu', noremap = true, silent = true })
vim.keymap.set('n', '<A-a>', function() harpoon:list():add() end, { desc = 'Harpoon: add file', noremap = true, silent = true })
vim.keymap.set('n', '<A-d>', function() harpoon:list():remove() end, { desc = 'Harpoon: remove file', noremap = true, silent = true })
vim.keymap.set('n', '<A-1>', function() harpoon:list():select(1) end)
vim.keymap.set('n', '<A-2>', function() harpoon:list():select(2) end)
vim.keymap.set('n', '<A-3>', function() harpoon:list():select(3) end)
vim.keymap.set('n', '<A-4>', function() harpoon:list():select(4) end)
vim.keymap.set('n', '<A-5>', function() harpoon:list():select(5) end)
vim.keymap.set('n', '<A-h>', function() harpoon:list():prev() end, { desc = 'Harpoon: previous file', noremap = true, silent = true })
vim.keymap.set('n', '<A-l>', function() harpoon:list():next() end, { desc = 'Harpoon: next file', noremap = true, silent = true })
vim.keymap.set('n', '<A-q>', function()
  local bufname = vim.api.nvim_buf_get_name(0)
  harpoon:list():remove(bufname)
  vim.cmd('bd')
end, { desc = 'Harpoon: remove current & close buffer', noremap = true, silent = true })

-- =========================
-- 🗂️ oil (file explorer) 🗂️
-- =========================
vim.keymap.set('n', '<leader>o', ':Oil<CR>', { desc = 'Oil: file tree', noremap = true, silent = true })

function _G.get_oil_winbar()
  local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
  local dir = require('oil').get_current_dir(bufnr)
  if dir then
    return vim.fn.fnamemodify(dir, ':~')
  else
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
    end
  },
  win_options = {
    wrap = true,
    winbar = '%!v:lua.get_oil_winbar()'
  },
  keymaps = {
    ['y'] = {
      desc = 'copy filepath to system clipboard',
      callback = function ()
        require('oil.actions').copy_entry_path.callback()
        vim.fn.setreg('+', vim.fn.getreg(vim.v.register))
        print('copied to clipboard: ' .. vim.fn.getreg(vim.v.register))
      end
    }
  }
})

-- =========================
-- 🎨 themery 🎨
-- =========================
vim.keymap.set('n', '<leader>t', ':Themery<CR>', { desc = 'Themery: colorscheme picker', noremap = true, silent = true })

require('themery').setup({
  themes = {
    { name = 'space vim light', colorscheme = 'space_vim_theme', before = [[ vim.o.background = 'light' ]] },
    { name = 'tokyonight light', colorscheme = 'tokyonight-day', before = [[ vim.o.background = 'light' ]] },
    { name = 'github light', colorscheme = 'github_light', before = [[ vim.o.background = 'light' ]] },
    { name = 'space vim dark', colorscheme = 'space_vim_theme', before = [[ vim.o.background = 'dark' ]] },
    { name = 'tokyonight dark', colorscheme = 'tokyonight-night', before = [[ vim.o.background = 'dark' ]] },
    { name = 'github dark', colorscheme = 'github_dark', before = [[ vim.o.background = 'dark' ]] },
    { name = 'cyberdream dark', colorscheme = 'cyberdream', before = [[ vim.o.background = 'dark' ]] },
    { name = 'murphy', colorscheme = 'murphy', before = [[ vim.o.background = 'dark' ]] },
    { name = 'wildcharm', colorscheme = 'wildcharm', before = [[ vim.o.background = 'dark' ]] },
    { name = 'retrobox', colorscheme = 'retrobox', before = [[ vim.o.background = 'dark' ]] },
    { name = 'slate', colorscheme = 'slate', before = [[ vim.o.background = 'dark' ]] }
  },
  livePreview = true
})

-- =========================
-- 🐛 trouble 🐛
-- =========================
-- vim.keymap.set('n', '<leader>de', function() vim.diagnostic.open_float(0, {scope='line'}) end, { desc = 'Diagnostics: show float', noremap = true, silent = true })
vim.keymap.set('n', '<leader>d', '<cmd>Trouble diagnostics toggle focus=false filter.buf=0<CR>', { desc = 'Trouble: diagnostics (buffer)', noremap = true, silent = true })
vim.keymap.set('n', '<leader>s', '<cmd>Trouble symbols toggle focus=true<CR>', { desc = 'Trouble: symbols', noremap = true, silent = true })

require('trouble').setup {}

-- =========================
-- 🤖 copilot & copilotchat 🤖
-- =========================
vim.keymap.set('i', '<A-d>', '<Plug>(copilot-dismiss)', { desc = 'Copilot: dismiss' })
vim.keymap.set('i', '<A-a>', 'copilot#accept("\\<CR>")', { expr = true, replace_keycodes = false, desc = 'Copilot: accept' })
vim.g.copilot_no_tab_map = true
vim.keymap.set('n', '<C-d>', ':Copilot disable<CR>', { desc = 'Copilot: disable', noremap = true, silent = true })
vim.keymap.set('n', '<C-e>', ':Copilot enable<CR>', { desc = 'Copilot: enable', noremap = true, silent = true })
vim.keymap.set('n', '<C-o>', ':CopilotChatToggle<CR>', { desc = 'CopilotChat: toggle', noremap = true, silent = true })

require('CopilotChat').setup {}

-- =========================
-- 🔥 spectre 🔥
-- =========================
-- vim.keymap.set('n', '<leader>sp', '<cmd>lua require("spectre").toggle()<CR>', { desc = 'Spectre: toggle', noremap = true, silent = true })
vim.keymap.set('n', '<leader>s', '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', { desc = 'Spectre: search in file', noremap = true, silent = true })

-- =========================
-- 🌳 treesitter 🌳
-- =========================
require('nvim-treesitter.configs').setup {
  ensure_installed = { 'c', 'lua', 'vim', 'vimdoc', 'query', 'elixir', 'heex' },
  sync_install = false,
  auto_install = true,
  ignore_install = {},
  highlight = {
    enable = true,
    disable = {},
    disable = function(lang, buf)
      local max_filesize = 100 * 1024 -- 100 KB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
    end,
    additional_vim_regex_highlighting = false
  },
  indent = {
    enable = true
  }
}

-- =========================
-- 🧠 nvim-cmp & luasnip 🧠
-- =========================
local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end
  },
  window = {
    -- completion = cmp.config.window.bordered(),
    -- documentation = cmp.config.window.bordered()
  },
  mapping = cmp.mapping.preset.insert({
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.locally_jumpable(1) then
        luasnip.jump(1)
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true })
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' }
  })
}

-- =========================
-- 📊 lualine 📊
-- =========================
require('lualine').setup {
  options = {
    theme = 'auto'
  }
}

-- =========================
-- 💬 comment.nvim 💬
-- =========================
require('Comment').setup {
  toggler = {
    line = '<C-c>'
  },
  opleader = {
    line = '<C-C>'
  }
}

-- 📋 use system clipboard
vim.opt.clipboard = 'unnamedplus'

-- =========================
-- 🪄 ibl (indent lines) 🪄
-- =========================
local highlight = {
    'RainbowRed',
    'RainbowYellow',
    'RainbowBlue',
    'RainbowOrange',
    'RainbowGreen',
    'RainbowViolet',
    'RainbowCyan'
}

local hooks = require 'ibl.hooks'
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
-- 🚨 diagnostics (optional) 🚨
-- =========================
-- uncomment to enable inline diagnostics
-- vim.diagnostic.config({
--   virtual_text = {
--     source = 'if_many',
--     prefix = '● '
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
--     prefix = ''
--   }
-- })
-- vim.diagnostic.config({ virtual_lines = true })
-- vim.diagnostic.config({ virtual_text = true })
