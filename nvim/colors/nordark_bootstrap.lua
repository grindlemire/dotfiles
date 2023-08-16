-- Condensed version of https://github.com/twschum/nordark.nvim to be source before plugins
local c = {
    polar_night   = {
        darker    = "#20242D", -- darker_black 1% darker than the origin
        origin    = "#232730", -- "#2E3440" -- nord0, black
        black2    = "#2a303c", -- b46 black2
        bright    = "#2E3440", -- "#3B4252" -- nord1, one_bg
        brighter  = "#3B4252", -- "#434C5E" -- nord2, one_bg2
        brightest = "#434C5E", -- "#4C566A" -- nord3, one_bg3, menu borders
        light     = "#4C566A", -- "#616E88" -- out of palette
    },
    snow_storm    = {
        origin    = "#D8DEE9", -- nord4 -- normal
        brighter  = "#E5E9F0", -- nord5
        brightest = "#ECEFF4", -- nord6
    },
    frost         = {
        polar_water = "#8FBCBB", -- nord7
        ice         = "#88C0D0", -- nord8
        artic_water = "#81A1C1", -- nord9, nord_blue
        artic_ocean = "#5E81AC", -- nord10
    },
    aurora        = {
        red    = "#BF616A", -- nord11
        orange = "#D08770", -- nord12
        yellow = "#EBCB8B", -- nord13
        green  = "#A3BE8C", -- nord14
        purple = "#B48EAD", -- nord15
    },
    backlight     = {
        red1    = "#332d36",
        yellow1 = "#373739",
    },
    none          = "NONE",
    -- extended base46 colors
    baby_pink     = "#de878f", -- lighter than aurora.red
    pink          = "#d57780", -- darker than aurora.red
    sun           = "#e1c181", -- darker than aurora.yellow
    vibrant_green = "#afca98", -- lighter than aurora.green
    blue          = "#7797b7", -- darker than frost.arctic_ocean
    teal          = "#6484a4",
    cyan          = "#9aafe6", -- brighter than frost
    dark_purple   = "#a983a2", -- darker than aurora.purble
    white         = "#abb2bf",
    grey          = "#4b515d",
    grey_fg       = "#565c68", -- comment
    grey_fg2      = "#606672",
    light_grey    = "#646a76",
    line          = "#414753", -- for lines  like vertsplit
    lightbg       = "#3f4551",
}

local global_bg = c.polar_night.origin
local transparent_bg = c.none

-- from nordark.nvim defaults
local highlights = {
    ColorColumn = { bg = c.polar_night.black2 },                                         -- used for the columns set with 'colorcolumn'
    Conceal = { fg = c.none, bg = c.none },                                              -- placeholder characters substituted for concealed text (see 'conceallevel')
    Cursor = { fg = c.snow_storm.origin, bg = c.none, reverse = true },                  -- the character under the cursor
    CursorIM = { fg = c.snow_storm.brighter, bg = c.none, reverse = true },              -- like Cursor, but used when in IME mode
    CursorColumn = { bg = c.polar_night.bright, sp = c.none },                           -- Screen-column at the cursor, when 'cursorcolumn' is set.
    CursorLine = { bg = c.polar_night.origin },                                          -- Screen-line at the cursor, when 'cursorline' is set.  Low-priority if foreground (ctermfg OR guifg) is not set.
    Directory = { fg = c.frost.ice },                                                    -- directory names (and other special names in listings)
    EndOfBuffer = { fg = c.polar_night.bright },                                         -- filler lines (~) after the end of the buffer.  By default, this is highlighted like |hl-NonText|.
    Error = { fg = c.aurora.red, bg = c.polar_night.origin },
    ErrorMsg = { fg = c.aurora.red, bg = c.backlight.red1 },                             -- error messages on the command line
    VertSplit = { fg = c.line, bg = global_bg },                                         -- the column separating vertically split windows
    WinSeparator = { fg = c.line, bg = global_bg },                                      -- Separators between window splits.
    Folded = { fg = c.snow_storm.brightest, bg = c.polar_night.bright },                 -- line used for closed folds
    FoldColumn = { fg = c.polar_night.brightest, bg = global_bg },                       -- 'foldcolumn'
    SignColumn = { fg = c.polar_night.bright, bg = transparent_bg },                     -- column where |signs| are displayed
    -- Substitute = { link = "Search" }, -- |:substitute| replacement text highlighting
    LineNr = { fg = c.grey, bg = c.none },                                               -- Line number for ":number" and ":#" commands, and when 'number' or 'relativenumber' option is set.
    CursorLineNr = { fg = c.white },                                                     -- Like LineNr when 'cursorline' or 'relativenumber' is set for the cursor line.
    MatchParen = { bg = c.polar_night.brightest, bold = true },                          -- The character under the cursor or just before it, if it is a paired bracket, and its match. |pi_paren.txt|
    ModeMsg = { fg = c.frost.artic_water },                             -- 'showmode' message (e.g., "-- INSERT -- ")
    MsgArea = { bg = c.black2 },                                                         -- Area for messages and cmdline
    MsgSeparator = {},                                                                   -- Separator for scrolled messages, `msgsep` flag of 'display'
    MoreMsg = { fg = c.frost.artic_water },                             -- |more-prompt|
    NonText = { fg = c.polar_night.brighter },                                           -- '@' at the end of the window, characters from 'showbreak' and other characters that do not really exist in the text (e.g., ">" displayed when a double-wide character doesn't fit at the end of the line). See also |hl-EndOfBuffer|.
    Normal = { fg = c.snow_storm.origin, bg = transparent_bg },                          -- normal text
    NormalFloat = { fg = c.snow_storm.origin, bg = c.polar_night.darker },               -- Normal text in floating windows.
    FloatBorder = { fg = c.polar_night.brightest, bg = c.polar_night.darker },           -- Borders of floating windows
    Pmenu = { fg = c.snow_storm.origin, bg = c.polar_night.bright },                     -- Popup menu: normal item.
    PmenuSel = { bg = c.polar_night.brighter },                                          -- Popup menu: selected item.
    PmenuSbar = { fg = c.snow_storm.origin, bg = c.polar_night.brighter },               -- Popup menu: scrollbar.
    PmenuThumb = { fg = c.frost.ice, bg = c.polar_night.brightest },                     -- Popup menu: Thumb of the scrollbar.
    Question = { fg = c.aurora.green },                                 -- |hit-enter| prompt and yes/no questions
    QuickFixLine = { fg = c.snow_storm.origin, bg = c.none, reverse = true },            -- Current |quickfix| item in the quickfix window. Combined with |hl-CursorLine| when the cursor is there.
    Search = { fg = c.frost.ice, bg = c.none, reverse = true },                          -- Last search pattern highlighting (see 'hlsearch').  Also used for similar items that need to stand out.
    IncSearch = { fg = c.snow_storm.brightest, bg = c.frost.ice },                       -- 'incsearch' highlighting; also used for the text replaced with ":s///c"
    CurSearch = { link = "IncSearch" },
    SpecialKey = { fg = c.polar_night.brightest },                                       -- Unprintable characters: text displayed differently from what it really is.  But not 'listchars' whitespace. |hl-Whitespace|
    SpellBad = { sp = c.frost.ice, undercurl = true },                                   -- Word that is not recognized by the spellchecker. |spell| Combined with the highlighting used otherwise.
    SpellCap = { sp = c.frost.artic_water, undercurl = true },                           -- Word that should start with a capital. |spell| Combined with the highlighting used otherwise.
    SpellLocal = { sp = c.frost.actic_water, undercurl = true },                         -- Word that is recognized by the spellchecker as one that is used in another region. |spell| Combined with the highlighting used otherwise.
    SpellRare = { sp = c.frost.actic_water, undercurl = true },                          -- Word that is recognized by the spellchecker as one that is hardly ever used.  |spell| Combined with the highlighting used otherwise.
    StatusLine = { fg = c.frost.ice, bg = c.polar_night.brightest },                     -- status line of current window
    StatusLineNC = { fg = c.snow_storm.origin, bg = c.polar_night.brighter },            -- status lines of not-current windows Note: if this is equal to "StatusLine" Vim will use "^^^" in the status line of the current window.
    TabLine = { fg = c.white, bg = c.polar_night.black2 },                               -- tab pages line, not active tab page label
    TabLineFill = { fg = c.polar_night.bright, bg = c.polar_night.black2 },              -- tab pages line, where there are no labels
    TabLineSel = { fg = c.snow_storm.origin, bold = true, bg = c.polar_night.brighter }, -- tab pages line, active tab page label
    Title = { fg = c.snow_storm.origin, bold = true },                                   -- titles for output from ":set all", ":autocmd" etc.
    Visual = { fg = c.none, bg = c.polar_night.brighter },                               -- Visual mode selection
    WarningMsg = { fg = c.aurora.yellow, bg = c.backlight.yellow1 },                     -- warning messages
    Whitespace = { fg = c.polar_night.brighter },                                        -- "nbsp", "space", "tab" and "trail" in 'listchars'
    WildMenu = { fg = c.frost.ice, bg = c.polar_night.bright },                          -- current match in 'wildmenu' completion
    qfLineNr = { fg = c.frost.artic_water },
    qfFileName = { fg = c.frost.ice },
    DiffAdd = { fg = c.aurora.green },     -- diff mode: Added line
    DiffChange = { fg = c.aurora.yellow }, --  diff mode: Changed line
    DiffDelete = { fg = c.aurora.red },    --  diff mode: Deleted line
    DiffText = { fg = c.frost.artic_water }, -- diff mode: Changed text within a changed line
    DiffModified = { link = "DiffChange" },
    diffAdded = { link = "DiffAdd" },
    diffChanged = { link = "DiffChange" },
    diffRemoved = { link = "DiffDelete" },
    healthError = { fg = c.aurora.red },
    healthSuccess = { fg = c.aurora.green },
    healthWarning = { fg = c.aurora.yellow },
    -- lazy.nvim highlights because lazy initializes plugins
    LazyH1 = {
        bg = c.aurora.green,
        fg = c.polar_night.origin,
    },
    LazyButton = {
        bg = c.polar_night.bright,
        fg = c.polar_night.brightest,
    },
    LazyH2 = {
        fg = c.aurora.red,
        bold = true,
        underline = true,
    },
    LazyReasonPlugin = { fg = c.aurora.red },
    LazyValue = { fg = c.teal },
    LazyDir = { fg = c.snow_storm.brighter },
    LazyUrl = { fg = c.snow_storm.brighter },
    LazyCommit = { fg = c.aurora.green },
    LazyNoCond = { fg = c.aurora.red },
    LazySpecial = { fg = c.blue },
    LazyReasonFt = { fg = c.aurora.purple },
    LazyOperator = { fg = c.white },
    LazyReasonKeys = { fg = c.teal },
    LazyTaskOutput = { fg = c.white },
    LazyCommitIssue = { fg = c.pink },
    LazyReasonEvent = { fg = c.aurora.yellow },
    LazyReasonStart = { fg = c.white },
    LazyReasonRuntime = { fg = c.frost.arctic_water },
    LazyReasonCmd = { fg = c.sun },
    LazyReasonSource = { fg = c.cyan },
    LazyReasonImport = { fg = c.white },
    LazyProgressDone = { fg = c.aurora.green },
}

-- apply all highlights
for group, hl in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, hl)
end
