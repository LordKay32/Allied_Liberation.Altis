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
sleep 5;

"US_AssaultMrk" setMarkerAlpha 0;
"UK_AssaultMrk" setMarkerAlpha 0;

_vehUS1 = createVehicle [vehInfSDKBoat, (getMarkerPos "start_5"), [], 0, "CAN_COLLIDE"];
_vehUS1 setDir 286.226;
_vehUS1 allowDamage false;

_vehUS2 = createVehicle [vehSDKBoat, (getMarkerPos "start_4"), [], 0, "CAN_COLLIDE"];
_vehUS2 setDir 287.108;
_vehUS2 allowDamage false;

_vehUS3 = createVehicle [vehInfSDKBoat, (getMarkerPos "start_3"), [], 0, "CAN_COLLIDE"];
_vehUS3 setDir 287.610;
_vehUS3 allowDamage false;

_vehUK1 = createVehicle [vehSDKBoat, (getMarkerPos "start_2"), [], 0, "CAN_COLLIDE"];
_vehUK1 setDir 286.093;
_vehUK1 allowDamage false;

_vehUK2 = createVehicle [vehInfSDKBoat, (getMarkerPos "start_1"), [], 0, "CAN_COLLIDE"];
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

_player1 = if (allPlayers findIf {roleDescription _x == "Commander"} != -1) then {(allPlayers select {roleDescription _x == "Commander"}) select 0} else {objNull};
_player2 = if (allPlayers findIf {roleDescription _x == "UK Officer (Medic)"} != -1) then {(allPlayers select {roleDescription _x == "UK Officer (Medic)"}) select 0} else {objNull};
_player3 = if (allPlayers findIf {roleDescription _x == "UK Officer (Engineer)"} != -1) then {(allPlayers select {roleDescription _x == "UK Officer (Engineer)"}) select 0} else {objNull};
_player4 = if (allPlayers findIf {roleDescription _x == "US Officer (Medic)"} != -1) then {(allPlayers select {roleDescription _x == "US Officer (Medic)"}) select 0} else {objNull};
_player5 = if (allPlayers findIf {roleDescription _x == "US Officer (Engineer)"} != -1) then {(allPlayers select {roleDescription _x == "US Officer (Engineer)"}) select 0} else {objNull};

private _groupUS1 = [[0,0,0], teamPlayer, groupsUSSquad] call A3A_fnc_spawnGroup;
{
	[_x] call A3A_fnc_FIAinit;
	_x moveInAny _vehUS1;
} forEach units _groupUS1;
_groupUS1 setGroupIdGlobal ["US-Sqd-" + str ({side (leader _x) == teamPlayer} count allGroups)];
theBoss hcSetGroup [_groupUS1];

private _groupUS2 = [[0,0,0], teamPlayer, groupsUSSquad] call A3A_fnc_spawnGroup;


if !(isNull _player5) then {
	deleteVehicle (leader  _groupUS2);
	_player5 joinAsSilent [(group _player5), 1];
	units _groupUS2 joinSilent (group _player5);
	private _clientID = owner _player5;
	{
	[_x] call A3A_fnc_FIAinit;
	[_x] remoteExec ["A3A_fnc_groupMarkersSM",_clientID];
	} forEach (units (group _player5) - [_player5]);
	{
	_x moveInAny _vehUS1;
	} forEach units (group _player5);
	_player5 addWeapon "LIB_Binocular_US";
	_player5 forceAddUniform "U_LIB_US_Off";
	_player5 addVest "V_LIB_US_Vest_Garand";
	_player5 addHeadgear "H_LIB_US_Helmet_Second_lieutenant";
	_player5 addMagazine "LIB_5Rnd_762x63";
	_player5 addWeapon "LIB_M1903A4_Springfield";
	_player5 addMagazine "LIB_7Rnd_45ACP";
	_player5 addWeapon "LIB_Colt_M1911";
	_player5 addItemToUniform "LIB_US_M18";
	for "_i" from 1 to 2 do
		{
		_player5 addItemToUniform "fow_i_fak_us";
		_player5 addItemToUniform "LIB_7Rnd_45ACP";
		_player5 addItemToVest "LIB_US_Mk_2";
		};
	for "_i" from 1 to 12 do
		{
		_player5 addItemToVest "LIB_5Rnd_762x63";
		};
} else {
	{
	[_x] call A3A_fnc_FIAinit;
	_x moveInAny _vehUS1;
	} forEach units _groupUS2;
	_groupUS2 setGroupIdGlobal ["US-Sqd-" + str ({side (leader _x) == teamPlayer} count allGroups)];
	theBoss hcSetGroup [_groupUS2];
};

_tankUSData = [[0,0,1000], 0, vehSDKTankUSM4, teamPlayer] call A3A_fnc_spawnVehicle;
_tankUS = _tankUSData select 0;
_tankUSCrew = _tankUSData select 1;
_tankUSGroup = _tankUSData select 2;
[_tankUS, teamPlayer] call A3A_fnc_AIVEHinit;
_vehUS2 setVehicleCargo _tankUS;
if !(isNull _player1) then {
	deleteVehicle commander _tankUS;
	_player1 joinAsSilent [(group _player1), 1];
	_tankUSCrew joinSilent (group _player1);
	private _clientID = owner _player1;
	{[_x] call A3A_fnc_FIAinit; [_x] remoteExec ["A3A_fnc_groupMarkersSM",_clientID];} forEach (units (group _player1) - [_player1]);
	_player1 assignAsCommander _tankUS;
	_player1 moveInCommander _tankUS;
	_player1 setSpeaker "Male03ENG";
	_player1 addWeapon "LIB_Binocular_US";
	_player1 forceAddUniform "U_LIB_US_Tank_Crew2";
	_player1 addVest "V_LIB_US_Vest_Thompson";
	_player1 addHeadgear "H_LIB_US_Helmet_Tank";
	_player1 addMagazine "LIB_30Rnd_M3_GreaseGun_45ACP";
	_player1 addWeapon "LIB_M3_GreaseGun";
	_player1 addMagazine "LIB_7Rnd_45ACP";
	_player1 addWeapon "LIB_Colt_M1911";
	_player1 addItemToUniform "LIB_US_M18";
	for "_i" from 1 to 2 do
		{
		_player1 addItemToUniform "fow_i_fak_uk";
		_player1 addItemToVest "LIB_30Rnd_M3_GreaseGun_45ACP";
		_player1 addItemToVest "LIB_7Rnd_45ACP";
		};
};

private _groupUS3 = [[0,0,0], teamPlayer, groupsUSSquad] call A3A_fnc_spawnGroup;
{
	[_x] call A3A_fnc_FIAinit;
	_x moveInAny _vehUS3;
} forEach units _groupUS3;
_groupUS3 setGroupIdGlobal ["US-Sqd-" + str ({side (leader _x) == teamPlayer} count allGroups)];
theBoss hcSetGroup [_groupUS3];

private _groupUS4 = [[0,0,0], teamPlayer, groupsUSSquad] call A3A_fnc_spawnGroup;
if !(isNull _player4) then {
	deleteVehicle (leader  _groupUS4);
	_player4 joinAsSilent [(group _player4), 1];
	units _groupUS4 joinSilent (group _player4);
	private _clientID = owner _player4;
	{
	[_x] call A3A_fnc_FIAinit;
	[_x] remoteExec ["A3A_fnc_groupMarkersSM",_clientID];
	} forEach (units (group _player4) - [_player4]);
	{
	_x moveInAny _vehUS3;
	} forEach units (group _player4);
	_player4 addWeapon "LIB_Binocular_US";
	_player4 forceAddUniform "U_LIB_US_Off";
	_player4 addVest "V_LIB_US_Vest_Carbine_nco";
	_player4 addBackpack "B_LIB_US_Backpack_RocketBag";
	_player4 addHeadgear "H_LIB_US_Helmet_Second_lieutenant";
	_player4 addMagazine "LIB_15Rnd_762x33";
	_player4 addWeapon "LIB_M1_Carbine";
	_player4 addMagazine "LIB_7Rnd_45ACP";
	_player4 addWeapon "LIB_Colt_M1911";
	_player4 addMagazine "LIB_1Rnd_60mm_M6";
	_player4 addWeapon "LIB_M1A1_Bazooka";
	_player4 addItemToUniform "LIB_US_M18";
	for "_i" from 1 to 2 do
		{
		_player4 addItemToUniform "fow_i_fak_us";
		_player4 addItemToUniform "LIB_7Rnd_45ACP";
		_player4 addItemToVest "LIB_US_Mk_2";
		};
		for "_i" from 1 to 3 do
		{
		_player4 addItemToBackpack "LIB_1Rnd_60mm_M6";
		};
	for "_i" from 1 to 8 do
		{
		_player4 addItemToVest "LIB_15Rnd_762x33";
		};
} else {
	{
	[_x] call A3A_fnc_FIAinit;
	_x moveInAny _vehUS3;
	} forEach units _groupUS4;
	_groupUS4 setGroupIdGlobal ["US-Sqd-" + str ({side (leader _x) == teamPlayer} count allGroups)];
	theBoss hcSetGroup [_groupUS4];
};

_tankUK = createVehicle [vehSDKTankUKM4, [0,0,1000], [], 0, "NONE"];
_UKTankCrew = UKCrew;
_UKTankGroup = createGroup teamPlayer;
for "_i" from 1 to 5 do {
private _unit = [_UKTankGroup, _UKTankCrew, [0,0,0], [], 0, "NONE"] call A3A_fnc_createUnit;
[_unit] spawn A3A_fnc_FIAInit;
_unit moveInAny _tankUK;
};

[_tankUK, teamPlayer] call A3A_fnc_AIVEHinit;
_vehUK1 setVehicleCargo _tankUK;
if !(isNull _player3) then {
	deleteVehicle commander _tankUK;
	_player3 joinAsSilent [(group _player3), 1];
	_tankUKCrew joinSilent (group _player3);
	private _clientID = owner _player3;
	{[_x] call A3A_fnc_FIAinit;[_x] remoteExec ["A3A_fnc_groupMarkersSM",_clientID];} forEach (units (group _player3) - [_player3]);
	_player3 assignAsCommander _tankUK;
	_player3 moveInCommander _tankUK;
	_player3 addWeapon "LIB_Binocular_UK";
	_player3 forceAddUniform "U_LIB_UK_P37_Sergeant";
	_player3 addVest "V_LIB_UK_P37_Crew";
	_player3 addBackpack "B_LIB_UK_HSack";
	_player3 addHeadgear "H_LIB_UK_Beret_Headset";
	_player3 addMagazine "LIB_32Rnd_9x19_Sten";
	_player3 addWeapon "LIB_Sten_Mk2";
	_player3 addMagazine "LIB_6Rnd_455";
	_player3 addWeapon "LIB_Webley_mk6";
	_player3 addItemToUniform "LIB_US_M18";
	_player3 addItemToBackpack "ToolKit";
	for "_i" from 1 to 2 do
		{
		_player3 addItemToUniform "fow_i_fak_uk";
		_player3 addItemToVest "LIB_32Rnd_9x19_Sten";
		_player3 addItemToVest "LIB_6Rnd_455";
		};
};

private _groupUK1 = [[0,0,0], teamPlayer, groupsUKSquad] call A3A_fnc_spawnGroup;
{
	[_x] call A3A_fnc_FIAinit;
	_x moveInAny _vehUK2;
} forEach units _groupUK1;
_groupUK1 setGroupIdGlobal ["UK-Sqd-" + str ({side (leader _x) == teamPlayer} count allGroups)];
theBoss hcSetGroup [_groupUK1];

private _groupUK2 = [[0,0,0], teamPlayer, groupsUKSquad] call A3A_fnc_spawnGroup;
if !(isNull _player2) then {
	deleteVehicle (leader  _groupUK2);
	_player2 joinAsSilent [(group _player2), 1];
	units _groupUK2 joinSilent (group _player2);
	private _clientID = owner _player2;
	{
	[_x] call A3A_fnc_FIAinit;
	[_x] remoteExec ["A3A_fnc_groupMarkersSM",_clientID];
	} forEach (units (group _player2) - [_player2]);
	{
	_x moveInAny _vehUK2;
	} forEach units (group _player2);
	_player2 addWeapon "LIB_Binocular_UK";
	_player2 forceAddUniform "U_LIB_UK_P37";
	_player2 addVest "V_LIB_UK_P37_Officer";
	_player2 addBackpack "B_LIB_UK_HSack";
	_player2 addHeadgear "H_LIB_UK_Helmet_Mk2";
	_player2 addMagazine "LIB_10Rnd_770x56";
	_player2 addWeapon "LIB_LeeEnfield_No4";
	_player2 addMagazine "LIB_6Rnd_455";
	_player2 addWeapon "LIB_Webley_mk6";
	_player2 addMagazine "LIB_1Rnd_89m_PIAT";
	_player2 addWeapon "LIB_PIAT";
	_player2 addItemToUniform "LIB_US_M18";
	for "_i" from 1 to 2 do
		{
		_player2 addItemToUniform "fow_i_fak_uk";
		_player2 addItemToVest "LIB_6Rnd_455";
		_player2 addItemToVest "LIB_MillsBomb";
		};
	for "_i" from 1 to 3 do
		{
		_player2 addItemToBackpack "LIB_1Rnd_89m_PIAT";
		};
	for "_i" from 1 to 8 do
		{
		_player2 addItemToVest "LIB_10Rnd_770x56";
		};
} else {
	{
	[_x] call A3A_fnc_FIAinit;
	_x moveInAny _vehUK2;
	} forEach units _groupUK2;
	_groupUK2 setGroupIdGlobal ["UK-Sqd-" + str ({side (leader _x) == teamPlayer} count allGroups)];
	theBoss hcSetGroup [_groupUK2];
};

sleep 1;

[] spawn {
	{
	_x allowDamage false;
	waitUntil {sleep 1; (isTouchingGround _x)};
	_x allowDamage true;
	} forEach allPlayers;
};

{
[_x] spawn {
	params ["_boat"];
	while {true} do {
		sleep 1;
		_boat setVelocityModelSpace [0, 8, 0];
		if ((isTouchingGround _boat) && (_boat inArea "landingZone1" || _boat inArea "landingZone2")) exitWith {
		
			sleep 3;
		
			private _cargoInf = fullCrew [_boat, "cargo"];  
 			private _cargoVeh = getVehicleCargo _boat;  
 	
			if (count _cargoInf > 0) then {  
  				_Deployment_Actions = getArray (configFile >> "CfgVehicles" >> (typeOf _boat) >> "LIB_Deployment_Actions");  
  				{  
  				_boat spawn compile ("this = _this;" + (getText (configFile >> "CfgVehicles" >> (typeOf _boat) >> "UserActions" >> _x >> "statement")));    
  				} foreach _Deployment_Actions;  
 			};  
 			if ((count _cargoInf == 0) && (count _cargoVeh > 0)) then {  
				{  
  				_Deployment_Actions = getArray (configFile >> "CfgVehicles" >> (typeOf _boat) >> "LIB_Deployment_Actions");  
  				{  
  				_boat spawn compile ("this = _this;" + (getText (configFile >> "CfgVehicles" >> (typeOf _boat) >> "UserActions" >> _x >> "statement")));    
  				} foreach _Deployment_Actions;  
  				sleep 5;  
  				objNull setVehicleCargo _x;  
  				sleep 1;  
  				} forEach _cargoVeh;  
 			};
		 	sleep random [20,30,40];
			private _timer = 0;
			while {_timer < 180}	do {
				sleep 1;
				_timer = _timer + 1;
				_boat setVelocityModelSpace [0,-6, 0];
			};
		{
		deleteVehicle _x;
		} forEach units group (driver _boat);
		deleteVehicle _boat;		
		};
	};
};	
} forEach [_vehUS1,_vehUS2,_vehUS3,_vehUK1,_vehUK2];

waitUntil {sleep 1; (spawner getVariable "outpost_100" != 2)};

sleep 20;

[] spawn {
	sleep 20;
	 private _mortars = nearestObjects [(getMarkerPos "outpost_100"), ["LIB_GrWr34_g"], 500];
	 [(_mortars select 0), artyTarget_1, "LIB_8Rnd_81mmHE_GRWR34", 100, 12, 5] spawn BIS_fnc_fireSupport;
	 [(_mortars select 1), artyTarget_2, "LIB_8Rnd_81mmHE_GRWR34", 100, 12, 5] spawn BIS_fnc_fireSupport;
	 
	 sleep 100;
	 {
	  _x setVehicleAmmo 1;
	 } forEach _mortars;
};

private _taskId1 = "startCaptureOutpost";
[[teamPlayer,civilian],_taskId1,["Capture the outpost at the landing zones.","Capture Outpost","outpost_100"],(getMarkerPos "outpost_100"),false,0,true,"attack",true] call BIS_fnc_taskCreate;

private _taskId2 = "clearLandingZones";
[[teamPlayer,civilian],_taskId2,["Clear the landing zones of enemy troops.","Clear Landing Zones","introMissionMarker"],getMarkerPos "introMissionMarker",false,0,true,"attack",true] call BIS_fnc_taskCreate;

waitUntil {sleep 10; (sidesX getVariable ["outpost_100", sideUnknown] == teamPlayer) || (((getMarkerPos "introMissionMarker") nearEntities 200) findIf {side _x == Occupants && [_x] call A3A_fnc_canFight} == -1)};

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