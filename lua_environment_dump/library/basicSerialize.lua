return function(s)
  if s == nil then
    return "\"\""
  else
    if ((type(s) == 'number') or (type(s) == 'boolean') or (type(s) == 'function') or (type(s) == 'table') or (type(s) == 'userdata') ) then
      return tostring(s)
    elseif type(s) == 'string' then
-- removed quotations from strings for better readability
--      s = string.format('%q', s)
      return s
--might need to add default else for case where type is novel or undefined
    end
  end
end
