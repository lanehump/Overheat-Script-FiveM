function ShowNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentSubstringPlayerName(text)
    DrawNotification(false, false)
end
-- Define your weapon overheating configuration here
local overheatingWeapons = {
    {hash = GetHashKey("WEAPON_CARBINERIFLE_MK2"), overheatTime = 5000, tempThreshhold = 1000, currentTemp = 0},
    -- weapon configurations to have a specific time its overheated a max temp and current temp
    -- weapon format is easy to understand and change
    -- {hash = GetHashKey("WEAPON"), overheatTime = value in milliseconds, tempThreshhold = temp of when the gun overheats, currentTemp = initialized at 0}
}

local isOverheated = false


function HandleWeaponOverheating()
    while true do
        Citizen.Wait(0)

        local player = PlayerId()
        local currentWeapon = GetSelectedPedWeapon(GetPlayerPed(-1))

        if isOverheated then  -- Check if the gun is overheated or shooting is disabled
            DisablePlayerFiring(player, true)
        end

        if not isOverheated then
            for _, weapon in pairs(overheatingWeapons) do
                if currentWeapon == weapon.hash then
                    local overheatTime = weapon.overheatTime
                    if IsShooting() then -- steps weapon temp up as shooting
                        Citizen.Wait(100)
                        weapon.currentTemp = weapon.currentTemp + 100
                        print(weapon.currentTemp)
                    end
                    if not IsShooting() and not isOverheated then -- cools weapon while not shooting and not already on over heat cooldown
                        Citizen.Wait(3000)
                        if weapon.currentTemp > 0 then
                            weapon.currentTemp = weapon.currentTemp - 50
                            print("cooled down to " .. weapon.currentTemp)
                        end
                    end
                    if weapon.currentTemp >= weapon.tempThreshhold then -- handles when the temp thresh hold is met
                        isOverheated = true
                        if isOverheated then
                            ShowNotification("~r~Gun is overheated.")
                        end
                        Citizen.SetTimeout(weapon.overheatTime, function ()
                            isOverheated = false
                            weapon.currentTemp = 0
                        end)
                    end
                end
            end
        end
    end
end



function IsShooting()
    local player = GetPlayerPed(-1)
    local currentWeapon = GetSelectedPedWeapon(PlayerPedId())

    if IsControlPressed(0, 24) and currentWeapon ~= GetHashKey("WEAPON_UNARMED") then
        return true
    end
    return false
end


Citizen.CreateThread(HandleWeaponOverheating)




