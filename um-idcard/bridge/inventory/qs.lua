if GetResourceState('qs-inventory') ~= 'started' then return end
local Inventory = exports['qs-inventory']

function NewMetaDataLicense(src, itemName, mugShot)
    local newMetaDataItem = Inventory:GetItemByName(src, itemName)
    if newMetaDataItem then
        local items = Inventory:GetInventory(src)
        local info = items[newMetaDataItem.slot].info or {}
        info.mugShot = mugShot or lib.callback.await('um-idcard:client:callBack:getMugShot', src)
        Inventory:SetItemMetadata(src, newMetaDataItem.slot, info)
    end
end
