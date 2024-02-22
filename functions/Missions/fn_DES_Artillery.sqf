//Mission: Destroy Artillery
if (!isServer and hasInterface) exitWith{};

private ["_markerX","_positionX", "_sideX", "_dateLimit","_dateLimitNum","_nameDest","_typeVehX", "_escortShip"];

_markerX = _this select 0;
_positionX = getMarkerPos _markerX;
_sideX = if (sidesX getVariable [_markerX,sideUnknown] == Occupants) then {Occupants} else {Invaders};
_timeLimit = 120 * settingsTimeMultiplier;
_dateLimit = [date select 0, date select 1, date select 2, date select 3, (date select 4) + _timeLimit];
_dateLimitNum = dateToNumber _dateLimit;
_dateLimit = numberToDate [date select 0, _dateLimitNum];//converts datenumber back to date array so that time formats correctly
_displayTime = [_dateLimit] call A3A_fnc_dateToTimeString;//Converts the time portion of the date array to a string for clarity in hints

_sideName = if (_sideX == Occupants) then {nameOccupants} else {nameInvaders};
_nameDest = [_markerX] call A3A_fnc_localizar;

private _taskId = "DES" + str A3A_taskCount;
[[teamPlayer,civilian],_taskId,[format ["We have discovered a %1 artillery post at %2. Destroy the artillery pieces, and we may get some relief from enemy shelling. <br/><br/>Reward: 1000CP per player",_sideName, _nameDest],"Destroy Artillery",_markerX],_positionX,false,0,true,"Destroy",true] call BIS_fnc_taskCreate;
[_taskId, "DES", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];
	
_artilleryPieces = nearestObjects [_positionX, [NATOHowitzer], 250];
	
waitUntil {sleep 1;(dateToNumber date > _dateLimitNum) or _artilleryPieces findIf {alive _x} == -1};
	
if (_artilleryPieces findIf {alive _x} == -1) then {	
	[_taskId, "DES", "SUCCEEDED"] call A3A_fnc_taskSetState;
	
	[0,2000,0] remoteExec ["A3A_fnc_resourcesFIA",2];
    if (_sideX == Occupants) then {aggressionOccupants = aggressionOccupants - 20} else {aggressionInvaders = aggressionInvaders - 20};
	[] call A3A_fnc_calculateAggression;
	[1200, _sideX] remoteExec ["A3A_fnc_timingCA",2];
	{ [100, _x] call A3A_fnc_playerScoreAdd } forEach (call BIS_fnc_listPlayers) select { side _x == teamPlayer || side _x == civilian};
} else {
    [_taskId, "DES", "FAILED"] call A3A_fnc_taskSetState;
	[-600, _sideX] remoteExec ["A3A_fnc_timingCA",2];
};
[_taskId, "DES", 1200] spawn A3A_fnc_taskDelete;
