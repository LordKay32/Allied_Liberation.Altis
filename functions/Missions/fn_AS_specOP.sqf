//Mission: Assassinate a SpecOp team
if (!isServer and hasInterface) exitWith{};

_markerX = _this select 0;

_difficultX = if (aggressionLevelOccupants > 3) then {true} else {false};
_positionX = getMarkerPos _markerX;
_sideX = if (sidesX getVariable [_markerX,sideUnknown] == Occupants) then {Occupants} else {Invaders};
_timeLimit = if (_difficultX) then {90 * settingsTimeMultiplier} else {120 * settingsTimeMultiplier};
_dateLimit = [date select 0, date select 1, date select 2, date select 3, (date select 4) + _timeLimit];
_dateLimitNum = dateToNumber _dateLimit;
_dateLimit = numberToDate [date select 0, _dateLimitNum];//converts datenumber back to date array so that time formats correctly
_displayTime = [_dateLimit] call A3A_fnc_dateToTimeString;//Converts the time portion of the date array to a string for clarity in hints

_nameDest = [_markerX] call A3A_fnc_localizar;
_naming = if (_sideX == Occupants) then {"NATO"} else {"CSAT"};
_reward = if (_difficultX) then {1500} else {1000};
private _taskString = format ["A squad of the hated Waffen SS is patrolling around a %1. Ambush them and wipe them out. Be careful, they are fanatically dedicated soldiers.<br/><br/>Reward: %2CP per player.",_nameDest, _reward];
private _taskId = "AS" + str A3A_taskCount;


_specOps = if(_sideX == Occupants) then { NATOSpecOp } else { CSATSpecOp };
_groupX = [_positionX, _sideX, _specOps] call A3A_fnc_spawnGroup;
{[_x,""] call A3A_fnc_NATOinit} forEach units _groupX;
_nul = [leader _groupX, _markerX, "SAFE","SPAWNED","RANDOM","NOVEH2","NOFOLLOW"] execVM "scripts\UPSMON.sqf";
[2, format ["SpecOps Group Array: %1, Group: %2", str _specOps, str _groupX], "fn_AS_specOP"] call A3A_fnc_log;

if (_difficultX) then {
	_tank = selectRandom ["LIB_GER_PzKpfwIV_H_Feldgrau","LIB_DAK_PzKpfwIV_H", "LIB_PzKpfwIV_H_tarn51c", "LIB_PzKpfwIV_H_tarn51d", "LIB_PzKpfwIV_H"];
	_vehicleType = selectRandom ["fow_v_sdkfz_222_camo_ger_heer", "fow_v_sdkfz_234_1", _tank];
	_vehPoint = [];
	_max_distance = 200;
	while { count _vehPoint < 1 } do
	{
		_vehPoint = _positionX findEmptyPosition [40, _max_distance, _vehicleType];
		_max_distance = _max_distance + 20;
	};
	_veh = [_vehPoint, (random 360), _vehicleType, _sideX] call A3A_fnc_spawnVehicle;
	_groupVeh = _veh select 2;
	{[_x,""] call A3A_fnc_NATOinit} forEach units _groupVeh;
	[_veh select 0, _sideX] call A3A_fnc_AIVEHinit;
	
	[_groupX,_groupVeh] spawn {
		params ["_groupX", "_groupVeh"];
		waitUntil {sleep 5; combatBehaviour _groupX == "COMBAT"};
		_reinfPos = getPos (leader _groupX);
		_groupVeh addWaypoint [_reinfPos, 0];
	};
};

[[teamPlayer,civilian],_taskId,[_taskString,"Eliminate Waffen SS Squad",_markerX],_positionX,false,0,true,"Kill",true] call BIS_fnc_taskCreate;
[_taskId, "AS", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];
waitUntil  {
	sleep 5;
	_aliveCount = {alive _x} count units _groupX;
	[2, format ["SpecOps Group Alive: %1", str _aliveCount], "fn_AS_specOP"] call A3A_fnc_log;
	(dateToNumber date > _dateLimitNum) or (sidesX getVariable [_markerX,sideUnknown] == teamPlayer) or (_aliveCount == 0)
};

if (dateToNumber date > _dateLimitNum) then
	{
	[_taskId, "AS", "FAILED"] call A3A_fnc_taskSetState;
	if (_difficultX) then
		{
		[10,0,_positionX] remoteExec ["A3A_fnc_citySupportChange",2];
		[-1200, _sideX] remoteExec ["A3A_fnc_timingCA",2];
		[-20,theBoss] call A3A_fnc_playerScoreAdd;
		}
	else
		{
		[5,0,_positionX] remoteExec ["A3A_fnc_citySupportChange",2];
		[-600, _sideX] remoteExec ["A3A_fnc_timingCA",2];
		[-10,theBoss] call A3A_fnc_playerScoreAdd;
		};
	}
else
	{
	[_taskId, "AS", "SUCCEEDED"] call A3A_fnc_taskSetState;
	if (_difficultX) then {
		[0,1500,0] remoteExec ["A3A_fnc_resourcesFIA",2];
		[0,10,_positionX] remoteExec ["A3A_fnc_citySupportChange",2];
		[1200, _sideX] remoteExec ["A3A_fnc_timingCA",2];
		{ [150,_x] call A3A_fnc_playerScoreAdd } forEach (call BIS_fnc_listPlayers) select { side _x == teamPlayer || side _x == civilian};
		[50,theBoss] call A3A_fnc_playerScoreAdd;
	}
	else {
		[0,1000,0] remoteExec ["A3A_fnc_resourcesFIA",2];
		[0,5,_positionX] remoteExec ["A3A_fnc_citySupportChange",2];
		[600, _sideX] remoteExec ["A3A_fnc_timingCA",2];
		{ [100,_x] call A3A_fnc_playerScoreAdd } forEach (call BIS_fnc_listPlayers) select { side _x == teamPlayer || side _x == civilian};
		[20,theBoss] call A3A_fnc_playerScoreAdd;
	};

	if (_sideX == Occupants) then {aggressionOccupants = aggressionOccupants - 10} else {aggressionInvaders = aggressionInvaders - 10};
	[] call A3A_fnc_calculateAggression;
	["TaskFailed", ["", format ["SpecOp Team decimated at a %1",_nameDest]]] remoteExec ["BIS_fnc_showNotification",_sideX];
};

[_taskId, "AS", 1200] spawn A3A_fnc_taskDelete;
