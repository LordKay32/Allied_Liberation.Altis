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

private ["_pool","_veh","_typeVehX"];

_veh = cursorObject;

if (isNull _veh) exitWith {["Check Vehicle in Base", "You are not looking at a vehicle."] call A3A_fnc_customHint;};

if (!alive _veh) exitWith {["Check Vehicle in Base", "This vehicle is destroyed."] call A3A_fnc_customHint;};

if (_veh isKindOf "Man") exitWith {["Check Vehicle in Base", "Are you kidding?"] call A3A_fnc_customHint;};
if (not(_veh isKindOf "AllVehicles")) exitWith {["Check Vehicle in Base", "The vehicle you are looking at cannot be used."] call A3A_fnc_customHint;};

private _friendlyBases = ((airportsX + milbases + outposts + seaports) select {(sidesX getVariable [_x,sideUnknown] == teamPlayer)}) + ["Synd_HQ"];

private _vehInBase = false;

{
if (_veh inArea _x) exitWith {_vehInBase = true};
} forEach _friendlyBases;

if (_vehInBase) then {
	["Check Vehicle in Base", "<t color='#00ff00'>This vehicle is inside a base</t>"] call A3A_fnc_customHint;
} else {
	["Check Vehicle in Base", "<t color='#ff0000'>This vehicle is NOT inside a base. Check your map to see the nearest base area.</t>"] call A3A_fnc_customHint;
};

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

_markerX setMarkerColorLocal _newColor;
_markerX setMarkerAlphaLocal 1;

sleep 20;

_markerX setMarkerColorLocal _originalColor;
_markerX setMarkerAlphaLocal 0;
