//Mission: Destroy the antenna
if (!isServer and hasInterface) exitWith{};

private ["_antenna","_positionX","_timeLimit","_markerX","_nameDest","_mrkFinal","_tsk"];


_antenna = _this select 0;
_markerX = [markersX,_antenna] call BIS_fnc_nearestPosition;
_sideX = if (sidesX getVariable [_markerX,sideUnknown] == Occupants) then {Occupants} else {Invaders};
_difficultX = if (aggressionLevelOccupants > 3) then {true} else {false};
_leave = false;
_contactX = objNull;
_groupContact = grpNull;
_tsk = "";
_nameDest = [_markerX] call A3A_fnc_localizar;
_positionX = getPos _antenna;

private _side = sidesX getVariable [_markerX, sideUnknown];
private _sideName = if (_side == Invaders) then {nameInvaders} else {nameOccupants};

_timeLimit = if (_difficultX) then {90 * settingsTimeMultiplier} else {120 * settingsTimeMultiplier};
_dateLimit = [date select 0, date select 1, date select 2, date select 3, (date select 4) + _timeLimit];
_dateLimitNum = dateToNumber _dateLimit;
_dateLimit = numberToDate [date select 0, _dateLimitNum];//converts datenumber back to date array so that time formats correctly
_displayTime = [_dateLimit] call A3A_fnc_dateToTimeString;//Converts the time portion of the date array to a string for clarity in hints

_mrkFinal = createMarker [format ["DES%1", random 100], _positionX];
_mrkFinal setMarkerShape "ICON";

_reward = if (_difficultX) then {1000} else {800};
private _taskId = "DES" + str A3A_taskCount;
[[teamPlayer,civilian],_taskId,[format ["We have located a radio tower in %1, capture or destroy it. This will interrupt %3 communications and propaganda efforts. <br/><br/>Reward: %4CP per player",_nameDest,_displayTime,_sideName,_reward],"Destroy Radio Tower",_mrkFinal],_positionX,false,0,true,"Destroy",true] call BIS_fnc_taskCreate;
[_taskId, "DES", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];
waitUntil {sleep 1;(dateToNumber date > _dateLimitNum) or (not alive _antenna) or (not(sidesX getVariable [_markerX,sideUnknown] == _side))};

_bonus = if (_difficultX) then {2} else {1};

if (dateToNumber date > _dateLimitNum) then
	{
	[_taskId, "DES", "FAILED"] call A3A_fnc_taskSetState;
	[5,0,_positionX] remoteExec ["A3A_fnc_citySupportChange",2];
	}
else
	{
	sleep 10;
	[_taskId, "DES", "SUCCEEDED"] call A3A_fnc_taskSetState;
	[-5,0,_positionX] remoteExec ["A3A_fnc_citySupportChange",2];
    if (_sideX == Occupants) then {aggressionOccupants = aggressionOccupants - 10} else {aggressionInvaders = aggressionInvaders - 10};
	[] call A3A_fnc_calculateAggression;
	[600*_bonus, _side] remoteExec ["A3A_fnc_timingCA",2];
	[0,_reward*2,0] remoteExec ["A3A_fnc_resourcesFIA",2];
    { [_reward/10, _x] call A3A_fnc_playerScoreAdd } forEach (call BIS_fnc_listPlayers) select { side _x == teamPlayer || side _x == civilian};
	};

deleteMarker _mrkFinal;

[_taskId, "DES", 1200] spawn A3A_fnc_taskDelete;
