/*
Author: Barbolani, Wurzel, Jaj22, Michael Phillips, Caleb Serafin
Attempts to sell the vehicle the player is looking at.
Vehicle cannot be sold if owned by another player.

Arguments:
    <OBJECT> Player who is trying to sell a vehicle.
    <OBJECT> cursorObject of the player.

Return Value:
<NIL> nil

Scope: Server/HC, All calls need to be executed on one machine, using an HC is also possible.
Environment: Unscheduled, is used to sell vehicles, execution cannot be stacked and exploited.
Public: No
Dependencies:
<STRING> ownerX found on vehicles, contains UID of player who bought it.
<ARRAY> Template vehicle arrays, see costs = call {}.

Example:
// From a button control:
action = "if (player == theBoss) then {closeDialog 0; nul = [player,cursorObject] remoteExecCall [""A3A_fnc_sellVehicle"",2]} else {[""Sell Vehicle"", ""Only the Commander can sell vehicles.""] call A3A_fnc_customHint;};";

// Testing spam:
for "_i" from 1 to 1000 do {
    [player,cursorObject] remoteExecCall ["A3A_fnc_sellVehicle",2];
};

*/
params [
    ["_player",objNull,[objNull]],
    ["_veh",objNull,[objNull]]
];
private _filename = "fn_sellVehicle";

if (isNull _player) exitWith {[1,"_player is null.",_filename] call A3A_fnc_log;};
if (isNull _veh) exitWith {["Sell Vehicle", "You are not looking at a vehicle."] remoteExecCall ["A3A_fnc_customHint",_player];};

_friendlyBases = ((airportsX + milbases + outposts + seaports) select {(sidesX getVariable [_x,sideUnknown] == teamPlayer)}) + ["Synd_HQ"];
private _vehInBase = false;
{
if (_veh inArea _x) exitWith {_vehInBase = true}
} forEach _friendlyBases;

if (!(_vehInBase)) exitWith {
    _veh setVariable ["A3A_sellVehicle_inProgress",false,false];
    ["Sell Vehicle", "Vehicle must be inside an Allied base (excluding cities and industry)."] remoteExecCall ["A3A_fnc_customHint",_player];
};

if ({isPlayer _x} count crew _veh > 0) exitWith {
    _veh setVariable ["A3A_sellVehicle_inProgress",false,false];
    ["Sell Vehicle", "In order to sell the vehicle, it must be empty."] remoteExecCall ["A3A_fnc_customHint",_player];
};

if (_veh getVariable ["A3A_sellVehicle_inProgress",false]) exitWith {["Sell Vehicle", "Vehicle sale already in progress."] remoteExecCall ["A3A_fnc_customHint",_player];};
_veh setVariable ["A3A_sellVehicle_inProgress",true,false];  // Only processed on the server. It is absolutely pointless trying to network this due to race conditions.

private _typeX = typeOf _veh;
private _costs = call {
	if (_typeX in vehFIA) exitWith { ([_typeX] call A3A_fnc_vehiclePrice) / 2 };
    if (_veh isKindOf "StaticWeapon") exitWith {400};			// in case rebel static is same as enemy statics
    if (_typeX in vehPoliceCars) exitWith {250};
    if (_typeX in (arrayCivVeh + civBoats + [civBoat,civCar,civTruck])) exitWith {150};
    if (_typeX in vehNormal || {_typeX in (vehBoats + vehAmmoTrucks + vehSupplyTrucks)}) exitWith {500};
    if (_typeX in [vehCSATPatrolHeli, vehNATOPatrolHeli, civHeli]) exitWith {3000};
    if (_typeX in (vehAPCs + vehTransportAir + vehUAVs)) exitWith {2500};
    if (_typeX in (vehAttackHelis + vehTanks + vehAA + vehMRLS)) exitWith {6500};
    if (_typeX in (vehNATOPlanes + vehNATOPlanesAA + vehCSATPlanes + vehCSATPlanesAA)) exitWith {7500};
    0;
};

if (_costs == 0) exitWith {
    _veh setVariable ["A3A_sellVehicle_inProgress",false,false];
    ["Sell Vehicle", "The vehicle you are looking is not suitable in our marketplace."] remoteExecCall ["A3A_fnc_customHint",_player];
};

_costs = round (_costs * (1-damage _veh));

[0,round (_costs/2),0] remoteExec ["A3A_fnc_resourcesFIA",2];
[round (_costs/20),_player] call A3A_fnc_playerScoreAdd;

if (_typeX in vehFIA) then {
	private _count = server getVariable (_typeX + "_count");
	_count = _count + 1;
	server setVariable [(_typeX + "_count"), _count, true];
};

if (_veh in staticsToSave) then {staticsToSave = staticsToSave - [_veh]; publicVariable "staticsToSave"};
if (_veh in reportedVehs) then {reportedVehs = reportedVehs - [_veh]; publicVariable "reportedVehs"};

[_veh,true] call A3A_fnc_empty;

if (_veh isKindOf "StaticWeapon") then {deleteVehicle _veh};

["Sell Vehicle", "Vehicle Sold."] remoteExecCall ["A3A_fnc_customHint",_player];
nil;
