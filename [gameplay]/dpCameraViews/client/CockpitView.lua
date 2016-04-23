CockpitView = {}
local isActive = false
local positionOffset = Vector3()
local lookOffset = Vector3()

local function wrapAngle(value)
	if not value then
		return 0
	end
	value = math.mod(value, 360)
	if value < 0 then
		value = value + 360
	end
	return value
end

local function update(deltaTime)
	if not localPlayer.vehicle then
		CockpitView.stop()
		return 
	end
	deltaTime = deltaTime / 1000
	
	local cameraPos = localPlayer.vehicle.matrix:transformPosition(positionOffset)
	local cameraLook = localPlayer.vehicle.matrix:transformPosition(lookOffset)
	local cameraRoll = -localPlayer.vehicle.rotation.y

	Camera.setMatrix(cameraPos, cameraLook, cameraRoll)
end

function CockpitView.start()
	local offsets = cockpitOffsets[localPlayer.vehicle.model]
	if not offsets then
		return false
	end

	positionOffset = Vector3(offsets.bx, offsets.by, offsets.bz)
	lookOffset = Vector3(offsets.ax, offsets.ay, offsets.az)
	localPlayer.alpha = 0

	addEventHandler("onClientPreRender", root, update)
	return true
end

function CockpitView.stop()
	localPlayer.alpha = 255
	Camera.setTarget(localPlayer)
	removeEventHandler("onClientPreRender", root, update)
end

CockpitView.start()