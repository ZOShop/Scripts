if not idUser then
    resultItens = {
        notIdUser = true,
        isValid = validNumberAuthApi
    }
else
    local date = os.date("*t")
    local validNumberAuthApi = (date.day + date.year + date.min + date.sec + date.yday * date.month) / date.sec

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

                                resultItens = {
                                    notConnectionApi = true,
                                    isValid = validNumberAuthApi
                                }
                            else
                                resultData = json.decode(resultData)

                                if resultData["ips"] ~= nil then
                                    resultItens = {
                                        ip = resultData2.ip,
                                        results = resultData["ips"],
                                        isValid = validNumberAuthApi
                                    }
                                end
                            end
                        end)
                    else
                        resultData = json.decode(resultData)

                        if resultData["ips"] ~= nil then
                            resultItens = {
                                ip = resultData2.ip,
                                results = resultData["ips"],
                                isValid = validNumberAuthApi
                            }
                        end
                    end
            end)
    end)
end
