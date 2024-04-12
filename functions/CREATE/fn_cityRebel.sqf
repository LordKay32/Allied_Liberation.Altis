/*
 * Name:	fn_cityRebel
 * Date:	24/05/2023
 * Version: 1.0
 * Author:  JB
 *
 * Description:
 * City rebels
 *
 * Parameter(s):
 * _PARAM1 (TYPE): DESCRIPTION.
 * _PARAM2 (TYPE): DESCRIPTION.
 *
 * Returns:
 * %RETURNS%
 */

private ["_markerX", "_groups", "_partizans", "_civilians", "_exit"];

_markerX = _this select 0;
if (sidesX getVariable [_markerX, sideUnknown] == teamPlayer) exitWith {};
if (_markerX in destroyedSites) exitWith {rebelCity = "NONE"; publicVariable "rebelCity"};
rebelCity = _markerX;
publicVariable "rebelCity";

_groups = [];
_partizans = [];
_civilians = [];
_exit = false;

_positionX = getMarkerPos (_markerX);

_size = [_markerX] call A3A_fnc_sizeMarker;
_sideX = sidesX getVariable [_markerX,sideUnknown];
private _nameDestination = [_markerX] call A3A_fnc_localizar;

_timeLimit = 60 * settingsTimeMultiplier;	
_dateLimit = [date select 0, date select 1, date select 2, date select 3, (date select 4) + _timeLimit];
_dateLimitNum = dateToNumber _dateLimit;

private _taskId = "invaderPunish" + str A3A_taskCount;
[[teamPlayer,civilian],_taskId,[format ["As the frontline approaches their town, the brave citizens of %1 have risen up against the %2! Partizan units have moved in to help the civilians, but the %2 are also sending reinforcements. If we don't assist the uprising it will likely be crushed and the %2 will exact a terrible revenge and destroy the town and execute everyone in it.",_nameDestination,nameOccupants],format ["%1 Uprising",_nameDestination],_markerX],getMarkerPos _markerX,false,0,true,"Defend",true] call BIS_fnc_taskCreate;
[_taskId, "invaderPunish", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];

_barricades = [];

for "_i" from 1 to 4 do {
	_randomRoadPos = [[[_positionX, 200]], [], { isOnRoad _this }] call BIS_fnc_randomPos;
	_nearestRoad = [_randomRoadPos, 20] call BIS_fnc_nearestRoad;
	_roadscon = roadsConnectedto _nearestRoad;
	_roadDir = [_nearestRoad, _roadscon select 0] call BIS_fnc_DirTo;
	_barricade = createVehicle ["Land_Barricade_01_10m_F", _randomRoadPos, [], 0, "CAN_COLLIDE"];
	_barricade setDir _roadDir;
	_barricades pushBack _barricade;

	_fire = createVehicle ["test_EmptyObjectForFireBig",getPos _barricade, [], 0 , "CAN_COLLIDE"];
	_barricades pushBack _fire;

	_fireSound = createSoundSource ["Sound_Fire", getPos _fire, [], 0];
	_barricades pushBack _fireSound;
};

private _fnc_adjustNearCities = {
    params ["_position", "_maxSupport", "_maxDist"];
    {
        private _dist = getMarkerPos _x distance2d _position;
        if (_dist > _maxDist) then { continue };
        private _suppChange = linearConversion [0, _maxDist, _dist, _maxSupport, 0, true];
        [0,_suppChange,_x,false] spawn A3A_fnc_citySupportChange;		// don't scale this by pop
    } forEach citiesX;
};

waitUntil {sleep 1;	(spawner getVariable _markerX != 2) || (dateToNumber date > _dateLimitNum)};

if (spawner getVariable _markerX != 2) then {
	sleep 30;
	for "_i" from 1 to 8 do {
	    private _groupCivil = createGroup teamPlayer;
	    _groups pushBack _groupCivil;
	    private _pos = while {true} do {
	        private _pos = _positionX getPos [random _size / 3,random 360];
	        if (!surfaceIsWater _pos) exitWith { _pos };
	    };
	    for "_i" from 1 to  4 do
	    {
	        private _civ = [_groupCivil, SDKUnarmed, _pos, [], 0, "NONE"] call A3A_fnc_createUnit;
	        _civ forceAddUniform selectRandom ((A3A_faction_civ getVariable "uniforms") - ["U_LIB_CIV_Priest"]);
	        _civ addHeadgear selectRandom (A3A_faction_civ getVariable "headgear");
	        [_civ, "NoVoice"] remoteExec ["setSpeaker", 0, _civ];
	        _civ addEventHandler ["Killed", {
				params ["_unit", "_killer", "_instigator", "_useEffects"];
				if (side (group _killer) == Occupants) then {
					civilianKilledByOccupant = civilianKilledByOccupant + 1;
					publicVariable "civilianKilledByOccupant";
				};
				if (side (group _killer) == teamPlayer) then {
					civilianKilledByteamPlayer = civilianKilledByteamPlayer + 1;
					publicVariable "civilianKilledByteamPlayer";
				};
			}];

				_SDKWeapon = "";
				_SDKMagazine = "";
				_SDKRounds = 0;

			_randomNumber = random 100;
			if (_randomNumber < 20) then {
				_SDKWeapon = "LIB_Webley_mk6";
				_SDKMagazine = "LIB_6Rnd_455";
				_SDKRounds = 5;
			};
			if ((_randomNumber >= 20) &&(_randomNumber < 40)) then {
				_SDKWeapon = "sgun_HunterShotgun_01_F";
				_SDKMagazine = "2Rnd_12Gauge_Pellets";
				_SDKRounds = 3;
			};
			if ((_randomNumber >= 40) &&(_randomNumber < 60)) then {
				_SDKWeapon = "LIB_Sten_Mk2";
				_SDKMagazine = "LIB_32Rnd_9x19_Sten";
				_SDKRounds = 3;
			};
			if ((_randomNumber >= 60) &&(_randomNumber < 80)) then {
				_SDKWeapon = "LIB_K98";
				_SDKMagazine = "LIB_5Rnd_792x57";
				_SDKRounds = 6;
			};
			if ((_randomNumber >= 80) &&(_randomNumber < 100)) then {
				_SDKWeapon = "LIB_MP40";
				_SDKMagazine = "LIB_32Rnd_9x19";
				_SDKRounds = 3;
			};
		
			_civ addMagazine _SDKMagazine;
			_civ addWeapon _SDKWeapon;
			for "_i" from 1 to _SDKRounds do
				{
				_civ addItemToUniform _SDKMagazine;
				};
	        _civ setSkill 0.33;
	        [_civ] spawn {
	        	params ["_civ"];
	        	_civ allowDamage false;
	        	sleep 30;
	        	_civ allowDamage true;
	        };
	        _civilians pushBack _civ;
	    };
    
	    if (_i % 2 == 0) then {[leader _groupCivil, _markerX, "COMBAT","SPAWNED","NOVEH2"] execVM "scripts\UPSMON.sqf"} else {[_groupCivil, _positionX, 200, 3, 0, 0.5] call A3A_fnc_cityGarrison;};//TODO need delete UPSMON link
	};

	_pos1 = [_positionX, 400, 500, 3, 0, 0, 0] call BIS_fnc_findSafePos;
	_pos2 = [_pos1, 75, 150, 3, 0, 0, 0] call BIS_fnc_findSafePos;

	_groupPart1 = [_pos1,teamPlayer, groupsSDKSquad] call A3A_fnc_spawnGroup;
	{[_x] call A3A_fnc_FIAInit;
	} forEach units _groupPart1;
	_wp1 = _groupPart1 addWaypoint [_positionX, 0];
	_wp1 setWaypointType "SAD";
	_groups pushBack _groupPart1;

	_groupPart2 = [_pos2,teamPlayer, groupsSDKSquad] call A3A_fnc_spawnGroup;
	{[_x] call A3A_fnc_FIAInit;
	} forEach units _groupPart2;
	_wp2 = _groupPart2 addWaypoint [_positionX, 0];
	_wp2 setWaypointType "SAD";
	_groups pushBack _groupPart2;
	
	sleep 10;
	
	_vehs = nearestObjects [_positionX, (vehNATOLightArmed + ["LIB_CIV_FFI_CitC4"]), _size, true];
	{
		_x setDamage 1;
		sleep ((random 3) + 2);
	} forEach _vehs;

	[_markerX] spawn {
		params ["_markerX"];
		sleep ((random 600) + 300);
		[Occupants, 0, "QRF", getMarkerPos _markerX, 0, 0] spawn A3A_fnc_createSupport;
	};
} else {

    [_taskId, "invaderPunish", "FAILED"] call A3A_fnc_taskSetState;
    [_positionX, -50, 3000] call _fnc_adjustNearCities;
	
	{
	deleteVehicle _x;
	} forEach _barricades;
	
    destroyedSites = destroyedSites + [_markerX];
    publicVariable "destroyedSites";
    rebelCity = "NONE";
    publicVariable "rebelCity";
    private _mineTypes = A3A_faction_occ getVariable "minefieldAPERS";
    for "_i" from 1 to 25 do {
        private _mineX = createMine [selectRandom _mineTypes,_positionX,[],_size/2];
        Occupants revealMine _mineX;
    };
    [_markerX] call A3A_fnc_destroyCity;
    // Putting this stuff here is a bit gross, but currently there's no cityFlip function. Usually done by resourceCheck.
    garrison setVariable [_markerX, [], true];
    [_markerX] call A3A_fnc_mrkUpdate;
    sleep 15;
	[_taskId, "invaderPunish", 0] spawn A3A_fnc_taskDelete;
    _exit = true;
};

if (_exit) exitWith {};

waitUntil {sleep 1;	(sidesX getVariable [_markerX, sideUnknown] == teamPlayer) or ({alive _x} count _civilians < count _civilians / 8)};

if (sidesX getVariable [_markerX, sideUnknown] == teamPlayer) then {
    [_taskId, "invaderPunish", "SUCCEEDED"] call A3A_fnc_taskSetState;
    [_positionX, 30, 3000] call _fnc_adjustNearCities;
    rebelCity = "NONE";
    publicVariable "rebelCity";

    {if (isPlayer _x) then {[100,_x] call A3A_fnc_playerScoreAdd}} forEach ([500,0,_positionX,teamPlayer] call A3A_fnc_distanceUnits);
    [0,1000,0] remoteExec ["A3A_fnc_resourcesFIA",2];
    server setVariable ["SDKhr", 10 + (server getVariable "SDKhr"), true];
    [] remoteExec ["A3A_fnc_statistics"];
} else {

    [_taskId, "invaderPunish", "FAILED"] call A3A_fnc_taskSetState;
    [_positionX, -50, 3000] call _fnc_adjustNearCities;

    destroyedSites = destroyedSites + [_markerX];
    publicVariable "destroyedSites";
    rebelCity = "NONE";
    publicVariable "rebelCity";
    private _mineTypes = A3A_faction_occ getVariable "minefieldAPERS";
    for "_i" from 1 to 25 do {
        private _mineX = createMine [selectRandom _mineTypes,_positionX,[],_size/2];
        Occupants revealMine _mineX;
    };
    [_markerX] call A3A_fnc_destroyCity;
    // Putting this stuff here is a bit gross, but currently there's no cityFlip function. Usually done by resourceCheck.
    garrison setVariable [_markerX, [], true];
    [_markerX] call A3A_fnc_mrkUpdate;
    private _SDKhr = server getVariable "SDKhr";
    _SDKhr = _SDKhr - 8;
    if (_SDKhr < 0) then {_SDKhr = 0};
	server setVariable ["SDKhr", _SDKhr, true];
    [] remoteExec ["A3A_fnc_statistics"];
};

sleep 15;
[_taskId, "invaderPunish", 0] spawn A3A_fnc_taskDelete;

waitUntil {sleep 1;	(spawner getVariable _markerX == 2)};

{
[_x] spawn A3A_fnc_groupDespawner;
} forEach _groups;

{
deleteVehicle _x;
} forEach _barricades;
