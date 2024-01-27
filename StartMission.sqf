/*
 * Name:	StartMission
 * Date:	27/08/2023
 * Version: 1.0
 * Author:  JB
 *
 * Description:
 * %DESCRIPTION%
 *
 * Parameter(s):
 * _PARAM1 (TYPE): - DESCRIPTION.
 * _PARAM2 (TYPE): - DESCRIPTION.
 */

if (introAttackStarted) exitWith {["Start Mission", "Mission already underway"] call A3A_fnc_customHint;};
introAttackStarted = true;

if (isDedicated) then {"introCinematic.sqf" remoteExec ["execVM",-2]} else {"introCinematic.sqf" remoteExec ["execVM",0]};

//readyMessage = false;
//["StartingIntro", true, 5] call BIS_fnc_blackIn;
//["StartingIntro", true, 5] remoteExec ["BIS_fnc_blackIn",0];
//publicVariable "readyMessage" ;

"US_AssaultMrk" setMarkerAlpha 0;
"UK_AssaultMrk" setMarkerAlpha 0;

sleep 5;

_vehUS1 = createvehicle [vehInfSDKBoat, (getMarkerPos "start_5"), [], 0, "CAN_COLLIDE"];
_vehUS1 setDir 286.226;
_vehUS1 allowDamage false;

_vehUS2 = createvehicle [vehSDKBoat, (getMarkerPos "start_4"), [], 0, "CAN_COLLIDE"];
_vehUS2 setDir 287.108;
_vehUS2 allowDamage false;

_vehUS3 = createvehicle [vehInfSDKBoat, (getMarkerPos "start_3"), [], 0, "CAN_COLLIDE"];
_vehUS3 setDir 287.610;
_vehUS3 allowDamage false;

_vehUK1 = createvehicle [vehSDKBoat, (getMarkerPos "start_2"), [], 0, "CAN_COLLIDE"];
_vehUK1 setDir 286.093;
_vehUK1 allowDamage false;

_vehUK2 = createvehicle [vehInfSDKBoat, (getMarkerPos "start_1"), [], 0, "CAN_COLLIDE"];
_vehUK2 setDir 287.211;
_vehUK2 allowDamage false;

{
	_boatCrew = USMil;
	_boatGroup = createGroup teamPlayer;
	private _unit = [_boatGroup, _boatCrew, [0,0,0], [], 0, "NONE"] call A3A_fnc_createUnit;
	[_unit] spawn A3A_fnc_FIAInit;
	_unit assignAsDriver _x;
	_unit moveInDriver _x;
	_unit allowDamage false;
	_unit disableAI "PATH";
	_boatGroup setBehaviourStrong "CARELESS";
} forEach [_vehUS1,_vehUS3,_vehUK2];

{
	_boatCrew = USMil;
	_boatGroup = createGroup teamPlayer;
	private _unit = [_boatGroup, _boatCrew, [0,0,0], [], 0, "NONE"] call A3A_fnc_createUnit;
	[_unit] spawn A3A_fnc_FIAInit;
	_unit assignAsDriver _x;
	_unit moveInDriver _x;
	_unit allowDamage false;
	_unit disableAI "PATH";
	for "_i" from 1 to 2 do {
	private _unit = [_boatGroup, _boatCrew, [0,0,0], [], 0, "NONE"] call A3A_fnc_createUnit;
	[_unit] spawn A3A_fnc_FIAInit;
	_unit moveInAny _x;
	};
} forEach [_vehUS2, _vehUK1];

private _groupUS1 = [[0,0,0], teamPlayer, groupsUSSquad] call A3A_fnc_spawnGroup;
{
	[_x] call A3A_fnc_FIAinit;
	_x moveInAny _vehUS1;
} forEach units _groupUS1;
_groupUS1 setGroupIdGlobal ["US-Sqd-" + str ({side (leader _x) == teamPlayer} count allGroups)];
theBoss hcSetGroup [_groupUS1];

[_vehUS1] spawn {
	params ["_vehUS1"];
	private _time = 0;
	while {true} do {
		_time = _time + 1;
		sleep 1;
	
		if (allPlayers findIf {roleDescription _x == "US Officer (Engineer)"} != -1) exitWith {
			_player5 = (allPlayers select {roleDescription _x == "US Officer (Engineer)"}) select 0;
			_player5 moveInAny _vehUS1;
			private _groupUS2 = [[0,0,0], teamPlayer, groupsUSSquad] call A3A_fnc_spawnGroup;
			deletevehicle (leader  _groupUS2);
			{
			_x moveInAny _vehUS1;
			} forEach units _groupUS2;
			_player5 joinAsSilent [(group _player5), 1];
			units _groupUS2 joinSilent (group _player5);
			["START"] remoteExec ["A3A_fnc_introLoadouts",_player5];
		};
		
		if (_time > 60) exitWith {
			private _groupUS2 = [[0,0,0], teamPlayer, groupsUSSquad] call A3A_fnc_spawnGroup;
			{
			[_x] call A3A_fnc_FIAinit;
			_x moveInAny _vehUS1;
			} forEach units _groupUS2;
			_groupUS2 setGroupIdGlobal ["US-Sqd-" + str ({side (leader _x) == teamPlayer} count allGroups)];
			theBoss hcSetGroup [_groupUS2];
		};
	};
};

[_vehUS2] spawn {
	params ["_vehUS2"];
	private _time = 0;
	while {true} do {
		_time = _time + 1;
		sleep 1;
	
		if (allPlayers findIf {roleDescription _x == "Commander"} != -1) exitWith {
			_player1 = (allPlayers select {roleDescription _x == "Commander"}) select 0;

			[tankUS, teamPlayer] call A3A_fnc_AIvehinit;
			_USTankCrew = USCrew;
			for "_i" from 1 to 4 do {
				private _unit = [(group _player1), _USTankCrew, [0,0,0], [], 0, "NONE"] call A3A_fnc_createUnit;
			};
			{
			_x moveInAny tankUS;
			} forEach units group _player1;
			_vehUS2 setvehicleCargo tankUS;
			["START"] remoteExec ["A3A_fnc_introLoadouts",_player1];
		};
		
		if (_time > 60) exitWith {
			_tankUS = createvehicle [vehSDKTankUSM4, [0,0,1000], [], 0, "NONE"];
			[_tankUS, teamPlayer] call A3A_fnc_AIvehinit;
			_USTankCrew = USCrew;
			_USTankGroup = createGroup teamPlayer;
			for "_i" from 1 to 5 do {
				private _unit = [_USTankGroup, _USTankCrew, [0,0,0], [], 0, "NONE"] call A3A_fnc_createUnit;
				[_unit] spawn A3A_fnc_FIAInit;
				_unit moveInAny _tankUS;
			};
			_vehUS2 setvehicleCargo _tankUS;
			_USTankGroup setGroupIdGlobal ["US-M4-" + str ({side (leader _x) == teamPlayer} count allGroups)];
			theBoss hcSetGroup [_USTankGroup];
		};
	};
};

private _groupUS3 = [[0,0,0], teamPlayer, groupsUSSquad] call A3A_fnc_spawnGroup;
{
	[_x] call A3A_fnc_FIAinit;
	_x moveInAny _vehUS3;
} forEach units _groupUS3;
_groupUS3 setGroupIdGlobal ["US-Sqd-" + str ({side (leader _x) == teamPlayer} count allGroups)];
theBoss hcSetGroup [_groupUS3];

[_vehUS3] spawn {
	params ["_vehUS3"];
	private _time = 0;
	while {true} do {
		_time = _time + 1;
		sleep 1;
	
		if (allPlayers findIf {roleDescription _x == "US Officer (Medic)"} != -1) exitWith {
			_player4 = (allPlayers select {roleDescription _x == "US Officer (Medic)"}) select 0;
			_player4 moveInAny _vehUS3;
			private _groupUS4 = [[0,0,0], teamPlayer, groupsUSSquad] call A3A_fnc_spawnGroup;
			deletevehicle (leader _groupUS4);
			{
			_x moveInAny _vehUS3;
			} forEach units _groupUS4;
			_player4 joinAsSilent [(group _player4), 1];
			units _groupUS4 joinSilent (group _player4);
			["START"] remoteExec ["A3A_fnc_introLoadouts",_player4];
		};
		
		if (_time > 60) exitWith {
			private _groupUS4 = [[0,0,0], teamPlayer, groupsUSSquad] call A3A_fnc_spawnGroup;
			{
			[_x] call A3A_fnc_FIAinit;
			_x moveInAny _vehUS3;
			} forEach units _groupUS4;
			_groupUS4 setGroupIdGlobal ["US-Sqd-" + str ({side (leader _x) == teamPlayer} count allGroups)];
			theBoss hcSetGroup [_groupUS4];
		};
	};
};

[_vehUK1] spawn {
	params ["_vehUK1"];
	private _time = 0;
	while {true} do {
		_time = _time + 1;
		sleep 1;
	
		if (allPlayers findIf {roleDescription _x == "UK Officer (Engineer)"} != -1) exitWith {
			_player3 = (allPlayers select {roleDescription _x == "UK Officer (Engineer)"}) select 0;
			_UKTankCrew = UKCrew;
			for "_i" from 1 to 4 do {
				private _unit = [(group _player3), _UKTankCrew, [0,0,0], [], 0, "NONE"] call A3A_fnc_createUnit;
			};
			{
			_x moveInAny tankUK;
			} forEach units group _player3;
			_vehUK1 setvehicleCargo tankUK;
			["START"] remoteExec ["A3A_fnc_introLoadouts",_player3];
		};
		
		if (_time > 60) exitWith {
			_tankUK = createvehicle [vehSDKTankUKM4, [0,0,1000], [], 0, "NONE"];
			[_tankUK, teamPlayer] call A3A_fnc_AIvehinit;
			_UKTankCrew = UKCrew;
			_UKTankGroup = createGroup teamPlayer;
			for "_i" from 1 to 5 do {
				private _unit = [_UKTankGroup, _UKTankCrew, [0,0,0], [], 0, "NONE"] call A3A_fnc_createUnit;
				[_unit] spawn A3A_fnc_FIAInit;
				_unit moveInAny _tankUK;
			};
			_vehUK1 setvehicleCargo _tankUK;
			_UKTankGroup setGroupIdGlobal ["UK-M4-" + str ({side (leader _x) == teamPlayer} count allGroups)];
			theBoss hcSetGroup [_UKTankGroup];
		};
	};
};

private _groupUK1 = [[0,0,0], teamPlayer, groupsUKSquad] call A3A_fnc_spawnGroup;
{
	[_x] call A3A_fnc_FIAinit;
	_x moveInAny _vehUK2;
} forEach units _groupUK1;
_groupUK1 setGroupIdGlobal ["UK-Sqd-" + str ({side (leader _x) == teamPlayer} count allGroups)];
theBoss hcSetGroup [_groupUK1];

[_vehUK2] spawn {
	params ["_vehUK2"];
	private _time = 0;
	while {true} do {
		_time = _time + 1;
		sleep 1;
	
		if (allPlayers findIf {roleDescription _x == "UK Officer (Medic)"} != -1) exitWith {
			_player2 = (allPlayers select {roleDescription _x == "UK Officer (Medic)"}) select 0;
			_player2 moveInAny _vehUK2;
			private _groupUK2 = [[0,0,0], teamPlayer, groupsUKSquad] call A3A_fnc_spawnGroup;
			deletevehicle (leader _groupUK2);
			{
			_x moveInAny _vehUK2;
			} forEach units _groupUK2;
			_player2 joinAsSilent [(group _player2), 1];
			units _groupUK2 joinSilent (group _player2);
			["START"] remoteExec ["A3A_fnc_introLoadouts",_player2];
		};
		
		if (_time > 60) exitWith {
			private _groupUK2 = [[0,0,0], teamPlayer, groupsUKSquad] call A3A_fnc_spawnGroup;
			{
			[_x] call A3A_fnc_FIAinit;
			_x moveInAny _vehUK2;
			} forEach units _groupUK2;
			_groupUK2 setGroupIdGlobal ["UK-Sqd-" + str ({side (leader _x) == teamPlayer} count allGroups)];
			theBoss hcSetGroup [_groupUK2];
		};
	};
};

sleep 10;

{
[_x] remoteExec ["A3A_fnc_startMissionLanding",_x];	
} forEach [_vehUS1,_vehUS2,_vehUS3,_vehUK1,_vehUK2];

waitUntil {sleep 1; (spawner getVariable "outpost_100" != 2)};
theBoss = commanderX;

forcedSpawn pushBack "outpost_100";
publicVariable "forcedSpawn";
	
sleep 20;


[] spawn {
	private _mortars = nearestObjects [(getMarkerPos "outpost_100"), ["LIB_GrWr34_g"], 500];
	if (count _mortars >= 1) then {
		[(_mortars select 0), artyTarget_1, "LIB_8Rnd_81mmHE_GRWR34", 100, 12, 5] spawn BIS_fnc_fireSupport;
	};
	if (count _mortars >= 2) then {
		[(_mortars select 1), artyTarget_2, "LIB_8Rnd_81mmHE_GRWR34", 100, 12, 5] spawn BIS_fnc_fireSupport;
	};
	sleep 100;
	{
		_x setvehicleAmmo 1;
	} forEach _mortars;
};


private _taskId1 = "startCaptureOutpost";
[[teamPlayer,civilian],_taskId1,["Capture the outpost at the landing zones.","Capture Outpost","outpost_100"],(getMarkerPos "outpost_100"),false,0,true,"attack",true] call BIS_fnc_taskCreate;

private _taskId2 = "clearLandingZones";
[[teamPlayer,civilian],_taskId2,["Clear the landing zones of enemy troops.","Clear Landing Zones","introMissionMarker"],getMarkerPos "introMissionMarker",false,0,true,"attack",true] call BIS_fnc_taskCreate;

waitUntil {sleep 10; (sidesX getVariable ["outpost_100", sideUnknown] == teamPlayer) || (((getMarkerPos "introMissionMarker") nearEntities 200) findIf {side _x == Occupants && [_x] call A3A_fnc_canFight} == -1)};

forcedSpawn = forcedSpawn - ["outpost_100"];
publicVariable "forcedSpawn";

if (sidesX getVariable ["outpost_100", sideUnknown] == teamPlayer) then {
	[_taskId1,"SUCCEEDED"] call BIS_fnc_taskSetState;
	waitUntil {sleep 10; (((getMarkerPos "introMissionMarker") nearEntities 200) findIf {side _x == Occupants && [_x] call A3A_fnc_canFight} == -1)};	
	[_taskId2,"SUCCEEDED"] call BIS_fnc_taskSetState;
};

if (((getMarkerPos "introMissionMarker") nearEntities 200) findIf {side _x == Occupants && [_x] call A3A_fnc_canFight} == -1) then {
	[_taskId2,"SUCCEEDED"] call BIS_fnc_taskSetState;
	waitUntil {sleep 10; (sidesX getVariable ["outpost_100", sideUnknown] == teamPlayer)};	
	[_taskId1,"SUCCEEDED"] call BIS_fnc_taskSetState;
};

introFinished = true;
publicVariable "introFinished";

sleep 10;

petros setPos getMarkerPos "petros";
flagX setPos getMarkerPos "flagX";
flagUK setPos getMarkerPos "flagUK";
mapX setPos getMarkerPos "whiteboard";
vehicleBox setPos getMarkerPos "garage";
BoxX setPos getMarkerPos "boxX";
"respawn_guerrila" setMarkerPos getMarkerPos "flagX";
"respawn_guerrila" setMarkerAlpha 1;
"synd_HQ" setMarkerPos getMarkerPos "flagX";

[] spawn {
	waitUntil {sleep 600; ((sidesX getVariable ["airport_2", sideUnknown] == teamPlayer) && (sidesX getVariable ["seaport_4", sideUnknown] == teamPlayer) && !(bigAttackInProgress))};
	["Molos"] spawn A3A_fnc_cityRebel;
};