local ip = {}

function validadeLocalPerformHttpRequest()
    local dataHttpRequest = debug.getinfo(PerformHttpRequest)
	
    if dataHttpRequest.source ~= "@citizen:/scripting/lua/scheduler.lua" then
	print(" ^1OPS^0 - A FUNÇÃO 'PerformHttpRequest' foi reescrita^0")
		
	Citizen.CreateThread(function()
            local segundos = 10

            while segundos > 0 do
                print("^0O SERVIDOR SERÁ FECHADO EM: ^0" .. segundos)

                segundos = segundos - 1
		Citizen.Wait(1000)
            end

            os.exit()
        end)
    end
	
    return dataHttpRequest.source ~= "@citizen:/scripting/lua/scheduler.lua"
end

function zo:checkvalue(tab, val)
    if validadeLocalPerformHttpRequest() then
	return false
    end
	
    for index, value in ipairs(tab) do
        if value.ip == val and value.script == nScript then
            return true
        end
    end
    
    return false
end

function zo:checkvaluenotscript(tab, val)
    if validadeLocalPerformHttpRequest() then
	return false
    end
	
    for index, value in ipairs(tab) do
        if value.ip == val then
            return true
        end
    end
    
    return false
end

-- https://api.ipify.org/?format=json
PerformHttpRequest('https://api.ipify.org/?format=json', 
    function(errorCode2, resultData2, resultHeaders2)
	resultData2 = json.decode(resultData2)
		
	while not resultData2  do
		Citizen.Wait(5)
		PerformHttpRequest('https://api.ipify.org/?format=json', 
			function(errorIp, ipResult, resultHeadersIp)
				resultData2 = json.decode(ipResult)	
		end)
	end
		
        PerformHttpRequest('http://54.39.11.213:3000/ip/buscarips/' .. idUser,
            function(errorCode, resultData, resultHeaders)
		if resultData == nil then
			PerformHttpRequest('http://54.39.11.213:3000/ip/buscarips/',
			function(errorCode3, resultData3, resultHeaders3)
				resultData = resultData3
							
				if resultData == nil then
					print("Erro ao estabelecer conexão com o servidor de autenticação! Script autenticado por segurança, servidor em manutenção!")

					auth = true
					zo:checkuth()
								
					return
				else
					resultData = json.decode(resultData)

					if resultData["ips"] ~= nil then
					    ip = resultData2.ip

					    if zo:checkvaluenotscript(resultData["ips"], ip) then 
						auth = true
						zo:checkuth()
					    else 
						zo:checkuth()
					    end
					end
				end
			end)
		else
			resultData = json.decode(resultData)

			if resultData["ips"] ~= nil then
			    ip = resultData2.ip

			    if zo:checkvalue(resultData["ips"], ip) then 
				auth = true
				zo:checkuth()
			    else 
				zo:checkuth()
			    end
			end
		end
        end)
end)
