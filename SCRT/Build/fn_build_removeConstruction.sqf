/*
    Author: 
        Socrates
    [Description]
        Removes object from persistent constructions list. That list will be stored in save file.

    Arguments:
    0. <object>

    Return Value:
    <nil>

    Scope: Server
    Environment: Any
    Public: Yes
    Dependencies:
        <ARRAY> constructionsToSave
     

    Example: [_vehicle] remoteExecCall ["SCRT_fnc_build_removeConstruction", 2];
*/
params ["_building"];

private _filename = "SCRT_fnc_build_removeConstruction";

if (!isServer) exitWith {
    [1, "Function miscalled locally, rerouting execution on server...", _filename, true] call A3A_fnc_log;
    _building remoteExecCall ["SCRT_fnc_build_removeConstruction", 2];
};

if (isNil "constructionsToSave") exitWith {
    [1, "For some reason constructionsToSave doesn't exist.", _filename] call A3A_fnc_log;
};

private _buildingIndex = constructionsToSave find _building;

if (_buildingIndex == -1) exitWith {
    [1, "Can't find building, aborting.", _filename, true] call A3A_fnc_log;
};

[2, format ["Deleting %1 object on %2 position...", (typeOf _building), (position _building)], _filename, true] call A3A_fnc_log;

deleteVehicle _building;

constructionsToSave deleteAt _buildingIndex;
publicVariable "constructionsToSave";