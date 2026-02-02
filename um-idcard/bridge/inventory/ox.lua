if GetResourceState('ox_inventory') ~= 'started' then return end

local ox_inventory = exports.ox_inventory

function NewMetaDataLicense(src, itemName, mugShot)
    local newMetaDataItem = ox_inventory:Search(src, 1, itemName)
    for _, v in pairs(newMetaDataItem) do
        newMetaDataItem = v
        break
    end
    newMetaDataItem.metadata = newMetaDataItem.metadata or {}
    newMetaDataItem.metadata.mugShot = mugShot or lib.callback.await('um-idcard:client:callBack:getMugShot', src)
    ox_inventory:SetMetadata(src, newMetaDataItem.slot, newMetaDataItem.metadata)
end