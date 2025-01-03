local function ValidateURL(url)
    if string.match(url, "https?://cdn%.discordapp%.com/attachments/[%d]+/[%d]+/[%w-_%.%+]+%.%w+") or
       string.match(url, "https?://media%.discordapp%.net/attachments/[%d]+/[%d]+/[%w-_%.%+]+%.%w+") or
       string.match(url, "https?://i%.imgur%.com/[%w]+%.%w+") or
       string.match(url, "https?://[%w-_%.]*pinterest%.[%w]+/pin/[%d]+") then
        return true
    end
    
    if string.match(url, "https?://[%w-_%.%?%.:/%+=&]+%.%w+") then
        local extension = string.match(url:lower(), "%.(%w+)$")
        if extension and (extension == "png" or extension == "jpg" or extension == "jpeg" or extension == "gif" or extension == "webp") then
            return true
        end
    end
    
    return false
end

local function ProcessURL(url)
    if string.match(url, "https?://cdn%.discordapp%.com") or string.match(url, "https?://media%.discordapp%.net") then
        local baseUrl = string.match(url, "([^%?]+)")
        local ex = string.match(url, "ex=([^&]+)")
        local is = string.match(url, "is=([^&]+)")
        local hm = string.match(url, "hm=([^&]+)")
        
        if string.match(url, "https?://media%.discordapp%.net") then
            baseUrl = string.gsub(baseUrl, "media%.discordapp%.net", "cdn.discordapp.com")
        end
        
        local path, filename = string.match(baseUrl, "(.+)/([^/]+)$")
        if filename and #filename > 32 then
            local name, ext = string.match(filename, "(.+)%.(.+)$")
            if name and ext then
                filename = string.sub(name, 1, 32) .. "." .. ext
                baseUrl = path .. "/" .. filename
            end
        end
        
        if ex and is and hm then
            url = string.format("%s?ex=%s&is=%s&hm=%s", baseUrl, ex, is, hm)
        else
            url = baseUrl
        end
    end
    
    if string.match(url, "https?://[%w-_%.]*pinterest%.[%w]+/pin/([%d]+)") then
        local pinID = string.match(url, "https?://[%w-_%.]*pinterest%.[%w]+/pin/([%d]+)")
        return "https://i.pinimg.com/originals/" .. pinID .. ".jpg"
    end
    
    return url
end

local function OpenDisplayMenu(entIndex)
    local background = vgui.Create("DPanel")
    background:SetSize(ScrW(), ScrH())
    background:SetPos(0, 0)
    
    local alpha = 0
    local targetAlpha = 200

    background.Think = function()
        alpha = Lerp(FrameTime() * 5, alpha, targetAlpha)
    end
    
    background.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, alpha))
    end

    local frame = vgui.Create("DFrame")
    local screenW, screenH = ScrW(), ScrH()
    local frameW, frameH = 500, 400
    
    frame:SetTitle("")
    frame:SetSize(frameW, frameH)
    frame:Center()
    frame:MakePopup()
    frame:ShowCloseButton(false)
    
    local targetEnt = entIndex and Entity(entIndex)
    local isEditing = IsValid(targetEnt)

    frame.OnRemove = function()
        if IsValid(background) then
            targetAlpha = 0
            background.Think = function()
                alpha = Lerp(FrameTime() * 5, alpha, targetAlpha)
                if alpha < 1 then
                    background:Remove()
                end
            end
        end
    end
    
    frame.Paint = function(self, w, h)
        draw.RoundedBox(20, 0, 30, w, h-30, Color(20, 20, 20, 240))
        draw.RoundedBox(5, 16, 0, 224, 30, Color(20, 20, 20, 240))
        draw.RoundedBox(5, 13, 94, 470, 220, Color(41, 41, 41, 240))
        draw.SimpleText("☀", "Trebuchet24", 26, 15, Color(255, 163, 3), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("SunBox Image Loader", "Trebuchet24", 50, 15, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    frame.OnCursorMoved = function(self, x, y)
        self.closeHovered = x >= self:GetWide()-40 and x <= self:GetWide()-20 and y >= 5 and y <= 25
    end

    frame.OnMousePressed = function(self, mouseCode)
        if mouseCode == MOUSE_LEFT and self.closeHovered then
            self:Remove()
        end
    end

    local content = vgui.Create("DPanel", frame)
    content:SetPos(20, 50)
    content:SetSize(frameW - 40, frameH - 70)
    content.Paint = function() end

    local urlEntry = vgui.Create("DTextEntry", content)
    urlEntry:SetPos(0, 2)
    urlEntry:SetSize(content:GetWide(), 30)
    urlEntry:SetPlaceholderText("Введите прямую ссылку на изображение (Discord/Pinterest/Imgur)")
    urlEntry.Paint = function(self, w, h)
        draw.RoundedBox(5, 0, 0, w, h, Color(41, 41, 41, 240))
        self:DrawTextEntryText(Color(255, 255, 255), Color(100, 100, 255), Color(255, 255, 255))
        if self:GetValue() == "" then
            draw.SimpleText(self:GetPlaceholderText(), "DermaDefault", 5, h/2, Color(150, 150, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end
    
    if isEditing then
        urlEntry:SetValue(targetEnt:GetNWString("DisplayURL", ""))
    end

    local widthLabel = vgui.Create("DLabel", content)
    widthLabel:SetPos(5, 50)
    widthLabel:SetText("Ширина:")
    widthLabel:SetTextColor(Color(255, 255, 255))
    widthLabel:SetFont("DermaDefaultBold")
    widthLabel:SizeToContents()

    local widthSlider = vgui.Create("DNumSlider", content)
    widthSlider:SetPos(-90, 50)
    widthSlider:SetSize(content:GetWide() - 65, 30)
    widthSlider:SetMin(32)
    widthSlider:SetMax(512)
    widthSlider:SetDecimals(0)
    widthSlider:SetValue(isEditing and targetEnt:GetNWInt("DisplayWidth", 90) or 90)
    widthSlider:SetDark(false)
    widthSlider:GetTextArea():SetTextColor(Color(255, 255, 255))

    local heightLabel = vgui.Create("DLabel", content)
    heightLabel:SetPos(5, 90)
    heightLabel:SetText("Высота:")
    heightLabel:SetTextColor(Color(255, 255, 255))
    heightLabel:SetFont("DermaDefaultBold")
    heightLabel:SizeToContents()

    local heightSlider = vgui.Create("DNumSlider", content)
    heightSlider:SetPos(-90, 90)
    heightSlider:SetSize(content:GetWide() - 65, 30)
    heightSlider:SetMin(32)
    heightSlider:SetMax(512)
    heightSlider:SetDecimals(0)
    heightSlider:SetValue(isEditing and targetEnt:GetNWInt("DisplayHeight", 90) or 90)
    heightSlider:SetDark(false)
    heightSlider:GetTextArea():SetTextColor(Color(255, 255, 255))

    local helpLabel = vgui.Create("DLabel", content)
    helpLabel:SetPos(0, 180)
    helpLabel:SetSize(content:GetWide(), 80)
    helpLabel:SetWrap(true)
    helpLabel:SetText("Примечание: URL должен быть прямой ссылкой на изображение.\nДля Discord: ПКМ по изображению → Копировать ссылку (Есть ошибки)\nДля Imgur: ПКМ по изображению → Копировать адрес изображения\nДля Pinterest: ПКМ по изображению → Копировать адрес изображения\nДля других: Копировать адрес изображения")
    helpLabel:SetTextColor(Color(200, 200, 200))
    helpLabel:SetFont("DermaDefault") 

    local createButton = vgui.Create("DButton", content)
    createButton:SetPos(0, content:GetTall() - 40)
    createButton:SetSize(content:GetWide(), 35)
    createButton:SetText("Поставить картинку")
    createButton:SetTextColor(Color(255, 255, 255))
    createButton.Paint = function(self, w, h)
        draw.RoundedBox(5, 0, 0, w, h, self:IsHovered() and Color(60, 60, 60, 255) or Color(30, 30, 30, 250))
    end
    createButton.DoClick = function()
        local url = urlEntry:GetValue()
        
        if not ValidateURL(url) then
            notification.AddLegacy("Неверный формат URL!", NOTIFY_ERROR, 3)
            return
        end
        
        url = ProcessURL(url)
        
        local width = widthSlider:GetValue()
        local height = heightSlider:GetValue()
        
        if isEditing then
            net.Start("SB_IL_UpdateDisplay")
            net.WriteEntity(targetEnt)
            net.WriteString(url)
            net.WriteUInt(width, 16)
            net.WriteUInt(height, 16)
            net.SendToServer()
        else
            net.Start("SB_IL_CreateDisplay")
            net.WriteString(url)
            net.WriteUInt(width, 16)
            net.WriteUInt(height, 16)
            net.SendToServer()
        end
        frame:Remove()
    end

    local closeButton = vgui.Create("DButton", frame)
    closeButton:SetPos(frame:GetWide() - 30, 35 )
    closeButton:SetSize(20, 20)
    closeButton:SetText("")
    closeButton.Paint = function(self, w, h)
        draw.SimpleText("✕", "Trebuchet24", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        if self:IsHovered() then
            draw.RoundedBox(12, 0, 0, w, h, Color(80, 80, 80, 100))
        end
    end

    closeButton.DoClick = function()
        frame:Remove()
    end
end

concommand.Add("sb_IL_menu", function(ply, cmd, args)
    if not args[1] then
        print("Error: Entity index not provided")
        return
    end

    local entIndex = tonumber(args[1])
    if not entIndex then
        print("Error: Invalid entity index")
        return
    end

    OpenDisplayMenu(entIndex)
end)
