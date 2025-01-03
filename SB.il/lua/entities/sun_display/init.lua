AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/hunter/plates/plate1x1.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end
end

function ENT:UpdateTransmitState()
    return TRANSMIT_ALWAYS
end

function ENT:SetDisplayURL(url)
    self:SetNWString("DisplayURL", url)
end

function ENT:SetDisplaySize(width, height)
    self:SetNWInt("DisplayWidth", width)
    self:SetNWInt("DisplayHeight", height)
end

function ENT:Use(activator, caller)
    return
end
