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
                print(resultData)
                resultData = json.decode(resultData)

                if resultData["ips"] ~= nil then
                    ip = resultData2
                    if zo:checkvalue(resultData["ips"], ip) then 
                        auth = true
                        zo:checkuth()
                    else 
                        zo:checkuth()
                    end
                else
                    auth = true
                    zo:checkuth()
                end
        end)
end)

-- function zo:checkuth()
--     if auth then
--         print(" ^2SCRIPT AUTENTICADO COM SUCESSO !^0")
--     else
--         print(" ^1SCRIPT NAO AUTENTICADO^0")
--     end
-- end
