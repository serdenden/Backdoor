local UserInputService = game:GetService("UserInputService")

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "BackdoorScanner"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 360, 0, 520)
Frame.Position = UDim2.new(0, 20, 0.5, -260)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.ClipsDescendants = true
Frame.Active = true
Frame.Draggable = false -- kendi sürükleme fonksiyonu var

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 4)
UIListLayout.Parent = Frame

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "🔍 Backdoor Tarayıcı (Pasif)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Position = UDim2.new(0, 0, 0, 0)

-- Sürükleme ayarları
local dragging, dragInput, dragStart, startPos
local function updatePosition(input)
    local delta = input.Position - dragStart
    Frame.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end
Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
Frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        updatePosition(input)
    end
end)

local SearchBox = Instance.new("TextBox", Frame)
SearchBox.PlaceholderText = "Ara..."
SearchBox.Size = UDim2.new(1, -20, 0, 30)
SearchBox.Position = UDim2.new(0, 10, 0, 35)
SearchBox.ClearTextOnFocus = false
SearchBox.Text = ""
SearchBox.Font = Enum.Font.SourceSans
SearchBox.TextSize = 16
SearchBox.TextColor3 = Color3.new(1,1,1)
SearchBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
SearchBox.BorderSizePixel = 0
SearchBox.Focused:Connect(function()
    SearchBox.PlaceholderText = ""
end)
SearchBox.FocusLost:Connect(function()
    if SearchBox.Text == "" then
        SearchBox.PlaceholderText = "Ara..."
    end
end)

local FilterFrame = Instance.new("Frame", Frame)
FilterFrame.Size = UDim2.new(1, -20, 0, 34)
FilterFrame.Position = UDim2.new(0, 10, 0, 70)
FilterFrame.BackgroundTransparency = 1

local function createFilterButton(name, parent)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0, 75, 1, 0)
    btn.Text = name
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.TextColor3 = Color3.new(1,1,1)
    btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = true

    btn.MouseEnter:Connect(function()
        if btn.BackgroundColor3 == Color3.fromRGB(70, 70, 70) then
            btn.BackgroundColor3 = Color3.fromRGB(85, 85, 85)
        end
    end)
    btn.MouseLeave:Connect(function()
        if btn.BackgroundColor3 == Color3.fromRGB(70, 70, 70) then
            btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        end
    end)

    return btn
end

local allBtn = createFilterButton("Hepsi", FilterFrame)
allBtn.Position = UDim2.new(0, 0, 0, 0)
local remoteEventBtn = createFilterButton("RemoteEvent", FilterFrame)
remoteEventBtn.Position = UDim2.new(0, 80, 0, 0)
local remoteFuncBtn = createFilterButton("RemoteFunction", FilterFrame)
remoteFuncBtn.Position = UDim2.new(0, 160, 0, 0)
local moduleScriptBtn = createFilterButton("ModuleScript", FilterFrame)
moduleScriptBtn.Position = UDim2.new(0, 240, 0, 0)

local ScrollFrame = Instance.new("ScrollingFrame", Frame)
ScrollFrame.Size = UDim2.new(1, -20, 1, -180)
ScrollFrame.Position = UDim2.new(0, 10, 0, 110)
ScrollFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

local UIListLayout2 = Instance.new("UIListLayout", ScrollFrame)
UIListLayout2.Padding = UDim.new(0, 6)

local foundObjs = {}

local suspiciousWords = {"exploit", "backdoor", "admin", "inject", "remote", "cmd"}

local function isSuspicious(name)
    local lower = name:lower()
    for _, word in ipairs(suspiciousWords) do
        if string.find(lower, word) then
            return true
        end
    end
    return false
end

local function createButton(obj)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 28)
    btn.Text = obj.ClassName .. " : " .. obj.Name
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 15
    btn.TextColor3 = Color3.new(1,1,1)
    btn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = true

    if isSuspicious(obj.Name) then
        btn.TextColor3 = Color3.fromRGB(255, 90, 90)
    end

    btn.MouseButton1Click:Connect(function()
        setclipboard(obj:GetFullName())
        btn.Text = "✅ Kopyalandı!"
        wait(1.5)
        btn.Text = obj.ClassName .. " : " .. obj.Name
    end)
    return btn
end

local function createCategoryLabel(text)
    local lbl = Instance.new("TextLabel", ScrollFrame)
    lbl.Size = UDim2.new(1, 0, 0, 24)
    lbl.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    lbl.BorderSizePixel = 0
    lbl.Text = "📂 " .. text
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextSize = 16
    return lbl
end

local function updateList()
    for _, v in pairs(ScrollFrame:GetChildren()) do
        if v:IsA("TextButton") or (v:IsA("TextLabel") and v.Text:sub(1,4) == "📂 ") then
            v:Destroy()
        end
    end

    local filter = {}
    if allBtn.BackgroundColor3 == Color3.fromRGB(100, 150, 255) then
        filter.RemoteEvent = true
        filter.RemoteFunction = true
        filter.ModuleScript = true
    else
        if remoteEventBtn.BackgroundColor3 == Color3.fromRGB(100, 150, 255) then
            filter.RemoteEvent = true
        end
        if remoteFuncBtn.BackgroundColor3 == Color3.fromRGB(100, 150, 255) then
            filter.RemoteFunction = true
        end
        if moduleScriptBtn.BackgroundColor3 == Color3.fromRGB(100, 150, 255) then
            filter.ModuleScript = true
        end
    end

    local searchText = SearchBox.Text:lower()

    local categories = {
        RemoteEvent = {},
        RemoteFunction = {},
        ModuleScript = {}
    }

    for _, obj in pairs(foundObjs) do
        if (filter[obj.ClassName] or next(filter) == nil) and
           (searchText == "" or obj.Name:lower():find(searchText)) then
            table.insert(categories[obj.ClassName], obj)
        end
    end

    for catName, objs in pairs(categories) do
        if #objs > 0 then
            createCategoryLabel(catName)
            for _, obj in ipairs(objs) do
                local btn = createButton(obj)
                btn.Parent = ScrollFrame
            end
        end
    end

    local listSize = UIListLayout2.AbsoluteContentSize.Y
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, listSize + 10)
end

local function setActiveButton(activeBtn)
    local buttons = {allBtn, remoteEventBtn, remoteFuncBtn, moduleScriptBtn}
    for _, btn in ipairs(buttons) do
        if btn == activeBtn then
            btn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        end
    end
end

allBtn.MouseButton1Click:Connect(function()
    setActiveButton(allBtn)
    updateList()
end)

remoteEventBtn.MouseButton1Click:Connect(function()
    setActiveButton(remoteEventBtn)
    updateList()
end)

remoteFuncBtn.MouseButton1Click:Connect(function()
    setActiveButton(remoteFuncBtn)
    updateList()
end)

moduleScriptBtn.MouseButton1Click:Connect(function()
    setActiveButton(moduleScriptBtn)
    updateList()
end)

SearchBox:GetPropertyChangedSignal("Text"):Connect(updateList)

-- Yeni Buton: Tümünü Tara
local scanAllBtn = Instance.new("TextButton", Frame)
scanAllBtn.Size = UDim2.new(1, -20, 0, 35)
scanAllBtn.Position = UDim2.new(0, 10, 1, -60)
scanAllBtn.BackgroundColor3 = Color3.fromRGB(45, 120, 255)
scanAllBtn.Font = Enum.Font.SourceSansBold
scanAllBtn.TextColor3 = Color3.new(1,1,1)
scanAllBtn.Text = "▶️ Tümünü Tara"
scanAllBtn.BorderSizePixel = 0
scanAllBtn.AutoButtonColor = true

scanAllBtn.MouseEnter:Connect(function()
    scanAllBtn.BackgroundColor3 = Color3.fromRGB(60, 150, 255)
end)
scanAllBtn.MouseLeave:Connect(function()
    scanAllBtn.BackgroundColor3 = Color3.fromRGB(45, 120, 255)
end)

scanAllBtn.MouseButton1Click:Connect(function()
    foundObjs = {}
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or obj:IsA("ModuleScript") then
            table.insert(foundObjs, obj)
        end
    end
    updateList()
    scanAllBtn.Text = "✅ Taramayı Tamamladı"
    wait(1.5)
    scanAllBtn.Text = "▶️ Tümünü Tara"
end)

-- Başlangıçta Hepsi seçili olsun
setActiveButton(allBtn)

-- İlk otomatik tarama (başlangıç objelerini bul)
foundObjs = {}
for _, obj in ipairs(game:GetDescendants()) do
    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or obj:IsA("ModuleScript") then
        table.insert(foundObjs, obj)
    end
end
updateList()
