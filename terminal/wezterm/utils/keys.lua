-- ============================================================================
-- keys.lua —— 键位辅助模块
-- ----------------------------------------------------------------------------
-- 提供一组生成键位条目的便捷函数，被 wezterm.lua 调用。
-- 说明：以下 "CMD" 修饰键是跨平台的：
--   macOS = ⌘ 键；Windows = Win 键；Linux = Super 键。
-- ============================================================================
local wt_action = require("wezterm").action
local M = {}

-- 把一段字符串（如 ":w"）逐字符发送到当前终端，最后补一个回车。
-- 用于模拟在 Neovim 中执行 Ex 命令；特殊字符可能需要转义。
M.multiple_actions = function(keys)
        local actions = {}
        for key in keys:gmatch(".") do
                table.insert(actions, wt_action.SendKey({ key = key }))
        end
        table.insert(actions, wt_action.SendKey({ key = "\n" }))
        return wt_action.Multiple(actions)
end

-- 生成一个标准的键位绑定条目
M.key_table = function(mods, key, action)
        return {
                mods = mods,
                key = key,
                action = action,
        }
end

-- Cmd + key（macOS ⌘ / Windows Win / Linux Super）
M.cmd_key = function(key, action)
        return M.key_table("CMD", key, action)
end

-- Cmd + Ctrl + key
M.cmd_ctrl_key = function(key, action)
        return M.key_table("CMD|CTRL", key, action)
end

-- 把 Cmd+key 映射为 tmux 前缀序列：
-- 先发送 Ctrl+空格（tmux prefix，需在 tmux 里把 prefix 设为 Ctrl+Space），
-- 再发送 tmux_key，实现分屏/切窗等操作。
M.cmd_to_tmux_prefix = function(key, tmux_key)
        return M.cmd_key(
                key,
                wt_action.Multiple({
                        wt_action.SendKey({ mods = "CTRL", key = " " }),
                        wt_action.SendKey({ key = tmux_key }),
                })
        )
end

return M
