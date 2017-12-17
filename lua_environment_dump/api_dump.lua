-- Testing script to dump the Lua environment


env.info('*** LUA _G API DUMP START *** ')

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

tableShow = function(tbl, api, reserved_indexes, ignore_G, prefix, indent, tableshow_tbls) --based on serialize_slmod, this is a _G serialization
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




-- Looking to determine unique API keys, not enumerate all data
tableAPIShow = function(tbl, reserved_indexes, ignore_G, tbl_track) --based on serialize_slmod, this is a _G serialization
  tbl_track = tbl_track or {}

--  env.info("table: " .. tostring(tbl))
  if type(tbl) == 'table' then

    -- If all children are tables, test them for commonality.
    local parent_table_flag = true
    for ind,val in pairs(tbl) do
      if type(val) ~= 'table' then
        parent_table_flag = false
        break
      end
    end

    -- if all children are table type, check each of them for subordinate commonality
    local api_flag = false
    if parent_table_flag == true then
--      env.info("found parent: " .. tostring(tbl))
      local child_table = {}
      local child_table_flag = false
      api_flag = true
      for ind,val in pairs(tbl) do -- loop through the top-level indexes again
        for sub_ind,sub_val in pairs(val) do -- For each child table, store the names of the indexes
          if child_table_flag == false then -- First time though, create starting template view of typical child table
            child_table[sub_ind] = true -- Store the indexes as a template table
          elseif child_table[sub_ind] == nil then -- Otherwise, test this child table compared to the reference template
--            env.info("compare failed, breaking loop1")
            api_flag = false
            break
          end
        end
        if api_flag == false then -- need to break out of nested loop
--          env.info("compare failed, breaking loop2")
          api_flag = false
          break
        end
        child_table_flag = true
      end
    else
--      env.info("not found parent: " .. tostring(tbl))
    end

    if api_flag == true then -- If everything gets to here, then this level is an API with matching child tables below
      env.info("FOUND: " .. tostring(tbl))
      local ind_save = nil
      for ind,val in pairs(tbl) do
        env.info("FOUND PARENT: " .. tostring(ind))
        if ind_save == nil then
          ind_save = val
        end
      end
      tableAPIShow(ind_save, reserved_indexes, ignore_G)
    else -- This level is not an API level, determine how to process otherwise
      for ind,val in pairs(tbl) do
        if ignore_G[ind] ~= nil then
          env.info("index part of ignore list, value is therefore ignored")
        else
          if type(val) == 'table' then
            if tbl_track[val] then -- Have we already recursed this table?

            else
              tbl_track[val] = true
              tableAPIShow(val, reserved_indexes, ignore_G, tbl_track)
            end
          else -- The children are not tables, they are values

          end
--          env.info("recurse returned")
        end
      end
    end
  end
end

-- turn a simple list into a key/value true table for future lookups
function tableset(t)
  local u = { }
  for _, v in ipairs(t) do u[v] = true end
  return u
end


env.info('*** LUA _G DUMP TABLE SETUP *** ')

-- We don't want to know about these Lua system functions
local syst = tableset({
    "_G",
    "_ARCHITECTURE",
    "_VERSION",
    "assert",
    "collectgarbage",
    "coroutine",
    "debug",
    "dofile",
    "error",
    "gcinfo",
    "getfenv",
    "getmetatable",
    "io",
    "ipairs",
    "lfs",
    "load",
    "loadfile",
    "loadstring",
    "log",
    "math",
    "module",
    "newproxy",
    "next",
    "os",
    "package",
    "pairs",
    "pcall",
    "print",
    "rawequal",
    "rawget",
    "rawset",
    "require",
    "select",
    "setfenv",
    "setmetatable",
    "string",
    "table",
    "tonumber",
    "tostring",
    "type",
    "unpack",
    "xpcall"
  })

-- These indexex will not be recursed
local ignore_G = tableset({
    "MissionScripting_G"
  })

env.info('*** LUA TESTING TABLEAPI _G *** ')
local str = tableAPIShow(_G, syst, ignore_G)

env.info('*** LUA TESTING TABLESHOW _G *** ')
local str1 = tableShow(_G, false, syst, ignore_G)

env.info('*** LUA _G DUMP OPEN FILE *** ')
local fdir = lfs.writedir() .. "tableshow.txt"
env.info(fdir)
local file,err = io.open( fdir, "wb" )
if err then return err end
file:write( str1 )
file:close()

env.info('*** LUA _G API DUMP END *** ')
