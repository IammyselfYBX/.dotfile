-- ============================================================================
-- ssh.lua —— SSH 远程域配置模块
-- ----------------------------------------------------------------------------
-- 定义 WezTerm 可直接连接的 SSH 域（新建标签页时可选择）。
-- remote_address 引用 ~/.ssh/config 里的 Host 别名，
-- 因此 ProxyCommand、IdentityFile 等配置会自动生效。
-- 注意：主配置目前未启用本模块；如需启用：
--   1) wezterm.lua 中取消注释 local ssh = require("utils/ssh")
--   2) 在 config 中加入 ssh_domains = ssh.get_ssh_domains()
-- ============================================================================
local M = {}

-- 返回 SSH 域列表
M.get_ssh_domains = function()
        return {
                {
                        name = "ws186",
                        remote_address = "ws186", -- 对应 ~/.ssh/config 中的 Host 别名
                        multiplexing = "None",    -- 每次连接新建进程，不依赖远程 wezterm-mux-server
                },
                {
                        name = "jlubastion",
                        remote_address = "jlubastion",
                        multiplexing = "None",
                },
        }
end

return M
