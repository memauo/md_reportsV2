local coords = nil


RegisterNUICallback("uiReady", function(data, cb)
    local name = GetPlayerName(PlayerId())
    SendNuiMessage(json.encode({action="setname", name=name}))
    SendNuiMessage(json.encode({
        action = "setDef",
        serverName = Config.ServerName,
        sound = Config.PlaySound,
        translate = Translate,
    }))

    cb("ok")
end)
RegisterCommand(Config.OpenCommand, function()
    SendNuiMessage(json.encode({action="openUi"}))
    SetNuiFocus(true, true)
end)

RegisterNUICallback("closeUI", function(data, cb)
    SetNuiFocus(false, false)
    cb('closed')
end)


RegisterNUICallback("createReport", function(data, cb)
    local header = data.header
    local info = data.info
    local typ = data.type
    TriggerServerEvent("md_reportsv2:createReport", header, info, typ)
    cb('ok')
end)
RegisterNetEvent("md_reportsv2:creationSuccess")
AddEventHandler("md_reportsv2:creationSuccess", function()
    SendNuiMessage(json.encode({
        action = "successCreation"
    }))
end)




RegisterNuiCallback("updateHome", function(data, cb)
    TriggerServerEvent("md_reportsv2:updateHome")
    cb('ok')
end)
RegisterNetEvent("md_reportsv2:updateHome")
AddEventHandler("md_reportsv2:updateHome", function(result)
    SendNuiMessage(json.encode({action="updateHomePage", result=result}))
end)




RegisterNUICallback("openPlayerReport",function(data, cb)
    local opened = data.opened
    TriggerServerEvent("md_reportsv2:bopenPlayerReport", opened)
    cb('ok')
end)
RegisterNetEvent("md_reportsv2:updatePlayerReport")
AddEventHandler("md_reportsv2:updatePlayerReport", function(result)
    SendNuiMessage(json.encode({action="updatePlayerPage", result=result}))
end)

RegisterNUICallback("getNewChat", function (data, cb)
    TriggerServerEvent("md_reportsv2:GetNewChat")
    cb('ok')    
end)


RegisterNUICallback("sendChatMsg", function(data, cb)
    TriggerServerEvent("md_reportsv2:sendChatMsg", data.msg, data.opened)
    cb('ok')
end)
RegisterNUICallback("chatUpdate",function(data, cb)
    TriggerServerEvent("md_reportsv2:updateChat", data.opened, data.newMessage)
    cb('ok')
end)
RegisterNetEvent("md_reportsv2:updatedChat")
AddEventHandler("md_reportsv2:updatedChat", function(result, new)
    SendNuiMessage(json.encode({action="updateChat",result=result, new=new}))
end)
RegisterNetEvent("md_reportsv2:chatNewMessage")
AddEventHandler("md_reportsv2:chatNewMessage", function(reportId)
    SendNuiMessage(json.encode({
        action = "forceChatUpdate",
        id = reportId
    }))

end)


RegisterNetEvent("md_reportsv2:setcreatedid")
AddEventHandler("md_reportsv2:setcreatedid", function(id)
    SendNuiMessage(json.encode({
        action = "setopenid",
        idecko = id
    }))
end)
local duty = 1
if Config.DefaultOnDuty == false then
    duty = 0
end
RegisterNetEvent("md_reportsv2:newReportNotify")
AddEventHandler("md_reportsv2:newReportNotify",function()
    if duty==1 and IsPlayerAllowed()==true then
        TriggerEvent("md_reportsv2:notify", Notify.NewReport, Notify.TypeSuccessfull, Notify.MessageHeader)
    end
end)


RegisterNUICallback("newMsgNotify", function(data, cb)
    TriggerEvent("md_reportsv2:notify", Notify.NewMessage, Notify.TypeSuccessfull, Notify.MessageHeader)
    cb('ok')
end)

RegisterNuiCallback("deleteopened", function(data, cb)

    TriggerServerEvent("md_reportsv2:deletereport", data.opened)
    cb('ok')
end)


RegisterNetEvent("md_reportsv2:solveduser", function(opened)
    SendNuiMessage(json.encode({action="closedreport",op=opened}))
end)
RegisterNetEvent("md_reportsv2:admindelsolveduser")
AddEventHandler("md_reportsv2:admindelsolveduser", function(opened)
    if IsPlayerAllowed()==true then
        SendNuiMessage(json.encode({action="closedreport", op=opened}))
    end
end)





CreateThread(function()
    while true do
        local admin = IsPlayerAllowed()
        SendNuiMessage(json.encode({action="setGroup", group = admin}))
        local manager = IsPlayerManager()
        SendNuiMessage(json.encode({action="setManager", group = manager}))
        Wait(Config.AdminInterval)
    end
end)
RegisterNUICallback("updateAdmin",function(data, cb)
    if IsPlayerAllowed()==true then
       TriggerServerEvent("md_reportsv2:openadmin")
    end
    cb('ok')
end)

RegisterNetEvent("md_reportsv2:updatedHome")
AddEventHandler("md_reportsv2:updatedHome", function(result)
    if IsPlayerAllowed()==true then
        SendNuiMessage(json.encode({action="updateAdmin", result = result}))
    end
end)


RegisterNuiCallback("markasdone", function(data, cb)
    TriggerServerEvent("md_reportsv2:markasdone", data.opened)
    cb('ok')    
end)
RegisterNUICallback("setduty", function(data, cb)
    duty = 1 - duty
    if duty==1 then
        TriggerEvent("md_reportsv2:notify", Notify.OnDuty, Notify.TypeSuccessfull, Notify.MessageHeader)
    else 
        TriggerEvent("md_reportsv2:notify", Notify.OffDuty, Notify.TypeSuccessfull, Notify.MessageHeader)
    end
    cb('ok')
end)
RegisterNUICallback("startsolving", function(data, cb)
    if IsPlayerAllowed()==true then
        TriggerServerEvent("md_reportsv2:startsolving", data.opened)
    end
    cb('ok')
end)

RegisterNetEvent("md_reportsv2:adminsolving")
AddEventHandler("md_reportsv2:adminsolving", function()
    if IsPlayerAllowed()==true then
        --TriggerServerEvent("md_reportsv2:openadmin")
    end
end)

RegisterNUICallback("transcript", function(data, cb)
    if Config.TranscriptWebhook and IsPlayerAllowed()==true then
        TriggerServerEvent("md_reportsv2:transcript", data.opened)
    end
    cb('ok')
end)
RegisterNUICallback("teleport", function(data, cb)
    if IsPlayerAllowed()==true then
        TriggerServerEvent("md_reportsv2:teleport", data.opened)
    end
    cb('ok')
end)
RegisterNUICallback("goback", function(data, cb)
    if IsPlayerAllowed()==true then
        TriggerServerEvent("md_reportsv2:goback", coords)
    end
    cb('ok')
end)
RegisterNetEvent("md_reportsv2:setback", function (acoords)
    if IsPlayerAllowed()==true then
        coords = acoords
    end
end)
RegisterNUICallback("wipeout", function(data, cb)
    if IsPlayerManager()==true then
        TriggerServerEvent("md_reportsv2:wipeout")
    end
    cb('ok')
end)

RegisterNetEvent("md_reportsv2:wiped")
AddEventHandler("md_reportsv2:wiped",function()
    SendNuiMessage(json.encode({action="wiped"}))
end)
RegisterNUICallback("updmng",function(data, cb)
    if IsPlayerManager()==true then
        TriggerServerEvent("md_reportsv2:updatemngmnt")
    end
    cb('ok')
end)
RegisterNetEvent('md_reportsv2:updatedMng')
AddEventHandler("md_reportsv2:updatedMng", function(result)
    if IsPlayerManager()==true then
       SendNuiMessage(json.encode({action="updatedMng", result = result}))
    end
end)