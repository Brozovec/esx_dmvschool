local CurrentAction     = nil
local CurrentActionMsg  = nil
local CurrentActionData = nil
local Licenses          = {}
local CurrentTest       = nil
local CurrentTestType   = nil
local CurrentVehicle    = nil
local CurrentCheckPoint, DriveErrors = 0, 0
local LastCheckPoint    = -1
local CurrentBlip       = nil
local CurrentZoneType   = nil
local IsAboveSpeedLimit = false
local LastVehicleHealth = nil

function DrawMissionText(msg, time)
	ClearPrints()
	BeginTextCommandPrint('STRING')
	AddTextComponentSubstringPlayerName('<FONT FACE="Fire Sans">'..msg)
	EndTextCommandPrint(time, true)
end

exports.qtarget:AddCircleZone("ridicak", vector3(-251.3199, -924.2873, 32.3433), 1.0, {
  name = "ridicak",
  heading = 84.9894,
  debugPoly = false,
  minZ = 81.77834,
  maxZ = 85.17834,
}, {
  options = {
    {
		action = function ()
			exports.ox_target:disableTargeting(true)
			local alert = lib.alertDialog({
				header = 'Zdravím vás,',
				content = 'U nás se začína děláním teoretických testů  \n následně si mužete zakoupit ŘIDIČÁK PODLE VLASNÍHO VÝBERU! \n Následne si prosím vyzvedněte RP na recepci',
				centered = true,
				cancel = false
			})
			OpenDMVSchoolMenu()
			exports.ox_target:disableTargeting(false)
		end,
		icon = "fas fa-user",
		label = "Otevřít Autoškolu",
    },
  },
  distance = 4.0
})


function StartDriveTest(type)
	ESX.Game.SpawnVehicle(Config.VehicleModels[type], Config.Zones.VehicleSpawnPoint.Pos, Config.Zones.VehicleSpawnPoint.Pos.h, function(vehicle)
		CurrentTest       = 'drive'
		CurrentTestType   = type
		CurrentCheckPoint = 0
		LastCheckPoint    = -1
		CurrentZoneType   = 'residence'
		DriveErrors       = 0
		IsAboveSpeedLimit = false
		CurrentVehicle    = vehicle
		LastVehicleHealth = GetEntityHealth(vehicle)

		local playerPed   = cache.ped
		TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
		SetVehicleFuelLevel(vehicle, 100.0)
		DecorSetFloat(vehicle, "_FUEL_LEVEL", GetVehicleFuelLevel(vehicle))
	end)
end

function StopDriveTest(success)
	if success then
		TriggerServerEvent('esx_dmvschool:addLicense', CurrentTestType)
		ESX.ShowNotification(_U('passed_test'))
	else
		ESX.ShowNotification(_U('failed_test'))
	end
	CurrentTest     = nil
	CurrentTestType = nil
end

function SetCurrentZoneType(type)
	CurrentZoneType = type
end

function OpenDMVSchoolMenu()
	local ownedLicenses = {}

	for i=1, #Licenses, 1 do
		ownedLicenses[Licenses[i].type] = true
	end

	lib.registerContext({
		id = 'dmv_menu',
		title = 'Autoškola',
		options = {
			{
				title = 'Teorie',
				description = 'Zapneš teoretické testy po kterém můžeš dělat jízdy',
				metadata = {
					{label = 'Cena', value = 500},
				},
				onSelect = function()
					if not ownedLicenses['dmv'] then
						ESX.TriggerServerCallback('esx_dmvschool:canYouPay', function(haveMoney)
							if haveMoney then
								local questions = {
									{
										question = 'Pokud jedeš rychlostí 55 mp/h a vjíždíš do obydlené oblasti, musíš:',
										answers = {
											a = 'Zvýšit rychlost',
											b = 'Zachováš rychlost, pokud si to situace vyžádá pustíš ostatní vozidla',
											c = 'Zpomalit na 31 mp/h',
											d = 'Dávat pozor na lidi',
											correct = 'c',
										}
									},
									{
										question = 'Pokud odbočuješ doprava na semaforu, máš zelenou ale zrazu ti tam vejde chodec co uděláš?:',
										answers = {
											a = 'Zastavíš v křižovatce dojdeš zbít chodce',
											b = 'Vystřelíš po chodci aby si uvědomil že tudy nemá chodit',
											c = 'Přejedeš chodce protože máš zelenou a jedeš dál',
											d = 'Zastavíš / zpomalíš vozidlo a necháš chodce přejít',
											correct = 'd',
										}
									},
									{
										question = 'Pokud značka neurčí jinak, je povolená rychlost v obydlených oblastech: __ mp/h',
										answers = {
											a = '25 mp/h',
											b = '37 mp/h',
											c = '55 mp/h',
											d = '31 mp/h',
											correct = 'd',
										}
									},
									{
										question = 'Jaká je maxiální hranice alkoholu v krvi při řízení motorového vozidla?',
										answers = {
											a = '0.05%',
											b = '0.18%',
											c = '0.08%',
											d = '0.06%',
											correct = 'c',
										}
									},
									{
										question = 'Kdy můžeš pokračovat v jízdě na semaforech?',
										answers = {
											a = 'Když svítí zelená a na červenou lze odbočit doprava',
											b = 'Když se nikdo nekouká',
											c = 'Když svítí červená',
											d = 'Když je zelená',
											correct = 'a',
										}
									},
									{
										question = 'Co uděláte pokud ve zpětném zrcátku zahlédnete blikající policejní auto?',
										answers = {
											a = 'Ujedete rychle pryč',
											b = 'Zastavíte na krajnici a vyčkáte na příchod policisty',
											c = 'Zapnete výstražná světla a jedete dále',
											d = 'Začnete střílet do světel',
											correct = 'b',
										}
									},
									{
										question = 'Co je povolené při předjíždění jiného vozidla?',
										answers = {
											a = 'Předjedete ho z bezpečné vzdálenosti od něho, můžete při tom zvýšit rychlost a musíte dát znamení o změně směru jízdy',
											b = 'Držíte rychlost a až on zpomalí předjedete ho',
											c = 'Předjedete ho zprava, protože nelze vjet do protisměru',
											d = 'Jedete těsně za něho, zvýšíte rychlost a co nejrychleji ho objedete zprava',
											correct = 'a',
										}
									},
									{
										question = 'Jedete po dálnici, kde vozidla jedou 85 mp/h přitom povolených je 80 mp/h, kolik pojedete vy?:',
										answers = {
											a = '87 mp/h',
											b = '80 mp/h',
											c = '72 mp/h',
											d = '75 mp/h',
											correct = 'b',
										}
									},
									{
										question = 'Pokud vás předjíždí jiné vozidlo, tak v žádném případě NESMÍTE:',
										answers = {
											a = 'Zpomalit',
											b = 'Sledovat ostatní co dělají',
											c = 'Zrychlovat',
											d = 'Zkontrolovat zrcátka',
											correct = 'c',
										}
									},
									{
										question = 'Pokaždé pokud vjíždíš do jiného pruhu musíš:',
										answers = {
											a = 'Zkontrolovat zrcátka',
											b = 'Vše uvedené',
											c = 'Zkontrolovat slepá místa',
											d = 'Dát blinkr',
											correct = 'b',
										}
									}
								}

								exports['bcs_questionare']:openQuiz({
									title = 'Teoretický test',
									task = 'Držíme ti palce!',
									description = 'Aby si mohl přejít na jízdy musíš prvně zvládnout teorii',
									image = '',
									minimum = 8,
									cancel = 'Zrušit',
									next = 'Další',
									shuffle = false,
								}, questions, function(correct, questions)
									ESX.ShowNotification('Uspěl si')
									TriggerServerEvent('esx_dmvschool:addLicense', "dmv")
									Wait(1500)
									OpenDMVSchoolMenu()
								end, function(correct, questions)
									ESX.ShowNotification('Neuspěl si')
									Wait(1500)
									OpenDMVSchoolMenu()
								end)
							else
								ESX.ShowNotification(_U('not_enough_money'))
							end
						end, 'dmv')
					else
						lib.notify({type = 'inform', title = 'Již máš hotovou teorii'})
					end
				end,
			},
			{
				title = 'Řidičák B, A',
				description = 'Řidičák na Auto',
				metadata = {
					{label = 'Cena', value = 500},
				},
				onSelect = function ()
					if ownedLicenses['dmv'] then
						if not ownedLicenses['drive'] then
							ESX.TriggerServerCallback('esx_dmvschool:canYouPay', function(haveMoney)
								if haveMoney then
									TriggerServerEvent('esx_dmvschool:addLicense', "drive")
									lib.notify({type = 'succes', title = 'Blahopřeji zakoupil jsi Řidičák B, A '})
								else
									ESX.ShowNotification(_U('not_enough_money'))
								end
							end, "drive")
						else
							lib.notify({type = 'inform', title = 'Již máš hotovou tuto skupinu'})
						end
					else
						lib.notify({type = 'error', title = 'Nemáš hotové teoretické testy.'})
					end
				end
			},
			{
				title = 'Řidičák A1',
				description = 'Řidičák na motorku',
				metadata = {
					{label = 'Cena', value = 650},
				},
				onSelect = function ()
					if ownedLicenses['dmv'] then
						if not ownedLicenses['drive_bike'] then
							ESX.TriggerServerCallback('esx_dmvschool:canYouPay', function(haveMoney)
								if haveMoney then
									TriggerServerEvent('esx_dmvschool:addLicense', "drive_bike")
									lib.notify({type = 'succes', title = 'Blahopřeji zakoupil jsi Řidičák A1 '})								else
									ESX.ShowNotification(_U('not_enough_money'))
								end
							end, "drive_bike")
						else
							lib.notify({type = 'inform', title = 'Již máš hotovou tuto skupinu'})
						end
					else
						lib.notify({type = 'error', title = 'Nemáš hotové teoretické testy.'})
					end
				end
			},
			{
				title = 'Řidičák C',
				description = 'Řidičák na kamion',
				metadata = {
					{label = 'Cena', value = 750},
				},
				onSelect = function ()
					if ownedLicenses['dmv'] then
						if not ownedLicenses['drive_truck'] then
							ESX.TriggerServerCallback('esx_dmvschool:canYouPay', function(haveMoney)
								if haveMoney then
									TriggerServerEvent('esx_dmvschool:addLicense', "drive_truck")
									lib.notify({type = 'succes', title = 'Blahopřeji zakoupil jsi Řidičák C '})									else
									ESX.ShowNotification(_U('not_enough_money'))
								end
							end, "drive_truck")
						else
							lib.notify({type = 'inform', title = 'Již máš hotovou tuto skupinu'})
						end
					else
						lib.notify({type = 'error', title = 'Nemáš hotové teoretické testy.'})
					end
				end
			}
		},
	})
	lib.showContext('dmv_menu')
end

RegisterNUICallback('question', function(data, cb)
	SendNUIMessage({ openSection = 'question' })
	cb()
end)

RegisterNUICallback('close', function(data, cb)
	StopTheoryTest(true)
	cb()
end)

RegisterNUICallback('kick', function(data, cb)
	StopTheoryTest(false)
	cb()
end)

AddEventHandler('esx_dmvschool:hasEnteredMarker', function(zone)
	if zone == 'DMVSchool' then
		CurrentAction     = 'dmvschool_menu'
		CurrentActionMsg  = _U('press_open_menu')
		CurrentActionData = {}
	end
end)

AddEventHandler('esx_dmvschool:hasExitedMarker', function(zone)
	CurrentAction = nil
	ESX.UI.Menu.CloseAll()
end)

RegisterNetEvent('esx_dmvschool:loadLicenses')
AddEventHandler('esx_dmvschool:loadLicenses', function(licenses)
	Licenses = licenses
end)

-- Create Blips
Citizen.CreateThread(function()
	local blip = AddBlipForCoord(Config.Zones.DMVSchool.Pos.x, Config.Zones.DMVSchool.Pos.y, Config.Zones.DMVSchool.Pos.z)

	SetBlipSprite (blip, 358)
	SetBlipDisplay(blip, 4)
	SetBlipScale  (blip, 0.7)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString('<FONT FACE="Fire Sans">Úřad')
	EndTextCommandSetBlipName(blip)
end)



-- Block UI
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		if CurrentTest == 'theory' then
			local playerPed = cache.ped

			DisableControlAction(0, 1, true) -- LookLeftRight
			DisableControlAction(0, 2, true) -- LookUpDown
			DisablePlayerFiring(playerPed, true) -- Disable weapon firing
			DisableControlAction(0, 142, true) -- MeleeAttackAlternate
			DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
		else
			Citizen.Wait(500)
		end
	end
end)



-- Drive test
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if CurrentTest == 'drive' then
			local playerPed      = cache.ped
			local coords         = GetEntityCoords(playerPed)
			local nextCheckPoint = CurrentCheckPoint + 1

			if Config.CheckPoints[nextCheckPoint] == nil then
				if DoesBlipExist(CurrentBlip) then
					RemoveBlip(CurrentBlip)
				end

				CurrentTest = nil

				ESX.ShowNotification(_U('driving_test_complete'))

				if DriveErrors < Config.MaxErrors then
					StopDriveTest(true)
				else
					StopDriveTest(false)
				end
			else
				if CurrentCheckPoint ~= LastCheckPoint then
					if DoesBlipExist(CurrentBlip) then
						RemoveBlip(CurrentBlip)
					end
					CurrentBlip = AddBlipForCoord(Config.CheckPoints[nextCheckPoint].Pos.x, Config.CheckPoints[nextCheckPoint].Pos.y, Config.CheckPoints[nextCheckPoint].Pos.z)
					SetBlipRoute(CurrentBlip, 1)
					LastCheckPoint = CurrentCheckPoint
				end
				local distance = GetDistanceBetweenCoords(coords, Config.CheckPoints[nextCheckPoint].Pos.x, Config.CheckPoints[nextCheckPoint].Pos.y, Config.CheckPoints[nextCheckPoint].Pos.z, true)
				if distance <= 100.0 then
					DrawMarker(1, Config.CheckPoints[nextCheckPoint].Pos.x, Config.CheckPoints[nextCheckPoint].Pos.y, Config.CheckPoints[nextCheckPoint].Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.5, 1.5, 1.5, 102, 204, 102, 100, false, true, 2, false, false, false, false)
				end

				if distance <= 3.0 then
					Config.CheckPoints[nextCheckPoint].Action(playerPed, CurrentVehicle, SetCurrentZoneType)
					CurrentCheckPoint = CurrentCheckPoint + 1
				end
			end
		else
			Citizen.Wait(500)
		end
	end
end)

-- Speed / Damage control
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)
		if CurrentTest == 'drive' then
			local playerPed = cache.ped
			if IsPedInAnyVehicle(playerPed, false) then
				local vehicle      = GetVehiclePedIsIn(playerPed, false)
				local speed        = GetEntitySpeed(vehicle) * Config.SpeedMultiplier - 5.0
				local tooMuchSpeed = false

				for k,v in pairs(Config.SpeedLimits) do
					if CurrentZoneType == k and speed > v then
						tooMuchSpeed = true

						if not IsAboveSpeedLimit then
							DriveErrors       = DriveErrors + 1
							IsAboveSpeedLimit = true
						end
					end
				end

				if not tooMuchSpeed then
					IsAboveSpeedLimit = false
				end

				local health = GetEntityHealth(vehicle)
				if health < LastVehicleHealth then
					DriveErrors = DriveErrors + 1
					LastVehicleHealth = health
					Citizen.Wait(1500)
				end
			end
		else
			Citizen.Wait(500)
		end
	end
end)
