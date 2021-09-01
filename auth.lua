-- auth = false
local ip = {}
-- local zo = {}

function zo:checkvalue (tab, val)
    for index, value in ipairs(tab) do
        if value.ip == val and value.script == nScript then
            return true
        end
    end
    
    return false
end

PerformHttpRequest('ipv4bot.whatismyipaddress.com/', 
    function(errorCode2, resultData2, resultHeaders2)
        PerformHttpRequest('http://54.39.11.213:3000/ip/buscarips/' .. idUser,
            function(errorCode, resultData, resultHeaders)
		if resultData == nil then
			PerformHttpRequest('http://54.39.11.213:3000/ip/buscarips/',
			function(errorCode3, resultData3, resultHeaders3)
				resultData = resultData3
							
				if resultData == nil then
					auth = true
					zo:checkuth()
					return
				end
			end)
		end

                resultData = json.decode(resultData)

                if resultData["ips"] ~= nil then
                    ip = resultData2
					
                    if zo:checkvalue(resultData["ips"], ip) then 
                        auth = true
                        zo:checkuth()
                    else 
                        zo:checkuth()
                    end
                end
        end)
end)
