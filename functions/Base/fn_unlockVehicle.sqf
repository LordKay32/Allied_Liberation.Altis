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
	["Check Vehicle in Base", "<t color='#ff0000'>This vehicle is NOT inside a base</t>"] call A3A_fnc_customHint;
};