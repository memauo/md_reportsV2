

local WEBHOOK = "https://discord.com/api/webhooks/1473353572409409689/v2F9O57lPxtY1gpIuf8gM-VzOmDp1DOn_TcypN4SyAssqwSErP5ZNjSshtv-WT0QS7t2"


ESX = nil
if Config.FW =="esx" then
    ESX = exports["es_extended"]:getSharedObject()

    print("^5========================================^0")
    print("^5|^0  ^3MD REPORTS^0 - ^2Framework ESX Found!^0   ^5|^0")
    print("^5|^0  ^7For more info visit:^0                ^5|^0")
    print("^5|^0  ^4https://md-dev.store^0                ^5|^0")
    print("^5========================================^0")
    function IsPlayerAllowed(src)
        local xPlayer = ESX.GetPlayerFromId(src)
        if not xPlayer then 
            return false
        end
        local group = xPlayer.getGroup()
        for _, i in pairs(Config.Admin) do
            if i == group then
                return true
            end
        end

        return false
    end
    function IsPlayerManager(src)
        local xPlayer = ESX.GetPlayerFromId(src)
        if not xPlayer then 
            return false
        end
        local group = xPlayer.getGroup()
        for _, i in pairs(Config.Manager) do
            if i == group then
                return true
            end
        end

        return false
    end
end


RegisterNetEvent("md_reportsv2:BcreateReport")
AddEventHandler("md_reportsv2:BcreateReport", function(src, license, header, info, typ)
    local id = exports.oxmysql:insert(
        'INSERT INTO md_reports (owner, status, type, header, info) VALUES (?, ?, ?, ?, ?)',
        {
            license,
            'waiting',
            typ,
            header,
            info
        },
        function(id)
            TriggerClientEvent("md_reportsv2:setcreatedid", src, id)
            TriggerClientEvent("md_reportsv2:newReportNotify", -1)

        end
    )

end)
RegisterNetEvent("md_reportsv2:bupdateHome")
AddEventHandler("md_reportsv2:bupdateHome",function(src, license)
    exports.oxmysql:query(
        'SELECT * FROM md_reports WHERE owner = ?',
        {license},
        function(result)
            TriggerClientEvent("md_reportsv2:updateHome", src, result)
        end
    )
end)
RegisterNetEvent("md_reportsv2:bopenPlayerReport")
AddEventHandler("md_reportsv2:bopenPlayerReport", function(id)
    local src = source
    exports.oxmysql:single(
        'SELECT * FROM md_reports WHERE id = ?',
        {id},
        function(result)
            TriggerClientEvent("md_reportsv2:updatePlayerReport", src, result)
        end
    )
end)
RegisterNetEvent("md_reportsv2:bgetNewChat")
AddEventHandler("md_reportsv2:bgetNewChat", function(src, license)
    exports.oxmysql:single(
        'SELECT * FROM md_reports WHERE owner = ? ORDER BY id DESC LIMIT 1',
        {license},
        function(result)
            if result then
                TriggerClientEvent("md_reportsv2:updatePlayerReport", src, result)
            end
        end
    )
end)
RegisterNetEvent("md_reportsv2:bsendChatMsg")
AddEventHandler("md_reportsv2:bsendChatMsg", function(license, msg, reportId, date)
    local src = source
    local foundName = "Unknown"
    for _, playerId in ipairs(GetPlayers()) do
        for _, identifier in ipairs(GetPlayerIdentifiers(playerId)) do
            if identifier == license then
                foundName = GetPlayerName(playerId)
                break
            end
        end
        if foundName ~= "Unknown" then break end
    end
    exports.oxmysql:insert('INSERT INTO md_reports_chat (report_id, sender, message) VALUES (?, ?, ?)', {
        reportId, foundName, msg
    }, function(id)
        TriggerClientEvent("md_reportsv2:chatNewMessage", -1, reportId)
    end)
end)
RegisterNetEvent("md_reportsv2:bupdateChat")
AddEventHandler("md_reportsv2:bupdateChat", function(src, id, new)
    exports.oxmysql:query(
        'SELECT * FROM md_reports_chat WHERE report_id = ?',
        {id},
        function(result)
            TriggerEvent("md_reportsv2:updatedChat", src, result, new)
        end
    )
end)


RegisterNetEvent("md_reportsv2:bdeletereport")
AddEventHandler("md_reportsv2:bdeletereport", function(src, license, opened)

    exports.oxmysql:execute(
        'UPDATE md_reports SET status = ? WHERE id = ? AND owner = ?',
        { 'closed', opened, license },
        function(result)

            local rows = result and (result.affectedRows or result) or 0

            if rows > 0 then
                TriggerClientEvent("md_reportsv2:solveduser", src, opened)
                TriggerClientEvent("md_reportsv2:admindelsolveduser", -1, opened)
            end

        end
    )

end)


RegisterNetEvent("md_reportsv2:bopenadmin")
AddEventHandler("md_reportsv2:bopenadmin", function(src)
    exports.oxmysql:query(
        'SELECT * FROM md_reports WHERE status = ? OR status = ?',
        {"waiting", "solving"},
        function(result)
            for i = 1, #result do
                local license = result[i].owner
                local foundName = "Offline"
                for _, playerId in ipairs(GetPlayers()) do
                    for _, identifier in ipairs(GetPlayerIdentifiers(playerId)) do
                        if identifier == license then
                            foundName = GetPlayerName(playerId)
                            break
                        end
                    end
                    if foundName ~= "Offline" then break end
                end
                result[i].name = foundName
            end
            TriggerClientEvent("md_reportsv2:updatedHome", src, result)
        end
    )
end)

RegisterNetEvent("md_reportsv2:bmarkasdone", function(license, opened)
    local src = source
    exports.oxmysql:single('SELECT owner FROM md_reports WHERE id = ?', {opened}, function(row)
        if not row then return end
        local ownerLicense = row.owner
        local closedData = json.encode({
            date = os.date("%Y-%m-%d %H:%M:%S"),
            closedBy = license
        })
        exports.oxmysql:execute(
            'UPDATE md_reports SET status = ?, dateclosed = ? WHERE id = ?',
            { 'closed', closedData, opened },
            function(result)
                local rows = result and (result.affectedRows or result) or 0
                if rows > 0 then
                    local target = nil
                    for _, playerId in ipairs(GetPlayers()) do
                        for _, identifier in ipairs(GetPlayerIdentifiers(playerId)) do
                            if identifier == ownerLicense then
                                target = playerId
                                break
                            end
                        end
                        if target then break end
                    end
                    if target then
                        TriggerClientEvent("md_reportsv2:solveduser", target, opened)
                        TriggerClientEvent("md_reportsv2:notify", target, Notify.ReportClosed, Notify.TypeSuccessfull, Notify.MessageHeader)
                    end
                    TriggerClientEvent("md_reportsv2:admindelsolveduser", -1, opened)
                end

            end
        )
    end)
end)
RegisterNetEvent("md_reportsv2:onLeaveOrRestartCloseReport")
AddEventHandler("md_reportsv2:onLeaveOrRestartCloseReport", function(license)
    if license=="all" then
        exports.oxmysql:query(
        'UPDATE md_reports SET status = ? WHERE status IN (?, ?)',
        { 'closed', 'waiting', 'solving' },
        function(result)
        end
    )
    end
    exports.oxmysql:execute(
        'UPDATE md_reports SET status = ? WHERE owner = ? AND (status = ? OR status = ?)',
        { 'closed', license, 'waiting', 'solving' },
        function(result)
        end
    )
end)
RegisterNetEvent("md_reportsv2:startsolving")
AddEventHandler("md_reportsv2:startsolving", function(id)
    local src = source
    local name = GetPlayerName(src)
    exports.oxmysql:single(
        'SELECT owner FROM md_reports WHERE id = ?',
        { id },
        function(row)
            if not row then return end
            local ownerLicense = row.owner
            local player = nil
            exports.oxmysql:execute(
                'UPDATE md_reports SET status = ?, admin = ? WHERE id = ?',
                { 'solving', name, id },
                function()
                    for _, playerId in ipairs(GetPlayers()) do
                        for _, identifier in ipairs(GetPlayerIdentifiers(playerId)) do
                            if identifier == ownerLicense then
                                player = playerId
                                break
                            end
                        end
                        if player then break end
                    end
                    if player then
                        TriggerClientEvent("md_reportsv2:notify", player, Notify.ReportSolving, Notify.TypeSuccessfull, Notify.MessageHeader)
                    end

                    TriggerClientEvent("md_reportsv2:adminsolving", -1, id)
                end
            )
        end
    )
end)

RegisterNetEvent("md_reportsv2:teleport")
AddEventHandler("md_reportsv2:teleport", function(id)
    local src = source
    local name = GetPlayerName(src)
    exports.oxmysql:single(
        'SELECT owner FROM md_reports WHERE id = ?',
        { id },
        function(row)
            if not row then return end
            local ownerLicense = row.owner
            local player = nil
            for _, playerId in ipairs(GetPlayers()) do
                for _, identifier in ipairs(GetPlayerIdentifiers(playerId)) do
                    if identifier == ownerLicense then
                        player = playerId
                        break
                    end
                end
                if player then break end
            end
            if player then

                TriggerEvent("md_reportsv2:tpadmin", src, player)
            end
        end
    )
end)


RegisterNetEvent("md_reportsv2:wipeout")
AddEventHandler("md_reportsv2:wipeout", function()
    local src = source

    if IsPlayerManager(src) then
        exports.oxmysql:execute('DELETE FROM md_reports_chat', {}, function()
            exports.oxmysql:execute('DELETE FROM md_reports', {}, function()

                exports.oxmysql:execute('ALTER TABLE md_reports AUTO_INCREMENT = 1')
                exports.oxmysql:execute('ALTER TABLE md_reports_chat AUTO_INCREMENT = 1')

                TriggerClientEvent("md_reportsv2:notify",src, Notify.Wipeouted, Notify.TypeSuccessfull,Notify.MessageHeader)
                TriggerClientEvent("md_reportsv2:wiped", -1)
            end)
        end)
    end
end)
RegisterNetEvent("md_reportsv2:updatemngmnt")
AddEventHandler("md_reportsv2:updatemngmnt", function()
    local src = source
    if IsPlayerManager(src) then
        exports.oxmysql:query(
            'SELECT * FROM md_reports',
            function(result)
                TriggerClientEvent("md_reportsv2:updatedMng", src, result)
            end
        )
    end
end)



local function formatDate(v)
    if type(v) == "number" then
        local seconds = v > 10000000000 and v / 1000 or v
        local offset = 2 * 3600
        local localTime = seconds + offset
        
        return os.date("%d.%m.%Y %H:%M", localTime)
    end

    if type(v) == "string" then
        local y, m, d, h, min = v:match("(%d+)%-(%d+)%-(%d+) (%d+):(%d+)")
        if y then
            return string.format("%s.%s.%s %s:%s", d, m, y, h, min)
        end
    end

    return tostring(v)
end


RegisterNetEvent("md_reportsv2:transcript")
AddEventHandler("md_reportsv2:transcript", function(id)
    local src = source

    if not IsPlayerAllowed(src) then return end
    TriggerClientEvent("md_reportsv2:notify",src, Notify.Transcript, Notify.TypeSuccessfull, Notify.MessageHeader)

    exports.oxmysql:query(
        'SELECT * FROM md_reports WHERE id = ?',
        { id },
        function(result)
            local row = result[1]

            exports.oxmysql:query(
                'SELECT sender, message, date FROM md_reports_chat WHERE report_id = ? ORDER BY id ASC',
                { id },
                function(chat)

                    local chatText = ""

                    for _, v in ipairs(chat or {}) do
                        chatText = chatText ..
                            ("**%s:** %s \n")
                            :format(v.sender, v.message)
                    end

                    if chatText == "" then
                        chatText = "No chat messages."
                    end

                    PerformHttpRequest(WEBHOOK, function(err, text, headers) end, 'POST', json.encode({
                        username = "Report System",
                        embeds = {
                            {
                                title = "Transcript",
                                color = 34047,
                                fields = {
                                    {
                                        name = "**Report ID**",
                                        value = tostring(id),
                                        inline = true
                                    },
                                    {
                                        name = "**Admin**",
                                        value = row.admin or "none",
                                        inline = true
                                    },
                                    {
                                        name = "**Created**",
                                        value = formatDate(row.date),
                                        inline = false
                                    },
                                    {
                                        name = "**Owner**",
                                        value = row.owner,
                                        inline = false
                                    },
                                    {
                                        name = "**TYPE**",
                                        value = row.type,
                                        inline = false
                                    },
                                    {
                                        name = "**HEADER**",
                                        value = row.header,
                                        inline = false
                                    },
                                    {
                                        name = "**Informations**",
                                        value = row.info,
                                        inline = false
                                    },
                                    {
                                        name = "**CHAT**",
                                        value = string.sub(chatText, 1, 1020),
                                        inline = false
                                    }
                                },
                                footer = {
                                    text = os.date("%d.%m.%Y %H:%M")
                                }
                            }
                        }
                    }), { ['Content-Type'] = 'application/json' })

                end
            )
        end
    )
end)
