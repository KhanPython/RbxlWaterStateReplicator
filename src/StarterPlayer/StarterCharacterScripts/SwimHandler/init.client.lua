--[[** 
	Note: 
	This is not a 1:1 replica of the terrain's swim behavior. Most of the formula's used here are arbitrary and require additional research. 
]]

-- Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

-- Dependencies
local BasicState = require(script:WaitForChild("BasicState"))
local Settings = require(script:WaitForChild("Settings"))

-- Player-related
local Player = Players.LocalPlayer
local Character = Player.Character
local Humanoid = Character:FindFirstChildOfClass("Humanoid")
local Root = Character:FindFirstChild("HumanoidRootPart")

local swimTag = Settings["SWIM_TAG"]  

-- States
local swimState = BasicState.new({
	isSwimming = false;
	swimVelocity = nil
})



function checkIfInWater(): boolean	
	local list = workspace:GetPartsInPart(Root)
	for _, touchingPart in pairs(list) do
		if not table.find(CollectionService:GetTagged(swimTag), touchingPart) then
			continue
		end
		return true
	end
	
	return false
end


RunService.Heartbeat:Connect(function()
	local isSwimming = checkIfInWater()
	swimState:Set("isSwimming", isSwimming)
	
	-- Set swimming motion
	if isSwimming then
		swimState:Get("swimVelocity").Velocity = Humanoid.MoveDirection * Humanoid.WalkSpeed * Settings["WATER_DRAG_FORCE_MULTIPLIER"]/1 + Vector3.new(0, Settings["PLAYER_FLOAT_FACTOR"] * Settings["WATER_DRAG_FORCE_MULTIPLIER"]/1 , 0)
	end
end)


swimState:GetChangedSignal("isSwimming"):Connect(function(newState, _oldState)
	local swimVelocityState = swimState:Get("swimVelocity")
	
	if not newState then
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
		if swimVelocityState ~= nil then
			swimVelocityState:Destroy()
		end
	else 
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
		Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
		swimVelocityState = Instance.new("BodyVelocity")
		swimVelocityState.Parent = Root
		swimState:Set("swimVelocity", swimVelocityState)
	end
end)


Humanoid.StateChanged:Connect(function(_oldState, newState)
	if newState == Enum.HumanoidStateType.Jumping then
		if swimState:Get("isSwimming") then
			Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
			Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
		end
	end
end)


Humanoid:GetPropertyChangedSignal("Jump"):Connect(function()
	if swimState:Get("isSwimming") then
    	swimState:Get("swimVelocity").Velocity += Vector3.new(0, Settings["WATER_JUMP_FORCE"] * Humanoid.WalkSpeed * Settings["WATER_DRAG_FORCE_MULTIPLIER"]/1 , 0)
	end
end)