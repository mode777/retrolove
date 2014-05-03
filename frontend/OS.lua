local cm = require("engine")
local OS = {}
local ctr = 0

function OS.getFolderContents(path)
    print(path)
    local handle = io.popen("dir /b \""..path.."\"")
    local result = handle:read("*a")
    handle:close()
    local buffer = {}
    for file in result:gmatch("[^\r\n]+") do
        table.insert(buffer, file)
    end
    return pairs(buffer)
end

function OS.runExe(path, filename,parameters)
    local file = love.filesystem.newFile( "run.bat", "w" )
    local drive = path:sub(1,2)
    file:write(drive.."\r\n".."cd "..path.."\r\n\""..filename.."\" "..parameters)
    file:close()
    assert(os.execute(love.filesystem.getSaveDirectory( ).."/".."run.bat"))
end

function OS.deleteRom(Platform,Rom)
    local cfg = require("emuConf")
    assert(os.execute("del \""..cfg[Platform].romPath.."\\"..Rom.."\""))
end

function OS.runEmulator(Platform, Rom)
    local cfg = require("emuConf")
    if cfg[Platform] then
        local para = cfg[Platform].parameter
        if para:find("%%iso%%") then --asume cd-rom system folder structure
            local hierarchy = {"ccd","mds","cue","iso","img","nrg","bin" }
            local filename
            local detected
            for _,iso in OS.getFolderContents(cfg[Platform].romPath.."\\"..Rom:sub(1,-2)) do
                local extension = iso:match(".-%.(..?.?.)$")
                for i, ext in ipairs(hierarchy) do
                    if detected then if i>detected then break end end
                    if extension == ext then
                        filename = iso
                        detected = i
                    end
                end
            end
            para = para:gsub("%%iso%%","\""..cfg[Platform].romPath.."\\"..Rom:sub(1,-2).."\\"..filename.."\"")
        end
        para = para:gsub("%%romPath%%","\""..cfg[Platform].romPath)
        para = para:gsub("%%file%%",Rom.."\"")
        para = para:gsub("%%fileNoExt%%",Rom:sub(1,-5))
        cm.thread.wait(1)
        OS.runExe(cfg[Platform].emuPath, cfg[Platform].fileName, para)
        cm.thread.wait(0.5)
    else
        print("No emulator configured for "..Platform)
    end
end

function OS.shutdown()
    os.execute("shutdown /s /t 0 /f")
end

function OS.reboot()
    os.execute("shutdown /r /t 0 /f")
end

return OS