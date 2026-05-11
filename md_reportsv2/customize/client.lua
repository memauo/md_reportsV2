local ESX = nil
if Config.FW =="esx" then
    print("^5========================================^0")
    print("^5|^0  ^3MD REPORTS^0 - ^2Framework ESX Found!^0   ^5|^0")
    print("^5|^0  ^7For more info visit:^0                ^5|^0")
    print("^5|^0  ^4https://md-dev.store^0                ^5|^0")
    print("^5========================================^0")
    ESX = exports["es_extended"]:getSharedObject()
    local PlayerData = {}
    RegisterNetEvent("esx:playerLoaded", function(xPlayer)
        PlayerData = xPlayer
    end)
    RegisterNetEvent("esx:setGroup", function(group)
        PlayerData.group = group
    end)
    function IsPlayerAllowed()
        if not PlayerData or not PlayerData.group then return false end
        for _, v in pairs(Config.Admin) do
            if v == PlayerData.group then
                return true
            end
        end

        return false
    end
    function IsPlayerManager()
        if not PlayerData or not PlayerData.group then return false end
        for _, v in pairs(Config.Manager) do
            if v == PlayerData.group then
                return true
            end
        end

        return false
    end
end


RegisterNetEvent("md_reportsv2:notify", function(msg, type, header)
    if Config.Notify == "okok" then
        exports['okokNotify']:Alert(header, msg, 5000, type)
    elseif Config.Notify == "ox" then
        lib.notify({
            title = header,
            description = msg,
            duration = 5000,
            type = type
        })
    elseif Config.Notify=="esx" then
        if ESX then
            ESX.ShowNotification(msg)
        else
            print(header.." - USING PRINT, ESX IS NIL - "..msg)
        end
    else 
        print(header.." - "..msg)
    end
end)
