local common = require("common")

-- TODO: tabline: https://github.com/rafcamlet/tabline-framework.nvim

-- from https://github.com/NvChad/ui/blob/v2.0/lua/nvchad_ui/statusline/default.lua
local function cwd()
  local dir_name = "  " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t") .. " "
  return (vim.o.columns > 85 and (common.icons.folder.empty_open .. dir_name)) or ""
end

local function nonstandard_encoding()
  local ret, _ = (vim.bo.fenc or vim.go.enc):gsub("^utf%-8$", "")
  return ret
end

-- fileformat: Don't display if &ff is unix.
local function nonstandard_fileformat()
  local ret, _ = vim.bo.fileformat:gsub("^unix$", "")
  return ret
end

-- from: https://github.com/nvim-lualine/lualine.nvim/blob/master/lua/lualine/components/filename.lua
---shortens path by turning apple/orange -> a/orange
---@param path string
---@param sep string path separator
---@param max_len integer maximum length of the full filename string
---@return string
local function shorten_path(path, sep, max_len)
  local len = #path
  if len <= max_len then
    return path
  end
  local segments = vim.split(path, sep)
  for idx = 1, #segments - 1 do
    if len <= max_len then
      break
    end
    local segment = segments[idx]
    local shortened = segment:sub(1, vim.startswith(segment, ".") and 2 or 1)
    segments[idx] = shortened
    len = len - (#segment - #shortened)
  end
  return table.concat(segments, sep)
end

local function fileInfo()
  local icon = "" --
  -- name only:  "%:t"
  -- absolute path, with tilde '%:p:~'
  -- relative path, %:~:.
  local filename = (vim.fn.expand("%") == "" and "Empty ") or vim.fn.expand("%:t")

  if filename ~= "Empty " then
    local devicons_present, devicons = pcall(require, "nvim-web-devicons")
    if devicons_present then
      local ft_icon = devicons.get_icon(filename)
      icon = (ft_icon ~= nil and " " .. ft_icon) or ""
    end
    -- get path TODO shorten target?
    --filename = vim.fn.expand("%:h:~") .. "/" .. "%#Bold#" .. filename
    filename = vim.fn.expand("%:~:.")

    -- Modification symbols
    if vim.bo.modified then
      filename = filename .. " " .. common.icons.modified
    end
    if vim.bo.modifiable == false or vim.bo.readonly == true then
      filename = filename .. " " .. common.icons.locked
    end
  end
  return " " .. icon .. " " .. filename -- .. "  " .. vim.fn.expand("%:t") -- .. "  "  ..
end

-- LSP STUFF TODO Workspace root?
local function LSP_progress()
  if not rawget(vim, "lsp") then
    return ""
  end
  local Lsp = vim.lsp.util.get_progress_messages()[1]
  if vim.o.columns < 120 or not Lsp then
    return ""
  end

  local msg = Lsp.message or ""
  local percentage = Lsp.percentage or 0
  local title = Lsp.title or ""
  local spinners = { "", "󰪞", "󰪟", "󰪠", "󰪢", "󰪣", "󰪤", "󰪥" }
  local ms = vim.loop.hrtime() / 1000000
  local frame = math.floor(ms / 120) % #spinners
  local content = string.format(" %%<%s %s %s (%s%%%%) ", spinners[frame + 1], title, msg, percentage)
  local max_len = 80
  if max_len then
    content = string.sub(content, 1, max_len)
  end

  --return ("%#lualine_b_diff_added_normal#" .. "" .. content .. "%#lualine_x_normal#" .. "") or ""
  return content or ""
end

local function LSP_status()
  if rawget(vim, "lsp") then
    for _, client in ipairs(vim.lsp.get_active_clients()) do
      if client.attached_buffers[vim.api.nvim_get_current_buf()] and client.name ~= "null-ls" then
        -- LSP symbols   󰒍 󰙅
        return (vim.o.columns > 100 and " 󰙅 LSP ~ " .. client.name .. " ") or " 󰙅  LSP "
      end
    end
  end
  return ""
end

return {
  {
    "folke/tokyonight.nvim",
    enabled = false,
    priority = 1000,
    lazy = false,
    config = function()
      require("tokyonight").setup({
        -- your configuration comes here
        -- or leave it empty to use the default settings
        style = "night",        -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
        transparent = false,    -- Enable this to disable setting the background color
        terminal_colors = true, -- Configure the colors used when opening a `:terminal` in Neovim
        styles = {
          -- Style to be applied to different syntax groups
          -- Value is any valid attr-list value for `:help nvim_set_hl`
          comments = { italic = false },
          keywords = { italic = false },
          functions = {},
          variables = {},
          -- Background styles. Can be "dark", "transparent" or "normal"
          sidebars = "dark",         -- style for sidebars, see below
          floats = "dark",           -- style for floating windows
        },
        sidebars = { "qf", "help" }, -- Set a darker background on sidebar-like windows. For example: `["qf", "vista_kind", "terminal", "packer"]`
      })
      vim.cmd([[colorscheme tokyonight]])
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    lazy = false,
    dependencies = {
      { "nvim-tree/nvim-web-devicons", opt = true },
    },
    config = function()
      -- disable the builtin message
      vim.opt.showmode = false
      require("lualine").setup({
        options = {
          globalstatus = true, -- single, global statusline
          icons_enabled = true,
          --theme = "nord",
          -- theme = "tokyonight",
          theme = "nordark",
          component_separators = common.icons.separator.component,
          section_separators = common.icons.separator.section,
          disabled_filetypes = {
            statusline = {},
            winbar = {},
          },
          ignore_focus = {},
          always_divide_middle = true,
        },
        sections = {
          lualine_a = {
            { "mode", icon = "" },
          },
          lualine_b = { { "branch", icon = common.icons.git.branch }, "diff", "diagnostics" },
          lualine_c = {
            --[[
                        { "filename",
                            newfile_status = true,
                            -- 0: Just the filename
                            -- 1: Relative path
                            -- 2: Absolute path
                            -- 3: Absolute path, with tilde as the home directory
                            -- 4: Filename and parent dir, with tilde as the home directory
                            path = 1,
                            symbols = {
                                modified = " " .. common.icons.modified,
                                readonly = " " .. common.icons.locked,
                            },
                        },
                        ]]
            fileInfo,
          },
          lualine_x = {
            {
              LSP_progress,
              color = "lualine_b_diff_added_normal",
              -- this is janky to make it show up as a "new" section
              separator = {
                left = common.icons.separator.section.right,
                right = common.icons.separator.section.left,
              },
            },
            { LSP_status, },
            "lazy",
            "filetype",
            {
              nonstandard_encoding,
              --separator = "",
            },
            nonstandard_fileformat,
          },
          lualine_y = { "progress", "location" },
          lualine_z = { cwd },
        },
        inactive_sections = {
          -- not in use with globalstatus=true
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
        tabline = {},
        --[[tabline = {
                    lualine_a = {},
                    lualine_b = {
                        {
                            "tabs",
                            symbols = {
                                modified = ' ',     -- Text to show when the buffer is modified
                                alternate_file = '󰘵 ', -- Text to show to identify the alternate file
                                directory = '',     -- Text to show when the buffer is a directory
                            },
                            mode = 1,                  -- 0: Shows tab_nr 1: Shows tab_name 2: Shows tab_nr + tab_name
                            tabs_color = {
                                -- Same values as the general color option can be used here.
                                active = 'lualine_c_normal',                  -- Color for active buffer.
                                inactive = 'lualine_c_inactive', -- Color for inactive buffer.
                            },
                            fmt = function(name, context)
                                -- Show + if buffer is modified in tab
                                local buflist = vim.fn.tabpagebuflist(context.tabnr)
                                local winnr = vim.fn.tabpagewinnr(context.tabnr)
                                local bufnr = buflist[winnr]
                                local mod = vim.fn.getbufvar(bufnr, '&mod')
                                return name .. (mod == 1 and ' ' or '')
                            end
                        },
                    },
                    lualine_c = { { function() return " " end, color = "ColorColumn" } },
                    lualine_x = { { function() return " " end, color = "ColorColumn" } },
                    lualine_y = {},
                    lualine_z = { "tabs" }
                },
                --]]
        winbar = {},
        inactive_winbar = {},
        extensions = { "lazy" },
      })
    end,
  },
}
