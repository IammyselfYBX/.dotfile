-- ============================================================================
-- helpers.lua —— 公共辅助模块
-- ----------------------------------------------------------------------------
-- 提供系统深浅色判断，以及"切换窗口透明度"事件（默认绑定 Cmd+Ctrl+T）。
-- 被 keys.lua / background.lua / color_scheme.lua 复用。
-- ============================================================================
local wezterm = require("wezterm")
local M = {}

-- 程序启动时读取一次系统外观："Dark" 或 "Light"
local appearance = wezterm.gui.get_appearance()

-- 是否处于深色模式（返回 true/false）
M.is_dark = function()
        return appearance:find("Dark") ~= nil
end

-- 切换窗口透明度事件
-- 效果：完全不透明(1.0) ⇄ 半透明(0.9)，并同步调整标签栏背景透明度
-- 注意：首次触发时当前透明度取默认值 1.0，因此第一下就会生效
wezterm.on("toggle-opacity", function(window, pane)
        local overrides = window:get_config_overrides() or {}
        -- 当前生效的透明度（没有覆盖时使用默认值 1.0）
        local current_opacity = overrides.window_background_opacity or 1.0
        if current_opacity >= 1.0 then
                -- 切换到半透明
                overrides.window_background_opacity = 0.9
                overrides.colors = {
                        tab_bar = {
                                background = "rgba(12%, 12%, 18%, 90%)",
                                active_tab = {
                                        bg_color = "#cba6f7",
                                        fg_color = "rgba(12%, 12%, 18%, 0%)",
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
                }
        else
                -- 恢复完全不透明
                overrides.window_background_opacity = 1.0
                overrides.colors = {
                        tab_bar = {
                                background = "rgba(12%, 12%, 18%, 100%)",
                                active_tab = {
                                        bg_color = "#cba6f7",
                                        fg_color = "rgba(12%, 12%, 18%, 100%)",
                                        intensity = "Bold",
                                },
                                inactive_tab = {
                                        fg_color = "#cba6f7",
                                        bg_color = "rgba(12%, 12%, 18%, 100%)",
                                        intensity = "Normal",
                                },
                                inactive_tab_hover = {
                                        fg_color = "#cba6f7",
                                        bg_color = "rgba(27%, 28%, 35%, 100%)",
                                        intensity = "Bold",
                                },
                                new_tab = {
                                        fg_color = "#808080",
                                        bg_color = "#1e1e2e",
                                },
                        },
                }
        end
        window:set_config_overrides(overrides)
end)

return M
