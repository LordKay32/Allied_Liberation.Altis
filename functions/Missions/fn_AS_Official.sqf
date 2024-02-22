//Mission: Assassinate an official
if (!isServer and hasInterface) exitWith{};

_markerX = _this select 0;

_leave = false;
_contactX = objNull;
_groupContact = grpNull;
_tsk = "";

_sideX = if (sidesX getVariable [_markerX,sideUnknown] == Occupants) then {Occupants} else {Invaders};
_positionX = getMarkerPos _markerX;

_timeLimit = 30 * settingsTimeMultiplier;
_dateLimit = [date select 0, date select 1, date select 2, date select 3, (date select 4) + _timeLimit];
_dateLimitNum = dateToNumber _dateLimit;

_nameDest = [_markerX] call A3A_fnc_localizar;
_naming = if (_sideX == Occupants) then {nameOccupants} else {nameInvaders};

private _taskString = if (_markerX in airportsX) then { 
	format ["We have been informed that a senior Luftwaffe commander is inspecting %1. Take him out.<br/><br/>Reward: 1000CP per player.",_nameDest];
} else {
	format ["We have been informed that a senior Wehrmacht commander is inspecting %1. Take him out.<br/><br/>Reward: 1000CP per player.",_nameDest];
};

private _taskId = "AS" + str A3A_taskCount;
[[teamPlayer,civilian],_taskId,[_taskString,"Kill the Officer",_markerX],_positionX,false,0,true,"Kill",true] call BIS_fnc_taskCreate;
[_taskId, "AS", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];

_grp = createGroup _sideX;
_typeX = if (_sideX == Occupants) then {"LIB_GER_oberst"} else {CSATOfficer};
_official = [_grp, _typeX, _positionX, [], 0, "NONE"] call A3A_fnc_createUnit;
if (_markerX in airportsX) then {
	_official forceAddUniform "U_LIB_GER_Officer_LuftbfvbfpHptmMp40";
	removeVest _official;
	_official addVest "V_LIB_GER_OfficerVest_0A";
	removeHeadgear _official;
	_official addHeadgear "H_LIB_GER_OfficerCap";
	removeAllWeapons _official;
} else {
	_official forceAddUniform "U_LIB_GER_Oberst";
	removeVest _official;
	_official addVest "V_LIB_GER_OfficerVest";
	removeHeadgear _official;
	_official addHeadgear "H_LIB_GER_OfficerCap_LUFT_Co";
	removeAllWeapons _official;
};

_officialAlerted = [_official, _markerX] spawn {
	params ["_official", "_markerX"];
	_isAlerted = false;
	
	while {_isAlerted == false} do {
		sleep 1;
		_friendlyList = (nearestObjects [_official, ["Man", "Car", "Tank"], 1200]) select {side _x == teamPlayer};
		{
			if (_official knowsAbout _x > 1.4 && captive _x == false) then {
				_isAlerted = true;
			};
		} forEach _friendlyList;
	};
	
	_official addMagazine "LIB_8Rnd_9x19_P08";
	_official addWeapon "LIB_P08";
	_official addItemToVest "LIB_8Rnd_9x19_P08";
	_official addItemToVest "LIB_8Rnd_9x19_P08";
	_group = group _official;
	_nul = [leader _group, _markerX, "COMBAT", "SPAWNED", "NOVEH", "NOFOLLOW","NOWP3"] execVM "scripts\UPSMON.sqf";
	for "_i" from (count waypoints _group - 1) to 0 step -1 do {
	deleteWaypoint [_group, _i];
	};
	
	_bunkers = nearestObjects [_official, ["Land_PillboxBunker_01_big_F"], 250];
	if (count _bunkers > 0) then {
		_bunker = _bunkers select 0;
		_pos = _bunker modelToWorld ([0.65, 4.2, -0.88]);
		_official doMove _pos;
	};
};

_typeX = if (_sideX == Occupants) then {
	(NATOGrunt call SCRT_fnc_unit_selectInfantryTier)
} else {
	(CSATGrunt call SCRT_fnc_unit_selectInfantryTier)
};

for "_i" from 1 to 5 do
	{
	_pilot = [_grp, _typeX, _positionX, [], 0, "NONE"] call A3A_fnc_createUnit;
	};


_grp selectLeader _official;
sleep 1;
_nul = [leader _grp, _markerX, "SAFE", "SPAWNED", "NOVEH", "NOFOLLOW"] execVM "scripts\UPSMON.sqf";

{_nul = [_x,""] call A3A_fnc_NATOinit; _x allowFleeing 0} forEach units _grp;

waitUntil {sleep 1; (dateToNumber date > _dateLimitNum) or (not alive _official)};

if (not alive _official) then {
	[_taskId, "AS", "SUCCEEDED"] call A3A_fnc_taskSetState;
	[0,2000,0] remoteExec ["A3A_fnc_resourcesFIA",2];
	[2400, _sideX] remoteExec ["A3A_fnc_timingCA",2];
	{ [100,_x] call A3A_fnc_playerScoreAdd } forEach (call BIS_fnc_listPlayers) select { side _x == teamPlayer || side _x == civilian};
	[_markerX,60] call A3A_fnc_addTimeForIdle;
	if (_sideX == Occupants) then {aggressionOccupants = aggressionOccupants - 20} else {aggressionInvaders = aggressionInvaders - 20};
    [] call A3A_fnc_calculateAggression;
} else {
	[_taskId, "AS", "FAILED"] call A3A_fnc_taskSetState;
	[-1200, _sideX] remoteExec ["A3A_fnc_timingCA",2];
	[_markerX,-60] call A3A_fnc_addTimeForIdle;
	if (_sideX == Occupants) then {aggressionOccupants = aggressionOccupants + 20} else {aggressionInvaders = aggressionInvaders + 20};
    [] call A3A_fnc_calculateAggression;
};

sleep 300;

{deleteVehicle _x} forEach units _grp;
deleteGroup _grp;

[_taskId, "AS", 1200] spawn A3A_fnc_taskDelete;
