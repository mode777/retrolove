return
{
    ["PlayStation"]=
    {
        ["emuPath"]=[[e:\emus\playstation\epsxe]],
        ["fileName"]=[[epsxe.exe]],
        ["extensions"]=[[DIR]],
        ["parameter"]=[[-nogui -loadbin %iso%]],
        ["romPath"]=[[e:\emus\playstation\isos]],
    }
    ,
    ["Super Nintendo Entertainment System"]=
    {
        ["emuPath"]=[[e:\emus\snes\zsnes]],
        ["fileName"]=[[zsnesw.exe]],
        ["extensions"]=[[smc fig sfc]],
        ["parameter"]=[[%romPath%\%file%]],
        ["romPath"]=[[e:\emus\snes\roms]],
    }
    ,
    ["Genesis"]=
    {
        ["emuPath"]=[[e:\emus\genesis\Fusion364]],
        ["fileName"]=[[Fusion.exe]],
        ["extensions"]=[[gen 32x]],
        ["parameter"]=[[-gen -fullscreen %romPath%\%file%]],
        ["romPath"]=[[e:\emus\genesis\roms]],
    }
    ,
    ["Sega Master System"]=
    {
        ["emuPath"]=[[e:\emus\genesis\Fusion364]],
        ["fileName"]=[[Fusion.exe]],
        ["extensions"]=[[sms sf7 mv sg]],
        ["parameter"]=[[-sms -fullscreen %romPath%\%file%]],
        ["romPath"]=[[e:\emus\mastersystem\roms]],
    }
    ,
    ["Neo Geo"]=
    {
        ["emuPath"]=[[e:\emus\neo-geo\fba]],
        ["fileName"]=[[fba.exe]],
        ["extensions"]=[[zip]],
        ["parameter"]=[[%fileNoExt%]],
        ["romPath"]=[[e:\emus\neo-geo\roms]],
    }
    ,
	["Arcade"]=
    {
        ["emuPath"]=[[e:\emus\neo-geo\fba]],
        ["fileName"]=[[fba.exe]],
        ["extensions"]=[[zip]],
        ["parameter"]=[[%fileNoExt%]],
        ["romPath"]=[[e:\emus\cps\roms]],
    }
    ,
	["Nintendo Entertainment System"]=
    {
        ["emuPath"]=[[e:\emus\nes\fceux]],
        ["fileName"]=[[fceux.exe]],
        ["extensions"]=[[nes unf]],
        ["parameter"]=[[%romPath%\%file%]],
        ["romPath"]=[[e:\emus\nes\roms]],
    }
    ,
		["TurboGrafx-16"]=
    {
        ["emuPath"]=[[e:\emus\pcengine\hugo]],
        ["fileName"]=[[hugo.exe]],
        ["extensions"]=[[pce]],
        ["parameter"]=[[%romPath%\%file%]],
        ["romPath"]=[[e:\emus\pcengine\roms]],
    }
    ,
    ["PC"]=
    {
        {["name"]=[[Rayman 2]],["path"]=[["C:\GOG Games\Rayman 2 - The Great Escape\"]],["file"]=[[Rayman2.exe]]},
        {["name"]=[[Tomb Raider 2]],["path"]=[["C:\GOG Games\Tomb Raider 1+2+3\Tomb Raider 2\"]],["file"]=[[Tomb2.exe]]},
        {["name"]=[[Heavy Metal - FAKK2]],["path"]=[["C:\Program Files\Ritual Entertainment\Heavy Metal - FAKK2\"]],["file"]=[[fakk2.exe]]},
        {["name"]=[[Baphomets Fluch - Der schlafende Drache]],["path"]=[["C:\Program Files\THQ\Baphomets Fluch - Der schlafende Drache\"]],["file"]=[[bs3pc.exe]]},
        {["name"]=[[Aquanox]],["path"]=[["C:\GOG Games\AquaNox\"]],["file"]=[[Aqua.exe]]},
        {["name"]=[[Grandia 2]],["path"]=[["C:\Program Files\Grandia2"]],["file"]=[[Grandia2.exe]]},
        {["name"]=[[Quake III Arena]],["path"]=[["C:\Program Files\Quake III Arena"]],["file"]=[[quake3.exe]]},
        {["name"]=[[American McGee's Alice]],["path"]=[["C:\Program Files\EA GAMES\American McGee's Alice"]],["file"]=[[Alice.exe]]},
        {["name"]=[[Escape from Monkey Island]],["path"]=[["C:\Program Files\LucasArts\Monkey 4"]],["file"]=[[Monkey4.exe]]},
        {["name"]=[[Grim Fandango]],["path"]=[["C:\GOG Games\Grim fan"]],["file"]=[[residualvm grim-win]]},
    }
}
