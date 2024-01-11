ESX = nil
local directions = { [0] = 'N', [45] = 'NW', [90] = 'W', [135] = 'SW', [180] = 'S', [225] = 'SE', [270] = 'E', [315] = 'NE', [360] = 'N', } 

CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getShtestaredObjtestect', function(obj) ESX = obj end)
		Citizen.Wait(100)
	end
end)

Citizen.CreateThread(function()
    local minimap = RequestScaleformMovie("minimap")
    SetRadarBigmapEnabled(true, false)
    Wait(0)
    SetRadarBigmapEnabled(false, true)
	SetRadarZoom(1200)
    while true do
        Wait(0)
        BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
		SetRadarBigmapEnabled(false, true)
		SetRadarZoom(1200)
        ScaleformMovieMethodAddParamInt(3)
        EndScaleformMovieMethod()
    end
end)

CreateThread(function()
    while true do
        Wait(400)
        local state = NetworkIsPlayerTalking(PlayerId())
        local mode = 'Normal'
        if NetworkGetTalkerProximity() == 2.5 then
            mode = 'Whisper'
        elseif NetworkGetTalkerProximity() == 8.0 then
            mode = 'Normal'
        elseif NetworkGetTalkerProximity() == 25.0 then
            mode = 'Shouting'
        end

        SendNUIMessage({
            type = 'UPDATE_VOICE',
            isTalking = state,
            mode = mode
        })
    end
end)

CreateThread(function()
    while true do
        Wait(50)
        if IsPedInAnyVehicle(PlayerPedId()) and not IsPauseMenuActive() then
            Wait(100)
            local PedCar = GetVehiclePedIsUsing(PlayerPedId(), false)
            Speed = math.floor(GetEntitySpeed(PedCar) * 3.6 + 0.5)
            MaxSpeed = math.ceil(GetVehicleEstimatedMaxSpeed(PedCar) * 3.6 + 0.5)
            SpeedPercent = Speed / MaxSpeed * 100
            rpm = GetVehicleCurrentRpm(PedCar) * 100

			SendNUIMessage({
                type = 'SHOW_CARHUD',
                speedometer = true,
				speed = Speed,
				percent = SpeedPercent,
				rpmx = rpm,
			})
        else
            Citizen.Wait(1000)

            SendNUIMessage({
                type = 'HIDE_CARHUD'
			})
        end
    end
end)

CreateThread(function()
    while true do
        Wait(450)
        if IsPedInAnyVehicle(PlayerPedId()) and not IsPauseMenuActive() then
			DisplayRadar(true)
            local PedCar = GetVehiclePedIsUsing(PlayerPedId(), false)
			local coords = GetEntityCoords(PlayerPedId())

			local _,lightsOn,highbeamsOn = GetVehicleLightsState(PedCar)
			local lightMode = 1
			if lightsOn == 1 then lightMode = lightMode + 1 end
			if highbeamsOn == 1 then lightMode = lightMode + 1 end

			SetMapZoomDataLevel(0, 0.96, 0.9, 0.08, 0.0, 0.0) -- Level 0
			SetMapZoomDataLevel(1, 1.6, 0.9, 0.08, 0.0, 0.0) -- Level 1
			SetMapZoomDataLevel(2, 8.6, 0.9, 0.08, 0.0, 0.0) -- Level 2
			SetMapZoomDataLevel(3, 12.3, 0.9, 0.08, 0.0, 0.0) -- Level 3
			SetMapZoomDataLevel(4, 22.3, 0.9, 0.08, 0.0, 0.0) -- Level 4
				
            SendNUIMessage({
                showhud = true,
				lights = lightMode,
				paliwo = fuel,
            })
			SendNUIMessage({
				type = 'UPDATE_SEATBELT',
				belt = exports['trp_dzwon']:seatbeltState()
			})
		else
			SendNUIMessage({
				showhud = false
			})
            if exports["gcphone"]:getMenuIsOpen() then
                DisplayRadar(true)
            else
                DisplayRadar(false)
            end
			Wait(2000)
		end   
	end
end)

local hash1, hash2;
CreateThread(function() 
    while true do
        Wait(500)
        local ped, direction = PlayerPedId(), nil
        for k, v in pairs(directions) do
            direction = GetEntityHeading(ped)
            if math.abs(direction - k) < 22.5 then
                direction = v
                break
            end
        end
        local coords = GetEntityCoords(ped, true)
        local zone = GetNameOfZone(coords.x, coords.y, coords.z)
        local zoneLabel = GetLabelText(zone)
        local var1, var2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z, Citizen.ResultAsInteger(), Citizen.ResultAsInteger())
        hash1 = GetStreetNameFromHashKey(var1);
		hash2 = GetStreetNameFromHashKey(var2);
        local street2;
        if (hash2 == '') then
			street2 = zoneLabel;
		else
			street2 = hash2..', '..zoneLabel;
		end
		--[[local blip = GetFirstBlipInfoId(8)
        local distance = 0
		local ghahahah = 0
        if (blip ~= 0) then
			local coord = GetBlipCoords(blip)
			ghahahah = CalculateTravelDistanceBetweenPoints(GetEntityCoords(Citizen.InvokeNative(0x43A66C31C68491C0,-1)), coord)
                    
			if blip ~= 0 then
				if ghahahah ~= 0 then
					distance = ghahahah
				else
					distance = 0
				end
			end
		end]]
        SendNUIMessage({
            street = street2,
			direction = (direction or 'N'),
			direction2 = direction .. ' | ' .. street2,
			--waypoint = distance,
        })   
    end    
end)

CreateThread(function()
    while true do
        Wait(1000)
        TriggerEvent('esx_status:getStatus', 'hunger', function(status)
            hunger = status.getPercent()
        end)
        TriggerEvent('esx_status:getStatus', 'thirst', function(status)
            thirst = status.getPercent()
        end)
        local armor = GetPedArmour(PlayerPedId())
        local hp = GetEntityHealth(PlayerPedId()) - 100
		local nurkowanie = GetPlayerUnderwaterTimeRemaining(PlayerId()) * 10
		--local inwater = IsPedSwimmingUnderWater(PlayerPedId()),
        SendNUIMessage({
            type = 'UPDATE_HUD',
			hunger = hunger,
			thirst = thirst,
            armor = armor,
            nurkowanie = nurkowanie,
            --inwater = inwater,
            zycie = hp,
            isdead = hp <= 0
        })
    end
end)

CreateThread(function() 
    while true do
        Wait(180000)
        TriggerEvent('esx_status:getStatus', 'hunger', function(status)
            hunger = status.getPercent()
        end)
        TriggerEvent('esx_status:getStatus', 'thirst', function(status)
            thirst = status.getPercent()
        end)
        if hunger < 20 and thirst < 20 then
            ESX.ShowNotification("Zostalo Ci ponizej 20% jedzenia i picia!")
        elseif hunger < 20 then
            ESX.ShowNotification("Zostalo Ci ponizej 20% jedzenia!")
        elseif thirst < 20 then
            ESX.ShowNotification("Zostalo Ci ponizej 20% picia!")
        end    
    end    
end)


CreateThread(function()
    while true do 
        Wait(5000)
        local idpedala = GetPlayerServerId(PlayerId())
        SendNUIMessage({
            type = 'UPDATE_ID',
			id = idpedala
        })
    end
end)

RegisterNetEvent("hud:Speedo", function(b) 
    SendNUIMessage({
        type = "HIDE_SPEDDO",
        bool = b
    })
end)
	
RegisterNetEvent('hud:updateSlot')
AddEventHandler('hud:updateSlot', function(slot, count, item)
    count = count and 'x' .. count
    
    SendNUIMessage({
        action = 'updateSlot',
        item = item,
        count = count,
        slot = slot
    })
end)
    
function ToggleSlots()
    if not ESX.UI.Menu.IsOpen('default', 'es_extended', 'inventory') then
        SendNUIMessage({action = 'toggleslots'})
    end
end

RegisterCommand("+toggleslots", ToggleSlots)
RegisterKeyMapping("+toggleslots", "Przełączanie widoczności slotów", "keyboard", "TAB") 

RegisterCommand("off", function(source, args, raw)
	ESX.DisplaySlots(false)
end)

RegisterCommand("edithud", function(source, args, raw)
	SendNUIMessage({ action = 'show_hud' })
	SetNuiFocus(true, true)
	cameraLocked = true -- wyjebac
end)

RegisterNUICallback("stopedit", function()
	SetNuiFocus(false, false)
	cameraLocked = false -- wyjebac
end)

-- wyjebac --
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if cameraLocked == true then
            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)
        end
    end  
end)

-- pawilon

Citizen.CreateThread(function()
	while true do
		local Ped = GetPlayerPed(-1)
		if(IsPedInAnyVehicle(Ped)) then
			local PedCar = GetVehiclePedIsIn(Ped, false)
			if PedCar and GetPedInVehicleSeat(PedCar, -1) == Ped then
				carSpeed = math.ceil(GetEntitySpeed(PedCar) * 3.6)
				fuel = GetVehicleFuelLevel(PedCar)
				rpm = GetVehicleCurrentRpm(PedCar)
				rpmfuel = 0

				if rpm > 0.9 then
					rpmfuel = fuel - rpm / 8.6
					Citizen.Wait(1000)
				elseif rpm > 0.8 then
					rpmfuel = fuel - rpm / 8.7
					Citizen.Wait(1500)
				elseif rpm > 0.7 then
					rpmfuel = fuel - rpm / 8.8
					Citizen.Wait(2000)
				elseif rpm > 0.6 then
					rpmfuel = fuel - rpm / 8.9
					Citizen.Wait(3000)
				elseif rpm > 0.5 then
					rpmfuel = fuel - rpm / 9.0
					Citizen.Wait(4000)
				elseif rpm > 0.4 then
					rpmfuel = fuel - rpm / 9.1
					Citizen.Wait(5000)
				elseif rpm > 0.3 then
					rpmfuel = fuel - rpm / 9.2
					Citizen.Wait(6000)
				elseif rpm > 0.2 then
					rpmfuel = fuel - rpm / 9.3
					Citizen.Wait(8000)
				else
					rpmfuel = fuel - rpm / 9.5
					Citizen.Wait(15000)
				end

				carFuel = SetVehicleFuelLevel(PedCar, rpmfuel)

				SendNUIMessage({
			showfuel = true,
					fuel = fuel
				})
			end
		end

		Citizen.Wait(1)
	end
end)