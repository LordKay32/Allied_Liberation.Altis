/*
 * Name:	fn_artyAttack
 * Date:	12/04/2023
 * Version: 1.0
 * Author:  JB
 *
 * Description:
 * fires arty on target
 *
 * Parameter(s):
 * _PARAM1 (TYPE): DESCRIPTION.
 * _PARAM2 (TYPE): DESCRIPTION.
 *
 * Returns:
 * %RETURNS%
 */


params ["_targetPos"];
private ["_artyMarkers", "_nearestArtyBase", "_artilleryPieces", "_magazines", "_rounds"];

_artyMarkers = ["outpost_9", "outpost_20", "outpost_17", "outpost_12", "outpost_40"];

_nearestArtyBase = ([_artyMarkers, _targetPos] call BIS_fnc_nearestPosition);

if ({side _x == Occupants} count (_targetPos nearEntities 500) > 4) exitWith {};

if (getMarkerPos _nearestArtyBase distance _targetPos < 9000) then {
	_artilleryPieces = nearestObjects [getMarkerPos _nearestArtyBase, [NATOHowitzer], 250]; 
	{
	_magazines = NATOHowitzerMagazineHE;
	_rounds = (10 + aggressionLevelOccupants);
	_x commandArtilleryFire [_targetPos, _magazines, _rounds];
	} forEach _artilleryPieces;
};
