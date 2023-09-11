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

params ["_group", "_markerX", "_wpPos", "_wpNum"];
private["_index", "_vector", "_entities", "_num", "_markerList", "_pos", "_marker"];

if ((combatMode _group != "GREEN") && (west knowsAbout (leader _group) < 4)) then {_group setCombatMode "GREEN"};

_vector = (getMarkerPos _markerX) getDir _wpPos;

_positionX = (getMarkerPos _markerX) getPos [300, _vector];

while {true} do {
	_entities = allGroups select {(side _x isEqualTo west) && ((leader _x) distance _positionX < 300)};

	_num = 0;
	_markerList = [];
	{
	_pos = getPos (leader _x);
	_num = _num + 1;
	_marker = createMarker [format["%2_Entity_%1", _num, _wpNum], _pos];
	_marker setMarkerType "mil_unknown_noShadow";
	_marker setMarkerColor colorOccupants;
	_marker setMarkerSize [0.6, 0.6];
	_markerList pushBack _marker;
	} forEach _entities;
	sleep 10;
	if ({alive _x} count units _group == 0) exitWith {
		{
		_x setMarkerAlpha 0.5;
		} forEach _markerList;
		sleep 120;
		{
		deleteMarker _x;
		} forEach _markerList;
	};
	if (combatMode _group != "GREEN") exitWith {
		{
		_x setMarkerAlpha 0.5;
		} forEach _markerList;
		sleep 120;
		{
		deleteMarker _x;
		} forEach _markerList;
	};
	if !(currentWaypoint _group == (_wpNum + 1)) exitWith {
		{
		_x setMarkerAlpha 0.5;
		} forEach _markerList;
		sleep 120;
		{
		deleteMarker _x;
		} forEach _markerList;
	};
	{
	deleteMarker _x;
	} forEach _markerList;
};
