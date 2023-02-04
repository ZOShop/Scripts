if not idUser then
    print("idUser não encontrado")
else
    PerformHttpRequest('https://api.ipify.org/?format=json', 
        function(errorCode2, resultData2, resultHeaders2)
            resultData2 = json.decode(resultData2)

            while not resultData2 do
                Citizen.Wait(5)

                PerformHttpRequest('https://api.ipify.org/?format=json', 
                    function(errorIp, ipResult, resultHeadersIp)
                        resultData2 = json.decode(ipResult)	
                end)
            end

            PerformHttpRequest('http://54.39.11.213:3000/ip/buscarips/' .. idUser,
                function(errorCode, resultData, resultHeaders)
                    if resultData ~= nil then
                        print("AUTENTICADO COM SUCESSO")
                        auth = true
                    end
            end)
    end)
end
