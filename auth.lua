if not idUser then
    print("idUser não encontrado")
else
    PerformHttpRequest('http://89.213.5.217:3000/ip/buscarips/' .. idUser,
        function(errorCode, resultData, resultHeaders)
            if resultData ~= nil then
                auth = true
                zo:checkuth()
            end
    end)
end
