local settingsMod = {
	
	SWIM_TAG = "SwimBasePart"; -- Name of the CollectionService tag for the swimmable baseparts
	WATER_DRAG_FORCE_MULTIPLIER = 1; -- Additional force multiplier to drag/push the player when in water
	WATER_JUMP_FORCE = .5; -- The force factor applied to the player when they attempt to jump in water 
	PLAYER_FLOAT_FACTOR = 0 -- Anything over n>0 will make the player float up, and vice versa with n<0

}

return settingsMod
