--[[
	---------------------------------------------------------
    Configuration part of Geierwallys Altitude Announcer; makes voice or Systembeep \ vibration announcement of changed altitude with
    by user set intevals when model goes up or up and down.
    App is a request for glider-towing.
    Works in DC/DS-14/16/24
	---------------------------------------------------------
	V1.7.2  overworked storage managemet 
			optional systemBeep or vibration output for increasing altitude
	V1.7.3  additional offset for vibration / system beep set zero on activation beep / vibration switch		
	---------------------------------------------------------
--]]
local globVar =  nil   --    global variables for application and config
local sensList = {} -- all sensor labels
local sensPaList = {} -- all sensor parameter labels for selected sensor
local sensListIdx = 1 -- index of sensor list box
local sensPaListIdx = 1 -- index of sesor parameter list box
local focRow = 3 

--------------------------------------------------------------------------------
-- Config initializer
local function init(globVar_)
	globVar = globVar_
end	

-------------------------------------------------------------------- 
-- AltA - lib configuration
-------------------------------------------------------------------- 
-- --only for simulation without connected telemetry
-- local function simAltaChanged(value)
	-- globVar.simAlta = value
	-- system.pSave("simAlta",globVar.simAlta)
-- end
-- --only for simulation without connected telemetry

local function sensorChanged(value)
	sensListIdx = value
	if(sensListIdx < #sensList)then
		globVar.sensID = sensListIdx -- set sensorid to corresponding window 
		sensPaListIdx = 1 
		globVar.sensPar = 1 -- preset parameter list index with first element
		system.pSave("AltSensID",globVar.sensID)
		focRow = 5
	end	
	form.reinit(1)
end

local function sensParChanged(value)
	sensPaListIdx = value
	if(sensPaListIdx < #sensPaList)then
		globVar.sensID = sensListIdx -- set sensorid to corresponding window
		globVar.sensPar = sensPaListIdx -- set sensor parameterid to corresponding window 
		system.pSave("AltSensPar",globVar.sensPar)
		focRow = 3
	end	
	form.reinit(1)
end

local function audioChanged(value)
	globVar.audioListIdx = value
	system.pSave("audio",globVar.audioListIdx)
	focRow = 3
	form.reinit(1)
end

local function vibChanged(value)
	globVar.vibBeepIdx = value
	system.pSave("vibBeep",globVar.vibBeepIdx)
	focRow = 3
	form.reinit(1)
end

local function vibSwitchChanged(value)
	globVar.vibBeepSwitch = value
	system.pSave("vibSwitch",globVar.vibBeepSwitch)
end

local function audioSwitchChanged(value)
	globVar.audioSwitch = value
	system.pSave("audioSwitch",globVar.audioSwitch)
end

local function maxChanged(value)
	globVar.maxAlt = value
	system.pSave("maxAlt", globVar.maxAlt)
end

local function minChanged(value)
	globVar.minAlt = value
	system.pSave("minAlt", globVar.minAlt)
end

local function offsetChanged(value)
	globVar.offset = value
	system.pSave("offset", globVar.offset)
end

local function beepOffsetChanged(value)
	globVar.beepOffset = value
	system.pSave("beepOffset", globVar.beepOffset)
end

--------------------------------------------------------------------------------
-- Config display
local function AltAConfig(formID)
	local sensor = {}
	for k in next,sensList do sensList[k] = nil end
	for k in next,sensPaList do sensPaList[k] = nil end
	
	for idx in ipairs(globVar.sensors) do 
		sensor = system.getSensorByID (globVar.sensors[idx],0)
		table.insert(sensList, string.format("%s", sensor.label))
	end
	table.insert(sensList,"---")
 
	if(globVar.sensID>0)then
		sensListIdx = globVar.sensID --preset sensorlist index
		if (globVar.sensParam[sensListIdx]~=nil) then
			for idx in ipairs(globVar.sensParam[sensListIdx]) do 
				sensor = system.getSensorByID (globVar.sensors[sensListIdx],globVar.sensParam[sensListIdx][idx])
				table.insert(sensPaList, string.format("%s", sensor.label))
			end
		end	
	else
		sensListIdx = #sensList
	end
	table.insert(sensPaList,"---")
	if(globVar.sensPar>0)then
		sensPaListIdx = globVar.sensPar --preset parameterlist index
	else
		sensPaListIdx = #sensPaList
	end
	
	form.setTitle(globVar.trans.altALib)
	form.addRow(1)
	form.addLabel({label=globVar.trans.config,font=FONT_BOLD})
	
-- --only for simulation without connected telemetry	
	-- form.addRow(2)
	-- form.addLabel({label="sensorSimulation"})
	-- form.addInputbox(globVar.simAlta,true,simAltaChanged)
-- --only for simulation without connected telemetry	
	
	if( sensPaList[1] ~=nil) then
		form.addRow(2)
		form.addLabel({label="Sensor",width=170})
		form.addSelectbox(sensList,sensListIdx,true,sensorChanged)
		
		form.addRow(2)
		form.addLabel({label="SensParam",width=170})
		form.addSelectbox(sensPaList,sensPaListIdx,true,sensParChanged)
	end	

	form.addRow(2)
	local audioList = {}
	table.insert(audioList,"---")
	table.insert(audioList,globVar.trans.up)
	table.insert(audioList,globVar.trans.down)		
	table.insert(audioList,globVar.trans.upDown)
	form.addLabel({label=globVar.trans.audioOut,width=170})
	form.addSelectbox(audioList,globVar.audioListIdx,true,audioChanged)
		
	form.addRow(2)
	local vibBeepList = {}
	table.insert(vibBeepList,"---")
	table.insert(vibBeepList,"Beep")		
	if(globVar.device24 == true)then
		table.insert(vibBeepList,"Vibration")
		form.addLabel({label="Vibration/Beep",width=170})
	else
		form.addLabel({label="Beep",width=170})
	end
	form.addSelectbox(vibBeepList,globVar.vibBeepIdx,true,vibChanged)
		
	if(globVar.vibBeepIdx >1) then
		form.addRow(2)
		form.addLabel({label="Beep Offset ("..sensor.unit..")", width=220})
		form.addIntbox(globVar.beepOffset, 1, 100, 0, 0, 1, beepOffsetChanged)

		form.addRow(2)
		form.addLabel({label=globVar.trans.swVib})
		form.addInputbox(globVar.vibBeepSwitch,true,vibSwitchChanged)
	end	
		
	if(globVar.audioListIdx >1) then
		form.addRow(2)
		form.addLabel({label="Audio Offset ("..sensor.unit..")", width=220})
		form.addIntbox(globVar.offset, 1, 100, 0, 0, 1, offsetChanged)

		form.addRow(2)
		form.addLabel({label=globVar.trans.swAudio})
		form.addInputbox(globVar.audioSwitch,true,audioSwitchChanged)
	end	
		
    form.addRow(2)
    form.addLabel({label=globVar.trans.min.." ("..sensor.unit..")", width=220})
    form.addIntbox(globVar.minAlt, -0, 10000, 0, 0, 10, minChanged)
        
    form.addRow(2)
    form.addLabel({label=globVar.trans.max.." ("..sensor.unit..")", width=220})
    form.addIntbox(globVar.maxAlt, -0, 10000, 0, 0, 10, maxChanged)
	
	-- version
	form.addRow(1)
	form.addLabel({label="Powered by Geierwally - "..globVar.version.."  Mem max: "..globVar.mem.."K",font=FONT_MINI, alignRight=true})
end


--------------------------------------------------------------------
local AltAConf = {init,AltAConfig}
return AltAConf