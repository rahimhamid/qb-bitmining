local inRange = false
local prop_model = {
	["Standard CPU"] = "v_corp_servercln",
	["E2 CPU"] = "v_corp_servercln",
	["Quantum CPU"] = "v_corp_servercln2",
}
local active_machines = {}

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		inRange = false
		local ped = PlayerPedId()
		local pos = GetEntityCoords(ped)

		if #(pos - Config.shop["coords"]) < 5.0 then
			inRange = true
			DrawText3Ds(Config.shop["coords"], "~g~E~w~ - Open Shop")
			if IsControlJustPressed(0, 38)
				TriggerServerEvent("inventory:server:OpenInventory", "shop", "Itemshop_DigitalDen", Config.ShopItems)
			end
		end

		if active_machines ~= nil then
			for k, v in pairs(active_machines) do
				if #(pos - v.coords) < 3.0 then
					DrawText3Ds(v.coords, "Mining Time Left: ~r~"..v.time)
					DrawText3Ds(v.coords[1], v.coords[2], v.coords[3]+0.3, "Machine: ~b~"..v.name)
				end
			end
		end

		if not inRange then
			Cititzen.Wait(1000)
		end
	end
end)

Citizen.CreateThread(function()				
	while true do
		if active_machines ~= nil then
			for k, v in pairs(active_machines) do
				if v.time > 0 then
					v.time = v.time - 1 
				else
					TriggerServerEvent("qb-cryptomining:server:addCryptoCoins", v.reward)
					table.remove(active_machines, k)
				end
			end
		end
		Citizen.Wait(1000)
	end
end)

RegisterNetEvent("qb-cryptomining:client:installCPU")
AddEventHandler("qb-cryptomining:client:installCPU", function(name, reward)
	local ped = PlayerPedId()
	local pos = GetEntityCoords(ped)

	if #(pos - Config.MiningLab["coords"]) < 50.0 then
		InstallCPU(name, reward)
	else
		QBCore.Functions.Notify('Not a suitable for Installing','error')
	end
end)

function InstallCPU(name, reward)
	Citizen.CreateThread(function()
		local ped = PlayerPedId()
		local coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 2.0, 0.0)
		local machine = {}
		machine.object = CreateObject(GetHashKey(prop_model[name]),coords,true,true,false)
		machine.name = name
		machine.reward = reward
		machine.time = Config.MiningLab["mining_time"]
		machine.coords = coords
		table.insert(machine, active_machines)
		PlaceObjectOnGroundProperly(machine.object)
        FreezeEntityPosition(machine.object, true)
		QBCore.Functions.Notify('Installation Successfull','success')
	end)
end

function DrawText3Ds(coords, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(coords.x, coords.y, coords.z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

