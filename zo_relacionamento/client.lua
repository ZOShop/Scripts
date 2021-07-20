-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONEXÃO
-----------------------------------------------------------------------------------------------------------------------------------------
src = {}
Tunnel.bindInterface("zo_relacionamento", src)
vSERVER = Tunnel.getInterface("zo_relacionamento")

local open = false
local idPlayerPedido = nil

function src.closeNui()
    open = false
    SetNuiFocus(false, false)
    vRP._DeletarObjeto()
    vRP._stopAnim(false)
    ClearPedTasks(PlayerPedId())
    SendNUIMessage({
        type = 'fecharCartaoStatus'
    })
    
end

Citizen.CreateThread(function()
    src.closeNui()
end)

function src.openNui()
    if usarAnimacaoAoAbrirMenu then
        local prop = "p_ld_id_card_01"

        local anim1 = "amb@world_human_stand_mobile@female@text@enter"
        RequestAnimDict(anim1)
        TaskPlayAnim(GetPlayerPed(-1), anim1, "enter", 8.0, 1.0, -1, 50, 0, 0, 0, 0)
        Citizen.Wait(2000)

        vRP._CarregarObjeto("amb@world_human_stand_mobile@female@text@base", "base", prop, 49, 28422)
    end

    local infos = vSERVER.searchMyInfos()

    if infos ~= nil then
        open = true
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = 'abrirCartaoStatus',
            dados = infos
        })
    end
    
end

function src.avisarTerminoSpawn(ex)
    open = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = 'abrirInfoTermino',
        dados = "Infelizmente o seu conjuge " .. ex .. " rompeu o relacionamento de vocês!"
    })
end

function src.request(id, text, time)
    open = true
    SetNuiFocus(false, false)
	SendNUIMessage({ type = "request", id = id, text = tostring(text), time = time })
end

Citizen.CreateThread(function()
	while true do
		local wait = 100

        if open then
            wait = 5
            if IsControlJustPressed(0, 246) then SendNUIMessage({ act = "event", event = "Y" }) end
		    if IsControlJustPressed(0, 303) then SendNUIMessage({ act = "event", event = "U" }) end
            if IsControlJustPressed(0, 23) then SendNUIMessage({ act = "event", event = "F" }) end
        end

        Citizen.Wait(wait)
    end
end)

RegisterCommand("relac", function(args, rawCommand)
    src.openNui()
end)

RegisterNUICallback("ButtonClick", function(data, cb)
    if data.action == "fecharCartaoStatus" then
        src.closeNui()
    end

    if data.action == "buscarPessoaProximaPedido" then
        local msg = ""

        if data.tipo == 4 then
            local infos = vSERVER.searchMyInfos()

            msg = "Deseja realmente separar-se de " .. infos.conjuge .. "?"
        else
            local retorno = vSERVER.getNamePlayerProximityAndCheckRelac(data.tipo)
            
            if retorno ~= nil then
                idPlayerPedido = retorno.id
                msg = retorno.msg
                
            end
        end

        src.closeNui()

        if msg ~= "" then
            open = true
            SetNuiFocus(true, true)
            SendNUIMessage({
                type = 'openDialogConfirm',
                msg = msg
            })
        end
    end

    if data.action == "response" then
        vSERVER.requestResult(data.id, data.ok)
        open = false
    end

    if data.action == "dialogConfirmResult" then
        if data.tipo == 1 then
            if idPlayerPedido then
                vSERVER.pedirNamoro(idPlayerPedido)
            end
        elseif data.tipo == 2 then
            if idPlayerPedido then
                vSERVER.pedirNoivado(idPlayerPedido)
            end
        elseif data.tipo == 3 then
            if idPlayerPedido then
                vSERVER.pedirCasamento(idPlayerPedido)
            end
        elseif data.tipo == 4 then
            vSERVER.separar()
        end

        SetNuiFocus(false, false)
    end
end)

function src.returnTimeWaitAlign(id)
    local playerPed = PlayerPedId()
    local playerPedTwo = GetPlayerPed(GetPlayerFromServerId(id))

    SetPedDesiredHeading(playerPedTwo, GetEntityHeading(playerPed) - 180.0)

    Citizen.Wait(1000)

    local x, y, z = table.unpack(GetEntityCoords(playerPedTwo))

    local ox2, oy2, oz2 = table.unpack(GetOffsetFromEntityGivenWorldCoords(playerPedTwo, x, y, z))
    x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(playerPedTwo, ox2 + 0.00001, oy2 - 0.50001, oz2 + 0.00001))

    local dstCheck = GetDistanceBetweenCoords(GetEntityCoords(playerPed), x, y, z, true)
    local wait = dstCheck * 1000

    return wait
end

function src.clearPedActionAndObjects()
    local playerPed = PlayerPedId()
    vRP._DeletarObjeto()
    vRP._stopAnim(false)
    ClearPedTasks(playerPed)
end

RegisterNetEvent("zo:alignPeds")
AddEventHandler("zo:alignPeds", function(other)
    local playerPed = PlayerPedId()
    local ped = GetPlayerPed(GetPlayerFromServerId(other))

    local x, y, z = table.unpack(GetEntityCoords(ped))

    local ox2, oy2, oz2 = table.unpack(GetOffsetFromEntityGivenWorldCoords(ped, x, y, z))
    x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(ped, ox2 + 0.00001, oy2 + 0.50001, oz2 + 0.00001))

    local dstCheck = GetDistanceBetweenCoords(GetEntityCoords(playerPed), x, y, z, true)
    local wait = dstCheck * 1000

    TaskWanderInArea(playerPed, x, y, z, 0.0, 0.0, 1.0)
    Citizen.Wait(wait + 500)

    SetPedDesiredHeading(playerPed, GetEntityHeading(ped) - 170.0)

    ClearPedTasks(playerPed)
end)