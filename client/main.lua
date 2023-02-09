ESX = exports['es_extended']:getSharedObject()
PlayerData = ESX.GetPlayerData()

RegisterNetEvent('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob', function(job)
	PlayerData.job = job
end)

exports('Jobcenter', function(coord,options)
	wait = promise.new()
	SendNUIMessage({jobs = Config.Jobs})
	return Citizen.Await(wait)
end)

RegisterCommand('jobcenter', function()
	exports.jobcenter:Jobcenter()
end)

-- NUI CALLBACKS
RegisterNUICallback('nuicb', function(data)
	if data.msg == 'select' then
		local job = {}
		for k,v in pairs(Config.Jobs) do
			if v.name == data.name then
				job = v
				break
			end
		end
		lib.callback.await('renzu_jobcenter:Setjob',false, job)
		lib.notify({
			title = 'Job Center',
			description = 'You are Hired as '..job.label,
			type = 'success'
		})
		if GetResourceState('fivem-appearance') == 'started' then
			SetSkin(job.name)
		end
		SetTimeScale(0.3)
        PlaySoundFrontend(-1, "PROPERTY_PURCHASE", "MEDAL_GOLD", 0)
        showScaleform('New Job','Check your map for '..job.label..' location',8)
        
        Wait(2000)
        SetTimeScale(1.0)
	end
	if data.msg == 'close' then
		SetNuiFocus(false,false)
		SetNuiFocusKeepInput(false)
	end
	cb(true)
end)

local oldskin = nil
SetSkin = function(job)
	if not Config.useSKin then return end
	local gender = GetEntityModel(PlayerPedId()) == `mp_m_freemode_01` and 'm' or 'f'
	print('skin',Config.Skins[job])
	if Config.Skins[job] then
		if not oldskin then
			oldskin = exports['fivem-appearance']:getPedAppearance(PlayerPedId())
		end
		exports['fivem-appearance']:setPedComponents(PlayerPedId(),Config.Skins[job][gender].components)
		exports['fivem-appearance']:setPedProps(PlayerPedId(),Config.Skins[job][gender].props)
	elseif oldskin then
		exports['fivem-appearance']:setPlayerAppearance(oldskin)
		oldskin = nil
	end
end

Center = function()
	local point = lib.points.new(Config.jobcenter, 5)
	function point:onEnter()
		print('entered range of point', self.id)
		lib.showTextUI('[E] - Job Center', {
			position = "top-center",
			icon = 'suitcase',
			style = {
				borderRadius = 0,
				backgroundColor = '#48BB78',
				color = 'white'
			}
		})
	end
	
	function point:onExit()
		print('left range of point', self.id)
		lib.hideTextUI()
	end
	
	function point:nearby()
		DrawMarker(2, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.5, 0.5, 0.5, 200, 200, 200, 99, false, true, 2, nil, nil, false)
	
		if self.currentDistance < 1 and IsControlJustReleased(0, 38) then
			SetNuiFocus(true,true)
			SetNuiFocusKeepInput(false)
			SendNUIMessage({jobs = Config.Jobs})
			lib.hideTextUI()
		end
	end
end

Multi = function()
	local point = lib.points.new(Config.multijob, 5)
	function point:onEnter()
		print('entered range of point', self.id)
		lib.showTextUI('[E] - Multi Jobs', {
			position = "top-center",
			icon = 'suitcase',
			style = {
				borderRadius = 0,
				backgroundColor = '#48BB78',
				color = 'white'
			}
		})
	end
	
	function point:onExit()
		print('left range of point', self.id)
		lib.hideTextUI()
	end
	
	function point:nearby()
		DrawMarker(2, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.5, 0.5, 0.5, 200, 200, 200, 99, false, true, 2, nil, nil, false)
	
		if self.currentDistance < 1 and IsControlJustReleased(0, 38) then
			lib.hideTextUI()
			local options = {}
			local Multijobs = GlobalState.Multijobs or {}
			print(Multijobs[PlayerData.identifier])
			for k,v in pairs(Multijobs[PlayerData.identifier] or {}) do
				table.insert(options,{
					title = v.label,
					description = 'Select '..v.label,
					onSelect = function()
						lib.callback.await('renzu_jobcenter:Setjob',false, v)
						lib.notify({
							title = 'Job Center',
							description = 'You are Now '..v.label,
							type = 'success'
						})
						if GetResourceState('fivem-appearance') == 'started' then
							SetSkin(v.name)
						end
						SetTimeScale(0.3)
						PlaySoundFrontend(-1, "PROPERTY_PURCHASE", "MEDAL_GOLD", 0)
						showScaleform('New Job','Check your map for '..v.label..' location',8)

						Wait(2000)
						SetTimeScale(1.0)
					end
				})
			end
			lib.registerContext({
				id = 'multijobs',
				title = 'Multi Jobs Selector',
				onExit = function()
					print('Hello there')
				end,
				options = options
			})
			lib.showContext('multijobs')
		end
	end
end

Blips = function()
	blip = AddBlipForCoord(Config.jobcenter)
    SetBlipSprite(blip, 351)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 2.2)
    SetBlipColour(blip, 3)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Job Center")
    EndTextCommandSetBlipName(blip)
end

Citizen.CreateThread(Center)
Citizen.CreateThread(Multi)
Blips()

function showScaleform(title, desc, sec)
    PlaySoundFrontend(-1, "PROPERTY_PURCHASE", "HUD_AWARDS", 0)
	function Initialize(scaleform)
		local scaleform = RequestScaleformMovie(scaleform)

		while not HasScaleformMovieLoaded(scaleform) do
			Citizen.Wait(0)
		end
		PushScaleformMovieFunction(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
		PushScaleformMovieFunctionParameterString(title)
		PushScaleformMovieFunctionParameterString(desc)
		PopScaleformMovieFunctionVoid()
		return scaleform
	end
	scaleform = Initialize("mp_big_message_freemode")
	while sec > 0 do
		sec = sec - 0.02
		Citizen.Wait(0)
		DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
	end
	SetScaleformMovieAsNoLongerNeeded(scaleform)
end