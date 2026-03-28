-- =============================================================================
-- ~/.config/nvim/lua/config/theme.lua
-- Carica il tema dal file auto-generato da theme-switch.sh
-- =============================================================================

local M = {}

-- Mappa nome tema → pacchetto lazy/plugin
local theme_map = {
  tokyonight = {
    plugin = "folke/tokyonight.nvim",
    setup = function(variant)
      require("tokyonight").setup({
        style = variant or "night",
        transparent = false,
        terminal_colors = true,
        styles = {
          comments    = { italic = true },
          keywords    = { italic = true },
          functions   = {},
          variables   = {},
          sidebars    = "dark",
          floats      = "dark",
        },
        on_highlights = function(hl, colors)
          -- Personalizzazioni aggiuntive
          hl.TelescopeNormal = { bg = colors.bg_dark }
          hl.TelescopeBorder = { fg = colors.blue, bg = colors.bg_dark }
        end,
      })
    end,
  },

  catppuccin = {
    plugin = "catppuccin/nvim",
    setup = function(variant)
      require("catppuccin").setup({
        flavour         = variant or "mocha",
        transparent_background = false,
        term_colors     = true,
        integrations = {
          cmp       = true,
          gitsigns  = true,
          nvimtree  = true,
          treesitter = true,
          telescope = { enabled = true },
          which_key = true,
          mini      = { enabled = true },
        },
      })
    end,
  },

  ["rose-pine"] = {
    plugin = "rose-pine/neovim",
    setup = function(variant)
      require("rose-pine").setup({
        variant         = variant or "main",
        dark_variant    = "main",
        dim_inactive_windows = false,
        extend_background_behind_borders = true,
      })
    end,
  },

  gruvbox = {
    plugin = "ellisonleao/gruvbox.nvim",
    setup = function(_)
      require("gruvbox").setup({
        contrast    = "hard",
        bold        = true,
        italic      = { strings = true, emphasis = true, comments = true },
        strikethrough = true,
        invert_selection = false,
      })
    end,
  },

  nord = {
    plugin = "shaunsingh/nord.nvim",
    setup = function(_)
      vim.g.nord_contrast           = true
      vim.g.nord_borders            = false
      vim.g.nord_disable_background = false
      vim.g.nord_italic             = true
      vim.g.nord_bold               = true
    end,
  },
}

-- ---------------------------------------------------------------------------
-- Legge il tema corrente dal file generato da theme-switch.sh
-- ---------------------------------------------------------------------------
function M.get_current()
  local ok, data = pcall(require, "config.current-theme")
  if ok and data then
    return data.colorscheme or "tokyonight", data.variant or "night"
  end
  return "tokyonight", "night"
end

-- ---------------------------------------------------------------------------
-- Applica il tema
-- ---------------------------------------------------------------------------
function M.apply()
  local colorscheme, variant = M.get_current()
  local entry = theme_map[colorscheme]

  if not entry then
    vim.notify("Theme Switcher: tema '" .. colorscheme .. "' non trovato", vim.log.levels.WARN)
    vim.cmd.colorscheme("default")
    return
  end

  -- Chiama setup se disponibile
  local ok, _ = pcall(entry.setup, variant)
  if not ok then
    vim.notify("Theme Switcher: errore setup per " .. colorscheme, vim.log.levels.ERROR)
  end

  -- Applica il colorscheme
  local ok2, err = pcall(vim.cmd.colorscheme, colorscheme)
  if not ok2 then
    vim.notify("Theme Switcher: colorscheme error: " .. err, vim.log.levels.ERROR)
  end
end

-- ---------------------------------------------------------------------------
-- Lista tutti i temi disponibili (per il picker interno)
-- ---------------------------------------------------------------------------
function M.list()
  local result = {}
  for name, _ in pairs(theme_map) do
    table.insert(result, name)
  end
  table.sort(result)
  return result
end

-- ---------------------------------------------------------------------------
-- Picker interno con Telescope (opzionale)
-- ---------------------------------------------------------------------------
function M.telescope_picker()
  local ok, telescope = pcall(require, "telescope.builtin")
  if not ok then
    vim.notify("Telescope non trovato", vim.log.levels.WARN)
    return
  end

  local themes = M.list()
  require("telescope.pickers").new({}, {
    prompt_title = "🎨 Scegli tema",
    finder = require("telescope.finders").new_table({ results = themes }),
    sorter = require("telescope.config").values.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      local actions = require("telescope.actions")
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = require("telescope.actions.state").get_selected_entry()
        if selection then
          -- Applica solo in neovim (non esegue lo script bash)
          local entry = theme_map[selection[1]]
          if entry then
            pcall(entry.setup, nil)
            pcall(vim.cmd.colorscheme, selection[1])
          end
        end
      end)
      return true
    end,
  }):find()
end

return M
