-- taken from https://github.com/ecosse3/nvim/blob/master/lua/lsp/utils/filterReactDTS.lua
local M = {}

M.filterReactDTS = function(value)
  -- Depending on typescript version either uri or targetUri is returned
  if value.uri then
    return string.match(value.uri, "%.d.ts") == nil
  elseif value.targetUri then
    return string.match(value.targetUri, "%.d.ts") == nil
  end
end

return M
