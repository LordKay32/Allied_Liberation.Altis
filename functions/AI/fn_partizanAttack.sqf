/*
 * Name:	fn_partizanAttack
 * Date:	7/08/2023
 * Version: 1.0
 * Author:  JB
 *
 * Description:
 * Partizans join attack
 *
 * Parameter(s):
 * _PARAM1 (TYPE): DESCRIPTION.
 * _PARAM2 (TYPE): DESCRIPTION.
 *
 * Returns:
 * %RETURNS%
 */

params ["_markerX"];

private _positionX = getMarkerPos _markerX;

sleep 270;

private _nearFriendlyCities = citiesX select {(sidesX getVariable [_x,sideUnknown] == teamPlayer) && (_positionX distance getMarkerPos _x < 2000)};

private _availableOrigins = [];

{
_dataX = server getVariable _x;
_prestigeBLUFOR = _dataX select 3;
if (_prestigeBLUFOR >= 50) then {_availableOrigins pushBack _x};
} forEach _nearFriendlyCities;

if (count _availableOrigins == 0) exitWith {};
if (count ((_positionX nearEntities 1400) select {side _x == teamPlayer}) < 16) exitWith {};

private _partizanCity = selectRandom _availableOrigins;

private _enemies = (_positionX nearEntities 1000) select {side _x == Occupants};

waitUntil {sleep 30; (_enemies findIf {(_x call BIS_fnc_enemyDetected == true)} != -1) || (spawner getVariable _markerX == 2)};
if (spawner getVariable _markerX == 2) exitWith {};

private _posOrigin = navGrid select ([_partizanCity] call A3A_fnc_getMarkerNavPoint) select 0;

private _route = [(getMarkerPos _partizanCity), _positionX] call A3A_fnc_findPath;

private _markers = [];

_route = _route apply { _x select 0 };			// reduce to position array
if (_route isEqualTo []) then { 
  // find nearest road for origin
  _roadpos = _posOrigin;
  _roads = _posOrigin nearRoads 100;
  if !(_roads isEqualTo []) then {
    _roadpos = (getRoadInfo(_roads select 0)) select 6;
  };
  _route = [_roadpos, _positionX] 
};

// AH - Move route forward by 40 m to ensure convoy isn't stuck in a base or other origin object
if (count _route > 2) then {
  // more than 2 nodes (assume proper path)
  _state = [];
  _state = [_route, 80, _state] call A3A_fnc_findPosOnRoute;
  _route = _route select [_state#2, count _route]; // Trim route down to start 40 m ahead
};

// Find location down route
private _pathState = [];
_pathState = [_route, [40, 0] select (count _pathState == 0), _pathState] call A3A_fnc_findPosOnRoute;

for "_i" from 1 to 2 do {
	while {true} do {
	    // make sure there are no other vehicles within 10m
	    if (count (ASLtoAGL (_pathState#0) nearEntities 20) == 0) exitWith {};
	    _pathState = [_route, 20, _pathState] call A3A_fnc_findPosOnRoute;
	};
	
	private _vehicle = createVehicle [civTruck, ASLtoAGL (_pathState#0) vectorAdd [0,0,0.5]];               // Give it a little air
	private _vecUp = (_pathState#1) vectorCrossProduct [0,0,1] vectorCrossProduct (_pathState#1);       // correct pitch angle
	_vehicle setVectorDirAndUp [_pathState#1, _vecUp];
	
	private _groupX = [_posOrigin, teamPlayer, groupsSDKSquad] call A3A_fnc_spawnGroup;
	_groupX addVehicle _vehicle;
	{
		[_x] call A3A_fnc_FIAinit;
		_x moveInAny _vehicle;
		[_x] spawn {
		_unit = _this select 0;
		}
	} forEach units _groupX;
	_groupX setCombatBehaviour "SAFE";
	[_groupX, _positionX, _vehicle] spawn {
		params ["_groupX", "_positionX", "_vehicle"];
		_soldiers = units _groupX;
		while {true} do {
			waitUntil {sleep 1; (_soldiers findIf {(_x call BIS_fnc_enemyDetected == true)} != -1) || ({alive _x} count _soldiers == 0) || (_vehicle distance _positionX < 400)};
			if ({alive _x} count _soldiers == 0) exitWith {};
			_soldiers allowGetIn false;
			if (_vehicle distance _positionX < 400) exitWith {
				for "_i" from 0 to (count waypoints _groupX - 1) do
				{
					deleteWaypoint [_groupX, 0];
				};
				_wp1 = _groupX addWaypoint [_positionX, 0];
				_wp1 setWaypointType "SAD";
			};
			waitUntil {sleep 1; (_soldiers findIf {(_x call BIS_fnc_enemyDetected == false)} != -1) || ({alive _x} count _soldiers == 0)};
			if ({alive _x} count _soldiers == 0) exitWith {};
			_soldiers allowGetIn true;
		};
	};
	
	[getPos _vehicle, _positionX, _groupX] call A3A_fnc_WPCreate;

	[_vehicle, _groupX, _markerX, _posOrigin] spawn {
		params ["_vehicle", "_groupX", "_markerX", "_posOrigin"];
		private _soldiers = units _groupX;

		waitUntil {sleep 5; (spawner getVariable _markerX == 2) || ({alive _x} count _soldiers == 0)};
		
		[_groupX] spawn A3A_fnc_groupDespawner;
		[_vehicle] spawn A3A_fnc_VEHdespawner;
	};
	sleep 8;
};

private _nameDest = [_markerX] call A3A_fnc_localizar;

["TaskSucceeded", ["", format ["Partizans are sending units to assist with the assault on %1", _nameDest]]] remoteExec ["BIS_fnc_showNotification",teamPlayer];
