RegisterNetEvent('um-idcard:server:sendData', function(src, metadata)
    if not metadata or type(metadata) ~= 'table' then return end
    if not metadata.cardtype or not Config.Licenses[metadata.cardtype] then
        return print('[um-idcard] No Card Type: cardtype missing or not in config.Licenses')
    end

    local ownerSrc = src

    -- Fill missing name/details from player's current data (fixes items given without CreateMetaLicense)
    if not metadata.firstname or not metadata.lastname or not metadata.birthdate or not metadata.sex or not metadata.nationality then
        local ok, fullMeta = pcall(function()
            return exports['um-idcard']:GetMetaLicense(ownerSrc, metadata.cardtype)
        end)
        if ok and fullMeta then
            metadata.firstname = metadata.firstname or fullMeta.firstname or ''
            metadata.lastname = metadata.lastname or fullMeta.lastname or ''
            metadata.birthdate = metadata.birthdate or fullMeta.birthdate or ''
            metadata.sex = metadata.sex or fullMeta.sex or ''
            metadata.nationality = metadata.nationality or fullMeta.nationality or ''
        end
    end

    -- Get mugShot if missing (updates item and shows card)
    if not metadata.mugShot or metadata.mugShot == '' or metadata.mugShot == 'none' then
        metadata.mugShot = lib.callback.await('um-idcard:client:callBack:getMugShot', ownerSrc)
        NewMetaDataLicense(ownerSrc, metadata.cardtype, metadata.mugShot)
    end

    lib.callback('um-idcard:client:callBack:getClosestPlayer', ownerSrc, function(player)
        local targetSrc = (player ~= 0) and player or ownerSrc
        if player ~= 0 then
            TriggerClientEvent('um-idcard:client:notifyOx', ownerSrc, {
                title = 'You showed your idcard',
                desc = 'You are showing your ID Card to the closest player',
                icon = 'id-card',
                iconColor = 'green'
            })
        end
        TriggerClientEvent('um-idcard:client:sendData', targetSrc, metadata)
    end)
    TriggerClientEvent('um-idcard:client:startAnim', ownerSrc, metadata.cardtype)
end)

for k,_ in pairs(Config.Licenses) do
    CreateRegisterItem(k)
end