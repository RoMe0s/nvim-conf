-- =========================
-- 🌟 keybindings summary 🌟
-- =========================
-- <space>         : leader key
-- <leader>ff      : telescope find files
-- <leader>fg      : telescope live grep
-- <leader>fb      : telescope buffers
-- <leader>fj      : telescope jumplist
-- <leader>fr      : telescope registers
-- <a-t>           : telescope open with trouble
-- <a-b>           : jump back in jumplist
-- <a-n>           : jump forward in jumplist
-- =========================
-- <leader>hh      : harpoon quick menu
-- <leader>hc      : clear harpoon list
-- <a-a>           : harpoon add file
-- <a-1>           : harpoon select file 1
-- <a-2>           : harpoon select file 2
-- <a-3>           : harpoon select file 3
-- <a-4>           : harpoon select file 4
-- <a-5>           : harpoon select file 5
-- <a-h>           : harpoon previous file
-- <a-l>           : harpoon next file
-- <a-q>           : harpoon remove current & close buffer
-- =========================
-- <leader>ft      : oil file tree
-- y (in oil)      : copy relpath to system clipboard
-- Y (in oil)      : copy fullpath to system clipboard
-- =========================
-- <leader>tt      : themery colorscheme picker
-- =========================
-- <leader>d       : trouble diagnostics (buffer)
-- <leader>s       : trouble symbols
-- =========================
-- <a-d> (insert)  : copilot dismiss
-- <a-a> (insert)  : copilot accept
-- <c-d>           : copilot disable
-- <c-e>           : copilot enable
-- <a-o>           : copilotchat toggle
-- =========================
-- <leader>S       : spectre search in file
-- =========================
-- <tab>           : nvim-cmp next completion/snippet
-- <s-tab>         : nvim-cmp previous completion/snippet
-- <c-space>       : nvim-cmp completion menu
-- <c-e>           : nvim-cmp abort completion
-- <cr>            : nvim-cmp confirm completion

-- =========================
-- ⚙️ General Settings
-- =========================
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.relativenumber = true
vim.opt.clipboard = 'unnamedplus'

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'lua',
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.expandtab = true
    vim.b.disable_indentexpr = true
  end
})

-- Clear jumplist on startup
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    vim.cmd('clearjumps')
  end
})

-- Load plugins
require('plugins')

-- =========================
-- 🎹 Keybindings
-- =========================
-- Leader key
vim.keymap.set('n', ' ', '<Nop>', { silent = true, noremap = true })
vim.g.mapleader = ' '

-- Jumplist navigation
vim.keymap.set('n', '<A-b>', '<C-o>', { desc = 'Jump back in jumplist' })
vim.keymap.set('n', '<A-n>', '<C-i>', { desc = 'Jump forward in jumplist' })

-- =========================
-- 🔍 Telescope
-- =========================
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local builtin = require('telescope.builtin')
local open_with_trouble = require('trouble.sources.telescope').open

-- Keybindings
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope: find files', noremap = true, silent = true })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope: live grep', noremap = true, silent = true })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope: buffers', noremap = true, silent = true })
vim.keymap.set('n', '<leader>fj', builtin.jumplist, { desc = 'Telescope: jumplist', noremap = true, silent = true })
vim.keymap.set('n', '<leader>fr', builtin.registers, { desc = 'Telescope: registers', noremap = true, silent = true })

-- Configuration
local telescope = require('telescope')
telescope.setup({
  pickers = {
    buffers = {
      initial_mode = 'normal',
      previewer = false
    },
    jumplist = {
      initial_mode = 'normal',
      previewer = false
    },
    registers = {
      initial_mode = 'normal',
      previewer = false
    }
  },
  defaults = {
    mappings = {
      i = { ['<A-t>'] = open_with_trouble },
      n = {
        ['<A-t>'] = open_with_trouble,
        ['dd'] = function(prompt_bufnr)
          local entry = action_state.get_selected_entry()
          local bufnr = entry.bufnr
          local filename = vim.api.nvim_buf_get_name(bufnr)
          
          actions.close(prompt_bufnr)
          vim.api.nvim_buf_delete(bufnr, { force = true })
          require('harpoon'):list():remove(filename)
        end
      }
    }
  }
})

-- =========================
-- 🔖 Harpoon
-- =========================
local harpoon = require('harpoon')
harpoon.setup()

-- Keybindings
vim.keymap.set('n', '<leader>hh', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = 'Harpoon: quick menu', noremap = true, silent = true })

vim.keymap.set('n', '<leader>hc', function()
  harpoon:list():clear()
  harpoon.ui:toggle_quick_menu()
end, { desc = 'Harpoon: quick menu', noremap = true, silent = true })

vim.keymap.set('n', '<A-a>', function() harpoon:list():add() end, { desc = 'Harpoon: add file', noremap = true, silent = true })
vim.keymap.set('n', '<A-1>', function() harpoon:list():select(1) end)
vim.keymap.set('n', '<A-2>', function() harpoon:list():select(2) end)
vim.keymap.set('n', '<A-3>', function() harpoon:list():select(3) end)
vim.keymap.set('n', '<A-4>', function() harpoon:list():select(4) end)
vim.keymap.set('n', '<A-5>', function() harpoon:list():select(5) end)
vim.keymap.set('n', '<A-h>', function() harpoon:list():prev() end, { desc = 'Harpoon: previous file', noremap = true, silent = true })
vim.keymap.set('n', '<A-l>', function() harpoon:list():next() end, { desc = 'Harpoon: next file', noremap = true, silent = true })
vim.keymap.set('n', '<A-q>', function()
  local Path = require('plenary.path')
  local bufname = Path:new(vim.api.nvim_buf_get_name(0)):absolute()
  local list = harpoon:list()
  local idx_to_remove = nil

  for i, item in ipairs(list.items) do
    if Path:new(item.value):absolute() == bufname then
      idx_to_remove = i
      break
    end
  end

  -- if idx_to_remove then
  list:remove_at(idx_to_remove)
  -- end

  vim.cmd('bd')
end, { desc = 'Harpoon: remove current & close buffer', noremap = true, silent = true })

-- =========================
-- 🛢️ Oil
-- =========================
-- Keybindings
vim.keymap.set('n', '<leader>ft', ':Oil<CR>', { desc = 'Oil: file tree', noremap = true, silent = true })

-- Configuration
local oil = require('oil')

function _G.get_oil_winbar()
  local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
  local dir = oil.get_current_dir(bufnr)
  if dir then
    return vim.fn.fnamemodify(dir, ':~')
  else
    return vim.api.nvim_buf_get_name(0)
  end
end

oil.setup({
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
      desc = 'copy relative path to system clipboard',
      callback = function()
        local entry = oil.get_cursor_entry()
        local dir = oil.get_current_dir()

        if not entry or not dir then
          return
        end

        local relpath = vim.fn.fnamemodify(dir, ':.') .. entry.name

        vim.fn.setreg('+', relpath)
        print('copied to clipboard: ' .. relpath)
      end
    },
    ['Y'] = {
      desc = 'copy full path to system clipboard',
      callback = function()
        require('oil.actions').copy_entry_path.callback()
        vim.fn.setreg('+', vim.fn.getreg(vim.v.register))
        print('copied to clipboard: ' .. vim.fn.getreg(vim.v.register))
      end
    }
  }
})

-- =========================
-- 🎨 Themery
-- =========================
-- Keybindings
vim.keymap.set('n', '<leader>tt', ':Themery<CR>', { desc = 'Themery: colorscheme picker', noremap = true, silent = true })

-- Configuration
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
-- ⚠️ Trouble
-- =========================
-- Keybindings
vim.keymap.set('n', '<leader>d', '<cmd>Trouble diagnostics toggle focus=false filter.buf=0<CR>', { desc = 'Trouble: diagnostics (buffer)', noremap = true, silent = true })
vim.keymap.set('n', '<leader>s', '<cmd>Trouble symbols toggle focus=true<CR>', { desc = 'Trouble: symbols', noremap = true, silent = true })

-- Configuration
require('trouble').setup { focus = true }

-- =========================
-- 🤖 Copilot & CopilotChat
-- =========================
-- Keybindings
vim.keymap.set('i', '<A-d>', '<Plug>(copilot-dismiss)', { desc = 'Copilot: dismiss' })
vim.keymap.set('i', '<A-a>', 'copilot#Accept("\\<CR>")', { expr = true, replace_keycodes = false, desc = 'Copilot: accept' })
vim.keymap.set('n', '<C-d>', ':Copilot disable<CR>', { desc = 'Copilot: disable', noremap = true, silent = true })
vim.keymap.set('n', '<C-e>', ':Copilot enable<CR>', { desc = 'Copilot: enable', noremap = true, silent = true })
vim.keymap.set('n', '<A-o>', ':CopilotChatToggle<CR>', { desc = 'CopilotChat: toggle', noremap = true, silent = true })
vim.g.copilot_no_tab_map = true

-- Configuration
require('CopilotChat').setup {}

-- =========================
-- 🔍 Spectre
-- =========================
-- Keybindings
vim.keymap.set('n', '<leader>S', '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', { desc = 'Spectre: search in file', noremap = true, silent = true })

-- =========================
-- 💬 Comment.nvim
-- =========================
require('Comment').setup {}

-- =========================
-- 🌲 Treesitter
-- =========================
require('nvim-treesitter.configs').setup {
  ensure_installed = { 'c', 'lua', 'vim', 'vimdoc', 'query', 'elixir', 'heex' },
  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
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
-- 🔤 Completion (nvim-cmp)
-- =========================
local cmp = require('cmp')
local luasnip = require('luasnip')
cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end
  },
  window = {},
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
-- 🔌 LSP Configuration
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
-- 📊 Status Line
-- =========================
require('lualine').setup {
  options = {
    theme = 'auto'
  }
}

-- =========================
-- 📏 Indent Guides
-- =========================
-- require('ibl').setup { indent = { highlight = highlight, char = '▏' } }
--   'RainbowRed',
--   'RainbowYellow',
--   'RainbowBlue',
--   'RainbowOrange',
--   'RainbowGreen',
--   'RainbowViolet',
--   'RainbowCyan'
-- }
-- local hooks = require('ibl.hooks')
-- hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
--   vim.api.nvim_set_hl(0, 'RainbowRed', { fg = '#E06C75' })
--   vim.api.nvim_set_hl(0, 'RainbowYellow', { fg = '#E5C07B' })
--   vim.api.nvim_set_hl(0, 'RainbowBlue', { fg = '#61AFEF' })
--   vim.api.nvim_set_hl(0, 'RainbowOrange', { fg = '#D19A66' })
--   vim.api.nvim_set_hl(0, 'RainbowGreen', { fg = '#98C379' })
--   vim.api.nvim_set_hl(0, 'RainbowViolet', { fg = '#C678DD' })
--   vim.api.nvim_set_hl(0, 'RainbowCyan', { fg = '#56B6C2' })
-- end)
-- require('ibl').setup { indent = { highlight = highlight, char = '▏' } }

-- =========================
-- 🚨 Diagnostics (optional)
-- =========================
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
