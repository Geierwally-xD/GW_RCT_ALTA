--[[
	---------------------------------------------------------
    Cycle part of Geierwallys Altitude Announcer; makes voice or Systembeep \ vibration announcement of changed altitude with
    by user set intevals when model goes up or up and down.
    App is a request for glider-towing.
    Works in DC/DS-14/16/24
	---------------------------------------------------------
	V1.7.2  overworked storage managemet 
			optional systemBeep or vibration output for increasing altitude
	---------------------------------------------------------
--]]
local globVar =  nil   -- global variables for application and config
local prevVal = 0    -- previous output value
local prevBeepSwitch = false --vibration beep switch active
local beepStartVal = 0       -- start value for beep / vibration offset calculation
local prevBeepVal = 0		-- previous beep / vibration output value

--------------------------------------------------------------------------------
-- cycle  initializer
local function init(globVar_)
	globVar = globVar_
end	

local function AltAloop()
	local sensor = {}
	local curVal = 0

 	if(globVar.initDone == true)then
		if(globVar.sensID >0 and globVar.sensPar >0)then
			if((globVar.sensors[globVar.sensID]~=nil)and(globVar.sensParam[globVar.sensID][globVar.sensPar] ~=nil)) then
				sensor = system.getSensorByID (globVar.sensors[globVar.sensID],globVar.sensParam[globVar.sensID][globVar.sensPar])	
			end
		end	
		
		-- ------only for simulation without connected telemetry
		-- sensor = {}
		-- local AltASimVal = system.getInputsVal(globVar.simAlta)
		-- if(AltASimVal ~= nil)then
			-- sensor["valid"] = true
			-- sensor["value"] = 0
			-- sensor["unit"] ="m"
			-- AltASimVal = math.modf(AltASimVal*100) 
			-- AltASimVal = 30*AltASimVal/100
			-- sensor.value = AltASimVal
		-- else
			-- sensor["valid"] = false
			-- sensor["value"] = 0			
		-- end
		-- ------only for simulation without connected telemetry
		if(sensor.valid)then
			-- handle beep / vibration output
			if(system.getInputsVal(globVar.vibBeepSwitch)==1)then
				if(prevBeepSwitch == false)then
					prevBeepSwitch = true
					beepStartVal = sensor.value
				end
				local tempVal = math.modf(sensor.value - beepStartVal)
				if(tempVal % globVar.beepOffset ==0)then
					if(prevBeepVal < tempVal)then
						prevBeepVal = tempVal
						if(globVar.vibBeepIdx == 2) then  -- beep 
							system.playBeep(1,4000,500)
							--print("Beep",tempVal)
						elseif(globVar.vibBeepIdx == 3)then -- vibration
							system.vibration (false,1)
							--print("Vibration",tempVal)
						end
					else
						beepStartVal = math.modf(sensor.value)  -- preset next beep start value for lower altitude
						prevBeepVal = 0
					end
				end
			else
				prevBeepSwitch = false
				beepStartVal = 0
				prevBeepVal = 0
			end

			-- handle audio output
			if(sensor.value % globVar.offset == 0)then
				curVal = math.modf(sensor.value)
				if(curVal ~= prevVal)then
					if((curVal >= globVar.minAlt)and(curVal <= globVar.maxAlt))then -- is value in range for output?
						if(curVal > prevVal)then
							if (system.isPlayback () == false) then
								if(system.getInputsVal(globVar.audioSwitch)==1)then
									if((globVar.audioListIdx == 2)or(globVar.audioListIdx == 4))then -- up or up/down
										system.playNumber (curVal, 2,sensor.unit,"Altitude")
										--print("audio output",curVal)
									end	
								end
								prevVal = curVal
							end	
						else
							if (system.isPlayback () == false) then
								if(system.getInputsVal(globVar.audioSwitch)==1)then
									if((globVar.audioListIdx == 3)or(globVar.audioListIdx == 4))then -- down
										system.playNumber (curVal, 2,sensor.unit,"Altitude")
										--print("audio output",curVal)
									end	
								end
								prevVal = curVal
							end	
						end
					end	
				end
			end
		end
	end
end	

--------------------------------------------------------------------
local altACycle = {init,AltAloop}
return altACycle