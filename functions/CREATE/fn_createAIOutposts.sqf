if (!isServer and hasInterface) exitWith{};
private ["_typeVehX","_markerX","_vehiclesX","_groups","_soldiers","_positionX","_pos","_size","_frontierX","_sideX","_cfg","_isFIA","_garrison","_antenna","_radiusX","_buildings","_mrk","_countX","_typeGroup","_groupX","_typeUnit","_veh","_unit","_flagX","_boxX","_roads","_mrkMar","_vehicle","_vehCrew","_groupVeh","_dist","_road","_roadCon","_dirVeh","_bunker","_dir","_posF"];
_markerX = _this select 0;

//Not sure if that ever happens, but it reduces redundance
if(spawner getVariable _markerX == 2) exitWith {};

_vehiclesX = [];
_groups = [];
_soldiers = [];
_props = [];

_positionX = getMarkerPos (_markerX);

private _baseMarker = [baseMarkersX, _positionX] call BIS_fnc_nearestPosition;
if (markerAlpha _baseMarker == 0) then {
	_baseMarker setMarkerAlpha 1;
	
	{
		if (getMarkerPos _x inArea _markerX) then {
			_x setMarkerAlpha 1;
		};
	} forEach mrkAntennas;
	
	[_baseMarker] spawn {
		_baseMarker = _this select 0;
		_num = round random 1000;
		_task = format ["Task_%1", _num];
		[[teamPlayer, civilian], _task, ["", "New Wehrmacht base discovered", ""], objNull, "ASSIGNED", 2, true] call BIS_fnc_taskCreate;
		[_task,"SUCCEEDED", true] call BIS_fnc_taskSetState;
			
		private _circleMrk = createMarker [format ["MrkCircle_%1", _num], (getMarkerPos _baseMarker)];
		_circleMrk setMarkerShape "ICON";
		_circleMrk setMarkerType "mil_circle";
		_circleMrk setMarkerSize [1.5, 1.5];		
	
		_time = time + 30;
		while {true} do {
			_circleMrk setMarkerColor "ColorYellow";
			sleep 1;
			_circleMrk setMarkerColor "colorBLUFOR";
			sleep 1;
			if (time > _time) exitWith {deleteMarker _circleMrk, [_task] call BIS_fnc_deleteTask};
		};
	};
};

_pos = [];

diag_log format ["[Antistasi] Spawning Outpost %1 (createAIOutposts.sqf)", _markerX];

_size = [_markerX] call A3A_fnc_sizeMarker;

_frontierX = [_markerX] call A3A_fnc_isFrontline;
_sideX = Invaders;
_isFIA = false;

switch (true) do {
	case ((gameMode == 4 && {sidesX getVariable [_markerX,sideUnknown] == Invaders})): {
		if ((random 10 >= (tierWar + difficultyCoef)) and !(_frontierX) and !(_markerX in forcedSpawn)) then {
			_isFIA = true;
		};
	};

	case (sidesX getVariable [_markerX,sideUnknown] == Occupants): {
		_sideX = Occupants;
		if ((random 10 >= (tierWar + difficultyCoef)) and !(_frontierX) and !(_markerX in forcedSpawn)) then {
			_isFIA = true;
		};
	};
};

_antenna = objNull;

if (_sideX == Occupants) then
{
	if (_markerX in outposts) then
	{
		_buildings = nearestObjects [_positionX,["Land_TTowerBig_1_F","Land_TTowerBig_2_F","Land_Communication_F"], _size];
		if (count _buildings > 0) then
		{
			_antenna = _buildings select 0;
		};
	};
};

_mrk = createMarkerLocal [format ["%1patrolarea", random 100], _positionX];
_mrk setMarkerShapeLocal "RECTANGLE";
_mrk setMarkerSizeLocal [(distanceSPWN/2),(distanceSPWN/2)];
_mrk setMarkerTypeLocal "hd_warning";
_mrk setMarkerColorLocal "ColorRed";
_mrk setMarkerBrushLocal "DiagGrid";
_ang = markerDir _markerX;
_mrk setMarkerDirLocal _ang;
if (!debug) then {_mrk setMarkerAlphaLocal 0};

private _patrolVehicleData = [_sideX, _positionX, _size] call SCRT_fnc_garrison_rollOversizeVehicle;
if (!(_patrolVehicleData isEqualTo [])) then {
	private _patrolVeh = _patrolVehicleData select 0;
	private _patrolVehCrew = crew _patrolVeh;
	private _patrolVehicleGroup = _patrolVehicleData select 2;
	{[_x] call A3A_fnc_NATOinit} forEach _patrolVehCrew;
	[_patrolVeh, _sideX] call A3A_fnc_AIVEHinit;

	_soldiers = _soldiers + _patrolVehCrew;
	_groups pushBack _patrolVehicleGroup;
	_vehiclesX pushBack _patrolVeh;

	[_patrolVehicleGroup, _positionX, (_size + 50)] call bis_fnc_taskPatrol;
};

private _additionalGarrison = [_sideX, _markerX] call SCRT_fnc_garrison_rollOversizeGarrison;
if (count _additionalGarrison > 0) then {
	for "_i" from 0 to (count _additionalGarrison) - 1 do {
		private _groupTypes = _additionalGarrison select _i;
		private _group = [_positionX, _sideX, _groupTypes, false, true] call A3A_fnc_spawnGroup;
		if !(isNull _group) then {
			sleep 1;
			_nul = [leader _group, _mrk, "SAFE","SPAWNED", "RANDOM", "NOVEH2"] execVM "scripts\UPSMON.sqf";//TODO need delete UPSMON link
			_groups pushBack _group;
			{[_x,_markerX] call A3A_fnc_NATOinit; _soldiers pushBack _x} forEach units _group;
		};
	};
};

_garrison = garrison getVariable [_markerX,[]];
_garrison = _garrison call A3A_fnc_garrisonReorg;

_radiusX = count _garrison;
private _patrol = true;
//If one is missing, there are no patrols??
if (_radiusX < ([_markerX] call A3A_fnc_garrisonSize)) then
{
	_patrol = false;
}
else
{
	//No patrol if patrol area overlaps with an enemy site
	_patrol = ((markersX findIf {(getMarkerPos _x inArea _mrk) && {sidesX getVariable [_x, sideUnknown] != _sideX}}) == -1);
};
if (_patrol) then
{
	_countX = 0;
	while {_countX < 4} do
	{
		_arraygroups = if (!_isFIA) then {
			if (_sideX == Occupants) then {
				[(groupsNATOSentry call SCRT_fnc_unit_selectInfantryTier), (groupsNATOSniper call SCRT_fnc_unit_selectInfantryTier)];
			} else {
				[(groupsCSATSentry call SCRT_fnc_unit_selectInfantryTier), (groupsCSATSniper call SCRT_fnc_unit_selectInfantryTier)];
			};
		} else {
			if (_sideX == Occupants) then {
				groupsFIASmall;
			} else {
				groupsWAMSmall;
			};
		};

				
		if ([_markerX,false] call A3A_fnc_fogCheck < 0.3) then {_arraygroups = _arraygroups - sniperGroups};
		_typeGroup = selectRandom _arraygroups;
		_groupX = [_positionX,_sideX, _typeGroup,false,true] call A3A_fnc_spawnGroup;
		if !(isNull _groupX) then
		{
			sleep 1;
			if ((random 10 < 2.5) and (!(_typeGroup in sniperGroups))) then
			{
				_dog = [_groupX, "Fin_random_F",_positionX,[],0,"FORM"] call A3A_fnc_createUnit;
				[_dog] spawn A3A_fnc_guardDog;
				sleep 1;
			};
			[leader _groupX, _mrk, "SAFE","SPAWNED", "RANDOM","NOVEH2"] execVM "scripts\UPSMON.sqf";//TODO need delete UPSMON link
			_groups pushBack _groupX;
			{[_x,_markerX] call A3A_fnc_NATOinit; _soldiers pushBack _x} forEach units _groupX;
		};
		_countX = _countX +1;
	};
};

_ret = [_markerX,_size,_sideX,_frontierX] call A3A_fnc_milBuildings;
_groups append (_ret select 0);
_vehiclesX append (_ret select 1);
_soldiers append (_ret select 2);
{ [_x, _sideX] call A3A_fnc_AIVEHinit } forEach _vehiclesX;

if(random 100 < (40 + tierWar * 3)) then
{
	_large = (random 100 < (30 + tierWar * 2));
	[_markerX, _large] spawn A3A_fnc_placeIntel;
};

_typeVehX = if (_sideX == Occupants) then {NATOFlag} else {CSATFlag};
_flagX = createVehicle [_typeVehX, _positionX, [],0, "NONE"];
_flagX allowDamage false;
[_flagX,"take"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_flagX];
_vehiclesX pushBack _flagX;

// Only create ammoBox if it's been recharged (see reinforcementsAI)
private _ammoBox = if (garrison getVariable [_markerX + "_lootCD", 0] == 0) then
{
	private _ammoBoxType = if (_sideX == Occupants) then {NATOAmmoBox} else {CSATAmmoBox};
	private _ammoBox = [_ammoBoxType, _positionX, 15, 5, true] call A3A_fnc_safeVehicleSpawn;
	// Otherwise when destroyed, ammoboxes sink 100m underground and are never cleared up
	_ammoBox addEventHandler ["Killed", { [_this#0] spawn { sleep 10; deleteVehicle (_this#0) } }];
	[_ammoBox] spawn A3A_fnc_fillLootCrate;
	[_ammoBox] call A3A_fnc_logistics_addLoadAction;

	/*if (_markerX in seaports) then {
		[_ammoBox] spawn {
			sleep 1;    //make sure fillLootCrate finished clearing the crate
			{
				_this#0 addItemCargoGlobal [_x, round random [2,6,8]];
			} forEach (A3A_faction_reb getVariable "diveGear");
		};
	};*/
	_ammoBox;
};

_roads = _positionX nearRoads _size;

if (_markerX in seaports) then
{
	_typeVehX = if (_sideX == Occupants) then {vehNATOBoat} else {vehCSATBoat};
	if ([_typeVehX] call A3A_fnc_vehAvailable) then
	{
		_mrkMar = seaSpawn select {getMarkerPos _x inArea _markerX};
		if(count _mrkMar > 0) then
		{
			_pos = (getMarkerPos (_mrkMar select 0)) findEmptyPosition [0,20,_typeVehX];
			_vehicle=[_pos, 0,_typeVehX, _sideX] call A3A_fnc_spawnVehicle;
			_veh = _vehicle select 0;
			[_veh, _sideX] call A3A_fnc_AIVEHinit;
			_vehCrew = _vehicle select 1;
			{[_x,_markerX] call A3A_fnc_NATOinit} forEach _vehCrew;
			_groupVeh = _vehicle select 2;
			_soldiers = _soldiers + _vehCrew;
			_groups pushBack _groupVeh;
			_vehiclesX pushBack _veh;
			sleep 1;
		}
		else
		{
			diag_log format ["createAIOutposts: Could not find seaSpawn marker on %1!", _markerX];
		};
	};
};

_spawnParameter = [_markerX, "Vehicle"] call A3A_fnc_findSpawnPosition;
if (_spawnParameter isEqualType []) then {
	private _truckTypes = switch (true) do {
		case (!_isFIA && {_sideX == Occupants}): {
			private _types = vehNATOTrucks + vehNATOCargoTrucks;
			_types = _types select { _x in vehCargoTrucks };
			if (_frontierX) then {_types append vehNATOLightArmed};
			if (_types isEqualTo []) then {_types = vehNATOTrucks + vehNATOCargoTrucks};
			_types;
		};
		case (_isFIA && {_sideX == Occupants}): {
			private _types = vehFIATrucks;
			_types = _types select { _x in vehCargoTrucks };
			if (_frontierX) then {_types append vehFIAArmedCars};
			if (_types isEqualTo []) then {_types = vehFIATrucks};
			_types;
		};
		case (!_isFIA && {_sideX == Invaders}): {
			private _types = vehCSATTrucks + vehCSATCargoTrucks;
			_types = _types select { _x in vehCargoTrucks };
			if (_frontierX) then {_types append vehCSATLightArmed};
			if (_types isEqualTo []) then {_types = vehCSATTrucks + vehCSATCargoTrucks};
			_types;
		};
		case (_isFIA && {_sideX == Invaders}): {
			private _types = vehWAMTrucks;
			_types = _types select { _x in vehCargoTrucks };
			if (_frontierX) then {_types append vehWAMArmedCars};
			if (_types isEqualTo []) then {_types = vehWAMTrucks};
			_types;
		};
		default {
			[];
		};
	};

	if (_truckTypes isEqualTo []) then {
		if (_sideX == Occupants) then {
			_truckTypes = vehNATOTrucks + vehNATOCargoTrucks + vehFIATrucks + vehFIAArmedCars + [vehNATOAmmoTruck,vehNATOFuelTruck,vehNATORepairTruck];
		} else {
			_truckTypes = vehCSATTrucks + vehCSATCargoTrucks + vehWAMTrucks + vehWAMArmedCars;
		};
	};
 
	_veh = createVehicle [selectRandom _truckTypes, (_spawnParameter select 0), [], 0, "NONE"];
	_veh setDir (_spawnParameter select 1);
	_vehiclesX pushBack _veh;
	_nul = [_veh, _sideX] call A3A_fnc_AIVEHinit;
	sleep 1;
};

{ _x setVariable ["originalPos", getPos _x] } forEach _vehiclesX;

_countX = 0;

if (!isNull _antenna) then
{
	_typeUnit = objNull;
	if ((typeOf _antenna == "Land_Vysilac_FM2")) then
	{
		_groupX = createGroup _sideX;

		_typeUnit = if (_sideX == Occupants) then {
			if (!_isFIA) then {NATOSniper call SCRT_fnc_unit_selectInfantryTier} else {FIAMarksman};
		} else {
			if (!_isFIA) then {CSATMarksman call SCRT_fnc_unit_selectInfantryTier} else {WAMMarksman};
		};
		_unit = [_groupX, _typeUnit, _positionX, [], _dir, "NONE"] call A3A_fnc_createUnit;
		_unit setPosATL (_antenna buildingPos 4);;
		_unit forceSpeed 0;
		_unit setUnitPos "UP";
		[_unit,_markerX] call A3A_fnc_NATOinit;
		_soldiers pushBack _unit;
		_groups pushBack _groupX;
	};
};

_array = [];
_subArray = [];
_countX = 0;
_radiusX = _radiusX -1;
while {_countX <= _radiusX} do
{
	_array pushBack (_garrison select [_countX,7]);
	_countX = _countX + 8;
};

for "_i" from 0 to (count _array - 1) do
{
	//What is so special about the first?
	_groupX = if (_i == 0) then
	{
		[_positionX,_sideX, (_array select _i),true,false] call A3A_fnc_spawnGroup
	}
	else
	{
		[_positionX,_sideX, (_array select _i),false,true] call A3A_fnc_spawnGroup
	};
	_groups pushBack _groupX;
	{
		[_x,_markerX] call A3A_fnc_NATOinit;
		_soldiers pushBack _x;
	} forEach units _groupX;
	if (_i == 0) then
	{
		//Can't we just precompile this and call this like every other funtion? Would save some time
		_nul = [leader _groupX, _markerX, "SAFE", "RANDOMUP", "SPAWNED", "NOVEH2", "NOFOLLOW"] execVM "scripts\UPSMON.sqf";
	}
	else
	{
		_nul = [leader _groupX, _markerX, "SAFE", "SPAWNED", "RANDOM","NOVEH2", "NOFOLLOW"] execVM "scripts\UPSMON.sqf";
	};
};//TODO need delete UPSMON link

waitUntil {sleep 1; (spawner getVariable _markerX == 2)};

[_markerX] call A3A_fnc_freeSpawnPositions;

deleteMarker _mrk;
//{if ((!alive _x) and (not(_x in destroyedBuildings))) then {destroyedBuildings = destroyedBuildings + [position _x]; publicVariableServer "destroyedBuildings"}} forEach _buildings;

{ if (alive _x) then { deleteVehicle _x } } forEach _soldiers;
{ deleteGroup _x } forEach _groups;

{
	// delete all vehicles that haven't been stolen
	if (_x getVariable ["ownerSide", _sideX] == _sideX) then {
		if (_x distance2d (_x getVariable "originalPos") < 100) then { deleteVehicle _x }
		else { if !(_x isKindOf "StaticWeapon") then { [_x] spawn A3A_fnc_VEHdespawner } };
	};
} forEach _vehiclesX;

{
	deleteVehicle _x;
} forEach _props;

// If loot crate was stolen, set the cooldown
if (!isNil "_ammoBox") then {
	if ((alive _ammoBox) and (_ammoBox distance2d _positionX < 100)) exitWith { deleteVehicle _ammoBox };
	if (alive _ammoBox) then { [_ammoBox] spawn A3A_fnc_VEHdespawner };
	private _lootCD = 120*16 / ([_markerX] call A3A_fnc_garrisonSize);
	garrison setVariable [_markerX + "_lootCD", _lootCD, true];
};