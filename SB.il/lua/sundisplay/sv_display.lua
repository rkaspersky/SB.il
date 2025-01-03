AddCSLuaFile()

util.AddNetworkString("SB_IL_CreateDisplay")
util.AddNetworkString("SB_IL_UpdateDisplay")

net.Receive("SB_IL_CreateDisplay", function(len, ply)
    if not IsValid(ply) then return end
    
    local url = net.ReadString()
    local width = net.ReadUInt(16)
    local height = net.ReadUInt(16)

    local display = ents.Create("sun_display")
    if not IsValid(display) then return end
    
    local tr = ply:GetEyeTrace()
    display:SetPos(tr.HitPos)
    display:SetAngles(tr.HitNormal:Angle())
    display:SetOwner(ply)
    display:Spawn()
    
    display:SetDisplayURL(url)
    display:SetDisplaySize(width, height)
    
    undo.Create("SB_IL")
        undo.AddEntity(display)
        undo.SetPlayer(ply)
    undo.Finish()
end)

net.Receive("SB_IL_UpdateDisplay", function(len, ply)
    if not IsValid(ply) then return end
    
    local ent = net.ReadEntity()
    if not IsValid(ent) or not ent:CanProperty(ply) then return end
    
    local url = net.ReadString()
    local width = net.ReadUInt(16)
    local height = net.ReadUInt(16)
    
    ent:SetDisplayURL(url)
    ent:SetDisplaySize(width, height)
end)
