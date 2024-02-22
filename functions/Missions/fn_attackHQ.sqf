//Mission: HQ is under attack
if (!isServer and hasInterface) exitWith{};

private _positionX = getMarkerPos respawnTeamPlayer;

private _pilots = [];
private _vehiclesX = [];
private _groups = [];
private _soldiers = [];

if ({(_x distance _positionX < 500) and (typeOf _x == staticAAteamPlayer)} count staticsToSave > 4) exitWith {};

private _airportsX = airportsX select {(sidesX getVariable [_x,sideUnknown] != teamPlayer) and (spawner getVariable _x == 2) and ((getMarkerPos _x) distance _positionX > 4000)};
if (count _airportsX == 0) exitWith {};
private _airportX = [_airportsX,_positionX] call BIS_fnc_nearestPosition;
private _posOrigin = getMarkerPos _airportX;
private _sideX = if (sidesX getVariable [_airportX,sideUnknown] == Occupants) then {Occupants} else {Invaders};
private _naming = if (_sideX == Occupants) then {nameOccupants} else {nameInvaders};

private _taskId = "DEF_HQ" + str A3A_taskCount;
[[teamPlayer,civilian],_taskId,[format ["We have intercepted important %1 radio communications, they have located our HQ and are mounting an attack on it. Defend it at all costs.",_naming],"Defend HQ",respawnTeamPlayer],_positionX,true,10,true,"Defend",true] call BIS_fnc_taskCreate;
[[_sideX],_taskId+"B",[format ["We know %2 HQ coordinates. We have sent a SpecOp Squad in order to kill his leader %1. Help the SpecOp team",name petros, nameTeamPlayer],format ["Kill %1",name petros],respawnTeamPlayer],_positionX,true,10,true,"Attack",true] call BIS_fnc_taskCreate;
[_taskId, "DEF_HQ", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];
/*
_typesVeh = if (_sideX == Occupants) then {vehNATOAttackHelis} else {vehCSATAttackHelis};
_typesVeh = _typesVeh select {[_x] call A3A_fnc_vehAvailable};

if (count _typesVeh > 0) then
	{
	_typeVehX = selectRandom _typesVeh;
	//_pos = [_positionX, distanceSPWN * 3, random 360] call BIS_Fnc_relPos;
	_vehicle=[_posOrigin, 0, _typeVehX, _sideX] call A3A_fnc_spawnVehicle;
	_heli = _vehicle select 0;
	_heliCrew = _vehicle select 1;
	_groupHeli = _vehicle select 2;
	_pilots = _pilots + _heliCrew;
	_groups pushBack _groupHeli;
	_vehiclesX pushBack _heli;
	{[_x] call A3A_fnc_NATOinit} forEach _heliCrew;
	[_heli, _sideX] call A3A_fnc_AIVEHinit;
	_wp1 = _groupHeli addWaypoint [_positionX, 0];
	_wp1 setWaypointType "SAD";
	//[_heli,"Air Attack"] spawn A3A_fnc_inmuneConvoy;
	sleep 30;
	};
_typesVeh = if (_sideX == Occupants) then {vehNATOTransportHelis} else {vehCSATTransportHelis};*/
_typesVeh = if (_sideX == Occupants) then {vehNATOTransportPlanes} else {vehCSATTransportPlanes};
//if (_typesVeh isEqualTo []) then {if (_sideX == Occupants) then {vehNATOTransportPlanes} else {vehCSATTransportPlanes};};
_typeGroup = if (_sideX == Occupants) then {NATOParaSquad} else {CSATSpecOp};

private _num = if (aggressionLevelOccupants > 3) then {2} else {1};

for "_i" from 1 to _num do
	{
	_typeVehX = selectRandom _typesVeh;
	//_pos = [_positionX, distanceSPWN * 3, random 360] call BIS_Fnc_relPos;
	_vehicle=[_posOrigin, 0, _typeVehX, _sideX] call A3A_fnc_spawnVehicle;
	_heli = _vehicle select 0;
	_heliCrew = _vehicle select 1;
	_groupHeli = _vehicle select 2;
	_dir = _posOrigin getDir _positionX;
	_heli setDir _dir;
	_pilots = _pilots + _heliCrew;
	_groups pushBack _groupHeli;
	_vehiclesX pushBack _heli;

	private _paraGroups = [];

	{_x setBehaviour "CARELESS";} forEach units _groupHeli;
	_groupX = [_posOrigin, _sideX, _typeGroup] call A3A_fnc_spawnGroup;
	{_x moveInAny _heli; _soldiers pushBack _x; [_x] call A3A_fnc_NATOinit} forEach units _groupX;
	_groups pushBack _groupX;
	_paraGroups pushBack _groupX;
	
	_groupY = [_posOrigin, _sideX, _typeGroup] call A3A_fnc_spawnGroup;
	{_x moveInAny _heli; _soldiers pushBack _x; [_x] call A3A_fnc_NATOinit} forEach units _groupY;
	_groups pushBack _groupY;
	_paraGroups pushBack _groupY;

	//[_heli,"Air Transport"] spawn A3A_fnc_inmuneConvoy;
	if (_typeVehX isKindOf "Plane") then {
		[_heli,_paraGroups,_positionX,_airportX] spawn A3A_fnc_paradrop;
	} else {
		[_heli,_groupX,_positionX,_posOrigin,_groupHeli] spawn A3A_fnc_fastrope;
	};

	sleep 5;
};

[_vehiclesX] spawn {
	params ["_vehiclesX","_positionX"];
	waitUntil {sleep 1; (_vehiclesX select 0) distance2D getMarkerPos respawnTeamPlayer < 5000};
	[(getMarkerPos respawnTeamPlayer)] spawn A3A_fnc_artyAttack;
};

waitUntil {sleep 1;(({[_x] call A3A_fnc_canFight} count _soldiers) / (count _soldiers)) < 0.33 or (_positionX distance getMarkerPos respawnTeamPlayer > 999) or (!alive petros)};

if (!alive petros) then
	{
	[_taskId, "DEF_HQ", "FAILED", true] call A3A_fnc_taskSetState;
	}
else
	{
	[_taskId, "DEF_HQ", "SUCCEEDED", true] call A3A_fnc_taskSetState;
	if (_positionX distance getMarkerPos respawnTeamPlayer < 999) then
		{
		[0,500,0] remoteExec ["A3A_fnc_resourcesFIA",2];
		//[-5,5,_positionX] remoteExec ["A3A_fnc_citySupportChange",2];
		{if (isPlayer _x) then {[50,_x] call A3A_fnc_playerScoreAdd}} forEach ([500,0,_positionX,teamPlayer] call A3A_fnc_distanceUnits);
		};
	};

[_taskId, "DEF_HQ", 1200, true] spawn A3A_fnc_taskDelete;
sleep 60;

{
	// return to base
	private _wp = _x addWaypoint [_posOrigin, 50];
	_wp setWaypointType "MOVE";
	_x setCurrentWaypoint _wp;
	[_x] spawn A3A_fnc_groupDespawner;
} forEach _groups;

{ [_x] spawn A3A_fnc_VEHdespawner } forEach _vehiclesX;
