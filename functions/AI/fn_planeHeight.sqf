/*
 * Name:	fn_planeHeight
 * Date:	19/02/2024
 * Version: 1.0
 * Author:  JB
 *
 * Description:
 * changes plane altitude
 *
 * Parameter(s):
 * _PARAM1 (TYPE): DESCRIPTION.
 * _PARAM2 (TYPE): DESCRIPTION.
 *
 * Returns:
 * %RETURNS%
 */

if (count hcSelected player != 1) exitWith {["Aircraft Altitude", "You must select one group on the HC bar."] call A3A_fnc_customHint;};

_group = hcSelected player select 0;

_aircraft = vehicle leader _group;

if !(_aircraft isKindOf "Air") exitWith {["Aircraft Altitude", "This group is not commanding an aircraft."] call A3A_fnc_customHint;};

_altitude = _aircraft getVariable ["altitude", 1000];

if (_altitude == 1000) then {
	_aircraft flyInHeight 250;
	_aircraft setVariable ["altitude", 250, true];
	["Aircraft Altitude", "Altitude set to 250m."] call A3A_fnc_customHint;
};

if (_altitude == 250) then {
	_aircraft flyInHeight 500;
	_aircraft setVariable ["altitude", 500, true];
	["Aircraft Altitude", "Altitude set to 500m."] call A3A_fnc_customHint;
};

if (_altitude == 500) then {
	_aircraft flyInHeight 750;
	_aircraft setVariable ["altitude", 750, true];
	["Aircraft Altitude", "Altitude set to 750m."] call A3A_fnc_customHint;
};

if (_altitude == 750) then {
	_aircraft flyInHeight 1000;
	_aircraft setVariable ["altitude", 1000, true];
	["Aircraft Altitude", "Altitude set to 1000m."] call A3A_fnc_customHint;
};