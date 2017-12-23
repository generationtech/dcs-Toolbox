basicSerialize = function(s)
  if s == nil then
    return "\"\""
  else
    if ((type(s) == 'number') or (type(s) == 'boolean') or (type(s) == 'function') or (type(s) == 'table') or (type(s) == 'userdata') ) then
      return tostring(s)
    elseif type(s) == 'string' then
      return s
    end
  end
end

tableShow = function(tbl, prefix, indent, tableshow_tbls)
  tableshow_tbls = tableshow_tbls or {}
  prefix         = prefix or ""
  indent         = indent or ""

  if type(tbl) == 'table' then
    tableshow_tbls[tbl] = prefix

    local tbl_str = {}

    tbl_str[#tbl_str + 1] = '{\n'

    for ind,val in pairs(tbl) do -- serialize its fields
      if (prefix == "") then
      else
        if type(ind) == "number" then
          tbl_str[#tbl_str + 1] = indent
          tbl_str[#tbl_str + 1] = prefix .. '['
          tbl_str[#tbl_str + 1] = tostring(ind)
          tbl_str[#tbl_str + 1] = '] = '
        else
          tbl_str[#tbl_str + 1] = indent
          tbl_str[#tbl_str + 1] = prefix .. '['
          tbl_str[#tbl_str + 1] = basicSerialize(ind)
          tbl_str[#tbl_str + 1] = '] = '
        end

        if ((type(val) == 'number') or (type(val) == 'boolean')) then
          tbl_str[#tbl_str + 1] = tostring(val)
          tbl_str[#tbl_str + 1] = ',\n'
        elseif type(val) == 'string' then
          tbl_str[#tbl_str + 1] = basicSerialize(val)
          tbl_str[#tbl_str + 1] = ',\n'
        elseif type(val) == 'nil' then -- won't ever happen, right?
          tbl_str[#tbl_str + 1] = 'nil,\n'
        elseif type(val) == 'table' then
          if tableshow_tbls[val] then
            tbl_str[#tbl_str + 1] = tostring(val) .. ' already defined: ' .. tableshow_tbls[val] .. ',\n'
          else
            tableshow_tbls[val] = prefix ..  '[' .. basicSerialize(ind) .. ']'
            tbl_str[#tbl_str + 1] = tostring(val) .. ' '
            tbl_str[#tbl_str + 1] = tableShow(val, prefix .. '[' .. basicSerialize(ind).. ']', indent .. '    ', tableshow_tbls)
            tbl_str[#tbl_str + 1] = ',\n'
          end
        elseif type(val) == 'function' then
          if debug and debug.getinfo then
            fcnname = tostring(val)
            local info = debug.getinfo(val, "S")
            if info.what == "C" then
              tbl_str[#tbl_str + 1] = string.format('%q', fcnname .. ', C function') .. ',\n'
            else
                if info.func ~= nil then
                  f = info.func
                else
                  f = ''
                end
                  tbl_str[#tbl_str + 1] = string.format('%q', fcnname .. ', defined in (' .. info.linedefined .. '-' .. info.lastlinedefined .. ') ' .. info.source .. ' ' .. f) ..',\n'
            end

          else
            tbl_str[#tbl_str + 1] = 'a function,\n'
          end
        else
          tbl_str[#tbl_str + 1] = 'unable to serialize value type ' .. basicSerialize(type(val)) .. ' at index ' .. tostring(ind)
        end
      end
    end

    tbl_str[#tbl_str + 1] = indent .. '}'
    return table.concat(tbl_str)
  end
end
