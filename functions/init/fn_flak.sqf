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

private _flakMarker = "airport_3";
private _AAList = [AA_1, AA_2, AA_3, AA_4];
private _flakModule = [flak_1, flak_2, flak_3, flak_4];

if ((sidesX getVariable [_flakMarker,sideUnknown] == teamPlayer) OR (flakList findif {_x == true} == -1)) exitWith {
	{
	deleteVehicle _x
	} forEach (_AAList + _flakModules);
};

private _positionX = getMarkerPos _flakMarker;
private _index = 0;
private _group = grpNull;
	
	{
		if (flakList select _index) then {
			[_x, Occupants] call A3A_fnc_AIVEHinit;
			_x setVariable ["index", _index, true];
			_x addEventHandler ["Killed", {
				params ["_unit", "_killer", "_instigator", "_useEffects"];
				_index = _unit getVariable "index";
				flakList set [_index, false];
				publicVariable "flakList";
			}];
		
			[_x, _positionX] spawn {
			params ["_flak", "_positionX"];
			while {alive _flak} do {
				waitUntil {sleep 1; ((_flak nearEntities 4000) findIf {side _x == teamPlayer}) != -1};
				_group = createGroup Occupants;
				[_group, policeGrunt, _positionX, [], 0, "NONE"] call A3A_fnc_createUnit;
				[_group, policeGrunt, _positionX, [], 0, "NONE"] call A3A_fnc_createUnit;
				{
					[_x] call A3A_fnc_NATOinit;
					_x moveInAny _flak;
				} forEach units _group;
		
					[_group] spawn {
					params ["_group"];
					while {true} do {
						sleep 1;
						_enemyAirUnits = (((leader _group) nearEntities ["air", 4000]) select {side _x == teamPlayer});
						{
						(leader _group) reveal [_x, 4];
						} forEach _enemyAirUnits;			
					};
					};
				waitUntil {sleep 30; ((_flak nearEntities 4000) findIf {side _x == teamPlayer}) == -1};
				{
					if (alive _x) then {deleteVehicle _x};
				} forEach units _group;
			};
			};
		} else {
		deleteVehicle (_AAList select _index);
		deleteVehicle (_flakModules select _index);
		};
		_index = _index + 1;
	} forEach _AAList;


