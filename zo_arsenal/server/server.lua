if checkoutGitCode then
    local Tunnel = module("vrp", "lib/Tunnel")
    local Proxy = module("vrp", "lib/Proxy")
    vRP = Proxy.getInterface("vRP")
    vRPclient = Tunnel.getInterface("vRP")

    src = {}
    Tunnel.bindInterface("zo_arsenal", src)

    TriggerEvent("zo_arsenal:server_loadout", -1)

    function src.checkPermissionByType(type)
        for i, perm in pairs(cfg.perms[type]) do
            if src.checkPermission(perm) then return true end
        end

        return false
    end

    function src.checkPermission(perm)
        local user_id = vRP.getUserId(source)
        if vRP.hasPermission(user_id, perm) then
            return true
        else
            return false
        end
    end

    RegisterServerEvent('zo_arsenal:colete')
    AddEventHandler('zo_arsenal:colete', function()
        local src = source
        local user_id = vRP.getUserId(src)
        local colete = 100
        vRPclient.setArmour(src, 100)
        vRP.setUData(user_id, "vRP:colete", json.encode(colete))
    end)

    RegisterServerEvent('zo_arsenal:limpar_colete')
    AddEventHandler('zo_arsenal:limpar_colete', function()
        local src = source
        local user_id = vRP.getUserId(src)
        local colete = 0
        vRPclient.setArmour(src, 0)
        vRP.setUData(user_id, "vRP:colete", json.encode(colete))
    end)

    RegisterServerEvent('zo_arsenal:log')
    AddEventHandler('zo_arsenal:log', function(type, title, desc)
        local source = source
        local user_id = vRP.getUserId(source)
        local identity = vRP.getUserIdentity(user_id)

        log(cfg.logs[type].link, identity, user_id, desc, nil, title)
    end)

    function log(link, identity, user_id, desc_comando, desc_comando_2,
                 titleDesc)
        if (desc_comando_2 == nil) then
            desc_comando_2 = "_______________"
        end

        PerformHttpRequest(link, function(err, text, headers) end, 'POST',
                           json.encode({
            embeds = {
                { ------------------------------------------------------------
                    title = titleDesc ..
                        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\n⠀",
                    thumbnail = {url = ""},
                    fields = {
                        {
                            name = identity.name .. " " .. identity.firstname ..
                                " [**" .. user_id .. "**] \n",
                            value = "_______________"
                        }, {name = desc_comando, value = desc_comando_2}
                    },
                    footer = {
                        text = "DATA E HORA - " ..
                            os.date("%d/%m/%Y | %H:%M:%S"),
                        icon_url = ""
                    },
                    color = 8519935
                }
            }
        }), {['Content-Type'] = 'application/json'})
    end
end
