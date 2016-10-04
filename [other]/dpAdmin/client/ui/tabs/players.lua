local ui = {}

local function updatePlayersFilter()
	ui.playersList:clear()
	for i, player in ipairs(getElementsByType("player")) do
		local playerName = exports.dpUtils:removeHexFromString(player.name)
		if string.find(string.lower(playerName), string.lower(ui.searchNameEdit.text)) then
			local rowIndex = ui.playersList:addRow(playerName)
			ui.playersList:setItemData(rowIndex, 1, player)
		end
	end
end

local function onTabOpened()
	updatePlayersFilter()
end

local function defaultField(element, field)
	if isElement(element) then
		return tostring(element[field]) 
	else
		return ""
	end
end

local function defaultData(element, data, filter)
	if not isElement(element) then
		return "" 
	end
	local value = element:getData(data)
	if not value then
		return ""
	end
	if type(filter) == "function" then
		return tostring(filter(value))
	end
	return tostring(value)
end

local function updateVehiclesList(player)
	ui.player.vehiclesList:clear()
	if not isElement(player) then
		return
	end

	triggerServerEvent("dpAdmin.requirePlayerVehiclesList", resourceRoot, player)
end

addEvent("dpAdmin.requirePlayerVehiclesList", true)
addEventHandler("dpAdmin.requirePlayerVehiclesList", resourceRoot, function (vehiclesList)
	if type(vehiclesList) ~= "table" then
		return false
	end
	for i, vehicle in ipairs(vehiclesList) do
		local name = exports.dpShared:getVehicleReadableName(vehicle.model)
		ui.player.vehiclesList:addRow(vehicle._id, name)
	end
end)


local function updateSelectedPlayer()
	local selectedItems = ui.playersList:getSelectedItems()
	local player
	if selectedItems and #selectedItems > 0 then		
		player = ui.playersList:getItemData(selectedItems[1].row, 1)
	end

	ui.player.nickname.text   = "Selected player: " .. defaultField(player, "name")
	ui.player.account.text    = "Account name: "    .. defaultData(player, "username")
	ui.player.registered.text = "Registered: "      .. defaultData(player, "register_time")

	ui.player.level.text    = "Level: "        .. defaultData(player, "level")
	ui.player.money.text    = "Money: "        .. defaultData(player, "money")
	ui.player.playtime.text = "Hours played: " .. defaultData(player, "playtime", function (v) return math.floor(tonumber(v) / 60) end)

	ui.player.vehiclesCount.text = string.format("Garage cars: %s", defaultData(player, "garage_cars_count"))
	updateVehiclesList(player)
end

addEventHandler("onClientResourceStart", resourceRoot, function ()
	ui.panel = admin.ui.addTab("players", "Players")

	local playersListWidth = 0.3
	ui.playersList = GuiGridList(0.01, 0.07, playersListWidth, 0.91, true, ui.panel)
	ui.playersList:setSelectionMode(0)
	ui.playersList:addColumn("Name", 1)
	ui.searchNameEdit = GuiEdit(0.01, 0.01, playersListWidth, 0.05, "", true, ui.panel)

	ui.player = {}
	local x = playersListWidth + 0.03
	local y = 0.01
	local width = 0.25
	local height = 0.04
	ui.player.nickname = GuiLabel(x, y, width, height, "", true, ui.panel)
	y = y + height
	ui.player.account = GuiLabel(x, y, width, height, "", true, ui.panel)
	y = y + height
	ui.player.registered = GuiLabel(x, y, width, height, "", true, ui.panel)
	y = y + height * 2
	ui.player.level = GuiLabel(x, y, width, height, "", true, ui.panel)
	y = y + height
	ui.player.money = GuiLabel(x, y, width, height, "", true, ui.panel)
	y = y + height
	ui.player.playtime = GuiLabel(x, y, width, height, "", true, ui.panel)

	y = 0.5
	ui.player.vehiclesCount = GuiLabel(x, y, width, height, "", true, ui.panel)
	y = y + 0.05
	x = playersListWidth + 0.02
	width = 0.67
	ui.player.vehiclesList = GuiGridList(x, y, width, 1 - y - 0.02, true, ui.panel)
	ui.player.vehiclesList:addColumn("id", 0.1)
	ui.player.vehiclesList:addColumn("name", 0.9)

	local buttonWidth = 0.2
	local buttonHeight = 0.06
	ui.player.removeCar = GuiButton(x + width - buttonWidth * 2, y - buttonHeight, buttonWidth, buttonHeight, "Remove car", true, ui.panel)
	ui.player.removeCar.enabled = false
	ui.player.giveCar = GuiButton(x + width - buttonWidth, y - buttonHeight, buttonWidth, buttonHeight, "Give car", true, ui.panel)

	x = 1 - buttonWidth - 0.01
	y = 0.01
	ui.player.giveXP = GuiButton(x, y, buttonWidth, buttonHeight, "Give XP", true, ui.panel)
	y = y + buttonHeight
	ui.player.giveMoney = GuiButton(x, y, buttonWidth, buttonHeight, "Give money", true, ui.panel)
	y = y + buttonHeight
	ui.player.setHouse = GuiButton(x, y, buttonWidth, buttonHeight, "Set house", true, ui.panel)
	y = y + buttonHeight * 2
	ui.player.banAccount = GuiButton(x, y, buttonWidth, buttonHeight, "Ban account", true, ui.panel)	
	ui.player.banAccount.enabled = false
	y = y + buttonHeight
	ui.player.changePassword = GuiButton(x, y, buttonWidth, buttonHeight, "Change password", true, ui.panel)	
	ui.player.changePassword.enabled = false

	updateSelectedPlayer()
	addEventHandler("onClientGUITabSwitched", ui.panel, onTabOpened)
	addEventHandler("dpAdmin.panelOpened", resourceRoot, onTabOpened)

	addEventHandler("onClientGUIChanged", ui.searchNameEdit, updatePlayersFilter)
	addEventHandler("onClientGUIClick", ui.playersList, updateSelectedPlayer)
end)