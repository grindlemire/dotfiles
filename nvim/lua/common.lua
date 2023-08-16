M = {}

--[[
    right = "",
    left = "",
    left = "",
    right = "󰞗",
]]
M.icons = {
  error = "", -- 
  warning = "", --
  hint = "",  -- 󰌶 󱠃
  info = "󰋽", --  
  other = "󰗡",

  -- compatible with 3.0.0 nerdfonts
    --error = '󰅚 ', -- x000f015a
    --warn = '󰀪 ', -- x000f002a
    --info = '󰋽 ', -- x000f02fd
    --hint = '󰌶 ', -- x000f0336
  arrow_closed = "",
  arrow_open = "",
  modified = "",
  locked = "󰌾",

  file_pos = " ",

  file = {
    default = "",
    symlink = "",
  },

  separator = {
    component = { left = "", right = "" },
    section = { left = "", right = "" },
  },

  -- names match nvim-tree icons.glyphs.folder
  folder = {
    arrow_closed = "",
    arrow_open = "",
    default = "",
    open = "",
    empty = "",
    empty_open = "",
    symlink = "",
    symlink_open = "",
  },

  -- TODO matching icons for mason
  plugin = {
    ft = "",
    lazy = "鈴 ",
    loaded = "",
    not_loaded = "",
  },

  git = {
    branch = "",
    unstaged = "󰙏", -- "", --" ",
    staged = "✓", -- "", --"", use default check
    unmerged = "",
    renamed = "➜",
    untracked = "﯏",
    deleted = "󰩺",
    ignored = "◌",
  },

  -- used with cmp
  lspkind = {
    Namespace = "",
    Text = "",
    Method = "",
    Function = "",
    Constructor = "",
    Field = "ﰠ",
    Variable = "",
    Class = "ﴯ",
    Interface = "",
    Module = "",
    Property = "ﰠ",
    Unit = "塞",
    Value = "",
    Enum = "",
    Keyword = "",
    Snippet = "",
    Color = "",
    File = "",
    Reference = "",
    Folder = "",
    EnumMember = "",
    Constant = "",
    Struct = "פּ",
    Event = "",
    Operator = "",
    TypeParameter = "",
    Table = "",
    Object = "",
    Tag = "",
    Array = "[]",
    Boolean = "",
    Number = "",
    Null = "ﳠ",
    String = "",
    Calendar = "",
    Watch = "",
    Package = "",
    Copilot = "",
  },
}

return M

--[[
	kinds = {
		Array = " ",
		Boolean = " ",
		Class = " ",
		Color = " ",
		Constant = " ",
		Constructor = " ",
		Copilot = " ",
		Enum = " ",
		EnumMember = " ",
		Event = " ",
		Field = " ",
		File = " ",
		Folder = " ",
		Function = " ",
		Interface = " ",
		Key = " ",
		Keyword = " ",
		Method = " ",
		Module = " ",
		Namespace = " ",
		Null = " ",
		Number = " ",
		Object = " ",
		Operator = " ",
		Package = " ",
		Property = " ",
		Reference = " ",
		Snippet = " ",
		String = " ",
		Struct = " ",
		Text = " ",
		TypeParameter = " ",
		Unit = " ",
		Value = " ",
		Variable = " ",
	},
--]]
