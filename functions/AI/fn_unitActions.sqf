/*
 * Name:	fn_unitActions
 * Date:	19/12/2023
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

params ["_units","_type"];

if (count _units > 1) exitWith {["Unit Actions", "Choose one unit at a time to perform this action on."] call A3A_fnc_customHint};
private _unit = _units select 0;
if (typeName _unit != "OBJECT") exitWith {["Unit Actions", "This action can only be done on a players group unit."] call A3A_fnc_customHint};


switch (_type) do {
	case ("TELEPORT"): {
		if !(alive _unit) exitWith {["Unit Actions", "This unit is dead."] call A3A_fnc_customHint};
		if (_unit getVariable ["incapacitated",false]) exitWith {["Unit Actions", "This unit is incapacitated."] call A3A_fnc_customHint};
		if (vehicle player != player) exitWith {["Unit Actions", "You cannot perform this action whilst in a vehicle."] call A3A_fnc_customHint};
		if (_unit distance player > 20) exitWith {["Unit Actions", "You must be closer than 20m to the chosen unit to perform this action."] call A3A_fnc_customHint};
		_unit setPos (getPos player);
	};
	case ("VEHICLE"): {
		if !(alive _unit) exitWith {["Unit Actions", "This unit is dead."] call A3A_fnc_customHint};
		if (_unit getVariable ["incapacitated",false]) exitWith {["Unit Actions", "This unit is incapacitated."] call A3A_fnc_customHint};
		if (vehicle player == player) exitWith {["Unit Actions", "You are not in a vehicle."] call A3A_fnc_customHint};
		if (_unit distance (vehicle player) > 20) exitWith {["Unit Actions", "The unit must be closer than 20m to your vehicle."] call A3A_fnc_customHint};
		_unit moveInAny (vehicle player);
	};
};