-- Looking to determine unique API keys, not enumerate all data
return function(tbl, index_reserved, index_ignored, table_track)
  table_track = table_track or {}
  local table_api = {}

--  env.info("table: " .. tostring(tbl))
  if type(tbl) == 'table' then

    -- If all children are tables, test them for commonality.
    local parent_table_flag = true
    for ind,val in pairs(tbl) do
      if index_reserved[ind] ~= nil then
      else
        if type(val) ~= 'table' then
          parent_table_flag = false
          break
        end
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
        if index_reserved[ind] ~= nil then
        else
          for sub_ind,sub_val in pairs(val) do -- For each child table, store the names of the indexes
            if index_reserved[sub_ind] ~= nil then
            else
              if child_table_flag == false then -- First time though, create starting template view of typical child table
                child_table[sub_ind] = true -- Store the indexes as a template table
              elseif child_table[sub_ind] == nil then -- Otherwise, test this child table compared to the reference template
    --            env.info("compare failed, breaking loop1")
                api_flag = false
                break
              end
            end
          end
          if api_flag == false then -- need to break out of nested loop
  --          env.info("compare failed, breaking loop2")
            break
          end
          child_table_flag = true
        end
        if api_flag == false then -- need to break out of nested loop
--          env.info("compare failed, breaking loop2")
          break
        end
      end
    else
--      env.info("not found parent: " .. tostring(tbl))
    end

    if api_flag == true then
      -- If everything gets to here, then this level is an API with matching child tables below
      env.info("API TABLE: " .. tostring(tbl))
--      local ind_save = nil
      for ind,val in pairs(tbl) do
        if index_reserved[ind] ~= nil then
        else
          env.info("API LABEL: " .. tostring(ind))
          if table_api["api"] == nil then
            table_api["api"] = {}
          end
--          env.info("recurse on api")
          table_api["api"][ind] = tableAPIShow(val, index_reserved, index_ignored, table_track)
--          env.info("returned from recurse on api")
        end
      end
    else
      -- This level is not an API level, determine how to process otherwise
      for ind,val in pairs(tbl) do
        if index_ignored[ind] ~= nil then
          env.info("index part of ignore list, value is therefore ignored")
        else
          if index_reserved[ind] ~= nil then
          else
            if type(val) == 'table' then
              if table_track[val] ~= nil then -- Have we already recursed this table?

              else
                table_track[val] = true
                if table_api["table"] == nil then
                  table_api["table"] = {}
                end
--                env.info("recurse on table")
                table_api["table"][ind] = tableAPIShow(val, index_reserved, index_ignored, table_track)
--                env.info("returned from recurse on table")
              end
            else -- The children are not tables, they are values
              if table_api["value"] == nil then
                table_api["value"] = {}
              end
              table_api["value"][ind] = val
            end
  --          env.info("recurse returned")
          end
        end
      end
    end
  else
    -- It's not a table, just return it.
    -- Probably never use this portion because it's caught on upper level recurse and not called
    return tbl
  end
--  env.info("returning table_api")
  return table_api
end
