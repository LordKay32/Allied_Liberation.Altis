if (!isServer and hasInterface) exitWith{};

private ["_pos","_markerX","_vehiclesX","_groups","_soldiers","_busy","_buildings","_pos1","_pos2","_groupX","_countX","_typeVehX","_veh","_unit","_arrayVehAAF","_nVeh","_frontierX","_size","_ang","_mrk","_typeGroup","_flagX","_dog","_typeUnit","_garrison","_sideX","_cfg","_max","_vehicle","_vehCrew","_groupVeh","_roads","_dist","_road","_roadscon","_roadcon","_dirveh","_bunker","_typeGroup"];
_markerX = _this select 0;

//Not sure if that ever happens, but it reduces redundance
if(spawner getVariable _markerX == 2) exitWith {};

diag_log format ["[Antistasi] Spawning Airbase %1 (createAIAirplane.sqf)", _markerX];

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

_size = [_markerX] call A3A_fnc_sizeMarker;
//_garrison = garrison getVariable _markerX;

_frontierX = [_markerX] call A3A_fnc_isFrontline;
_busy = if (dateToNumber date > server getVariable _markerX) then {false} else {true};
_nVeh = (round (_size/60) min 4);

_sideX = sidesX getVariable [_markerX,sideUnknown];

private _radarType = if (_sideX == Occupants) then {NATOAARadar} else {CSATAARadar};
private _samType = if (_sideX == Occupants) then {NATOAASam} else {CSATAASam};
private _aaElements = [_radarType, _samType];

/////////////////////////////
// SPAWNING AA ELEMENTS
////////////////////////////
_spawnParameter = [_markerX, "Sam"] call A3A_fnc_findSpawnPosition;
while {_spawnParameter isEqualType []} do {
    {
        if(_x != "") then {
            private _vehiclePosition = [_spawnParameter select 0, 0, 125, 10, 0, 0.7] call BIS_fnc_findSafePos;
            private _rotation = random 360;

            private _aaVehicleData = [_vehiclePosition, _rotation, _x, _sideX] call A3A_fnc_spawnVehicle;
            private _aaVehicle = _aaVehicleData select 0;
            private _aaVehicleCrew = _aaVehicleData select 1;
            {[_x,_markerX] call A3A_fnc_NATOinit} forEach _aaVehicleCrew;
            [_aaVehicle, _sideX] call A3A_fnc_AIVEHinit;
            _aaVehicleGroup = _aaVehicleData select 2;

            _soldiers = _soldiers + _aaVehicleCrew;
            _groups pushBack _aaVehicleGroup;
            _vehiclesX pushBack _aaVehicle;
            sleep 1;

            //radar rotation
            if(_x == _radarType) then {
                [_aaVehicle] spawn {
                    params ["_radar"];

                    while {alive _radar} do {
                        {
                            _radar lookAt (_radar getRelPos [100, _x]);
                            sleep 2.45;
                        } forEach [120, 240, 0];
                    };
                };
            };
        };
    } forEach _aaElements;
	_spawnParameter = [_markerX, "Sam"] call A3A_fnc_findSpawnPosition;
	sleep 1;
};


_typeVehX = if (_sideX == Occupants) then {selectRandom vehNATOAA} else {selectRandom vehCSATAA};
_max = if (_frontierX && {[_typeVehX] call A3A_fnc_vehAvailable}) then {2} else {1};
for "_i" from 1 to _max do {
	_spawnParameter = [_markerX, "Vehicle"] call A3A_fnc_findSpawnPosition;

	if (_spawnParameter isEqualType []) then
	{
		_vehicle=[_spawnParameter select 0, _spawnParameter select 1,_typeVehX, _sideX] call A3A_fnc_spawnVehicle;
		_veh = _vehicle select 0;
		_vehCrew = _vehicle select 1;
		{[_x,_markerX] call A3A_fnc_NATOinit} forEach _vehCrew;
		[_veh, _sideX] call A3A_fnc_AIVEHinit;
		_groupVeh = _vehicle select 2;
		_soldiers = _soldiers + _vehCrew;
		_groups pushBack _groupVeh;
		_vehiclesX pushBack _veh;
		sleep 0.1;
		[(gunner _veh), 300] spawn SCRT_fnc_common_scanHorizon;
	}
	else
	{
		_i = _max;
	};
};

private _vehiclePool = if (_sideX == Occupants) then { vehNATOAttack -  ["LIB_PzKpfwVI_E_tarn51d"] } else { vehCSATAttack };
private _selectedVehicle = nil;
_vehiclePool = [_vehiclePool] call CBA_fnc_shuffle;

{
	if([_x] call A3A_fnc_vehAvailable) exitWith {_selectedVehicle = _x};
} forEach _vehiclePool;

if (!isNil "_selectedVehicle") then {
	private _patrolPos = [_positionX, 20, _size, 5, 0, 0.5, 0, [], [_positionX, _positionX]] call BIS_Fnc_findSafePos;
	private _patrolVehicleData = [_patrolPos, 0, _selectedVehicle, _sideX] call A3A_fnc_spawnVehicle;
	private _patrolVeh = _patrolVehicleData select 0;
	private _patrolVehCrew = crew _patrolVeh;
	private _patrolVehicleGroup = _patrolVehicleData select 2;
	{[_x] call A3A_fnc_NATOinit} forEach _patrolVehCrew;
	[_patrolVeh, _sideX] call A3A_fnc_AIVEHinit;
	_soldiers = _soldiers + _patrolVehCrew;
	_groups pushBack _patrolVehicleGroup;
	_vehiclesX pushBack _patrolVeh;

	[_patrolVehicleGroup, _positionX, 450] call bis_fnc_taskPatrol;
};

/*
if (_frontierX) then {
	private _helicopterClass = if(_sideX == Occupants) then { selectRandom vehNATOAttackHelis; } else { selectRandom vehCSATAttackHelis; };
	_heliData = [[_positionX select 0, _positionX select 1, 300], 0, _helicopterClass, _sideX] call A3A_fnc_spawnVehicle;
	_heliVeh = _heliData select 0;
	[_heliVeh, _sideX] call A3A_fnc_AIVEHinit;
	_heliCrew = _heliData select 1;
	{[_x] call A3A_fnc_NATOinit} forEach _heliCrew;
	_heliVehicleGroup = _heliData select 2;
	_soldiers = _soldiers + _heliCrew;
	_groups pushBack _heliVehicleGroup;
	_vehiclesX pushBack _heliVeh;
	[_heliVehicleGroup, _positionX, 650] call bis_fnc_taskPatrol;

	_roads = _positionX nearRoads _size;
	if (count _roads != 0) then {
		_groupX = createGroup _sideX;
		_groups pushBack _groupX;
		_dist = 0;
		_road = objNull;
		{if ((position _x) distance _positionX > _dist) then {_road = _x;_dist = position _x distance _positionX}} forEach _roads;
		_roadscon = roadsConnectedto _road;
		_roadcon = objNull;
		{if ((position _x) distance _positionX > _dist) then {_roadcon = _x}} forEach _roadscon;
		_dirveh = [_roadcon, _road] call BIS_fnc_DirTo;
		_pos = [getPos _road, 7, _dirveh + 270] call BIS_Fnc_relPos;
		_bunker = sandbag createVehicle _pos;
		_vehiclesX pushBack _bunker;
		_bunker setDir _dirveh;
		_pos = getPosATL _bunker;
		_typeVehX = if (_sideX == Occupants) then {staticATOccupants} else {staticATInvaders};
		_veh = _typeVehX createVehicle _positionX;
		_vehiclesX pushBack _veh;
		_veh setDir _dirVeh + 180;
		_veh setPos [(_pos select 0) - 1, (_pos select 1) - 1, _pos select 2];
		_typeUnit = if (_sideX==Occupants) then {
			staticCrewOccupants call SCRT_fnc_unit_selectInfantryTier
		} else {
			staticCrewInvaders call SCRT_fnc_unit_selectInfantryTier
		};
		_unit = [_groupX, _typeUnit, _positionX, [], 0, "NONE"] call A3A_fnc_createUnit;
		[_unit,_markerX] call A3A_fnc_NATOinit;
		[_veh, _sideX] call A3A_fnc_AIVEHinit;
		_unit moveInGunner _veh;
		_soldiers pushBack _unit;
	};
};*/


_mrk = createMarkerLocal [format ["%1patrolarea", random 100], _positionX];
_mrk setMarkerShapeLocal "RECTANGLE";
_mrk setMarkerSizeLocal [(distanceSPWN/2),(distanceSPWN/2)];
_mrk setMarkerTypeLocal "hd_warning";
_mrk setMarkerColorLocal "ColorRed";
_mrk setMarkerBrushLocal "DiagGrid";
_ang = markerDir _markerX;
_mrk setMarkerDirLocal _ang;
if (!debug) then {_mrk setMarkerAlphaLocal 0};
_garrison = garrison getVariable [_markerX,[]];

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

_garrison = _garrison call A3A_fnc_garrisonReorg;
_radiusX = count _garrison;
private _patrol = true;
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
	while {_countX < 5} do
	{
		_arraygroups = if (_sideX == Occupants) then {
			[(groupsNATOSentry call SCRT_fnc_unit_selectInfantryTier), (groupsNATOSniper call SCRT_fnc_unit_selectInfantryTier)]
		}
		else {
			[(groupsCSATSentry call SCRT_fnc_unit_selectInfantryTier), (groupsCSATSniper call SCRT_fnc_unit_selectInfantryTier)]
		};
		
		if ([_markerX,false] call A3A_fnc_fogCheck < 0.3) then {_arraygroups = _arraygroups - sniperGroups};
		_typeGroup = selectRandom _arraygroups;
		_groupX = [_positionX,_sideX, _typeGroup,false,true] call A3A_fnc_spawnGroup;
		if !(isNull _groupX) then
		{
			sleep 1;
			if ((random 10 < 2.5) and (not(_typeGroup in sniperGroups))) then
			{
				_dog = [_groupX, "Fin_random_F",_positionX,[],0,"FORM"] call A3A_fnc_createUnit;
				[_dog] spawn A3A_fnc_guardDog;
				sleep 1;
			};
			_nul = [leader _groupX, _mrk, "SAFE","SPAWNED", "RANDOM", "NOVEH2"] execVM "scripts\UPSMON.sqf";//TODO need delete UPSMON link
			_groups pushBack _groupX;
			{[_x,_markerX] call A3A_fnc_NATOinit; _soldiers pushBack _x} forEach units _groupX;
		};
		_countX = _countX +1;
	};
};
_countX = 0;

_groupX = createGroup _sideX;
_groups pushBack _groupX;
_typeUnit = if (_sideX == Occupants) then {
	staticCrewOccupants call SCRT_fnc_unit_selectInfantryTier
} else {
	staticCrewInvaders call SCRT_fnc_unit_selectInfantryTier
};
private _typeVehX = if (_sideX == Occupants) then {NATOMortar} else {CSATMortar};

_spawnParameter = [_markerX, "Mortar"] call A3A_fnc_findSpawnPosition;
while {_spawnParameter isEqualType []} do
{
	private _mortarPos = _spawnParameter select 0;
	_veh = _typeVehX createVehicle (_mortarPos);
	_veh setDir (_spawnParameter select 1);
	//_veh setPosATL (_spawnParameter select 0);
	_nul=[_veh] execVM "scripts\UPSMON\MON_artillery_add.sqf";//TODO need delete UPSMON link
	_unit = [_groupX, _typeUnit, _positionX, [], 0, "CAN_COLLIDE"] call A3A_fnc_createUnit;
	[_unit,_markerX] call A3A_fnc_NATOinit;
	_unit moveInGunner _veh;
	_soldiers pushBack _unit;
	_vehiclesX pushBack _veh;
	[_veh, _sideX] call A3A_fnc_AIVEHinit;
	_spawnParameter = [_markerX, "Mortar"] call A3A_fnc_findSpawnPosition;
	sleep 1;

	{
		private _relativePosition = [_mortarPos, 4, _x] call BIS_Fnc_relPos;
		private _sandbag = createVehicle ["Land_BagFence_Round_F", _relativePosition, [], 0, "CAN_COLLIDE"];
		_sandbag setDir ([_sandbag, _mortarPos] call BIS_fnc_dirTo);
		_sandbag setVectorUp surfaceNormal position _sandbag;
		_props pushBack _sandbag;
	} forEach [0, 90, 180, 270];
};

_ret = [_markerX,_size,_sideX,_frontierX] call A3A_fnc_milBuildings;
_groups append (_ret select 0);
_vehiclesX append (_ret select 1);
_soldiers append (_ret select 2);
{[_x, _sideX] call A3A_fnc_AIVEHinit} forEach (_ret select 1);

if(random 100 < (50 + tierWar * 3)) then
{
	_large = (random 100 < (40 + tierWar * 2));
	[_markerX, _large] spawn A3A_fnc_placeIntel;
};

if (!_busy) then
{
	//Newer system in place
	private _runwaySpawnLocation = [_markerX] call A3A_fnc_getRunwayTakeoffForAirportMarker;
	_spawnParameter = [_markerX, "Plane"] call A3A_fnc_findSpawnPosition;
	if !(_runwaySpawnLocation isEqualTo []) then
	{
		_pos = _runwaySpawnLocation select 0;
		_ang = _runwaySpawnLocation select 1;
	};
	_groupX = createGroup _sideX;
	_groups pushBack _groupX;
	_countX = 0;
	while {_countX < 2} do
	{
		private _veh = objNull;
		if(_spawnParameter isEqualType []) then
		{
			private _vehPool = [];
			if (_sideX == Occupants) then {
				private _vehPool = vehNATOAir select {[_x] call A3A_fnc_vehAvailable};
			}
			else {
				private _vehPool = vehCSATAir select {[_x] call A3A_fnc_vehAvailable};
			};
			
			if(count _vehPool > 0) then
			{
				_typeVehX = selectRandom _vehPool;
				_veh = createVehicle [_typeVehX, (_spawnParameter select 0), [], 0, "CAN_COLLIDE"];
				_veh setDir (_spawnParameter select 1);
				_veh setPos (_spawnParameter select 0);
				_vehiclesX pushBack _veh;
				[_veh, _sideX] call A3A_fnc_AIVEHinit;
			};
			_spawnParameter = [_markerX, "Plane"] call A3A_fnc_findSpawnPosition;
		}
		else
		{
			if !(_runwaySpawnLocation isEqualTo []) then
			{
				_typeVehX = if (_sideX == Occupants) then {selectRandom (vehNATOPlanes select {[_x] call A3A_fnc_vehAvailable})} else {selectRandom (vehCSATPlanes select {[_x] call A3A_fnc_vehAvailable})};
				_veh = createVehicle [_typeVehX, _pos, [],3, "NONE"];
				_veh setDir (_ang);
				_pos = [_pos, 50,_ang] call BIS_fnc_relPos;
				_vehiclesX pushBack _veh;
				[_veh, _sideX] call A3A_fnc_AIVEHinit;
								
				_unitType = [_sideX, _veh] call A3A_fnc_crewTypeForVehicle;

				_group = createGroup _sideX;
				_group = [_group, _veh, _unitType] call A3A_fnc_createVehicleCrew;
				_crew = units _group;
				_soldiers append _crew;
				_groups pushback _group;
				
				_group setBehaviourStrong "SAFE";
				private _pos = [_positionX, 10, 100, 3, 0, 0, 0] call BIS_fnc_findSafePos;
				{
				[_x,_markerX] call A3A_fnc_NATOinit;
				_x setPos _pos;
				[_x] allowGetIn false;
				} forEach _crew;
				[_group, _positionX] spawn {
					params ["_group", "_positionX"];
					waitUntil {sleep 1; combatBehaviour _group != "SAFE"};
					{
					[_x] allowGetIn true;
					[_x] orderGetIn true;
					} forEach units _group;
					waitUntil {sleep 1; (units _group) findIf {vehicle _x == _x} == -1};
					_wp = _group addWaypoint [_positionX, 0];
					_wp setWaypointType "SAD";
				};	
			}
			else
			{
				//No places found, neither hangar nor runway
				_countX = 1;
			};
		};
		_countX = _countX + 1;
	};
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

	[_ammoBox] spawn {
		sleep 1;    //make sure fillLootCrate finished clearing the crate
		{
			_this#0 addItemCargoGlobal [_x, round random [5,15,15]];
		} forEach (A3A_faction_reb getVariable "flyGear");
	};
	_ammoBox;
};

if (!_busy) then
{
	for "_i" from 1 to (round (random 2)) do
	{
		_arrayVehAAF = if (_sideX == Occupants) then {(vehNATOAttack - ["LIB_PzKpfwVI_E_tarn51d"]) select {[_x] call A3A_fnc_vehAvailable}} else {vehCSATAttack select {[_x] call A3A_fnc_vehAvailable}};
		private _typeVehX = selectRandom _arrayVehAAF;
		_spawnParameter = [_markerX, "Vehicle"] call A3A_fnc_findSpawnPosition;
		if (count _arrayVehAAF > 0 && {_spawnParameter isEqualType []}) then
		{
			if (_typeVehX in (vehNATOTanks + vehCSATTanks + vehNATOLightArmed + vehCSATLightArmed + ["fow_v_sdkfz_222_camo_ger_heer","fow_v_sdkfz_250_9_camo_ger_heer"])) then {
				private _vehVehicleData = [_spawnParameter select 0, _spawnParameter select 1, _typeVehX, _sideX] call A3A_fnc_spawnVehicle;
				_veh = _vehVehicleData select 0;
				_crew = _vehVehicleData select 1;
				_group = _vehVehicleData select 2;
				_vehiclesX pushBack _veh;
				_soldiers append _crew;
				_groups pushBack _group;
				[_veh, _sideX] call A3A_fnc_AIVEHinit;
				_group setBehaviourStrong "SAFE";
				private _pos = [_positionX, 10, 100, 3, 0, 0, 0] call BIS_fnc_findSafePos;
				{
				[_x,_markerX] call A3A_fnc_NATOinit;
				_x setPos _pos;
				[_x] allowGetIn false;
				} forEach _crew;
				[_group] spawn {
					params ["_group"];
					waitUntil {sleep 1; combatBehaviour _group != "SAFE"};
					{
					[_x] allowGetIn true;
					[_x] orderGetIn true;
					} forEach units _group;
				};
			} else {
				_veh = createVehicle [_typeVehX, (_spawnParameter select 0), [], 0, "CAN_COLLIDE"];
				_veh setDir (_spawnParameter select 1);
				_vehiclesX pushBack _veh;
				[_veh, _sideX] call A3A_fnc_AIVEHinit;
			};
			_nVeh = _nVeh -1;
			sleep 1;
		};
	};
};

_arrayVehAAF = if (_sideX == Occupants) then {vehNATONormal} else {vehCSATNormal};
_countX = 0;

while {_countX < _nVeh && {_countX < 3}} do
{
	_typeVehX = selectRandom _arrayVehAAF;
	_spawnParameter = [_markerX, "Vehicle"] call A3A_fnc_findSpawnPosition;
	if(_spawnParameter isEqualType []) then
	{
		_veh = createVehicle [_typeVehX, (_spawnParameter select 0), [], 0, "NONE"];
		_veh setDir (_spawnParameter select 1);
		_vehiclesX pushBack _veh;
		[_veh, _sideX] call A3A_fnc_AIVEHinit;
		sleep 1;
		_countX = _countX + 1;
	}
	else
	{
		//No further spaces to spawn vehicle
		_countX = _nVeh;
	};
};

{ _x setVariable ["originalPos", getPos _x] } forEach _vehiclesX;

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
	_groupX = if (_i == 0) then {
		[_positionX,_sideX, (_array select _i),true,false] call A3A_fnc_spawnGroup
	} else {
		[_positionX,_sideX, (_array select _i),false,true] call A3A_fnc_spawnGroup
	};
	_groups pushBack _groupX;
	{[_x,_markerX] call A3A_fnc_NATOinit; _soldiers pushBack _x} forEach units _groupX;
	if (_i == 0) then {_nul = [leader _groupX, _markerX, "SAFE", "RANDOMUP","SPAWNED", "NOVEH2", "NOFOLLOW"] execVM "scripts\UPSMON.sqf"} else {_nul = [leader _groupX, _markerX, "SAFE","SPAWNED", "RANDOM","NOVEH2", "NOFOLLOW"] execVM "scripts\UPSMON.sqf"};
	};//TODO need delete UPSMON link
	
[_markerX] spawn A3A_fnc_partizanAttack;

waitUntil {sleep 1; (spawner getVariable _markerX == 2)};

[_markerX] call A3A_fnc_freeSpawnPositions;

deleteMarker _mrk;
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
