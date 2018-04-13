--[[
	---------------------------------------------------------
    Geierwallys Altitude Announcer makes voice or Systembeep \ vibration announcement of changed altitude with
    by user set intevals when model goes up or up and down.
    App is a request for glider-towing.
    Works in DC/DS-14/16/24
	---------------------------------------------------------
	Released by Geierwally 05 2017
	---------------------------------------------------------
	G1.7.1 	Modified by Geierwally 05 2017 calculation of up and down
			step changed 
	---------------------------------------------------------
	V1.7.2  overworked storage managemet 
			optional systemBeep or vibration output for increasing altitude
	---------------------------------------------------------
--]]
--Configuration
--Local variables
local appLoaded = false
local main_lib = nil  -- lua main script
local initDelay = 0
local globVar ={--                          main version | version of screenlib | version of the app (or template) 
				simAlta = nil, --			only for simulation without connected telemetry
				version = "V1.7.2", --      version of the app 1.             1.                     1
				mem = 0,--                  maximum of used storage
				debugmem = 0,--             used storage
				trans = {},--               translations depending on set language
				sensors = {}, --			all sensor iDs
				sensParam = {}, --          all sensor parameter
				device24 = false, --		device is ds/dc 24 true otherwise false
				initDone = false, --	 App initialized
				vibBeepIdx = 1, -- 			beep / vibration off 
				audioListIdx = 1, -- 		audio output off , up , down , up/down 
				minAlt = 0, -- 				begin of output
				maxAlt = 0, -- 				end of output
				offset = 0, -- 				offset output
				audioSwitch = nil, -- 		switch for audio output
				vibBeepSwitch = nil, -- 	switch for vibration or system beep output
				sensID = 0,
				sensPar = 0,
			   }

-------------------------------------------------------------------- 
-- 
--------------------------------------------------------------------
local function init(code)
	if(code ==1)then
		if(initDelay == 0)then
			initDelay = system.getTimeCounter()
		end	
		if(main_lib ~= nil) then
			local func = main_lib[1]
			func(0,globVar) --init(0)
		end
	end	
end

--------------------------------------------------------------------
-- main Loop function
--------------------------------------------------------------------
local function loop() 
	globVar.currentTime = system.getTimeCounter()
	 -- load current task
    if(main_lib == nil)then
		init(1)
		if((globVar.currentTime - initDelay > 5)and(initDelay ~=0)) then
			if(appLoaded == false)then
				if(globVar.sensors[1]~=nil)then
					main_lib = require("AltAGW/Task/AltAMain")
					if(main_lib ~= nil)then
						appLoaded = true
						init(1)
						initDelay = 0
					end
					collectgarbage()
				else
					local memTxt = "max: "..globVar.mem.."K act: "..globVar.debugmem.."K"
					print(memTxt)
				
					local sensors_ = system.getSensors() -- read in all sensor data
					local sensPar = {}
					for k in next,globVar.sensors do globVar.sensors[k] = nil end
					for k in next,globVar.sensParam do globVar.sensParam[k] = nil end
					for idx,sensor in ipairs(sensors_) do
						if(sensor.param == 0) then
							if(sensPar[1] ~=nil)then
								table.insert(globVar.sensParam,sensPar)
								sensPar = {}
							end
							table.insert(globVar.sensors,sensor.id)
						else
							table.insert(sensPar,sensor.param)
						end
					end	
					if(sensPar[1]~=nil)then
						table.insert(globVar.sensParam,sensPar)
					end	

				end
			end	
		end	
	else
		local func = main_lib[2] --loop()
		func() -- execute main loop
	end	
	globVar.debugmem = math.modf(collectgarbage('count'))
	if (globVar.mem < globVar.debugmem) then
		globVar.mem = globVar.debugmem
		print("max Speicher Zyklus: "..globVar.mem.."K")		
	end
end
 
--------------------------------------------------------------------
return { init=init, loop=loop, author="Geierwally", version=globVar.version, name="Alt.Announcer"}