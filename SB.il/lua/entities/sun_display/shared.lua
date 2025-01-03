ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "SunBox Image Loader"
ENT.Author = "Kaspersky (Солнечный Sandbox)"
ENT.Category = "SB_IL"
ENT.Spawnable = true
ENT.AdminOnly = false

function ENT:CanProperty(ply)
    return IsValid(ply) and self:GetOwner() == ply  -- Allow only the owner to interact
end
