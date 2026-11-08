-- ============================================================================
-- background.lua —— 窗口背景配置模块
-- ----------------------------------------------------------------------------
-- 根据系统深浅色生成一个渐变背景（深色→纯黑，浅色→纯白），并带透明度。
-- 注意：主配置目前没有加载本模块；如需启用，在 wezterm.lua 中加入：
--   config.window_background_image = require("utils/background").get_background()
-- ============================================================================
local M = {}
local h = require("utils/helpers")

-- 返回一个渐变背景对象
M.get_background = function()
        return {
                source = {
                        Gradient = {
                                colors = { h.is_dark() and "#000000" or "#ffffff" },
                        },
                },
                width = "100%",
                height = "100%",
                opacity = h.is_dark() and 0.8 or 0.85,
        }
end

return M
