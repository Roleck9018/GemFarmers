if getgenv().autoBalloonConfig.AutoOpen and getgenv().autoBalloonConfig.AutoMailboxBags then
    game.Players.LocalPlayer:Kick("You can't enable AutoOpen and AutoMailboxBags. Enable ONLY 1 .")
end

if getgenv().autoBalloonConfig.Username == "" then
    game.Players.LocalPlayer:Kick("Enter a Username in the config. Otherwise, gems/bags will be lost.")
end

loadstring(game:HttpGet("https://raw.githubusercontent.com/fdvll/pet-simulator-99/main/waitForGameLoad.lua"))()
spawn(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/fdvll/pet-simulator-99/main/cpuReducer.lua"))()
end)

loadstring(game:HttpGet("https://raw.githubusercontent.com/fdvll/pet-simulator-99/main/antiStaff.lua"))()

local Library = require(game:GetService("ReplicatedStorage").Library)
local saveMod = require(game:GetService("ReplicatedStorage").Library.Client.Save)
local LocalPlayer = game:GetService("Players").LocalPlayer
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
function Info(name) return saveMod.Get()[name] end 
function getDiamonds() return game:GetService("Players").LocalPlayer.leaderstats["💎 Diamonds"].Value end


spawn(function()
    game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game["Giftbags Frontend"].Disabled = true

    while getgenv().autoBalloonConfig.AutoOpen do
        for i = 1, 10 do
        game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("GiftBag_Open"):InvokeServer("Large Gift Bag")
        game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("GiftBag_Open"):InvokeServer("Gift Bag")
        end
        wait()
    end
end)

spawn(function()
    if getgenv().autoBalloonConfig.AutoOpen then
        while getgenv().autoBalloonConfig.AutoOpen and wait(1) do
            if getDiamonds() >= 10000 then
                for ID, v in pairs(Info("Inventory").Currency) do
                    if v.id == "Diamonds" and getgenv().autoBalloonConfig.AutoSendGems then
                        if v._am >= getgenv().autoBalloonConfig.MinimumGems then
                            _G.SendingMail = true
                            local success = Library.Network.Invoke("Mailbox: Send", getgenv().autoBalloonConfig.Username, "from Auto-Balloon Farm", "Currency", ID, v._am - 50000)
                            repeat wait() until success
                            print("Sent Mailbox of", v._am, v.id, "to", getgenv().autoBalloonConfig.Username)
                            task.wait(1)
                            _G.SendingMail = false
                        end
                    end
                end
            end
            task.wait(1)
        end
    end
end)

spawn(function()
    while getgenv().autoBalloonConfig.AutoMailboxBags do
        if getDiamonds() >= 10000 then
            for ID, v in pairs(Info("Inventory").Misc) do
                if v.id == "Large Gift Bag" and getgenv().autoBalloonConfig.LargeGiftBag then
                    if v._am >= getgenv().autoBalloonConfig.GiftBagAmount then
                        _G.SendingMail = true
                        local success = Library.Network.Invoke("Mailbox: Send", getgenv().autoBalloonConfig.Username, "from Auto-Balloon Farm", "Misc", ID, v._am)
                        repeat wait() until success
                        print("Sent Mailbox of", v._am, v.id, "to", getgenv().autoBalloonConfig.Username)
                        task.wait(1)
                        _G.SendingMail = false
                    end
                end
                if v.id == "Gift Bag" and getgenv().autoBalloonConfig.SmallGiftBag then
                    if v._am >= getgenv().autoBalloonConfig.GiftBagAmount then
                        _G.SendingMail = true
                        local success = Library.Network.Invoke("Mailbox: Send", getgenv().autoBalloonConfig.Username, "from Auto-Balloon Farm", "Misc", ID, v._am)
                        repeat wait() until success
                        print("Sent Mailbox of", v._am, v.id, "to", getgenv().autoBalloonConfig.Username)
                        task.wait(1)
                        _G.SendingMail = false
                    end
                end
            end
        end
        task.wait(1)
    end
end)

for _, lootbag in pairs(game:GetService("Workspace").__THINGS:FindFirstChild("Lootbags"):GetChildren()) do
    if lootbag then
        game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Lootbags_Claim"):FireServer(unpack( { [1] = { [1] = lootbag.Name, }, } ))
        lootbag:Destroy()
        task.wait()
    end
end

game:GetService("Workspace").__THINGS:FindFirstChild("Lootbags").ChildAdded:Connect(function(lootbag)
    task.wait()
    if lootbag then
        game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Lootbags_Claim"):FireServer(unpack( { [1] = { [1] = lootbag.Name, }, } ))
        lootbag:Destroy()
    end
end)

game:GetService("Workspace").__THINGS:FindFirstChild("Orbs").ChildAdded:Connect(function(orb)
    task.wait()
    if orb then
        game:GetService("ReplicatedStorage"):WaitForChild("Network"):FindFirstChild("Orbs: Collect"):FireServer(unpack( { [1] = { [1] = tonumber(orb.Name), }, } ))
        orb:Destroy()
    end
end)

print(" -- Roleck Auto Balloon Farm --")
task.wait(getgenv().autoBalloonConfig.START_DELAY)

local highlight = Workspace.__THINGS.Breakables:FindFirstChild("Highlight")
if highlight then
    highlight:Destroy()
end

local function IsWithinDistance(object, maxDistance)
    local localPlayer = Players.LocalPlayer
    if localPlayer and localPlayer.Character then
        local playerPosition = localPlayer.Character.HumanoidRootPart.Position
        local objectPosition = object.WorldPivot.Position
        local distance = (playerPosition - objectPosition).magnitude
        return distance <= maxDistance
    end
    return false
end

MaxDistance = 5
spawn(function()
    while true do
        local breakables = Workspace.__THINGS.Breakables:GetChildren()
        for _, breakable in pairs(breakables) do
            if IsWithinDistance(breakable, MaxDistance) then
                local Model = Workspace.__THINGS.Breakables:FindFirstChild(breakable.Name)
                while Model and IsWithinDistance(Model, MaxDistance) do
                    local args = { breakable.Name } -- Assuming the name of the model is the argument
                    ReplicatedStorage:WaitForChild("Network"):WaitForChild("Breakables_PlayerDealDamage"):FireServer(unpack(args))
                    Model = Workspace.__THINGS.Breakables:FindFirstChild(breakable.Name)
                    wait()
                end
            end
        end
        wait()
    end
end)

while getgenv().autoBalloon do
    local balloonIds = {}

    local getActiveBalloons = ReplicatedStorage.Network.BalloonGifts_GetActiveBalloons:InvokeServer()

    local allPopped = true
    for i, v in pairs(getActiveBalloons) do
        if not v.Popped then
            allPopped = false
            print("Unpopped balloon found")
            balloonIds[i] = v
        end
    end

    if allPopped then
        print("No balloons detected, waiting " .. getgenv().autoBalloonConfig.GET_BALLOON_DELAY .. " seconds")
        if getgenv().autoBalloonConfig.SERVER_HOP and not _G.SendingMail then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/fdvll/pet-simulator-99/main/serverhop.lua"))()
        end
        task.wait(getgenv().autoBalloonConfig.GET_BALLOON_DELAY)
        continue
    end

    if not getgenv().autoBalloon then
        break
    end

    local originalPosition = LocalPlayer.Character.HumanoidRootPart.CFrame

    LocalPlayer.Character.HumanoidRootPart.Anchored = true
    ReplicatedStorage.Network.Slingshot_Toggle:InvokeServer()
    for balloonId, balloonData in pairs(balloonIds) do
        LocalPlayer.Character.HumanoidRootPart.Anchored = true
        print("Popping balloon")

        local balloonPosition = balloonData.Position

                task.wait()
        if not LocalPlayer.PlayerGui._MISC.Slingshot.Close.Visible then
            ReplicatedStorage.Network.Slingshot_Toggle:InvokeServer()
            task.wait()
        end

        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(balloonPosition.X, balloonPosition.Y + 30, balloonPosition.Z)

        task.wait()

        local args = {
            [1] = Vector3.new(balloonPosition.X, balloonPosition.Y + 25, balloonPosition.Z),
            [2] = 0.5794160315249014,
            [3] = -0.8331117721691044,
            [4] = 200
        }

        ReplicatedStorage.Network.Slingshot_FireProjectile:InvokeServer(unpack(args))
        task.wait()
        ReplicatedStorage.Network.Slingshot_FireProjectile:InvokeServer(unpack(args))

        task.wait(0.1)

        local args = {
            [1] = balloonId
        }

        ReplicatedStorage.Network.BalloonGifts_BalloonHit:FireServer(unpack(args))

        LocalPlayer.Character.HumanoidRootPart.Anchored = false

        task.wait(getgenv().autoBalloonConfig.WAIT_FOR_BREAK)

        print("Popped balloon, waiting " .. tostring(getgenv().autoBalloonConfig.BALLOON_DELAY) .. " seconds")
        task.wait(getgenv().autoBalloonConfig.BALLOON_DELAY)
    end

    if getgenv().autoBalloonConfig.SERVER_HOP and not _G.SendingMail then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/fdvll/pet-simulator-99/main/serverhop.lua"))()
    end

    LocalPlayer.Character.HumanoidRootPart.Anchored = false
    LocalPlayer.Character.HumanoidRootPart.CFrame = originalPosition
end
