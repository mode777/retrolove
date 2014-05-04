local scene = {}

local function writeAPI()
    local buffer = {}
    local function add(str) table.insert(buffer,str) end
    for name,module in pairs(cine) do
        if module.new then
            local classname = name
            add(classname.." = {}\r\n")
            local instance = module.new()
            for funcname in pairs(instance) do
                add("function "..classname..":"..funcname.."() end\r\n")
            end
            add("\r\n")
        end
        add("module('cine."..name.."')\r\n")
        for funcname in pairs(module) do
            if funcname ~="_DOC" then add("function "..funcname.."() end\r\n") end
        end
        local str = table.concat(buffer)
        cine.serialize.saveString(str, "module_"..name..".lua")
        buffer = {}
    end
    print("Created documentation")
end

local function markdown(filename)
    local buffer = {}
    local sections = {}
    local function add(str) table.insert(buffer,str) end
    local i = {}
    function i:newSection(str)
        table.insert(sections,{name=str,blocks={}})
        add(string.format("##%s\r\n",str))
    end
    function i:newBlock(name,desc,usage,para,ret)
        add(string.format("####%s\r\n",name))
        if desc then add(string.format("%s\r\n",desc)) end
        add(string.format("\r\n**Usage**\r\n\r\n    %s\r\n",usage))
        if #para > 0 then
            add("\r\n**Arguments**\r\n\r\n")
            for i,v in ipairs(para) do
                add(string.format("`%s` %s: %s\r\n\r\n",v[1],v[2],v[3] or ""))
            end
        end
        if #ret > 0 then
            add("\r\n**Returns**\r\n\r\n")
            for i,v in ipairs(ret) do
                add(string.format("`%s` %s: %s\r\n\r\n",v[1],v[2],v[3] or ""))
            end
        end
        add("\r\n---\r\n")
        table.insert(sections[#sections].blocks,name)
    end

    function i:newParagraph(str)


    end

    function i:getString()
        local str = table.concat(buffer)
        str = str:gsub("%%(.-)%%",function(c) return string.format("[`%s`](cine.%s)",c,c) end)
        return str
    end

    function i:generateTOC()
        local tocbuffer = {}
        local function addToc(str) table.insert(tocbuffer,str) end
        addToc("## Table of contents\r\n")
        for num, data in ipairs(sections) do
            local linkname = data.name:gsub("[^%w]","")
            linkname = "#wiki-"..linkname:lower()
            addToc(string.format("%d. [%s](%s)\r\n",num,data.name,linkname))
            for _,name in ipairs(data.blocks) do
                local linkname = name:gsub("[^%w]","")
                linkname = "#wiki-"..linkname:lower()
                addToc(string.format(" * [%s](%s)\r\n",name,linkname))
            end
        end
        addToc("\r\n")
        table.insert(buffer,1,table.concat(tocbuffer))
    end

    function i:save()
        local str= self:getString()
        cine.serialize.saveString(str, filename..".md")
    end

    return i
end



local function createDocumentation(doclet)
    local function formatUsage(str, para, ret)
        local sRet, sPara = "",""
        for i,v in ipairs(para) do sPara=sPara..v[2] if i < #para then sPara=sPara.."," end end
        for i,v in ipairs(ret) do sRet=sRet..v[2] if i < #ret then sRet=sRet..", " else sRet=sRet.." = " end end
        return string.format(str,sRet,sPara)
    end
    for name,module in pairs(cine) do
        if module._DOC then
            print("Documentation found for module "..name)
            local document = doclet("cine."..name)
            local doc = module._DOC
            document:newSection("Functions")
            for func,content in pairs(doc) do
                if func ~= "new" then
                    local desc, para, ret = content[1], content[2] or {}, content[3] or {}
                    local usage = formatUsage("%scine."..name.."."..func.."(%s)",para,ret)
                    document:newBlock("cine."..name.."."..func,desc,usage,para,ret)
                end
            end
            if doc.new then
                local content = doc.new
                document:newSection("Constructor")
                local desc, para, ret = content[1], content[2] or {}, content[3] or {}
                local usage = formatUsage("%scine."..name..".new(%s)",para,ret)
                document:newBlock("cine."..name..".new",desc,usage,para,ret)
                if content.methods then
                    document:newSection("Methods")
                    for func,content in pairs(content.methods) do
                        local desc, para, ret = content[1], content[2] or {}, content[3] or {}
                        local usage = formatUsage("%s`"..name.."`:"..func.."(%s)",para,ret)
                        document:newBlock("`"..name.."`:"..func,desc,usage,para,ret)
                    end
                end
            end
            document:generateTOC()
            document:save()
            --document.newSection("Constructor")
        end
    end
end

function scene:onLoad()
    createDocumentation(markdown)
    love.event.quit()
 --initialize your scene here
end

function scene:onUpdate()
    --update your scene here.
end

function scene:onStop()
    --define what is going to happen when your scene stops
end

return scene