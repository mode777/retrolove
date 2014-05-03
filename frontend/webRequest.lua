local http = require("socket.http")
local socket = require("socket")
local ltn12 = require("ltn12")
local filesystem = require("love.filesystem")

local R_IN = love.thread.getChannel("webRequestIN")
local R_OUT = love.thread.getChannel("webRequestOUT")
local W_IN = love.thread.getChannel("webDownloadIN")
local W_OUT = love.thread.getChannel("webDownloadOUT")

while true do
    if R_IN:getCount() > 0 then
        local strg = R_IN:pop()
        local result = http.request(strg)
        R_OUT:push({strg,result})
    end
    if W_IN:getCount() > 0 then
        local input = W_IN:pop()
        local strg,file = input[1],input[2]
        local myFile = filesystem.newFile(file)
        --myFile:open("w+b")
        myFile:open("w")
        --Request remote file and save data to local file
        local message
        http.request{
            url = strg,
            sink = ltn12.sink.file(myFile,message),
        }
        if message then error(message) end
        myFile:close()
        R_OUT:push(file)
    end
end