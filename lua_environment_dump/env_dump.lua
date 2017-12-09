-- Testing script to dump the Lua environment


env.info('*** LUA _G DUMP START *** ')

basicSerialize = function(s)
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

tableShow = function(tbl, track, track_tbl, track_lvl, reserved_indexes, ignore_G, prefix, indent, tableshow_tbls) --based on serialize_slmod, this is a _G serialization
  tableshow_tbls = tableshow_tbls or {} --create table of tables
  prefix         = prefix or ""
  indent         = indent or ""
  track_lvl      = track_lvl or {}

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

        --add index to our tracking table if we're tracking
        if track then


          track_tbl[][][][ind] = true
        end


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
            tbl_str[#tbl_str + 1] = tostring(val)
            tbl_str[#tbl_str + 1] = ',\n'
          elseif type(val) == 'string' then
            tbl_str[#tbl_str + 1] = basicSerialize(val)
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
              tbl_str[#tbl_str + 1] = tableShow(val, reserved_indexes, ignore_G, prefix .. '[' .. basicSerialize(ind).. ']', indent .. '    ', tableshow_tbls)
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

-- turn a simple list into a key/value true table for future lookups
function tableset(t)
  local u = { }
  for _, v in ipairs(t) do u[v] = true end
  return u
end


env.info('*** LUA _G DUMP TABLE SETUP *** ')
--
-- We don't want to know about these Lua system functions
--
local syst = tableset({
    "_G",           "_ARCHITECTURE",  "_VERSION", "assert",   "collectgarbage",
    "coroutine",    "debug",          "dofile",   "error",    "gcinfo",
    "getfenv",      "getmetatable",   "io",       "ipairs",   "lfs",      "load",     "loadfile",
    "loadstring",   "log",            "math",     "module",   "newproxy",
    "next",         "os",             "package",        "pairs",    "pcall",    "print",
    "rawequal",     "rawget",         "rawset",   "require",  "select",   "setfenv",
    "setmetatable", "string",         "table",    "tonumber", "tostring",
    "type",         "unpack",         "xpcall"
  })

env.info('*** LUA TESTING TABLESHOW _G *** ')
ignore_G = tableset({ "MissionScripting_G"})
str = tableShow(_G, syst, ignore_G)

env.info('*** LUA _G DUMP OPEN FILE *** ')
fdir=lfs.writedir() .. "tableshow.txt"
env.info(fdir)
local file,err = io.open( fdir, "wb" )
if err then return err end
file:write( str )
file:close()

env.info('*** LUA _G DUMP END *** ')
