-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

src = {}
Tunnel.bindInterface("zo_relacionamento", src)
Proxy.addInterface("zo_relacionamento", src)

vCLIENT = Tunnel.getInterface("zo_relacionamento")

local statusRelacionamento = {
	[0] = { index = "solteiro", title = "Solteiro", pedido = "" },
	[1] = { index = "namorando", title = "Namorando", pedido = "Namoro" },
	[2] = { index = "noivando", title = "Noivo(a)", pedido = "Noivado" },
	[3] = { index = "casado", title = "Casado(a)", pedido = "Casamento" }
}

local Tools = {}
local IDGenerator = {}

function Tools.newIDGenerator()
	local r = setmetatable({}, { __index = IDGenerator })
	r:construct()
	return r
end

function IDGenerator:construct()
	self:clear()
end

function IDGenerator:clear()
	self.max = 0
	self.ids = {}
end

function IDGenerator:gen()
	if #self.ids > 0 then
		return table.remove(self.ids)
	else
		local r = self.max
		self.max = self.max+1
		return r
	end
end

function IDGenerator:free(id)
	table.insert(self.ids,id)
end

function src.getInfosRelac(id)
	local consulta = vRP.getSData("ZoRelac:" .. id) or {}
	return json.decode(consulta) or {}
end

function src.searchMyInfos()
	local source = source
	local user_id = vRP.getUserId(source)

	if user_id then
		local resultado = src.getInfosRelac(user_id)

		print(resultado)

		print(#resultado)
		if #resultado ~= nil and resultado.idConjuge then
			resultado["statusTitle"] = statusRelacionamento[resultado.status].title
			return resultado
		else
			local relac = {}

			relac.conjuge = "Indefinido"
			relac.desde = tostring(os.date("%d/%m/%Y"))
			relac.status = 0
			relac.idConjuge = 0

			vRP.setSData("ZoRelac:" .. user_id, json.encode(relac))

			resultado = src.getInfosRelac(user_id)
			
			print(#resultado)
			if resultado ~= nil and resultado.idConjuge then
				resultado["statusTitle"] = statusRelacionamento[resultado.status].title
				return resultado
			end
		end
	end

	return
end

function src.getNamePlayerProximityAndCheckRelac(type)
	local source = source
	local user_id = vRP.getUserId(source)
	local nplayer = vRPclient.getNearestPlayer(source, 2)

	if nplayer then
		local nuser_id = vRP.getUserId(nplayer)
		local identity = vRP.getUserIdentity(nuser_id)
		local resultado = src.getInfosRelac(nuser_id)
		local myresult = src.getInfosRelac(nuser_id)

		if resultado ~= nil and resultado.status then
			if resultado.status ~= 0 then
				if myresult ~= nil and myresult.idConjuge then
					if user_id ~= myresult.idConjuge then
						TriggerClientEvent("Notify", source, "aviso", "Ops! " .. identity.name .. ' ' .. identity.firstname .. " já está em um relacionamento!")
						return
					else
						return { msg = "Deseja realmente pedir " .. identity.name .. ' ' .. identity.firstname .. " em " .. statusRelacionamento[type].pedido .. "?", id = nuser_id }
					end
				end
			else
				return { msg = "Deseja realmente pedir " .. identity.name .. ' ' .. identity.firstname .. " em " .. statusRelacionamento[type].pedido .. "?", id = nuser_id }
			end
		else
			local relac = {}

			relac.conjuge = "Indefinido"
			relac.desde = tostring(os.date("%d/%m/%Y"))
			relac.status = 0

			vRP.setSData("ZoRelac:" .. nuser_id, json.encode(relac))
			
			resultado = src.getInfosRelac(nuser_id)

			if resultado.status ~= 0 then
				TriggerClientEvent("Notify", source, "aviso", "Ops! " .. identity.name .. ' ' .. identity.firstname .. " já está em um relacionamento!")
				return
			else
				return "Deseja realmente pedir " .. identity.name .. ' ' .. identity.firstname .. " em " .. statusRelacionamento[type].pedido .. "?" 
			end
		end
	else
		TriggerClientEvent("Notify", source, "aviso", "Ninguém próximo a você!")
	end

	return
end

function src.pedirNamoro(id)
	local source = source
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)
	local identity_c = vRP.getUserIdentity(id)
	local nplayer = vRP.getUserSource(id)

	TriggerClientEvent("zo:alignPeds", source, nplayer)

	local wait = vCLIENT.returnTimeWaitAlign(source, id)

	Citizen.Wait(wait + 1000)

	vRPclient._playAnim(source,false,{{"amb@medic@standing@kneel@idle_a","idle_a"}},false)

	Wait(1000)

	vRPclient._playAnim(source,true,{{"anim@heists@box_carry@","idle"}},true)
	vRPclient._playAnim(nplayer,false,{{"rcmme_tracey1","nervous_loop"}},true)
	local rosa = vRPclient._CarregarObjeto(source,"anim@heists@humane_labs@finale@keycards","cellphone_call_to_text","prop_single_rose",50,60309,0.055,0.05,0.0,240.0,0.0,0.0)

	Wait(1000)

	local resp = src.requestCreator(nplayer, identity.name .. ' ' .. identity.firstname .. " pediu-lhe em Namoro, deseja aceitar o pedido?", 30)

	if resp then
		local relac = src.getInfosRelac(user_id)
		
		relac.conjuge = identity_c.name .. ' ' .. identity_c.firstname
		relac.desde = tostring(os.date("%d/%m/%Y"))
		relac.status = 1
		relac.idConjuge = id

		vRP.setSData("ZoRelac:" .. user_id, json.encode(relac))

		relac = src.getInfosRelac(id)
		
		relac.conjuge = identity.name .. ' ' .. identity.firstname
		relac.desde = tostring(os.date("%d/%m/%Y"))
		relac.status = 1
		relac.idConjuge = user_id

		vRP.setSData("ZoRelac:" .. id, json.encode(relac))

		vRPclient._playAnim(nplayer,false,{{"anim@mp_player_intincarthumbs_uplow@ds@","enter"}},true)

		TriggerClientEvent("Notify", source, "sucesso", "Parabéns, você está namorando!")
		TriggerClientEvent("Notify", nplayer, "sucesso", "Parabéns, você está namorando!")

		Citizen.Wait(500)

		vCLIENT.clearPedActionAndObjects(source)
		vCLIENT.clearPedActionAndObjects(nplayer)
	else
		vRPclient._playAnim(nplayer,false,{{"gestures@m@standing@casual","gesture_no_way"}},true)
		TriggerClientEvent("Notify", source, "aviso", "Infelizmente seu pedido foi recusado!")
		TriggerClientEvent("Notify", nplayer, "aviso", "Você recusou o pedido!")

		Citizen.Wait(500)

		vCLIENT.clearPedActionAndObjects(source)
		vCLIENT.clearPedActionAndObjects(nplayer)
	end
end

function src.pedirNoivado(id)
	local source = source
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)
	local identity_c = vRP.getUserIdentity(id)
	local nplayer = vRP.getUserSource(id)

	TriggerClientEvent("zo:alignPeds", source, nplayer)

	local wait = vCLIENT.returnTimeWaitAlign(source, id)

	Citizen.Wait(wait + 1000)

	vRPclient._playAnim(source,false,{{"amb@medic@standing@kneel@idle_a","idle_a"}},false)

	Wait(1000)

	vRPclient._playAnim(source,true,{{"anim@heists@box_carry@","idle"}},true)
	vRPclient._playAnim(nplayer,false,{{"rcmme_tracey1","nervous_loop"}},true)
	local rosa = vRPclient._CarregarObjeto(source,"anim@heists@humane_labs@finale@keycards","cellphone_call_to_text","prop_single_rose",50,60309,0.055,0.05,0.0,240.0,0.0,0.0)

	Wait(1000)

	local resp = src.requestCreator(nplayer, identity.name .. ' ' .. identity.firstname .. " pediu-lhe em Noivado, deseja aceitar o pedido?", 30)

	if resp then
		local relac = src.getInfosRelac(user_id)
		
		relac.conjuge = identity_c.name .. ' ' .. identity_c.firstname
		relac.desde = tostring(os.date("%d/%m/%Y"))
		relac.status = 2
		relac.idConjuge = id

		vRP.setSData("ZoRelac:" .. user_id, json.encode(relac))

		relac = src.getInfosRelac(id)
		
		relac.conjuge = identity.name .. ' ' .. identity.firstname
		relac.desde = tostring(os.date("%d/%m/%Y"))
		relac.status = 2
		relac.idConjuge = user_id

		vRP.setSData("ZoRelac:" .. id, json.encode(relac))

		TriggerClientEvent("Notify",source,"sucesso","Ela aceitou!")
	else
		TriggerClientEvent("Notify",source,"sucesso","Ela recusou!")
	end
end

function src.pedirCasamento(id)
	local source = source
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)
	local identity_c = vRP.getUserIdentity(id)
	local nplayer = vRP.getUserSource(id)

	TriggerClientEvent("zo:alignPeds", source, nplayer)

	local wait = vCLIENT.returnTimeWaitAlign(source, id)

	Citizen.Wait(wait + 1000)

	vRPclient._playAnim(source,false,{{"amb@medic@standing@kneel@idle_a","idle_a"}},false)

	Wait(1000)

	vRPclient._playAnim(source,true,{{"anim@heists@box_carry@","idle"}},true)
	vRPclient._playAnim(nplayer,false,{{"rcmme_tracey1","nervous_loop"}},true)
	local rosa = vRPclient._CarregarObjeto(source,"anim@heists@humane_labs@finale@keycards","cellphone_call_to_text","prop_single_rose",50,60309,0.055,0.05,0.0,240.0,0.0,0.0)

	Wait(1000)

	local resp = src.requestCreator(nplayer, identity.name .. ' ' .. identity.firstname .. " pediu-lhe em Casamento, deseja aceitar o pedido?", 30)

	if resp then
		local relac = src.getInfosRelac(user_id)
		
		relac.conjuge = identity_c.name .. ' ' .. identity_c.firstname
		relac.desde = tostring(os.date("%d/%m/%Y"))
		relac.status = 3
		relac.idConjuge = id

		vRP.setSData("ZoRelac:" .. user_id, json.encode(relac))

		relac = src.getInfosRelac(id)
		
		relac.conjuge = identity.name .. ' ' .. identity.firstname
		relac.desde = tostring(os.date("%d/%m/%Y"))
		relac.status = 3
		relac.idConjuge = user_id

		vRP.setSData("ZoRelac:" .. id, json.encode(relac))

		TriggerClientEvent("Notify",source,"sucesso","Ela aceitou!")
	else
		TriggerClientEvent("Notify",source,"sucesso","Ela recusou!")
	end
end

function src.separar()
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)

	local relac = src.getInfosRelac(user_id)

	local id = relac.idConjuge
	local nplayer = vRP.getUserSource(id)
		
	relac["ex"] = relac.conjuge
	relac["avisoTermino"] = 0
	relac.conjuge = "Indefinido"
	relac.desde = tostring(os.date("%d/%m/%Y"))
	relac.status = 0

	vRP.setSData("ZoRelac:" .. user_id, json.encode(relac))
	TriggerClientEvent("Notify",source,"sucesso","Você separou-se de " .. relac.ex .. "!")

	relac = src.getInfosRelac(id)

	if nplayer then
		vCLIENT.avisarTerminoSpawn(nplayer, relac.conjuge)
		relac["avisoTermino"] = 0
	else
		relac["avisoTermino"] = 1
	end
	
	relac["ex"] = relac.conjuge
	relac.conjuge = "Indefinido"
	relac.desde = tostring(os.date("%d/%m/%Y"))
	relac.status = 0

	vRP.setSData("ZoRelac:" .. id, json.encode(relac))
end

AddEventHandler("vRP:playerSpawn",function(user_id, source, first_spawn)
	Citizen.Wait(10000)
    local resultado = src.getInfosRelac(user_id)
	
	if resultado ~= nil then
		if resultado.avisoTermino or 0 ~= 0 then
			vCLIENT.avisarTerminoSpawn(source, resultado.ex)
		end
	else
		local relac = {}
		relac.conjuge = "Indefinido"
		relac.desde = tostring(os.date("%d/%m/%Y"))
		relac.status = 0

		vRP.setSData("ZoRelac:" .. user_id, json.encode(relac))
	end
end)

local request_ids = Tools.newIDGenerator()
local requests = {}

function src.requestCreator(source, text, time)
	local r = async()
	local id = request_ids:gen()
	local request = { source = source, cb_ok = r, done = false }
	requests[id] = request

	vCLIENT.request(source, id, text, time)

	SetTimeout(time*1000,function()
		if not request.done then
			request.cb_ok(false)
			request_ids:free(id)
			requests[id] = nil
		end
	end)
	
	return r:wait()
end

function src.requestResult(id, ok)
	local request = requests[id]
	if request and request.source == source then
		request.done = true
		request.cb_ok(not not ok)
		request_ids:free(id)
		requests[id] = nil
	end
end