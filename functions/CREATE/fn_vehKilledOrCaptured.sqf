/*
	Updates enemy vehicle reserve pool, city support and aggro for vehicle destruction or capture
	Also handles the ownerSide update and enabling despawner on rebel capture

	Params:
	1. Object: Vehicle object
	2. Side: Side of unit that captured or destroyed the vehicle
	2. Bool (default false): True if captured, else destroyed
*/

private _filename = "fn_vehKilledOrCaptured";
params ["_veh", "_sideEnemy", ["_captured", false]];

private _type = typeof _veh;
private _side = _veh getVariable ["ownerSide", teamPlayer];			// default because Zeus

if (_captured && (_side == _sideEnemy)) exitWith {};

private _act = if (_captured) then {"captured"} else {"destroyed"};
[3, format ["%1 of %2 %3 by %4", _type, _side, _act, _sideEnemy], _filename] call A3A_fnc_log;

if (_side == Occupants or _side == Invaders) then
{
	_type remoteExecCall ["A3A_fnc_removeVehFromPool", 2];
	if (_sideEnemy != teamPlayer) exitWith {};

	private _value = call {
		if (_type in vehAPCs) exitWith {0.5};
		if (_type in vehTanks) exitWith {1};
		if (_type in vehAA or _type in vehMRLS) exitWith {1};
		if (_type in vehAttackHelis) exitWith {10};
		if (_type in vehTransportAir) exitWith {0.5};
		if (_type in vehFixedWing) exitWith {1};		// transportAir must be before this
		if (_type isKindOf "StaticWeapon") exitWith {0.2};
		2;		// trucks, light attack, boats, UAV etc
	};
	if (_side == Occupants) then {aggressionOccupants = aggressionOccupants - _value} else {aggressionInvaders = aggressionInvaders - _value};
	[] call A3A_fnc_calculateAggression;
	if (_side == Occupants) then {
		[-_value, _value, position _veh] remoteExec ["A3A_fnc_citySupportChange", 2];
	};
};

if (_side == civilian) then
{
	if (_sideEnemy != teamPlayer) exitWith {};

	// Punish players slightly for stealing cars. Code used to be in vehDespawner.
	private _pos = position _veh;
	[0, -1, _pos] remoteExec ["A3A_fnc_citySupportChange", 2];

	private _city = [citiesX, _pos] call BIS_fnc_nearestPosition;
	private _dataX = server getVariable _city;
	private _prestigeBLUFOR = _dataX select 2;		// government support?
	if (random 100 < _prestigeBLUFOR) exitWith {};

	{
		private _thief = _x;
		if ((captive _thief) and (isPlayer _thief)) then {
			[_thief, false] remoteExec ["setCaptive", _thief];
		};
		{
			if ((side _x == Occupants) and (_x distance _pos < distanceSPWN2)) then {_x reveal _thief};
		} forEach allUnits;
	} forEach crew _veh;
};

if (_captured) then
{
	// Do the actual side-switch
	_veh setVariable ["ownerSide", _sideEnemy, true];
	if (_sideEnemy == teamPlayer) then {
		if !(_veh isKindOf "StaticWeapon") then { [_veh] spawn A3A_fnc_VEHdespawner };
	};
};
