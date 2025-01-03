properties.Add("sb_IL_edit", {
    MenuLabel = "Редактировать Дисплей",
    Order = 2000,
    MenuIcon = "icon16/image_edit.png",

    Filter = function(self, ent, ply)
        if not IsValid(ent) then return false end
        if ent:GetClass() != "sun_display" then return false end
        return true
    end,

    Action = function(self, ent)
        if CLIENT then
            RunConsoleCommand("sb_IL_menu", ent:EntIndex())
        end
    end
})
