/*
 * Name:	watchPostRecon
 * Date:	27/01/2023
 * Version: 1.0
 * Author:  JB
 *
 * Description:
 * %DESCRIPTION%
 *
 * Parameter(s):
 * _PARAM1 (TYPE): - DESCRIPTION.
 * _PARAM2 (TYPE): - DESCRIPTION.
 */

params ["_group", "_reconPos", "_dirPos", "_markerX"];
private["_vector", "_positionX", "_timer", "_exit", "_entities", "_statics", "_num", "_markerList", "_pos", "_marker"];

if ((combatMode _group != "GREEN") && (west knowsAbout (leader _group) < 4)) then {_group setCombatMode "GREEN"};

_vector = _reconPos getDir _dirPos;
_positionX = _reconPos getPos [300, _vector];
_timer = 0;

[
    "Recon Mission",
    parseText "Recon Mission Started."
] call A3A_fnc_customHint;

_groupNum = random 1000;
_groupMarker = createMarker [format["Entity_%1", _groupNum], _reconPos];
_groupMarker setMarkerType "plp_icon_binoculars";
_groupMarker setMarkerColor colorTeamplayer;
_groupMarker setMarkerDir (_vector + 180);
_groupMarker setMarkerText "Recon Team";

_exit = false;

while {_timer <= 60} do {
	_entities = (_positionX nearEntities 500) select {side _x isEqualTo Occupants};
	_num = 0;
	_markerList = [];
	{
	_pos = getPos _x;
	_num = _num + 1;
	_marker = createMarker [format["Entity_%1", _num], _pos];
	_marker setMarkerType "mil_unknown_noShadow";
	_marker setMarkerColor colorOccupants;
	_marker setMarkerSize [0.6, 0.6];
	_markerList pushBack _marker;
	} forEach _entities;

	sleep 10;
	_timer = _timer + 10;
	if ({alive _x} count units _group == 0) exitWith {_exit = true};
	if (combatMode _group != "GREEN") exitWith {_exit = true};
	{
	deleteMarker _x;
	} forEach _markerList;
};
if (_exit == true) exitWith {
	deleteMarker _groupMarker;
	{
	_x setMarkerAlpha 0.5;
	} forEach _markerList;
	if ({alive _x} count units _group > 0) then {
	[
    "Recon Mission",
    parseText "Recon team spotted, recon mission aborted."
	] call A3A_fnc_customHint;
	private _wp1 = _group addWaypoint [(getMarkerPos _markerX), 0];
	_wp1 setWaypointSpeed "FULL";
		{
		"LIB_US_M18" createVehicle getPos _x;
		[_x] spawn {
			params ["_unit"];
			sleep 20;
			while {true} do {	
				[_unit,_unit] spawn A3A_fnc_chargeWithSmoke;
				sleep 60;
				if (!(alive _unit) || (combatMode (group _unit) == "GREEN")) exitWith {};
			};
		};
		} forEach units _group;
		waitUntil {sleep 1; west knowsAbout (leader _group) < 4}; 
		_group setCombatMode "GREEN";
	};
	sleep 300;
	{
	deleteMarker _x;
	} forEach _markerList;
};
while {true} do {
	_entities = allGroups select {(side _x isEqualTo west) && ((leader _x) distance _positionX < 500)};
	
	_num = 0;
	_markerList = [];
	{
	_pos = getPos (leader _x);
	_num = _num + 1;
	_marker = createMarker [format["Entity_%1", _num], _pos];
	
	if (vehicle (leader _x) == (leader _x)) then {_marker setMarkerType "b_inf"};
	if (typeOf (vehicle (leader _x)) in vehNormal) then {_marker setMarkerType "b_motor_inf"};
	if (typeOf (vehicle (leader _x)) in (vehAmmoTrucks + vehSupplyTrucks)) then {_marker setMarkerType "b_support"};
	if (typeOf (vehicle (leader _x)) in vehAPCs) then {_marker setMarkerType "b_mech_inf"};
	if (typeOf (vehicle (leader _x)) in vehTanks) then {_marker setMarkerType "b_armor"};
	if (typeOf (vehicle (leader _x)) in vehAA) then {_marker setMarkerType "b_antiair"};
	if (typeOf (vehicle (leader _x)) in vehFixedWing) then {_marker setMarkerType "b_plane"};
	if (typeOf (vehicle (leader _x)) in vehBoats) then {_marker setMarkerType "b_naval"};
	{
		if (vehicle _x == _x) then {
		_infMarker = createMarker [format["Inf_%1", (random 1000)], getPos _x];
		_infMarker setMarkerType "mil_dot";
		_infMarker setMarkerColor colorOccupants;
		_markerList pushBack _infMarker;
		};
	} forEach ((units _x) - [leader _x]);
	_markerList pushBack _marker;
	} forEach _entities;

	_statics = (nearestObjects [_positionX, ["StaticWeapon"], 600]) select {side _x isEqualTo west};
	{
	_pos = getPos _x;
	_num = _num + 1;
	_marker = createMarker [format["Entity_%1", _num], _pos];
	
	if (typeOf (vehicle _x) in NATOMG) then {_marker setMarkerType "b_Ordnance"; _marker setMarkerText "MG"};
	if (typeOf (vehicle _x) in ["fow_w_mg42_deployed_high_ger_heer", "fow_w_mg42_deployed_middle_ger_heer"]) then {_marker setMarkerType "mil_dot"; _marker setMarkerColor colorOccupants};
	if (typeOf (vehicle _x) in [staticATOccupants]) then {_marker setMarkerType "b_Ordnance"; _marker setMarkerText "AT"};
	if (typeOf (vehicle _x) in staticAAOccupants) then {_marker setMarkerType "b_antiair"};
	if (typeOf (vehicle _x) in NATOMortar) then {_marker setMarkerType "b_mortar"};
	if (typeOf (vehicle _x) in NATOHowitzer) then {_marker setMarkerType "b_art"};

	_markerList pushBack _marker;
	} forEach _statics;
	
	sleep 10;
	if ({alive _x} count units _group == 0) exitWith {_exit = true};
	if (combatMode _group != "GREEN") exitWith {_exit = true};
	{
	deleteMarker _x;
	} forEach _markerList;
};
if (_exit == true) exitWith {
	deleteMarker _groupMarker;
	{
	[_x] spawn {
		private _marker = _this select 0;
		_marker setMarkerAlpha 0.5;
		
		sleep 120;
		
		deleteMarker _marker;
	};
	} forEach _markerList;
	
	if ({alive _x} count units _group > 0) then {
	[
    "Recon Mission",
    parseText "Recon team spotted, recon mission aborted."
	] call A3A_fnc_customHint;
	private _wp1 = _group addWaypoint [(getMarkerPos _markerX), 0];
	_wp1 setWaypointSpeed "FULL";
		{
		[_x] spawn {
			params ["_unit"];
			sleep 2;
			while {true} do {	
				[_unit,_unit] spawn A3A_fnc_chargeWithSmoke;
				sleep 60;
				if (!(alive _unit) || (combatMode (group _unit) == "GREEN")) exitWith {};
			};
		};
		} forEach units _group;
		waitUntil {sleep 1; Occupants knowsAbout (leader _group) < 4}; 
		_group setCombatMode "GREEN";
	};
};
