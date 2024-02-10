/*
 * Name:	fn_reconSquadRecon
 * Date:	5/03/2023
 * Version: 1.0
 * Author:  JB
 *
 * Description:
 * Recon Squad recon function
 *
 * Parameter(s):
 * _PARAM1 (TYPE): DESCRIPTION.
 * _PARAM2 (TYPE): DESCRIPTION.
 *
 * Returns:
 * %RETURNS%
 */


params ["_group"];

{
	_x setUnitTrait ["camouflageCoef",0.2];
	_x setUnitTrait ["audibleCoef",0.2];
	[_x] spawn {
		_unit = _this select 0;
		while {alive _unit} do {	
			waitUntil {sleep 1; ((_unit nearEntities 300) findIf {side _x == Occupants || side _x == Invaders}) != -1 and combatMode (group _unit) == "GREEN"};
			_unit setUnitPos "DOWN";
			waitUntil {sleep 1; ((_unit nearEntities 300) findIf {side _x == Occupants || side _x == Invaders}) == -1 or combatMode (group _unit) != "GREEN"};
			_unit setUnitPos "AUTO";
		};
	};
} forEach units _group;

while {true} do {
	private _leader = (leader _group);
	private _positionX = (getPos _leader);

	private _entities = (_positionX nearEntities 300) select {side _x isEqualTo Occupants};

	private _num = 0;
	private _markerList = [];
	{
	private _pos = getPos (leader _x);
	_num = _num + 1;
	private _wpNum = (round (random 1000));
	private _marker = createMarker [format["%2_Entity_%1", _num, _wpNum], _pos];
	_marker setMarkerType "mil_unknown_noShadow";
	_marker setMarkerColor colorOccupants;
	_marker setMarkerSize [0.6, 0.6];
	_markerList pushBack _marker;
	} forEach _entities;
	
	if ({alive _x} count units _group == 0) exitWith {
		{
		_x setMarkerAlpha 0.5;
		} forEach _markerList;
		sleep 120;
		{
		deleteMarker _x;
		} forEach _markerList;
	};
	
	sleep 10;
		
	if (!(unitReady (leader _group)) OR (combatMode _group != "GREEN")) then {
		[_markerList] spawn {
			private _markerList = _this select 0;
			{
			_x setMarkerAlpha 0.5;
			} forEach _markerList;
			sleep 120;
			{
			deleteMarker _x;
			} forEach _markerList;
		};
		waitUntil {sleep 1; ({unitReady _x} count units _group == count units _group) && (combatMode _group == "GREEN")};
		sleep 60;
	} else {
		{
		deleteMarker _x;
		} forEach _markerList;
	};
};

