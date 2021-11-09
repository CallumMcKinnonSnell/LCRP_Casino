ESX = nil -- ESX Variable
PlayerData = {} -- Player Data.


-------------------------------------
--
-- FUNCTIONS
--
-------------------------------------

-------------------------------------
-- openCashOrCardMenu()
-- Menu used to purchase casino chips
-------------------------------------
function openCashOrCardMenu()
    ESX.UI.Menu.CloseAll()
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'cash_or_card',
    {
        title = "Diamond Casino Payment Method:",
        align = "top-right",
        elements = {
            {label = 'Buy with Cash', value = 'cash'},
            {label = 'Buy with Card (2.5% Fee)', value = 'bank'},
        }
    }, function(data, menu)
        if data.current.value == "cash" then
            openBuyChipsMenu("cash")
        else
            openBuyChipsMenu("bank")
        end
    end, function(data, menu)
        menu.close()
    end)
end

-------------------------------------
-- openBuyChipsMenu()
-- Menu used to purchase casino chips
-------------------------------------
function openBuyChipsMenu(method)
    ESX.UI.Menu.CloseAll()
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'chips_menu',
    {
        title = "Diamond Casino Cashier",
        align = "top-right",
        elements = {
            {label = '100 (£100)', value = '100'},
            {label = '250 (£250)', value = '250'},
            {label = '500 (£500)', value = '500'},
            {label = '1000 (£1000)', value = '1000'},
            {label = '2500 (£2500)', value = '2500'},
            {label = '5000 (£5000)', value = '5000'},
            {label = '10000 (£10000)', value = '10000'},
            {label = 'Custom Amount', value = 'custom'},
        }
    }, function(data, menu)
        if data.current.value == "custom" then
            ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'custom_chips', {
                title = "Enter Quantity"
            }, function(data2, menu2)
                local amount = tonumber(data2.current.value)
                if amount then
                    TriggerServerEvent('LCRP_Casino:BuyChips', amount, method)
                else
                    ESX.UI.Menu.CloseAll()
                    exports['mythic_notify']:DoHudText('error', 'Not a Number.')
                end
            end, function(data2, menu2)
                menu2.close()
            end)
        else
            local amount = tonumber(data.current.value)
            TriggerServerEvent('LCRP_Casino:BuyChips', amount, method)
        end
    end, function(data, menu)
        menu.close()
    end)
end

-------------------------------------
-- openSellChipsMenu()
-- Menu used to cash in casino chips
-------------------------------------
function openSellChipsMenu()
    ESX.UI.Menu.CloseAll()
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'sell_chips',
    {
        title = "Diamond Casino Chip Cash-in",
        align = 'top-right',
        elements = {
            {label = 'Exchange All Chips for Cash', value = 'cash'},
            {label = 'Exchange All Chips for Bank Transfer (5% Fee split between you and the house)', value = 'bank'},
        }
    }, function(data, menu)
        if data.current.value == "cash" then
            TriggerServerEvent("LCRP_Casino:SellChips", "cash")
        else
            TriggerServerEvent("LCRP_Casino:SellChips", "bank")
        end
    end, function(data, menu)
        menu.close()
    end)
end

-------------------------------------
-- isEmployed()
-- Checks if the players' job is "casino"
-------------------------------------
function isEmployed()
    PlayerData = ESX.GetPlayerData()
    local isEmployed = false
    if PlayerData.job.name == "casino" then
        isEmployed = true
    end
    return isEmployed
end

-------------------------------------
-- isBoss()
-- Checks if the players' job is "casino",
-- Then Checks if they hold the boss or viceboss ranks
-------------------------------------
function isBoss()
    PlayerData = ESX.GetPlayerData()
    local isBoss = false
    if PlayerData.job.name == "casino" then
        if PlayerData.job.grade_name == "boss" or PlayerData.job.grade_name == "viceboss" then
            isBoss = true
        end
    end
    return isBoss
end

-------------------------------------
--
-- EVENT HANDLERS
--
-------------------------------------

-------------------------------------
-- LCRP_Casino:BuyChip
-- opens the Buy Chip Menu
--
-------------------------------------
RegisterNetEvent("LCRP_Casino:BuyChip")
AddEventHandler("LCRP_Casino:BuyChip", function()
    openCashOrCardMenu()
end)

-------------------------------------
-- LCRP_Casino:SellChip
-- opens the Buy Chip Menu
--
-------------------------------------
RegisterNetEvent("LCRP_Casino:SellChip")
AddEventHandler("LCRP_Casino:SellChip", function()
    openSellChipsMenu()
end)

-------------------------------------
-- esx:playerLoaded
-- Loads playerData
-- @param xPlayer - The Player
-------------------------------------
RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function(xPlayer)
    PlayerData = xPlayer
end)

-------------------------------------
-- esx:setJob
-- Loads player job from their PlayerData
-- @param job - the job
-------------------------------------
RegisterNetEvent("esx:setJob")
AddEventHandler("esx:setJob", function(job)
    PlayerData.job = job
end)

------------------------------------
--
-- THREADS START HERE
--
------------------------------------

-- ESX Thread
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)
        if ESX == nil then
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
            Citizen.Wait(200)
        end
    end
end)

-- Spawn Peds
Citizen.CreateThread(function()
    if Config.SpawnPeds then
        for i, j in pairs(Config.Peds) do
            RequestModel(GetHashKey(j.hash))
            while not HasModelLoaded(GetHashKey(j.hash)) do
                Wait(1)
            end
            local npc = CreatePed(4, j.hash, j.x, j.y, j.z, j.heading, false, true)
            print(i)
            FreezeEntityPosition(npc, true)	
            SetEntityHeading(npc, j.heading)
            SetEntityInvincible(npc, true)
            SetBlockingOfNonTemporaryEvents(npc, true)
            RequestAnimDict("anim@amb@nightclub@peds@")
            while not HasAnimDictLoaded("anim@amb@nightclub@peds@") do
                Citizen.Wait(1000)
            end
              
            Citizen.Wait(200)
            if j.hash == "s_m_m_highsec_01" then
                TaskPlayAnim(npc,"anim@amb@nightclub@peds@","amb_world_human_stand_guard_male_base",1.0, 1.0, -1, 1, 1.0, 0, 0, 0)
            end
        end
    end
end)

-- QTarget
Citizen.CreateThread(function()
    local cashierPed = {
        `s_m_y_clubbar_01`
    }
    exports['qtarget']:AddTargetModel(cashierPed, {
        options = {
            {
                event = "LCRP_Casino:BuyChip", -- Open Employee menu
                icon = "fas fa-gg-circle",
                label = "Buy Casino Chips",
            },
            {
                event = "LCRP_Casino:SellChip", -- Open Employee menu
                icon = "fas fa-gg-circle",
                label = "Sell Casino Chips",
            },
        },
        distance = 2.5,
    })
end)