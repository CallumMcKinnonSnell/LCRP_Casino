-- /* DO NOT EDIT */

ESX = nil

--------------
-- ESX Trigger
--------------
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
-------------------
-- Register Society
-------------------
TriggerEvent('esx_society:registerSociety', 'casino', 'Diamond Casino', 'society_casino', 'society_casino', 'society_casino', {type = 'public'})

-- /* END OF DO NOT EDIT */

-- /* Server Callbacks start here */


-- None needed POG


-- /* Server Callbacks end here */

-- /* Server Events start here */
----------------------------------------------------------------------
-- LCRP_Casino:BuyChips
-- @param amount - Amount of chips to purchase
-- @param method - Payment method (Cash or card)
----------------------------------------------------------------------
RegisterServerEvent("LCRP_Casino:BuyChips")
AddEventHandler("LCRP_Casino:BuyChips", function(amount, method)
    local xPlayer = ESX.GetPlayerFromId(source)
    if method == "bank" then
        local taxedAmount = amount * 0.975
        print(taxedAmount)
        if xPlayer.getAccount('bank').money >= tonumber(amount) then
            xPlayer.removeAccountMoney('bank', amount)
            xPlayer.addInventoryItem('poker_chip', taxedAmount)
            TriggerEvent('esx_addonaccount:getSharedAccount', "society_casino", function(account)
                account.addMoney(taxedAmount)
            end)
            TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'success', text = 'After the 2.5% fee, you bought ' .. taxedAmount .. " chips.", style = { ['background-color'] = '#ffffff', ['color'] = '#000000' } })
        else
            TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = 'You cannot afford this.', style = { ['background-color'] = '#ffffff', ['color'] = '#000000' } })
        end
    else
        if xPlayer.getMoney() >= amount then
            xPlayer.removeMoney(amount)
            xPlayer.addInventoryItem('poker_chip', amount)
            TriggerEvent('esx_addonaccount:getSharedAccount', "society_casino", function(account)
                account.addMoney(amount)
            end)
            TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'success', text = 'You bought ' .. amount .. " chips.", style = { ['background-color'] = '#ffffff', ['color'] = '#000000' } })
        else
            TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = 'You cannot afford this.', style = { ['background-color'] = '#ffffff', ['color'] = '#000000' } })
        end
    end
end)

----------------------------------------------------------------------
-- LCRP_Casino:SellChips
-- @param amount - String - the name of the item to be withdrawn
-- @param method - Payment method (Cash or card)
----------------------------------------------------------------------
RegisterServerEvent("LCRP_Casino:SellChips")
AddEventHandler("LCRP_Casino:SellChips", function(method)
    local xPlayer = ESX.GetPlayerFromId(source)
    local amount = xPlayer.getInventoryItem("poker_chip").count
    local taxedAmountAccount = amount * 1.025
    local taxedAmountPlayer = amount * 0.975
    TriggerEvent('esx_addonaccount:getSharedAccount', "society_casino", function(account)
        if method == "bank" then
            if account.money >= taxedAmountAccount then
                account.removeMoney(taxedAmountAccount)
                xPlayer.removeInventoryItem("poker_chip", amount)
                xPlayer.addAccountMoney("bank", taxedAmountPlayer)
                TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'success', text = 'You cashed in ' .. amount .. " chips, and after fees received £" .. taxedAmountPlayer, style = { ['background-color'] = '#ffffff', ['color'] = '#000000' } })
            else
                TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = "The Casino cannot afford to pay you out.", style = { ['background-color'] = '#ffffff', ['color'] = '#000000' } })
            end
        else
            if account.money >= amount then
                account.removeMoney(amount)
                xPlayer.removeInventoryItem("poker_chip", amount)
                xPlayer.addAccountMoney("money", amount)
                TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'success', text = 'You cashed in ' .. amount .. " chips, and received £" .. amount, style = { ['background-color'] = '#ffffff', ['color'] = '#000000' } })
            else
                TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = "The Casino cannot afford to pay you out.", style = { ['background-color'] = '#ffffff', ['color'] = '#000000' } })
            end
        end
    end)
end)