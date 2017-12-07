-- Testing script to dump the Lua environment

env.info('*** LUA _G DUMP START *** ')

basicSerialize = function(s)
  if s == nil then
    return "\"\""
  else
    if ((type(s) == 'number') or (type(s) == 'boolean') or (type(s) == 'function') or (type(s) == 'table') or (type(s) == 'userdata') ) then
      return tostring(s)
    elseif type(s) == 'string' then
      s = string.format('%q', s)
      return s
--might need to add default else for case where type is novel or undefined
    end
  end
end

tableShow = function(tbl, prefix, indent, tableshow_tbls) --based on serialize_slmod, this is a _G serialization
  tableshow_tbls = tableshow_tbls or {} --create table of tables
  prefix         = prefix or ""
  indent         = indent or ""

  if type(tbl) == 'table' then --function only works for tables!
    tableshow_tbls[tbl] = prefix

    local tbl_str = {}

    tbl_str[#tbl_str + 1] = indent .. '{\n'

    for ind,val in pairs(tbl) do -- serialize its fields
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
          tbl_str[#tbl_str + 1] = tableShow(val,  prefix .. '[' .. basicSerialize(ind).. ']', indent .. '    ', tableshow_tbls)
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

--[[
local systemf = {
    "_G",           "_ARCHITECTURE",  "_VERSION", "assert",   "collectgarbage",
    "coroutine",    "debug",          "dofile",   "error",    "gcinfo",
    "getfenv",      "getmetatable",   "ipairs",   "load",     "loadfile",
    "loadstring",   "log",            "math",     "module",   "newproxy",
    "next",         "package",        "pairs",    "pcall",    "print",
    "rawequal",     "rawget",         "rawset",   "select",   "setfenv",
    "setmetatable", "string",         "table",    "tonumber", "tostring",
    "type",         "unpack",         "xpcall"
  }

for k,v in pairs(systemf) do
  env.info(tostring(k) .. " " .. tostring(v))
end

local syst = tableset(systemf)
]]--

local syst = tableset({
    "_G",           "_ARCHITECTURE",  "_VERSION", "assert",   "collectgarbage",
    "coroutine",    "debug",          "dofile",   "error",    "gcinfo",
    "getfenv",      "getmetatable",   "ipairs",   "load",     "loadfile",
    "loadstring",   "log",            "math",     "module",   "newproxy",
    "next",         "package",        "pairs",    "pcall",    "print",
    "rawequal",     "rawget",         "rawset",   "select",   "setfenv",
    "setmetatable", "string",         "table",    "tonumber", "tostring",
    "type",         "unpack",         "xpcall"
  })

--[[
for k,v in pairs(syst) do
  env.info(tostring(k) .. " " .. tostring(v))
end
]]--

env.info('*** LUA _G DUMP SHOW_G *** ')

for k,v in pairs(_G) do
  if syst[k] == nil then
    env.info(tostring(k) .. "[" .. type(k) .. "] :  " .. tostring(v) .. "[" .. type(v) .. "]")
  end
end

--[[
env.info('*** LUA TESTING TABLESHOW _G *** ')

env.info(tableShow(_G))

str = tableShow(_G)
lines = {}
for s in str:gmatch("[^\r\n]+") do
    table.insert(lines, s)
end
for k,v in pairs(lines) do
  env.info(v)
end
]]--

env.info('*** LUA _G DUMP END *** ')
