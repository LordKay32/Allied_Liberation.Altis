private _filename = "fn_saveLoop";
if (!isServer) exitWith {
    [1, "Miscalled server-only function", _filename] call A3A_fnc_log;
};

if (savingServer) exitWith {["Save Game", "Server data save is still in progress..."] remoteExecCall ["A3A_fnc_customHint",theBoss]};
savingServer = true;
[2, "Starting persistent save", _filename] call A3A_fnc_log;
["Persistent Save","Starting persistent save..."] remoteExec ["A3A_fnc_customHint",0,false];

// Set next autosave time, so that we won't run another shortly after a manual save
autoSaveTime = time + autoSaveInterval;

// Save each player with global flag
{
	[getPlayerUID _x, _x, true] call A3A_fnc_savePlayer;
} forEach (call A3A_fnc_playableUnits);

// Check if this campaign is already in the save list
private _saveList = [profileNamespace getVariable "antistasiPlusSavedGames"] param [0, [], [[]]];
private _saveIndex = -1;
{
	if (_x select 0 == campaignID) exitWith { _saveIndex = forEachIndex };
} forEach _saveList;

// If not, append a new entry
if (_saveIndex == -1) then {
	_saveList pushBack [campaignID, worldName, "Greenfor"];
	profileNamespace setVariable ["antistasiPlusSavedGames", _saveList];
};

// Update the legacy campaign ID store
profileNamespace setVariable ["ss_campaignID", campaignID];

// Save persistent global variables defined in initParam
private _savedParams = A3A_paramTable apply { [_x#0, missionNameSpace getVariable _x#0] };
[3, format ["Saving params: %1", _savedParams], _filename] call A3A_fnc_log;
["params", _savedParams] call A3A_fnc_setStatVariable;

private ["_garrison"];
["version", antistasiVersion] call A3A_fnc_setStatVariable;
["attackCountdownOccupants", attackCountdownOccupants] call A3A_fnc_setStatVariable;
["attackCountdownInvaders", attackCountdownInvaders] call A3A_fnc_setStatVariable;
["gameMode", gameMode] call A3A_fnc_setStatVariable;					// backwards compatibility
["difficultyX", skillMult] call A3A_fnc_setStatVariable;				// backwards compatibiiity
["bombRuns", bombRuns] call A3A_fnc_setStatVariable;
["traderDiscount", traderDiscount] call A3A_fnc_setStatVariable;
["supportPoints", supportPoints] call A3A_fnc_setStatVariable;
["smallCAmrk", smallCAmrk] call A3A_fnc_setStatVariable;
["membersX", membersX] call A3A_fnc_setStatVariable;
private _antennasDeadPositions = [];
{ _antennasDeadPositions pushBack getPos _x; } forEach antennasDead;
["antennas", _antennasDeadPositions] call A3A_fnc_setStatVariable;
//["mrkNATO", (markersX - controlsX) select {sidesX getVariable [_x,sideUnknown] == Occupants}] call A3A_fnc_setStatVariable;
["mrkSDK", (markersX - controlsX - watchpostsFIA - roadblocksFIA - aapostsFIA - atpostsFIA - mortarpostsFIA - hmgpostsFIA - lightroadblocksFIA - supportpostsFIA) select {sidesX getVariable [_x,sideUnknown] == teamPlayer}] call A3A_fnc_setStatVariable;
["mrkCSAT", (markersX - controlsX) select {sidesX getVariable [_x,sideUnknown] == Invaders}] call A3A_fnc_setStatVariable;
["posHQ", [getMarkerPos respawnTeamPlayer,[getDir boxX,getPos boxX],[getDir mapX,getPos mapX],getPos flagX,[getDir vehicleBox,getPos vehicleBox],getPos flagUK]] call A3A_fnc_setStatVariable;
["dateX", date] call A3A_fnc_setStatVariable;
["skillFIA", skillFIA] call A3A_fnc_setStatVariable;
["destroyedSites", destroyedSites] call A3A_fnc_setStatVariable;
["distanceSPWN", distanceSPWN] call A3A_fnc_setStatVariable;		// backwards compatibility
["chopForest", chopForest] call A3A_fnc_setStatVariable;
["maxUnits", maxUnits] call A3A_fnc_setStatVariable;
["maxConstructions", maxConstructions] call A3A_fnc_setStatVariable;
["nextTick", nextTick - time] call A3A_fnc_setStatVariable;
["weather",[fogParams,overcast]] call A3A_fnc_setStatVariable;
private _destroyedPositions = destroyedBuildings apply { getPosATL _x };
["destroyedBuildings",_destroyedPositions] call A3A_fnc_setStatVariable;
["isTraderQuestCompleted", isTraderQuestCompleted] call A3A_fnc_setStatVariable;
["areOccupantsDefeated", areOccupantsDefeated] call A3A_fnc_setStatVariable;
["areInvadersDefeated", areInvadersDefeated] call A3A_fnc_setStatVariable;
["traderPosition", traderPosition] call A3A_fnc_setStatVariable;
["rebelLoadouts", rebelLoadouts] call A3A_fnc_setStatVariable;
["randomizeRebelLoadoutUniforms", randomizeRebelLoadoutUniforms] call A3A_fnc_setStatVariable;
["artilleryList", artilleryList] call A3A_fnc_setStatVariable;
["flakList", flakList] call A3A_fnc_setStatVariable;
["battleshipStarted", battleshipStarted] call A3A_fnc_setStatVariable;
["battleshipDone", battleshipDone] call A3A_fnc_setStatVariable;
["introFinished", introFinished] call A3A_fnc_setStatVariable;

//Save aggression values
["aggressionOccupants", [aggressionLevelOccupants, aggressionStackOccupants]] call A3A_fnc_setStatVariable;
["aggressionInvaders", [aggressionLevelInvaders, aggressionStackInvaders]] call A3A_fnc_setStatVariable;

private ["_hrBackground","_resourcesBackground","_veh","_typeVehX","_weaponsX","_ammunition","_items","_backpcks","_containers","_arrayEst","_posVeh","_dierVeh","_prestigeOPFOR","_prestigeBLUFOR","_city","_dataX","_markersX","_garrison","_arrayMrkMF","_positionOutpost","_typeMine","_posMine","_detected","_typesX","_exists","_friendX"];

//_hrBackground = (server getVariable "hr") + ({(alive _x) and (not isPlayer _x) and (_x getVariable ["spawner",false]) and ((group _x in (hcAllGroups theBoss) or (isPlayer (leader _x))) and (side group _x == teamPlayer))} count allUnits);
_UKhrBackground = (server getVariable "UKhr") + ({(typeOf _x in UKTroops) and (alive _x) and (not isPlayer _x) and (_x getVariable ["spawner",false]) and ((group _x in (hcAllGroups theBoss) or (isPlayer (leader _x))) and (side group _x == teamPlayer))} count allUnits);
_SAShrBackground = (server getVariable "SAShr") + ({(typeOf _x in SASTroops) and (alive _x) and (not isPlayer _x) and (_x getVariable ["spawner",false]) and ((group _x in (hcAllGroups theBoss) or (isPlayer (leader _x))) and (side group _x == teamPlayer))} count allUnits);
_UShrBackground = (server getVariable "UShr") + ({(typeOf _x in USTroops) and (alive _x) and (not isPlayer _x) and (_x getVariable ["spawner",false]) and ((group _x in (hcAllGroups theBoss) or (isPlayer (leader _x))) and (side group _x == teamPlayer))} count allUnits);
_parahrBackground = (server getVariable "parahr") + ({(typeOf _x in paraTroops) and (alive _x) and (not isPlayer _x) and (_x getVariable ["spawner",false]) and ((group _x in (hcAllGroups theBoss) or (isPlayer (leader _x))) and (side group _x == teamPlayer))} count allUnits);
_SDKhrBackground = (server getVariable "SDKhr") + ({(typeOf _x in SDKTroops) and (alive _x) and (not isPlayer _x) and (_x getVariable ["spawner",false]) and ((group _x in (hcAllGroups theBoss) or (isPlayer (leader _x))) and (side group _x == teamPlayer))} count allUnits);
_hrBackground = _UKhrBackground + _SAShrBackground + _UShrBackground + _parahrBackground + _SDKhrBackground;
_resourcesBackground = server getVariable "resourcesFIA";
_intelPoints = server getVariable "intelPoints";
_vehInGarage = [];
_vehInGarage = _vehInGarage + vehInGarage;

//return gear to arsenal
_remainingUnits = allUnits select {((alive _x) and (not isPlayer _x) and (_x getVariable ["spawner",false]) and ((group _x in (hcAllGroups theBoss) or (isPlayer (leader _x))) and (side group _x == teamPlayer)))};
{
	_loadout = getUnitLoadout _x;
	_fullUnitGear = _loadout call A3A_fnc_reorgLoadoutUnit;
	{ [_x select 0 call jn_fnc_arsenal_itemType, _x select 0, _x select 1] call jn_fnc_arsenal_addItem } forEach _fullUnitGear;
} forEach _remainingUnits;

{
	_friendX = _x;
	if ((_friendX getVariable ["spawner",false]) and (side group _friendX == teamPlayer))then {
		if ((alive _friendX) and (!isPlayer _friendX)) then {
			if (((isPlayer leader _friendX) and (!isMultiplayer)) or (group _friendX in (hcAllGroups theBoss)) and (not((group _friendX) getVariable ["esNATO",false]))) then {
				_resourcesBackground = _resourcesBackground + (server getVariable [(_friendX getVariable "unitType"),0]);
				_backpck = backpack _friendX;
				if (_backpck != "") then {
					switch (_backpck) do {
						case MortStaticSDKB: {_resourcesBackground = _resourcesBackground + ([SDKMortar] call A3A_fnc_vehiclePrice)};
						case AAStaticSDKB: {_resourcesBackground = _resourcesBackground + ([staticAAteamPlayer] call A3A_fnc_vehiclePrice)};
						case MGStaticSDKB: {_resourcesBackground = _resourcesBackground + ([SDKMGStatic] call A3A_fnc_vehiclePrice)};
						case ATStaticSDKB: {_resourcesBackground = _resourcesBackground + ([staticATteamPlayer] call A3A_fnc_vehiclePrice)};
					};
				};
				if (vehicle _friendX != _friendX) then {
					_veh = vehicle _friendX;
					_typeVehX = typeOf _veh;
					if (not(_veh in staticsToSave)) then {
						if ((_veh isKindOf "StaticWeapon") or (driver _veh == _friendX)) then {
							if ((group _friendX in (hcAllGroups theBoss)) or (!isMultiplayer)) then {
								_resourcesBackground = _resourcesBackground + ([_typeVehX] call A3A_fnc_vehiclePrice);
								if (count attachedObjects _veh != 0) then {{_resourcesBackground = _resourcesBackground + ([typeOf _x] call A3A_fnc_vehiclePrice)} forEach attachedObjects _veh};
							};
						};
					};
				};
			};
		};
	};
} forEach allUnits;

private _lootCratePrice = [lootCrate] call A3A_fnc_vehiclePrice;

{
	_resourcesBackground = _resourcesBackground + _lootCratePrice;
} forEach (allMissionObjects lootCrate);

if (!isNil "isRallyPointPlaced" && {isRallyPointPlaced}) then {
	private _rallyPointCost = [rallyPoint] call A3A_fnc_vehiclePrice;
	_resourcesBackground = _resourcesBackground + round(_rallyPointCost/1.3);
};

["resourcesFIA", _resourcesBackground] call A3A_fnc_setStatVariable;
["intelPoints", _intelPoints] call A3A_fnc_setStatVariable;
["UKhr", _UKhrBackground] call A3A_fnc_setStatVariable;
["SAShr", _SAShrBackground] call A3A_fnc_setStatVariable;
["UShr", _UShrBackground] call A3A_fnc_setStatVariable;
["parahr", _parahrBackground] call A3A_fnc_setStatVariable;
["SDKhr", _SDKhrBackground] call A3A_fnc_setStatVariable;
["vehInGarage", _vehInGarage] call A3A_fnc_setStatVariable;
["HR_Garage", [] call HR_GRG_fnc_getSaveData] call A3A_fnc_setStatVariable;

//WW2 vehicle counts
private _vehicleCountArray = [];
{
private _vehicleCount = server getVariable (_x + "_count");
_vehicleCountArray pushBack _vehicleCount;
} forEach vehFIA;
["vehicleCountArray", _vehicleCountArray] call A3A_fnc_setStatVariable;
//
_arrayEst = [];

/*{
	_veh = _x;
	_typeVehX = typeOf _veh;
	if ((_veh distance getMarkerPos respawnTeamPlayer < 50) and !(_veh in staticsToSave) and !(_typeVehX in ["ACE_SandbagObject","Land_FoodSacks_01_cargo_brown_F","Land_Pallet_F", "Land_DeskChair_01_black_F", "Land_PortableDesk_01_black_F","Land_Laptop_02_unfolded_F","Land_Ammobox_rounds_F","Land_Cargo20_military_green_F"])) then {
		if (((not (_veh isKindOf "StaticWeapon")) and (not (_veh isKindOf "ReammoBox")) and (not (_veh isKindOf "ReammoBox_F")) and (not(_veh isKindOf "Building"))) and (not (_typeVehX == civSupplyVehicle)) and (count attachedObjects _veh == 0) and (alive _veh) and ({(alive _x) and (!isPlayer _x)} count crew _veh == 0) and (not(_typeVehX == "WeaponHolderSimulated"))) then {
			_posVeh = getPosWorld _veh;
			_xVectorUp = vectorUp _veh;
			_xVectorDir = vectorDir _veh;
            private _state = [_veh] call HR_GRG_fnc_getState;
			_arrayEst pushBack [_typeVehX,_posVeh,_xVectorUp,_xVectorDir, _state];
		};
	};
} forEach vehicles - [boxX,flagX,vehicleBox,mapX,flagUK];
*/

private _friendlySites = ["Synd_HQ"] + (airportsX + milbases + outposts + seaports + factories + resourcesX) select {sidesX getVariable [_x,sideUnknown] == teamPlayer};

{
	_veh = _x;
	_typeVehX = typeOf _veh;
	if ((_friendlySites findIf {_veh inArea _x} != -1) and !(_veh in staticsToSave) and !(_typeVehX in ["ACE_SandbagObject","Land_FoodSacks_01_cargo_brown_F","Land_Pallet_F", "Land_DeskChair_01_black_F", "Land_PortableDesk_01_black_F","Land_Laptop_02_unfolded_F","Land_Ammobox_rounds_F","Land_Cargo20_military_green_F"])) then {
		if (((not (_veh isKindOf "StaticWeapon")) and (not (_veh isKindOf "ReammoBox")) and (not (_veh isKindOf "ReammoBox_F")) and (not(_veh isKindOf "Building"))) and (not (_typeVehX == civSupplyVehicle)) and (count attachedObjects _veh == 0) and (alive _veh) and ({(alive _x) and (!isPlayer _x)} count crew _veh == 0) and (not(_typeVehX == "WeaponHolderSimulated"))) then {
			_posVeh = getPosWorld _veh;
			_xVectorUp = vectorUp _veh;
			_xVectorDir = vectorDir _veh;
            private _state = [_veh] call HR_GRG_fnc_getState;
			_arrayEst pushBack [_typeVehX,_posVeh,_xVectorUp,_xVectorDir, _state];
		};
	};
} forEach vehicles - [boxX,flagX,vehicleBox,mapX,flagUK];

{
	_positionX = position _x;
	if ((alive _x) and !(surfaceIsWater _positionX) and !(isNull _x)) then {
		_arrayEst pushBack [typeOf _x,getPosWorld _x,vectorUp _x, vectorDir _x];
	};
} forEach staticsToSave;
["staticsX", _arrayEst] call A3A_fnc_setStatVariable;

private _excessiveConstructions = maxConstructions - (count constructionsToSave);
if(_excessiveConstructions < 0) then {
	private _top = abs _excessiveConstructions;
	for "_i" from 0 to _top do {
		constructionsToSave deleteAt _i;
	};
};

_arrayConstructions = [];
{
	_positionX = position _x;
	if ((alive _x) and !(surfaceIsWater _positionX) and !(isNull _x)) then {
		_arrayConstructions pushBack [typeOf _x,getPosWorld _x,vectorUp _x, vectorDir _x];
	};
} forEach constructionsToSave;
["constructionsX", _arrayConstructions] call A3A_fnc_setStatVariable;

[] call A3A_fnc_arsenalManage;

_jna_dataList = [];
_jna_dataList = _jna_dataList + jna_dataList;
["jna_dataList", _jna_dataList] call A3A_fnc_setStatVariable;

_prestigeOPFOR = [];
_prestigeBLUFOR = [];

{
	_city = _x;
	_dataX = server getVariable _city;
	_opfor = _dataX select 2;
	_blufor = _dataX select 3;

	if (isNil "_opfor") then {
		_opfor = 50;
	};

	if (isNil "_blufor") then {
		_blufor = 0;
	};

	_prestigeOPFOR pushBack _opfor;
	_prestigeBLUFOR pushBack _blufor;
} forEach citiesX;

["prestigeOPFOR", _prestigeOPFOR] call A3A_fnc_setStatVariable;
["prestigeBLUFOR", _prestigeBLUFOR] call A3A_fnc_setStatVariable;

_markersX = markersX - watchpostsFIA - roadblocksFIA - aapostsFIA - atpostsFIA - mortarpostsFIA - lightroadblocksFIA - hmgpostsFIA - supportpostsFIA - controlsX;
_garrison = [];
_wurzelGarrison = [];

{
	_garrison pushBack [_x,garrison getVariable [_x,[]],garrison getVariable [_x + "_lootCD", 0]];
	_wurzelGarrison pushBack [
		_x,
		garrison getVariable [format ["%1_garrison",_x], []],
	 	garrison getVariable [format ["%1_requested",_x], []],
		garrison getVariable [format ["%1_over", _x], []]
	];
} forEach _markersX;

["garrison",_garrison] call A3A_fnc_setStatVariable;
["wurzelGarrison", _wurzelGarrison] call A3A_fnc_setStatVariable;
["usesWurzelGarrison", true] call A3A_fnc_setStatVariable;

_baseMarkersX = [];
{
	if (markerAlpha _x == 1) then {_baseMarkersX pushback _x};
} forEach baseMarkersX;
["baseMarkersX", _baseMarkersX] call A3A_fnc_setStatVariable;

_mrkAntennas = [];
{
	if (markerAlpha _x == 1) then {_mrkAntennas pushback _x};
} forEach mrkAntennas;
["mrkAntennas", _mrkAntennas] call A3A_fnc_setStatVariable;

_arrayMines = [];
private _mineChance = 500 / (500 max count allMines);
{
	// randomly discard mines down to ~500 to avoid ballooning saves
	if (random 1 > _mineChance) then { continue };
	_typeMine = typeOf _x;
	_posMine = getPos _x;
	_dirMine = getDir _x;
	_detected = [];
	if (_x mineDetectedBy teamPlayer) then {
		_detected pushBack teamPlayer
	};
	if (_x mineDetectedBy Occupants) then {
		_detected pushBack Occupants
	};
	if (_x mineDetectedBy Invaders) then {
		_detected pushBack Invaders
	};
	_arrayMines pushBack [_typeMine,_posMine,_detected,_dirMine];
} forEach allMines;

["minesX", _arrayMines] call A3A_fnc_setStatVariable;

private _arrayWatchpostsFIA = [];

{
	_positionOutpost = getMarkerPos _x;
	_arrayWatchpostsFIA pushBack [_positionOutpost,garrison getVariable [_x,[]]];
} forEach watchpostsFIA;

["watchpostsFIA", _arrayWatchpostsFIA] call A3A_fnc_setStatVariable;

private _arrayRoadblocksFIA = [];

{
	_positionOutpost = getMarkerPos _x;
	_arrayRoadblocksFIA pushBack [
		_positionOutpost,
		garrison getVariable [_x,[]],
		staticPositions getVariable [_x,[]],
		garrison getVariable [format ["%1_statics", _x], []]
	];
} forEach roadblocksFIA;

["roadblocksFIA", _arrayRoadblocksFIA] call A3A_fnc_setStatVariable;

private _arrayAAPostsFIA = [];

{
	_positionOutpost = getMarkerPos _x;
	_arrayAAPostsFIA pushBack [
		_positionOutpost,
		garrison getVariable [_x,[]],
		staticPositions getVariable [_x,[]],
		garrison getVariable [format ["%1_statics", _x], []]
	];
} forEach aapostsFIA;

["aapostsFIA", _arrayAAPostsFIA] call A3A_fnc_setStatVariable;

private _arrayATPostsFIA = [];

{
	_positionOutpost = getMarkerPos _x;
	_arrayATPostsFIA pushBack [
		_positionOutpost,
		garrison getVariable [_x,[]],
		staticPositions getVariable [_x,[]],
		garrison getVariable [format ["%1_statics", _x], []]
	];
} forEach atpostsFIA;

["atpostsFIA", _arrayATPostsFIA] call A3A_fnc_setStatVariable;

private _arrayMortarPostsFIA = [];

{
	_positionOutpost = getMarkerPos _x;
	_arrayMortarPostsFIA pushBack [
		_positionOutpost,
		garrison getVariable [_x,[]],
		staticPositions getVariable [_x,[]],
		garrison getVariable [format ["%1_statics", _x], []]
	];
} forEach mortarpostsFIA;

["mortarpostsFIA", _arrayMortarPostsFIA] call A3A_fnc_setStatVariable;

private _arrayLightRoadblocksFIA = [];

{
	_positionOutpost = getMarkerPos _x;
	_arrayLightRoadblocksFIA pushBack [
		_positionOutpost,
		garrison getVariable [_x,[]],
		staticPositions getVariable [_x,[]],
		garrison getVariable [format ["%1_statics", _x], []]
	];
} forEach lightroadblocksFIA;

["lightroadblocksFIA", _arrayLightRoadblocksFIA] call A3A_fnc_setStatVariable;

private _arrayHMGPostsFIA = [];

{
	_positionOutpost = getMarkerPos _x;
	_arrayHMGPostsFIA pushBack [
		_positionOutpost,
		garrison getVariable [_x,[]],
		staticPositions getVariable [_x,[]],
		garrison getVariable [format ["%1_statics", _x], []]
	];
} forEach hmgpostsFIA;

["hmgpostsFIA", _arrayHMGPostsFIA] call A3A_fnc_setStatVariable;

private _arraySupportPostsFIA = [];

{
	_positionOutpost = getMarkerPos _x;
	_arraySupportPostsFIA pushBack [
		_positionOutpost,
		garrison getVariable [_x,[]],
		staticPositions getVariable [_x,[]],
		garrison getVariable [format ["%1_statics", _x], []]
	];
} forEach supportpostsFIA;

["supportpostsFIA", _arraySupportPostsFIA] call A3A_fnc_setStatVariable;

if (!isDedicated) then {
	_typesX = [];
	{
		private _type = _x;
		private _index = A3A_tasksData findIf { (_x#1) isEqualTo _type and (_x#2) isEqualTo "CREATED" };
		if (_index != -1) then { _typesX pushBackUnique _type };

	} forEach ["AS","CON","DES","LOG","RES","ENC","CONVOY","DEF_HQ","rebelAttack","invaderPunish"];

	["tasks",_typesX] call A3A_fnc_setStatVariable;
};

_dataX = [];
{
	_dataX pushBack [_x,server getVariable _x];
} forEach airportsX + outposts + milbases;

["idlebases",_dataX] call A3A_fnc_setStatVariable;

_dataX = [];
{
	_dataX pushBack [_x,timer getVariable _x];
} forEach (vehAttack + vehMRLS + vehAA + vehHelis + vehFixedWing + staticAAOccupants + staticAAInvaders + [vehNATOBoat, vehCSATBoat, staticATOccupants, staticATInvaders]);

["idleassets",_dataX] call A3A_fnc_setStatVariable;

_dataX = [];
{
	_dataX pushBack [_x,killZones getVariable [_x,[]]];
} forEach airportsX + outposts + milbases;

["killZones",_dataX] call A3A_fnc_setStatVariable;

_controlsX = controlsX select {(sidesX getVariable [_x,sideUnknown] == teamPlayer) and (controlsX find _x < defaultControlIndex)};
["controlsSDK",_controlsX] call A3A_fnc_setStatVariable;

_finalStatistics = [
occupantKilled,
occupantKilledByPlayers,
occupantVehKilled,
occupantVehKilledByPlayers,
playerDeaths,
playerDeathsFF,
teamPlayerDeployed,
teamPlayerStoodDown,
teamPlayerKilled,
teamPlayerKilledFF,
partizanKilled,
partizanKilledFF,
teamPlayerVehDeployed,
teamPlayerVehDepot,
teamPlayerVehKilled,
teamPlayerVehKilledFF,
civilianKilledByOccupant,
civilianKilledByteamPlayer,
prisonersCaptured,
vehiclesCaptured,
sectorsLiberated,
sectorsLost
];

["finalStatistics",_finalStatistics] call A3A_fnc_setStatVariable;




//Saving the state of the testing timer
["testingTimerIsActive", testingTimerIsActive] call A3A_fnc_setStatVariable;

saveProfileNamespace;
savingServer = false;
_saveHintText = ["<t size='1.5'>",nameTeamPlayer," Assets:<br/><t color='#f0d498'>HR: ",str _hrBackground,"<br/>Command Points: ",str _resourcesBackground," CP</t></t><br/><br/>"] joinString "";
["Persistent Save",_saveHintText] remoteExec ["A3A_fnc_customHint",0,false];
[2, "Persistent Save Completed", _filename] call A3A_fnc_log;
