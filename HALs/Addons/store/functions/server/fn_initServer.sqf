/*
	Function: HALs_store_fnc_initServer
	Author: HallyG
	Server initialisation.

	Argument(s):
	0: None

	Return Value:
	None

	Example:
	[] call HALs_store_fnc_initServer;
__________________________________________________________________*/
if (!isServer) exitWith {};
if (!isNil "HALs_store_debug") exitWith {};

[
	["CfgHALsStore"],
	"HALs_store_",
	[
		["containerRadius", 30, {_this max 0}, true],
		["containerTypes", ["LandVehicle", "Air", "Ship", "ReammoBox_F"], {_this}, true],
		["currencySymbol", "CP", {_this}, true],
		["sellFactor", 1, {_this max 0 min 1}, true],
		["debug", 0, {_this isEqualTo 1}]
	]
] call HALs_fnc_getModuleSettings;

missionNamespace setVariable ["HALs_store_getNearbyVehicles", compileFinal '
	params [
		["_trader", objNull, [objNull]],
		["_types", ["LandVehicle", "Air", "Ship", "ReammoBox_F"], [[]]],
		["_radius", HALs_store_containerRadius, [0]]
	];

	private _vehicles = nearestObjects [_trader, _types, _radius, true];
	_vehicles select {local _x && {abs speed _x < 1 && {alive _x && isNil {_x getVariable "HALs_store_trader_type"}}}};
', true];