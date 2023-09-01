/*
 * Name:	fn_minefield
 * Date:	20/05/2023
 * Version: 1.0
 * Author:  JB
 *
 * Description:
 * %DESCRIPTION%
 *
 * Parameter(s):
 * _PARAM1 (TYPE): DESCRIPTION.
 * _PARAM2 (TYPE): DESCRIPTION.
 *
 * Returns:
 * %RETURNS%
 */

private ["_mineMarkers"];

{
	_markerX = [(airportsX + milbases + seaports + outposts), _x] call BIS_fnc_nearestPosition;
	_sideX = sidesX getVariable [_markerX,sideUnknown];
	_mine = (([A3A_faction_inv,A3A_faction_occ] select (_sideX == Occupants)) getVariable "minefieldAPERS") select 1;
	_x setMarkerAlpha 0;
	_area = getMarkerSize _x;
	_quantity = ceil (((_area select 0) * (_area select 1)) / 150);
	for "_i" from 1 to _quantity do {
		_randomPos = [[[getMarkerPos _x, (_area select 1)]], [], { _this inArea _x }] call BIS_fnc_randomPos;
		_mineX = createMine [ _mine ,_randomPos,[],0];
		Occupants revealMine _mineX;
		Invaders revealMine _mineX;
	};
} forEach mineMarkers;