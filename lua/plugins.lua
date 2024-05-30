return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Syntax highlight
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }

  -- Autocomplete
  use 'neovim/nvim-lspconfig'
  use 'nvim-treesitter/completion-treesitter' -- Only if you are using TS
  use 'hrsh7th/nvim-cmp' -- Autocompletion plugin
  use 'hrsh7th/cmp-nvim-lsp' -- LSP source for nvim-cmp
  use 'saadparwaiz1/cmp_luasnip' -- Snippets source for nvim-cmp
  use 'L3MON4D3/LuaSnip' -- Snippets plugin

  -- Files search
  use {
    'nvim-telescope/telescope.nvim', tag = '0.1.6',
    requires = { 'nvim-lua/plenary.nvim' }
  }

  -- copilot
  use 'github/copilot.vim'

  -- Tabs
  use 'nvim-tree/nvim-web-devicons'
  use 'romgrk/barbar.nvim'

  -- Filetree
  use 'nvim-tree/nvim-tree.lua'

  -- Statusline
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'nvim-tree/nvim-web-devicons', opt = true }
  }

  -- Git blame
  use 'f-person/git-blame.nvim'

  -- Commenting
  use 'numToStr/Comment.nvim'

  -- Theme
  use { 'catppuccin/nvim', as = 'catppuccin' }

  -- Words highlight
  use 'RRethy/vim-illuminate'

  -- Surround
  use({
    "kylechui/nvim-surround",
    tag = "*", -- Use for stability; omit to use `main` branch for the latest features
    config = function()
        require("nvim-surround").setup({
            -- Configuration here, or leave empty to use defaults
        })
    end
  })
end)
