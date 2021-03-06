addEvent("garageEnterVehiclesReceived", false)
addEventHandler("garageEnterVehiclesReceived", resourceRoot, function (player, playerVehicles)
	if type(playerVehicles) ~= "table" or #playerVehicles == 0 then
		triggerClientEvent(player, "dpGarage.enter", resourceRoot, false, "garage_enter_failed_no_cars")
		return
	end
	player:setData("dpCore.state", "garage")

	-- _id машины, в которой был игрок, когда вошел в гараж (если это его машина)
	local enteredVehicleId

	-- Перенос игрока в уникальный dimension
	local garagePosition = Vector3 { x = 2915.438, y = -3186.282, z = 2535.3 }

	player.dimension = tonumber(player:getData("_id")) + 4000
	player.position = Vector3(garagePosition + Vector3(0, 5, 25))
	player.frozen = true
	player.interior = 0
	player.alpha = 0
	removePedFromVehicle(player)

	local vehicle = createVehicle(547, 5000, 0, -1000)
	vehicle.rotation = Vector3(0, 0, -90)
	vehicle.dimension = player.dimension
	vehicle.interior = player.interior
	player:setData("garageVehicle", vehicle)
	vehicle:setData("localVehicle", true)
	vehicle:setSyncer(player)

	triggerClientEvent(player, "dpGarage.enter", resourceRoot, true, playerVehicles, enteredVehicleId, vehicle)
	player:setData("activeMap", false)
end)

addEvent("dpGarage.enter", true)
addEventHandler("dpGarage.enter", resourceRoot, function ()
	if client:getData("dpCore.state") then
		triggerClientEvent(client, "dpGarage.enter", resourceRoot, false, "garage_enter_failed")
		return
	end
	if not client:getData("_id") then
		triggerClientEvent(client, "dpGarage.enter", resourceRoot, false, "garage_enter_failed")
		return
	end

	-- Выкинуть игрока из машины
	exports.dpCore:returnPlayerVehiclesToGarage(client)
	exports.dpCore:getPlayerVehiclesAsync(client, "garageEnterVehiclesReceived")
end)

addEvent("dpGarage.exit", true)
addEventHandler("dpGarage.exit", resourceRoot, function (selectedCarId)
	if client:getData("dpCore.state") ~= "garage" then
		triggerClientEvent(client, "dpGarage.exit", resourceRoot, false)
		return
	end
	client:setData("dpCore.state", false)
	-- Удаление машины
	local garageVehicle = client:getData("garageVehicle")
	if isElement(garageVehicle) then
		destroyElement(garageVehicle)
		garageVehicle = nil
	end

	-- Координаты дома
	local houseLocation = exports.dpHouses:getPlayerHouseLocation(client)
	if type(houseLocation) ~= "table" or type(houseLocation.garage) ~= "table" then
		client.position = Vector3(0, 0, 10)
	else
		client.position = houseLocation.garage.position
		client.rotation = houseLocation.garage.rotation
	end
	client.frozen = false
	client.dimension = 0
	client.interior = 0
	client.alpha = 255
	-- Если игрок выбрал машину в гараже
	if selectedCarId then
		local vehicle = exports.dpCore:spawnVehicle(selectedCarId, client.position, client.rotation)
		if isElement(vehicle) then
			warpPedIntoVehicle(client, vehicle)
		else
			outputDebugString("Garage server: Failed to spawn vehicle")
		end
	end
	triggerClientEvent(client, "dpGarage.exit", resourceRoot, true)
end)

addEventHandler("onResourceStart", resourceRoot, function ()
	for i, player in ipairs(getElementsByType("player")) do
		-- Сбросить state всех игроков при перезапуске ресурса
		if player:getData("dpCore.state") == "garage" then
			player:setData("dpCore.state", false)
			player.dimension = 0
		end
	end
end)
