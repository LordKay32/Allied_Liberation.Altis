/*
 * Name:	fn_showMarkerArea
 * Date:	9/07/2023
 * Version: 1.0
 * Author:  JB
 *
 * Description:
 * Shows marker area locally
 *
 * Parameter(s):
 * _PARAM1 (TYPE): DESCRIPTION.
 * _PARAM2 (TYPE): DESCRIPTION.
 *
 * Returns:
 * Shows area of marker player is in or nearest area if not
 */

_friendlyBases = ((airportsX + milbases + outposts + seaports) select {(sidesX getVariable [_x,sideUnknown] == teamPlayer)}) + ["Synd_HQ"];

private _playerInBase = false;
private _markerX = "";

{
if (player inArea _x) exitWith {_playerInBase = true; _markerX = _x}
} forEach _friendlyBases;

if (!(_playerInBase)) then {
	_markerX = [_friendlyBases, player] call BIS_fnc_nearestPosition;
};

_originalColor = markerColor _markerX;
_newColor = colorTeamPlayer;

if (!visibleMap) then {openMap true};

_markerX setMarkerColorLocal _newColor;
_markerX setMarkerAlphaLocal 1;

sleep 20;

_markerX setMarkerColorLocal _originalColor;
_markerX setMarkerAlphaLocal 0;