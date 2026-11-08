-- ============================================================================
-- color_scheme.lua —— 配色方案模块
-- ----------------------------------------------------------------------------
-- 跟随系统深浅色自动切换配色：
--   深色 → Catppuccin Mocha；浅色 → Catppuccin Latte
-- 注意：主配置目前写死为 "Catppuccin Mocha"；如需自动切换，
--   在 wezterm.lua 中改为：
--   color_scheme = require("utils/color_scheme").get_color_scheme()
-- ============================================================================
local h = require("utils/helpers")
local M = {}

-- 根据系统深浅色返回对应的配色方案名称
M.get_color_scheme = function()
        return h.is_dark() and "Catppuccin Mocha" or "Catppuccin Latte"
end

return M
