local cooldowns = {}

RegisterNetEvent("md_reportsv2:createReport")
AddEventHandler("md_reportsv2:createReport", function(header, info, typ)

    local src = source
    local license = GetLicense(src)
    local now = os.time()

    if cooldowns[license] and (now - cooldowns[license]) < Config.ReportCooldown then
        TriggerClientEvent("md_reportsv2:notify", src, Notify.MessageNeedWait, Notify.TypeError, Notify.MessageHeader)
        return
    end

    cooldowns[license] = now

    if typ == 'report1' then
        typ = "player"
    elseif typ == 'report2' then
        typ = "bug"
    else
        typ = "other"
    end

    TriggerEvent("md_reportsv2:BcreateReport",src, license, header, info, typ)

    TriggerClientEvent("md_reportsv2:notify", src,
        Notify.MessageCreated,
        Notify.TypeSuccessfull,
        Notify.MessageHeader
    )
    TriggerClientEvent("md_reportsv2:creationSuccess", source)
end)

function GetLicense(source)
    for _, identifier in pairs(GetPlayerIdentifiers(source)) do
        if string.find(identifier, "license:") then
            return identifier
        end
    end
    return nil
end



RegisterNetEvent("md_reportsv2:updateHome")
AddEventHandler("md_reportsv2:updateHome",function()
    local src = source
    local license = GetLicense(src)
    TriggerEvent("md_reportsv2:bupdateHome", src, license)
end)

RegisterNetEvent("md_reportsv2:GetNewChat", function()
    local src = source
    local license = GetLicense(src)
    TriggerEvent("md_reportsv2:bgetNewChat", src, license)
end)

RegisterNetEvent("md_reportsv2:sendChatMsg")
AddEventHandler("md_reportsv2:sendChatMsg", function(msg, reportId)
    local src = source
    local license = GetLicense(src)
    TriggerEvent("md_reportsv2:bsendChatMsg", license, msg, reportId, 0)
    TriggerClientEvent("md_reportsv2:notify", source, Notify.MessageSent, Notify.TypeSuccessfull, Notify.MessageHeader)
end)

RegisterNetEvent("md_reportsv2:updateChat")
AddEventHandler("md_reportsv2:updateChat", function(id, new)
    local src = source
    TriggerEvent("md_reportsv2:bupdateChat", src, id, new)
end)
RegisterNetEvent("md_reportsv2:updatedChat")
AddEventHandler("md_reportsv2:updatedChat", function(src, result, new)
    for i = 1, #result do
        local license = result[i].sender
        for _, playerId in ipairs(GetPlayers()) do
            local identifiers = GetPlayerIdentifiers(playerId)

            for _, id in pairs(identifiers) do
                if id == license then
                    result[i].sender = GetPlayerName(playerId)
                end
            end
        end

    end
    TriggerClientEvent("md_reportsv2:updatedChat", src, result, new)
end)



RegisterNetEvent("md_reportsv2:deletereport")
AddEventHandler("md_reportsv2:deletereport", function(opened)
    local src = source
    local license = GetLicense(src)
    TriggerEvent("md_reportsv2:bdeletereport",src, license, opened)
end)





RegisterNetEvent("md_reportsv2:openadmin")
AddEventHandler("md_reportsv2:openadmin", function()
    local src = source
    if IsPlayerAllowed(src)==true then
        TriggerEvent("md_reportsv2:bopenadmin", src)
    end
end)

RegisterNetEvent("md_reportsv2:markasdone")
AddEventHandler("md_reportsv2:markasdone", function(id)
    local src = source
    local license = GetLicense(src)
    if IsPlayerAllowed(src)==true then
        TriggerEvent("md_reportsv2:bmarkasdone", license, id)
    end
end)




AddEventHandler("playerDropped", function(reason)
    local src = source
    local license = GetLicense(src)
    if Config.CloseOnLeave==true then
        TriggerEvent("md_reportsv2:onLeaveOrRestartCloseReport", license)
    end
end)
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    if Config.CloseOnRestart==true then
        TriggerEvent("md_reportsv2:onLeaveOrRestartCloseReport", "all")
    end
end)
RegisterNetEvent("md_reportsv2:tpadmin")
AddEventHandler("md_reportsv2:tpadmin", function(src, player)
    if IsPlayerAllowed(src)==true then
        local playerPed = GetPlayerPed(player)
        local adminPed = GetPlayerPed(src)
        if DoesEntityExist(playerPed) then
            local coords = GetEntityCoords(playerPed)
            local adminCoords = GetEntityCoords(adminPed)

            SetEntityCoords(adminPed, coords.x, coords.y, coords.z, false, false, false, true)
            TriggerClientEvent("md_reportsv2:setback", src, adminCoords)
        end
    end
end)
RegisterNetEvent("md_reportsv2:goback", function(c)
    if IsPlayerAllowed(source)==true then
        local adminPed = GetPlayerPed(source)
        if DoesEntityExist(adminPed) then
            SetEntityCoords(adminPed, c.x, c.y, c.z, false, false, false, true)
        end
    end
end)