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
	_x setUnitTrait ["camouflageCoef",0.1];
	_x setUnitTrait ["audibleCoef",0.1];
	_x setSkill ["spotDistance", 1];
	_x setSkill ["spotTime", 1];
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

	private _knownEntities = (units Occupants) select {_leader knowsAbout _x >= 1.5};

	private _num = 0;
	private _markerList = [];
	{
	private _pos = getPos _x;
	_num = _num + 1;
	private _wpNum = (round (random 1000));
	private _marker = createMarker [format["%2_Entity_%1", _num, _wpNum], _pos];
	_marker setMarkerType "mil_unknown_noShadow";
	_marker setMarkerColor colorOccupants;
	_marker setMarkerSize [0.6, 0.6];
	_markerList pushBack _marker;
	} forEach _knownEntities;
	
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
		
	{
	deleteMarker _x;
	} forEach _markerList;
};

