include("shared.lua")

local cachedMaterials = {}
local cachedImages = {}

function ENT:Initialize()
    self.LastURL = ""
    self.Material = nil
end

function ENT:LoadImageFromURL(url)
    if cachedImages[url] then
        self.Material = cachedImages[url]
        return
    end

    local headers = {
        ["Accept"] = "image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8",
        ["Accept-Language"] = "en-US,en;q=0.9"
    }

    http.Fetch(url,
        function(body, size, headers, code)
            if code != 200 then
                print("SB_IL Error: Server returned code " .. code .. " for URL: " .. url)
                notification.AddLegacy("Ошибка загрузки изображения (код " .. code .. ")", NOTIFY_ERROR, 5)
                return
            end

            if size <= 0 then
                print("SB_IL Error: Received empty image")
                notification.AddLegacy("Ошибка: Получено пустое изображение", NOTIFY_ERROR, 5)
                return
            end

            local tempFile = "sundisplay/" .. util.CRC(url) .. ".png"
            file.CreateDir("sundisplay")
            file.Write(tempFile, body)
            
            local mat = Material("../data/" .. tempFile, "noclamp smooth")
            
            if not mat:IsError() then
                cachedImages[url] = mat
                self.Material = mat
            else
                print("SB_IL Error: Failed to create material from image")
                notification.AddLegacy("Ошибка: Неподдерживаемый формат изображения", NOTIFY_ERROR, 5)
                file.Delete(tempFile)
            end
        end,
        function(error)
            print("SB_IL Error: Failed to load image - " .. error .. " URL: " .. url)
            notification.AddLegacy("Ошибка загрузки: " .. error, NOTIFY_ERROR, 5)
        end,
        headers
    )
end

function ENT:Draw()
    local url = self:GetNWString("DisplayURL", "")
    
    if url == "" then
        self:DrawModel()
        return
    end
    
    if self.LastURL != url then
        self.LastURL = url
        self:LoadImageFromURL(url)
    end
    
    if self.Material then
        local pos = self:GetPos()
        local ang = self:GetAngles()
        local width = self:GetNWInt("DisplayWidth", 256)
        local height = self:GetNWInt("DisplayHeight", 256)
        
        local scale = width / 100 -- Размерчик
        
        cam.Start3D2D(pos + ang:Forward() * 0.1, ang, scale)
            surface.SetMaterial(self.Material)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRect(-width/2, -height/2, width, height)
        cam.End3D2D()
    end
end
