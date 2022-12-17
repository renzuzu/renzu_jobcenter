
ESX = exports['es_extended']:getSharedObject()

GlobalState.Multijobs = json.decode(GetResourceKvpString('Multijobs') or '[]') or {}

DoesJobExist = function(name)
	for k,v in pairs(Config.Jobs) do
		if v.name == name then
			return true
		end
	end
	return false
end

DoesJobExistinMulti = function(id,name)
	for k,v in pairs(GlobalState.Multijobs[id] or {}) do
		if v.name == name then
			return true
		end
	end
	return false
end

lib.callback.register('renzu_jobcenter:Setjob', function(source,data)
	local xPlayer = ESX.GetPlayerFromId(source)
	if DoesJobExist(data.name) or DoesJobExist(xPlayer.job.name) then
		local multijobs = GlobalState.Multijobs
		if not multijobs[xPlayer.identifier] then multijobs[xPlayer.identifier] = {} end
		if not DoesJobExistinMulti(xPlayer.identifier,xPlayer.job.name) then
			table.insert(multijobs[xPlayer.identifier], {
				name = xPlayer.job.name,
				label = xPlayer.job.label,
				grade = xPlayer.job.grade
			})
			SetResourceKvp('Multijobs',json.encode(multijobs))
			GlobalState.Multijobs = multijobs
		end
		xPlayer.setJob(data.name, data.grade)
	end
end)