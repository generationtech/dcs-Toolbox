-- Testing script to dump the Lua environment
env.info('*** LUA _G API DUMP START *** ')

basicSerialize = dofile("library/basicSerialize.lua")
tableShow = dofile("library/tableShow.lua")
tableAPIShow = dofile("library/tableAPIShow.lua")
tableset = dofile("library/tableset.lua")

env.info('*** LUA _G DUMP TABLE SETUP *** ')

-- We don't want to know about these Lua system functions
local reserved_terms = tableset({
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
local ignore_terms = tableset({
    "MissionScripting_G"
  })

env.info('*** LUA TESTING TABLEAPI _G *** ')
local str = tableAPIShow(_G, reserved_terms, ignore_terms)

env.info('*** LUA TESTING TABLESHOW API *** ')
local str1 = tableShow(str, false, reserved_terms, ignore_terms)

env.info('*** LUA API DUMP OPEN FILE *** ')
local fdir = lfs.writedir() .. "tableshow.txt"
env.info(fdir)
local file,err = io.open( fdir, "wb" )
if err then return err end
file:write( str1 )
file:close()
env.info('*** LUA API DUMP END *** ')

env.info('*** LUA TESTING TABLESHOW _G *** ')
local str1 = tableShow(_G, false, reserved_terms, ignore_terms)

env.info('*** LUA _G DUMP OPEN FILE *** ')
local fdir = lfs.writedir() .. "tableshow_G.txt"
env.info(fdir)
local file,err = io.open( fdir, "wb" )
if err then return err end
file:write( str1 )
file:close()
env.info('*** LUA _G DUMP END *** ')
