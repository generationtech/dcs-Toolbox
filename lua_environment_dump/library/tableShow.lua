return function(tbl, api, reserved_indexes, ignore_G, prefix, indent, tableshow_tbls) --based on serialize_slmod, this is a _G serialization
  tableshow_tbls = tableshow_tbls or {} --create table of tables
  prefix         = prefix or ""
  indent         = indent or ""

  if type(tbl) == 'table' then --function only works for tables!
    tableshow_tbls[tbl] = prefix

    local tbl_str = {}

-- removed indent for opening braces
--    tbl_str[#tbl_str + 1] = indent .. '{\n'
    tbl_str[#tbl_str + 1] = '{\n'

    for ind,val in pairs(tbl) do -- serialize its fields

      -- don't explore _G data for obvious stuff (like standard Lua functions/features)
      if ((prefix == "") and (reserved_indexes[ind])) then
      else

        if type(ind) == "number" then
  -- is this section redundant with following section because basicSerialize already handles number type in the same manner?
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

        if ignore_G[ind] ~= nil then
          tbl_str[#tbl_str + 1] = "index part of ignore list, value is therefore ignored\n"
        else
          if ((type(val) == 'number') or (type(val) == 'boolean')) then
    --same here. this might also be redundant to next block due to same functionality of basicSerialize
            if (api ~= true) then
              tbl_str[#tbl_str + 1] = tostring(val)
            end
            tbl_str[#tbl_str + 1] = ',\n'
          elseif type(val) == 'string' then
            if (api ~= true) then
              tbl_str[#tbl_str + 1] = basicSerialize(val)
            end
            tbl_str[#tbl_str + 1] = ',\n'
          elseif type(val) == 'nil' then -- won't ever happen, right?
            tbl_str[#tbl_str + 1] = 'nil,\n'
          elseif type(val) == 'table' then
            if tableshow_tbls[val] then
    --let's add some kind of alert for if this possibility actually occurs
              tbl_str[#tbl_str + 1] = tostring(val) .. ' already defined: ' .. tableshow_tbls[val] .. ',\n'
            else
              tableshow_tbls[val] = prefix ..  '[' .. basicSerialize(ind) .. ']'
              tbl_str[#tbl_str + 1] = tostring(val) .. ' '
    --recurces here
              tbl_str[#tbl_str + 1] = tableShow(val, api, reserved_indexes, ignore_G, prefix .. '[' .. basicSerialize(ind).. ']', indent .. '    ', tableshow_tbls)
              tbl_str[#tbl_str + 1] = ',\n'
            end
          elseif type(val) == 'function' then
            if debug and debug.getinfo then
              fcnname = tostring(val)
              local info = debug.getinfo(val, "S")
              if info.what == "C" then
                tbl_str[#tbl_str + 1] = string.format('%q', fcnname .. ', C function') .. ',\n'
              else
    --						if (string.sub(info.source, 1, 2) == [[./]]) then
    --tbl_str[#tbl_str + 1] = string.format('%q', fcnname .. ', defined in (' .. info.linedefined .. '-' .. info.lastlinedefined .. ')' .. info.source) ..',\n'
                  if info.func ~= nil then
                    f = info.func
                  else
                    f = ''
                  end
                    tbl_str[#tbl_str + 1] = string.format('%q', fcnname .. ', defined in (' .. info.linedefined .. '-' .. info.lastlinedefined .. ') ' .. info.source .. ' ' .. f) ..',\n'
    --[[
                else
                  tbl_str[#tbl_str + 1] = string.format('%q', fcnname .. ', defined in (' .. info.linedefined .. '-' .. info.lastlinedefined .. ')') ..',\n'
                end
    ]]--
              end

            else
              tbl_str[#tbl_str + 1] = 'a function,\n'
            end
          else
    --not cool, watch for any of this
            tbl_str[#tbl_str + 1] = 'unable to serialize value type ' .. basicSerialize(type(val)) .. ' at index ' .. tostring(ind)
          end
        end
      end
    end --for ind,val in pairs(tbl) do

    tbl_str[#tbl_str + 1] = indent .. '}'
    return table.concat(tbl_str)
  end  --if type(tbl) == 'table' then
end
