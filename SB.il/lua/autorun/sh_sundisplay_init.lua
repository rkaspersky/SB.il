if SERVER then
    AddCSLuaFile("sundisplay/cl_menu.lua")
    AddCSLuaFile("properties/sb_IL_edit.lua")
    include("sundisplay/sv_display.lua")
else
    include("sundisplay/cl_menu.lua")
    include("properties/sb_IL_edit.lua")
end
