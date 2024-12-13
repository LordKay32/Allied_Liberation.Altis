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

params ["_WPPos","_WPGroup"];

sleep ((random 300) + 300);


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
	private _groups = allGroups select {(getPos (leader _x) distance _WPPos < 600) && side _x == Occupants && (count getGroupIcons _x == 0)};
	{
	if (random 100 < _odds) then {[_x] spawn _makeGroupSpotted};
	} forEach _groups;
	
	_odds = _odds + 5;
	if (_odds > 90) then {_odds = 90};
	
	if ((units _WPGroup) findIf {damage _x > 0} != -1) exitWith {
		
		{
		private _unitPos = getPos _x;
		"LIB_US_M18" createVehicle (_unitPos getRelPos [1,0]);
		} forEach ((units _WPGroup) select {alive _x});
		[
	    "Recon Mission",
	    parseText "Recon team under fire, recon mission aborted."
		] call A3A_fnc_customHint;
	
		for "_i" from count waypoints _WPGroup - 1 to 0 step -1 do
		{
		deleteWaypoint [_WPGroup, _i];
		};

		private _wp1 = _WPGroup addWaypoint [_WPPos, 0];
		_wp1 setWaypointSpeed "FULL";
	};
	sleep 15;
};