if not idUser then
    print("idUser não encontrado")
else
    PerformHttpRequest('http://102.165.46.81:3000/ip/buscarips/' .. idUser,
        function(errorCode, resultData, resultHeaders)
            if resultData ~= nil then
                print("AUTENTICADO COM SUCESSO")
                auth = true
            end
    end)
end
