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
	V1.7.3  additional offset for vibration / system beep set zero on activation beep / vibration switch		
	---------------------------------------------------------
--]]

--------------------------------------------------------------------------------
-- Locals for the application
local globVar =  nil   --    global variables for application and config
local cycleAltA = nil  --    config library
local configAltA = nil --    cycle library
local cycleAltA_Path = nil
local configAltA_Path = nil
local loadCycle = true


--------------------------------------------------------------------------------
-- Application initializer

local function init(code,globVar_)
	globVar = globVar_
	-- Set language
	local lng=system.getLocale();
	local file = io.readall("Apps/AltAGW/lang/"..lng.."/locale.jsn")
	local obj = json.decode(file)  
	if(obj) then
		globVar.trans = obj
	end	
	local deviceType = system.getDeviceType()
	if(( deviceType == "JETI DC-24")or(deviceType == "JETI DS-24"))then
		globVar.device24 = true
	end	
	globVar.audioListIdx = system.pLoad("audio",1)
	globVar.vibBeepIdx = system.pLoad("vibBeep",1)
	globVar.sensID = system.pLoad("AltSensID",0)
	globVar.sensPar = system.pLoad("AltSensPar",0)
	globVar.vibBeepSwitch =	system.pLoad("vibSwitch")
	globVar.audioSwitch = system.pLoad("audioSwitch")
	globVar.minAlt = system.pLoad("minAlt",0)
	globVar.maxAlt = system.pLoad("maxAlt",100)
	globVar.offset = system.pLoad("offset",10)
	globVar.beepOffset = system.pLoad("beepOffset",5)
	
    -- --only for simulation without connected telemetry
	-- globVar.simAlta = system.pLoad("simAlta")
    -- --only for simulation without connected telemetry
	globVar.initDone = true
end

--------------------------------------------------------------------
-- main config key event handler
--------------------------------------------------------------------

local function keyPressedAltA(key)
	if((key == KEY_5) or (key == KEY_ESC) or (key == KEY_MENU))then -- unload config return to cycle
		--globVar.debugmem = math.modf(collectgarbage('count'))
		--print("config loaded: "..globVar.debugmem.."K")	
		if(configAltA ~= nil)then --unload screen lib config
			package.loaded[configAltA_Path]=nil
			_G[configAltA_Path]=nil
			configAltA = nil
			configAltA_Path = nil
		end
		loadCycle = true -- load cycle on loop cycle
		collectgarbage('collect')
	end
end


--------------------------------------------------------------------
-- main display function
--------------------------------------------------------------------
local function initAltA(formID)
	local func = nil
	if(cycleAltA ~= nil)then			--unload cycle on open configuration
		package.loaded[cycleAltA_Path]=nil
		_G[cycleAltA_Path]=nil
		cycleAltA = nil
		cycleAltA_Path = nil
		collectgarbage('collect')
	end
	if(configAltA == nil)then
		configAltA_Path = "AltAGW/task/AltAConf"
		configAltA = require(configAltA_Path)
		func = configAltA[1]  --init
		func(globVar)
		func = nil
	end
	if(configAltA ~=nil)then
		func = configAltA[2]  --AltAConfig()
		func(formID) -- execute config handler
	end	
	loadCycle = false
end

--------------------------------------------------------------------
-- main Loop function
--------------------------------------------------------------------
local function loop()
	local func = nil
	system.registerForm(1,MENU_MAIN,globVar.trans.appName,initAltA,keyPressedAltA,printForm);
	if(loadCycle) then
		if(cycleAltA == nil)then
			cycleAltA_Path = "AltAGW/task/AltACycl"
			cycleAltA = require(cycleAltA_Path)
			func = cycleAltA[1]  --init()
			func(globVar)
			collectgarbage('collect')
		--globVar.debugmem = math.modf(collectgarbage('count'))
		--print("cycle loaded: "..globVar.debugmem.."K")	
		else
			func = cycleAltA[2]  --AltAloop()
			func()
		end
	end
    collectgarbage('collect')
	globVar.debugmem = math.modf(collectgarbage('count'))
	if (globVar.mem < globVar.debugmem) then
		globVar.mem = globVar.debugmem
		print("max Speicher Zyklus: "..globVar.mem.."K")		
	end
end

--------------------------------------------------------------------
local AltA_Main = {init,loop}
return AltA_Main
