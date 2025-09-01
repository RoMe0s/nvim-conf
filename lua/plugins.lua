return require('packer').startup(function(use)
  -- 🧩 Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- 🌲 Syntax highlighting via Treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }

  -- ⚡ Autocompletion setup
  use 'neovim/nvim-lspconfig'                          -- LSP configuration
  use 'nvim-treesitter/completion-treesitter'          -- Treesitter-based completion (if using TS)
  use 'hrsh7th/nvim-cmp'                               -- Core completion plugin
  use 'hrsh7th/cmp-nvim-lsp'                           -- LSP source for nvim-cmp
  use 'saadparwaiz1/cmp_luasnip'                       -- LuaSnip source for nvim-cmp
  use 'L3MON4D3/LuaSnip'                               -- Snippet engine

  -- 🔍 Fuzzy file search
  use {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    requires = { 'nvim-lua/plenary.nvim' }
  }

  -- 🔁 File content replacement
  use 'nvim-pack/nvim-spectre'

  -- 🤖 GitHub Copilot integration
  use 'github/copilot.vim'
  use 'CopilotC-Nvim/CopilotChat.nvim'                 -- Optional Copilot chat interface

  -- 📁 Tabs and devicons
  use 'nvim-tree/nvim-web-devicons'                    -- Icons for UI elements
  -- use 'romgrk/barbar.nvim'                          -- Optional tabline plugin

  use {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    requires = { 'nvim-lua/plenary.nvim' }
  }

  -- 🌳 File explorer
  -- use 'nvim-tree/nvim-tree.lua'                     -- Optional tree-based file explorer
  use {
    'stevearc/oil.nvim',
    requires = {
      'nvim-tree/nvim-web-devicons',
      'echasnovski/mini.icons'
    }
  }

  -- 📊 Statusline
  use {
    'nvim-lualine/lualine.nvim',
    requires = {
      'nvim-tree/nvim-web-devicons',
      opt = true
    }
  }

  -- 🕵️ Git blame annotations
  use 'f-person/git-blame.nvim'

  -- 💬 Comment toggling
  use 'numToStr/Comment.nvim'

  -- 🎨 Themes
  use 'zaldih/themery.nvim'                            -- Theme switcher
  use 'liuchengxu/space-vim-theme'                     -- SpaceVim-inspired theme
  use 'scottmckendry/cyberdream.nvim'                  -- Cyberpunk-style theme
  use 'folke/tokyonight.nvim'                          -- Popular Tokyo Night theme
  use 'projekt0n/github-nvim-theme'                    -- GitHub-inspired theme

  -- ❗ Diagnostics and error navigation
  use 'folke/trouble.nvim'

  -- 📏 Indentation guides
  -- use 'lukas-reineke/indent-blankline.nvim'
end)
