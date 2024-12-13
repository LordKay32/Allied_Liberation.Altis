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

_vector = _reconPos getDir _dirPos;
_positionX = _reconPos getPos [300, _vector];
_timer = 0;

[
    "Recon Mission",
    parseText "Recon Mission Started."
] call A3A_fnc_customHint;

sleep 4;
//((random 300) + 300);

private _makeGroupSpotted = {
	params ["_enemyGroup"];
	private _revealed = player getVariable ["MARTA_reveal",[]];
	_revealed pushBack _enemyGroup;
	player setVariable ["MARTA_reveal", _revealed, true];
	sleep 300;
	_revealed = player getVariable ["MARTA_reveal",[]];
	_revealed = _revealed - [_enemyGroup];
	player setVariable ["MARTA_reveal", _revealed, true];
};

private _odds = 25;

while {true} do {
	private _groups = allGroups select {(getPos (leader _x) distance _positionX < 500) && side _x == Occupants && (count getGroupIcons _x == 0)};
	{
	if (random 100 < _odds) then {[_x] spawn _makeGroupSpotted};
	} forEach _groups;
	
	_odds = _odds + 5;
	if (_odds > 90) then {_odds = 90};
	
	if ((units _group) findIf {damage _x > 0} != -1) exitWith {
		
		{
		private _unitPos = getPos _x;
		"LIB_US_M18" createVehicle (_unitPos getRelPos [1,0]);
		} forEach ((units _group) select {alive _x});
		[
	    "Recon Mission",
	    parseText "Recon team under fire, recon mission aborted."
		] call A3A_fnc_customHint;
	
		for "_i" from count waypoints _group - 1 to 0 step -1 do
		{
		deleteWaypoint [_group, _i];
		};

		private _wp1 = _group addWaypoint [_reconPos, 0];
		_wp1 setWaypointSpeed "FULL";
	};
	sleep 15;
};
