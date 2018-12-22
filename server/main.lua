ESX 						  	= nil
local CopsConnected       	 	= 0
local PlayersHarvestingRuby     = {}
local PlayersTransformingRuby   = {}
local PlayersSellingRuby        = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function CountCops()

	local xPlayers = ESX.GetPlayers()

	CopsConnected = 0

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'police' then
			CopsConnected = CopsConnected + 1
		end
	end

	SetTimeout(5000, CountCops)

end

CountCops()

-- Stage 1
local function HarvestRuby(source)

	if CopsConnected < Config.RequiredCopsRuby then
		TriggerClientEvent('esx:showNotification', source, _U('act_imp_police') .. CopsConnected .. '/' .. Config.RequiredCopsRuby)
		return
	end

	SetTimeout(5000, function()

		if PlayersHarvestingRuby[source] == true then

			local xPlayer  = ESX.GetPlayerFromId(source)

			local ruby = xPlayer.getInventoryItem('ruby')

			if ruby.limit ~= -1 and ruby.count >= ruby.limit then
				TriggerClientEvent('esx:showNotification', source, _U('inv_full_ruby'))
			else
				xPlayer.addInventoryItem('ruby', 1)
				HarvestRuby(source)
			end

		end
	end)
end

RegisterServerEvent('esx_ruby:startHarvestRuby')
AddEventHandler('esx_ruby:startHarvestRuby', function()

	local _source = source

	PlayersHarvestingRuby[_source] = true

	TriggerClientEvent('esx:showNotification', _source, _U('pickup_in_prog'))

	HarvestRuby(_source)

end)

RegisterServerEvent('esx_ruby:stopHarvestRuby')
AddEventHandler('esx_ruby:stopHarvestRuby', function()

	local _source = source

	PlayersHarvestingRuby[_source] = false

end)

-- Stage 2

local function TransformRuby(source)

	if CopsConnected < Config.RequiredCopsRuby then
		TriggerClientEvent('esx:showNotification', source, _U('act_imp_police') .. CopsConnected .. '/' .. Config.RequiredCopsRuby)
		return
	end

	SetTimeout(10000, function()

		if PlayersTransformingRuby[source] == true then

			local xPlayer  = ESX.GetPlayerFromId(source)

			local rubyQuantity = xPlayer.getInventoryItem('ruby').count
			local bagQuantity = xPlayer.getInventoryItem('ruby_bag').count

			if bagQuantity > 35 then
				TriggerClientEvent('esx:showNotification', source, _U('too_many_bags'))
			elseif rubyQuantity < 10 then
				TriggerClientEvent('esx:showNotification', source, _U('not_enough_ruby'))
			else
				xPlayer.removeInventoryItem('ruby', 10)
				xPlayer.addInventoryItem('ruby_bag', 1)
			
				TransformRuby(source)
			end

		end
	end)
end

RegisterServerEvent('esx_ruby:startTransformRuby')
AddEventHandler('esx_ruby:startTransformRuby', function()

	local _source = source

	PlayersTransformingRuby[_source] = true

	TriggerClientEvent('esx:showNotification', _source, _U('packing_in_prog'))

	TransformRuby(_source)

end)

RegisterServerEvent('esx_ruby:stopTransformRuby')
AddEventHandler('esx_ruby:stopTransformRuby', function()

	local _source = source

	PlayersTransformingRuby[_source] = false

end)

-- Stage 3

local function SellRuby(source)

	if CopsConnected < Config.RequiredCopsRuby then
		TriggerClientEvent('esx:showNotification', source, _U('act_imp_police') .. CopsConnected .. '/' .. Config.RequiredCopsRuby)
		return
	end

	SetTimeout(7500, function()

		if PlayersSellingRuby[source] == true then

			local xPlayer  = ESX.GetPlayerFromId(source)

			local bagQuantity = xPlayer.getInventoryItem('ruby_bag').count

			if bagQuantity == 0 then
				TriggerClientEvent('esx:showNotification', source, _U('no_bags_sale'))
			else
				xPlayer.removeInventoryItem('ruby_bag', 1)
				if CopsConnected == 0 then
                    xPlayer.addAccountMoney('black_money', 150)
                    TriggerClientEvent('esx:showNotification', source, _U('sold_one_ruby'))
                elseif CopsConnected == 1 then
                    xPlayer.addAccountMoney('black_money', 250)
                    TriggerClientEvent('esx:showNotification', source, _U('sold_one_ruby'))
                elseif CopsConnected == 2 then
                    xPlayer.addAccountMoney('black_money', 350)
                    TriggerClientEvent('esx:showNotification', source, _U('sold_one_ruby'))
                elseif CopsConnected == 3 then
                    xPlayer.addAccountMoney('black_money', 450)
                    TriggerClientEvent('esx:showNotification', source, _U('sold_one_ruby'))
                elseif CopsConnected == 4 then
                    xPlayer.addAccountMoney('black_money', 550)
                    TriggerClientEvent('esx:showNotification', source, _U('sold_one_ruby'))
                elseif CopsConnected >= 5 then
                    xPlayer.addAccountMoney('black_money', 650)
                    TriggerClientEvent('esx:showNotification', source, _U('sold_one_ruby'))
                end
				
				SellRuby(source)
			end

		end
	end)
end

RegisterServerEvent('esx_ruby:startSellRuby')
AddEventHandler('esx_ruby:startSellRuby', function()

	local _source = source

	PlayersSellingRuby[_source] = true

	TriggerClientEvent('esx:showNotification', _source, _U('sale_in_prog'))

	SellRuby(_source)

end)

RegisterServerEvent('esx_ruby:stopSellRuby')
AddEventHandler('esx_ruby:stopSellRuby', function()

	local _source = source

	PlayersSellingRuby[_source] = false

end)

-- RETURN INVENTORY TO CLIENT
RegisterServerEvent('esx_ruby:GetUserInventory')
AddEventHandler('esx_ruby:GetUserInventory', function(currentZone)
	local _source = source
    local xPlayer  = ESX.GetPlayerFromId(_source)
    TriggerClientEvent('esx_ruby:ReturnInventory', 
    	_source,
		xPlayer.getInventoryItem('ruby').count, 
		xPlayer.getInventoryItem('ruby_bag').count,
		xPlayer.job.name, 
		currentZone
    )
end)
