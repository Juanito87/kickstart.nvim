local M = {}

function M.generate(provider_name) return require('plugins_config.ai_explain').explain_visual(provider_name) end

return M
