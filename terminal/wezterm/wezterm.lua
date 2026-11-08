--
-- ██╗    ██╗███████╗███████╗████████╗███████╗██████╗ ███╗   ███╗
-- ██║    ██║██╔════╝╚══███╔╝╚══██╔══╝██╔════╝██╔══██╗████╗ ████║
-- ██║ █╗ ██║█████╗    ███╔╝    ██║   █████╗  ██████╔╝██╔████╔██║
-- ██║███╗██║██╔══╝   ███╔╝     ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║
-- ╚███╔███╔╝███████╗███████╗   ██║   ███████╗██║  ██║██║ ╚═╝ ██║
--  ╚══╝╚══╝ ╚══════╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝
-- A GPU-accelerated cross-platform terminal emulator
-- https://wezfurlong.org/wezterm/
--
-- ============================================================================
-- WezTerm 主配置（跨平台版）
-- ----------------------------------------------------------------------------
-- 说明：
--   1. 启动时自动检测操作系统（Windows / macOS / Linux），
--      并按平台选择默认 Shell、字体、窗口装饰等设置。
--   2. 键位中的 "CMD" 修饰键是跨平台的：
--      macOS 上为 ⌘，Windows 上为 Win 键，Linux 上为 Super 键，
--      因此同一套键位无需为每个平台单独维护。
--   3. utils/ 下的模块均可按需启用（详见各文件头部注释）。
-- ============================================================================

local k = require("utils/keys")
-- 如需启用 SSH 远程域，取消下面这行注释，并在 config 中加入：
--   ssh_domains = ssh.get_ssh_domains()
-- local ssh = require("utils/ssh")
local wezterm = require("wezterm")

-- ----------------------------------------------------------------------------
-- 平台检测
--   wezterm.target_triple 常见取值：
--     x86_64-pc-windows-msvc   → Windows
--     x86_64-apple-darwin      → macOS
--     x86_64-unknown-linux-gnu → Linux
-- ----------------------------------------------------------------------------
local target_triple = wezterm.target_triple
local is_windows = target_triple:find("windows", 1, true) ~= nil
local is_macos = target_triple:find("darwin", 1, true) ~= nil
-- 其余情况（非 Windows / macOS）统一按 Linux 处理

wezterm.on("gui-startup", function(cmd) -- 启动时设置窗口初始位置
	local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
	window:gui_window():set_position(1000, 1000)
end)

local act = wezterm.action
-- 窗口默认不透明度：1.0 = 完全不透明
-- 可用 Cmd+Ctrl+T 在 1.0 与 0.9 之间切换（见 utils/helpers.lua）
local opacity = 1.0

-- ----------------------------------------------------------------------------
-- 默认 Shell：跨平台自动选择
--   Windows     → powershell.exe
--   macOS/Linux → 优先使用 $SHELL 环境变量，其次使用平台常见 shell
-- ----------------------------------------------------------------------------
local default_prog
if is_windows then
	default_prog = { "powershell.exe", "-NoLogo" }
else
	local shell = os.getenv("SHELL")
	if shell ~= nil and shell ~= "" then
		default_prog = { shell }
	elseif is_macos then
		default_prog = { "/bin/zsh" }
	else
		default_prog = { "/bin/bash" }
	end
end

-- ----------------------------------------------------------------------------
-- 字体：按平台提供回退列表（列表第一个为优先字体，未安装会自动回退）
--   Windows → JetBrainsMono Nerd Font Mono / 微软雅黑 / Segoe UI Symbol
--   macOS   → JetBrains Mono / Sarasa Term SC Nerd / SF Pro / 苹方
--   Linux   → JetBrains Mono / Noto Sans Mono CJK SC / Noto Sans CJK SC
-- ----------------------------------------------------------------------------
local font_families
if is_windows then
	font_families = {
		"JetBrainsMono Nerd Font Mono",
		"Microsoft YaHei UI",
		"Segoe UI Symbol",
	}
elseif is_macos then
	font_families = {
		"JetBrainsMono Nerd Font Mono",
		"Sarasa Term SC Nerd",
		"SF Pro",
		"PingFang SC",
	}
else
	font_families = {
		"JetBrainsMono Nerd Font Mono",
		"Noto Sans Mono CJK SC",
		"Noto Sans CJK SC",
	}
end
local fonts = {}
for _, family in ipairs(font_families) do
	table.insert(fonts, { family = family, weight = "Regular" })
end

local home_dir = os.getenv("HOME") or os.getenv("USERPROFILE")
local font_dir = home_dir and (home_dir .. "/.dotfile/assets/fonts/JetBrainsMono")
    or (wezterm.config_dir .. "/fonts")

local config = {
	-- ╭─────────────────────────────────────────────────────────╮
	-- │                         GENERAL                         │
	-- ╰─────────────────────────────────────────────────────────╯
	check_for_updates = false,      -- 关闭自动检查更新
	enable_kitty_keyboard = true,   -- 启用 Kitty 键盘协议，远程主机可使用更多快捷键
	enable_kitty_graphics = true,   -- 【必须】允许远程主机使用 Kitty 图像协议
	custom_block_glyphs = false,    -- 使用 Nerd Font 真实字形，避免图标/图片变成方框
	term = "xterm-256color",
	font_dirs = { font_dir }, -- 从 ~/.dotfile/assets/fonts/JetBrainsMono 加载内置字体
	default_prog = default_prog,    -- 见上方平台判断
	audible_bell = "Disabled",      -- 取消响铃

	-- ╭─────────────────────────────────────────────────────────╮
	-- │                       APPEARANCE                        │
	-- ╰─────────────────────────────────────────────────────────╯
	-- FONT
	font_size = 17,
	font = wezterm.font_with_fallback(fonts), -- 见上方平台判断
	line_height = 1.25,
	cell_width = 1.1,              -- 单元格横向宽度，缓解字体过窄

	-- COLOR SCHEME
	-- 固定使用 Catppuccin Mocha（深色）
	color_scheme = "Catppuccin Mocha",
	-- 如需跟随系统深浅色自动切换，改用：
	--   color_scheme = require("utils/color_scheme").get_color_scheme()
	set_environment_variables = {
		BAT_THEME = "Catppuccin-mocha", -- 让 bat 使用匹配的主题
		TERM_PROGRAM = "WezTerm",
		LC_TERMINAL = "WezTerm",
		COLORTERM = "truecolor",
	},

	-- WINDOW
	initial_cols = 127,
	initial_rows = 37,
	window_padding = {
		left = 15,
		right = 15,
		top = 15,
		bottom = 15,
	},
	adjust_window_size_when_changing_font_size = false,
	window_close_confirmation = "AlwaysPrompt", -- 关闭窗口前总是确认
	window_background_opacity = opacity,
	-- 窗口装饰：macOS 去掉标题栏并启用阴影；其他平台保留系统默认标题栏
	-- 如需在所有平台隐藏标题栏，可改为 window_decorations = "NONE"
	window_decorations = is_macos and "RESIZE | MACOS_FORCE_ENABLE_SHADOW" or "TITLE | RESIZE",

	-- TABS
	enable_tab_bar = true,
	use_fancy_tab_bar = false,
	hide_tab_bar_if_only_one_tab = true,    -- 只有一个标签时自动隐藏标签栏
	show_new_tab_button_in_tab_bar = false, -- 不显示"新建标签"按钮
	colors = {
		tab_bar = {
			background = "rgba(12%, 12%, 18%, 90%)", -- 标签栏背景
			active_tab = {
				bg_color = "#cba6f7",                 -- 当前标签背景（猫柳紫）
				fg_color = "rgba(12%, 12%, 18%, 0%)", -- 当前标签文字颜色
				intensity = "Bold",
			},
			inactive_tab = {
				fg_color = "#cba6f7",
				bg_color = "rgba(12%, 12%, 18%, 90%)",
				intensity = "Normal",
			},
			inactive_tab_hover = {
				fg_color = "#cba6f7",
				bg_color = "rgba(27%, 28%, 35%, 90%)",
				intensity = "Bold",
			},
			new_tab = {
				fg_color = "#808080",
				bg_color = "#1e1e2e",
			},
		},
	},

	-- ╭─────────────────────────────────────────────────────────╮
	-- │                          KEYS                           │
	-- ╰─────────────────────────────────────────────────────────╯
	-- 键位说明：CMD 修饰键跨平台可用（macOS ⌘ / Windows Win / Linux Super）
	keys = {
		-- F11：切换全屏
		{
			key = "F11",
			action = act.ToggleFullScreen,
		},

		-- Cmd+b：Neovim 文件树
		k.cmd_key("b", k.multiple_actions(":Neotree toggle")),
		-- Cmd+p：查找文件
		k.cmd_key("p", k.multiple_actions(":Telescope find_files")),
		-- Cmd+F：全局文本搜索
		k.cmd_key("F", k.multiple_actions(":Telescope live_grep")),
		-- Cmd+g：Lazygit（git 操作）
		k.cmd_key("g", k.multiple_actions(":LazyGitCurrentFile")),
		-- Cmd+G：git 子模块列表
		k.cmd_key("G", k.multiple_actions(":Telescope git_submodules")),
		-- Cmd+R：重新运行上次任务（Overseer）
		k.cmd_key("R", k.multiple_actions(":OverseerRestartLast")),
		-- Cmd+r：选择并运行任务（Overseer）
		k.cmd_key("r", k.multiple_actions(":OverseerRun")),
		-- Cmd+Ctrl+d：查看当前文件 git 历史（Diffview）
		k.cmd_ctrl_key("d", k.multiple_actions(":DiffviewFileHistory %")),
		-- Cmd+s：先按 Esc 退出插入模式，再执行 :w 保存
		k.cmd_key(
			"s",
			act.Multiple({
				act.SendKey({ key = "\x1b" }), -- Escape
				k.multiple_actions(":w"),
			})
		),
		-- 以下 Cmd+数字：切换到对应编号的 tmux 窗口
		k.cmd_to_tmux_prefix("1", "1"),
		k.cmd_to_tmux_prefix("2", "2"),
		k.cmd_to_tmux_prefix("3", "3"),
		k.cmd_to_tmux_prefix("4", "4"),
		k.cmd_to_tmux_prefix("5", "5"),
		k.cmd_to_tmux_prefix("6", "6"),
		k.cmd_to_tmux_prefix("7", "7"),
		k.cmd_to_tmux_prefix("8", "8"),
		k.cmd_to_tmux_prefix("9", "9"),
		-- Cmd+n / Cmd+N：tmux 分屏（" 与 % 的具体方向由 tmux 配置决定）
		k.cmd_to_tmux_prefix("n", '"'),
		k.cmd_to_tmux_prefix("N", "%"),
		-- Cmd+d：启动 tmux-sessionx
		k.cmd_to_tmux_prefix("d", "w"),
		-- Cmd+t：新建 tmux 窗口
		k.cmd_to_tmux_prefix("t", "c"),
		-- Cmd+w：关闭 tmux 窗格
		k.cmd_to_tmux_prefix("w", "x"),
		-- Cmd+z：放大/还原当前 tmux 窗格
		k.cmd_to_tmux_prefix("z", "z"),
		-- Cmd+Ctrl+t：切换窗口透明度（见 utils/helpers.lua）
		{
			key = "t",
			mods = "CMD|CTRL",
			action = wezterm.action.EmitEvent("toggle-opacity"),
		},
	},
}

-- macOS 专属设置：非 macOS 平台设置会被忽略，因此按平台单独赋值
if is_macos then
	config.macos_window_background_blur = 70   -- 窗口背景毛玻璃模糊度
	config.native_macos_fullscreen_mode = false -- 使用普通全屏而非 macOS 原生全屏
end

return config
