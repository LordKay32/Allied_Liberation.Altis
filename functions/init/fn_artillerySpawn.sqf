/*
 * Name:	fn_artillerySpawn
 * Date:	12/04/2023
 * Version: 1.0
 * Author:  JB
 *
 * Description:
 * spawns arty
 *
 * Parameter(s):
 * _PARAM1 (TYPE): DESCRIPTION.
 * _PARAM2 (TYPE): DESCRIPTION.
 *
 * Returns:
 * %RETURNS%
 */


private _artyMarker = ["outpost_9", "outpost_20", "outpost_17", "outpost_12", "outpost_40"];

private _num = 0;
{
	if (sidesX getVariable [_x,sideUnknown] == teamPlayer) then {
		artilleryList set [_num, false];
	};
	_num = _num + 1;
	if (sidesX getVariable [_x,sideUnknown] == teamPlayer) then {
		artilleryList set [_num, false];
	};
	_num = _num + 1;
} forEach _artyMarker;

private _index = 0;
private _artillery = objNull;

{
	private _positionX = getMarkerPos _x;
	private _artyNests = nearestObjects [_positionX, ["Land_fort_artillery_nest_EP1"], 250]; 
	{
		if (artilleryList select _index) then {
			_dir = getDir _x;
			_pos = _x getRelPos [3.2, 180];
			_artilleryType = NATOHowitzer;
		
			_artillery = createVehicle [_artilleryType, _positionX, [], 0, "NONE"];  
			_artillery setDir _dir;
			_artillery setPos _pos;
			[_artillery, Occupants] call A3A_fnc_AIVEHinit;
			_artillery setVariable ["index", _index, true];
			_artillery addEventHandler ["Killed", {
				params ["_unit", "_killer", "_instigator", "_useEffects"];
				_index = _unit getVariable "index";
				artilleryList set [_index, false];
			}];
		
			[_artillery, _positionX] spawn {
			params ["_artillery", "_positionX"];
				waitUntil {sleep 60; getMarkerPos ([((["Synd_HQ"] + citiesX + airportsX + milbases + outposts + seaports + resourcesX + factories) select {sidesX getVariable [_x,sideUnknown] == teamPlayer}), _positionX] call BIS_fnc_nearestPosition) distance _positionX < 9000};
				_group = createGroup Occupants;
				[_group, policeGrunt, _positionX, [], 0, "NONE"] call A3A_fnc_createUnit;
				[_group, policeGrunt, _positionX, [], 0, "NONE"] call A3A_fnc_createUnit;
				{
					[_x] call A3A_fnc_NATOinit;
					_x moveInAny _artillery;
				} forEach units _group;
			};
		};
		_index = _index + 1;
	} forEach _artyNests;
} forEach _artyMarker;

