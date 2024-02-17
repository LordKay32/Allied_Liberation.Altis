if (!isServer and hasInterface) exitWith{};

private ["_markerX","_vehiclesX","_groups","_soldiers","_positionX","_staticsX","_garrison", "_index", "_USindex", "_UKindex", "_prestigeBLUFOR"];

_markerX = _this select 0;

_vehiclesX = [];
_groups = [];
_soldiers = [];
_civs = [];
_positionX = getMarkerPos (_markerX);
_prestigeBLUFOR = 0;

if (_markerX in citiesX) then {
	_dataX = server getVariable _markerX;
	_prestigeBLUFOR = _dataX select 3;
};

if (_markerX != "Synd_HQ") then
{
	if (!(_markerX in citiesX)) then
	{
		private _veh = createVehicle [SDKFlag, _positionX, [],0, "NONE"];
		_veh allowDamage false;
		_vehiclesX pushBack _veh;

		if (_markerX in milbases) then
		{
			[_veh,"SDKFlag"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_veh];
		};
		if (_markerX in seaports) then
		{
			[_veh,"seaport"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_veh];
		};
		if (_markerX in (airportsX - ["airport_3"])) then
		{
			[_veh,"airbase"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_veh];
		};
		if (_markerX == "airport_3") then
		{
			[_veh,"airbase3"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_veh];
		};
		if (_markerX in outposts) then
		{
			[_veh,"outpost"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_veh];
		};
		_veh = createVehicle [SDKFlag2, _positionX, [],1, "NONE"];
		_veh allowDamage false;
		_vehiclesX pushBack _veh;
		if (_markerX in airportsX + milbases) then {[_veh,"SDKFlag2"] remoteExec ["A3A_fnc_flagaction",0,_veh]};
		if (_markerX in seaports + outposts) then {[_veh,"SDKFlag2OP"] remoteExec ["A3A_fnc_flagaction",0,_veh]};
	} else {
		//if (_markerX in [?cities, villages?]) then {
		private _SDKpos = [];
		private _dir = 0;
		if ((_prestigeBLUFOR > 50) && (_markerX in (majorCitiesX + townsX))) then {
			if (_markerX in ["Kavala","Charkia","Sofia","Panochori","Athira","Telos","Zaros","Pyrgos","AgiosDionysios","Neochori","Paros"]) then {
				_church = nearestObjects [_positionX, ["Land_Church_04_white_red_F","Land_Church_04_white_F","Land_Church_04_yellow_F"], 400]; 
				_dir = getDir (_church select 0);
				_SDKpos = (_church select 0) getRelPos [10, 0];
			} else {
				_church = nearestTerrainObjects [_positionX, ["CHURCH"], 400];	
				_dir = (getDir (_church select 0)) + 270;
				_SDKpos = (_church select 0) getRelPos [8, 270]};
			_groupA = [_SDKpos, teamPlayer, groupSDKLeaders] call A3A_fnc_spawnGroup;
			_groupA selectLeader ((units _groupA) select 2);
			_SDKLeader = leader _groupA;
			_groupA setBehaviour "SAFE";
			[_SDKLeader,"SDKRecruit"] remoteExec ["A3A_fnc_flagaction",0,_SDKLeader];
			sleep 0.5;
			_groupA setFormDir _dir;
			{
				[_x,_markerX] call A3A_fnc_FIAinitBases;
				_soldiers pushBack _x;
				_x setDir _dir;
			} forEach units _groupA;
			_groupB = [_positionX, teamPlayer, groupsSDKSquad] call A3A_fnc_spawnGroup;
			//_nul = [leader _groupB, _markerX, "SAFE","SPAWNED","NOVEH2","NOFOLLOW"] execVM "scripts\UPSMON.sqf";
			{
				[_x,_markerX] call A3A_fnc_FIAinitBases;
				_soldiers pushBack _x;
			} forEach units _groupB;
			[_groupB, _positionX, 200, 3, 1, false] call A3A_fnc_cityGarrison;
		};
		if ((_prestigeBLUFOR > 50) && (_markerX in majorCitiesX)) then {
			_pos = _positionX findEmptyPosition [10,100];
			_groupC = [_pos, teamPlayer, groupsSDKSquad] call A3A_fnc_spawnGroup;
			//_nul = [leader _groupC, _markerX, "SAFE","SPAWNED","RANDOMUP","NOVEH2","NOFOLLOW"] execVM "scripts\UPSMON.sqf";
			{
				[_x,_markerX] call A3A_fnc_FIAinitBases;
				_soldiers pushBack _x;
			} forEach units _groupC;
			[_groupC, _positionX, 200, 3, 1, false] call A3A_fnc_cityGarrison;
		};
	};
	if ((_markerX in resourcesX) or (_markerX in factories)) then
	{
		if (not(_markerX in destroyedSites)) then
		{
			if ((daytime > 8) and (daytime < 18)) then
			{
				private _groupCiv = createGroup civilian;
				_groups pushBack _groupCiv;
				for "_i" from 1 to 4 do
				{
					if (spawner getVariable _markerX != 2) then
					{
						private _civ = [_groupCiv, "C_man_w_worker_F", _positionX, [],0, "NONE"] call A3A_fnc_createUnit;
						_nul = _civ spawn A3A_fnc_CIVinit;
						_civs pushBack _civ;
						_civ setVariable ["markerX",_markerX,true];
						sleep 0.5;
						_civ addEventHandler ["Killed",
						{
							if (({alive _x} count units group (_this select 0)) == 0) then
							{
								private _markerX = (_this select 0) getVariable "markerX";
								private _nameX = [_markerX] call A3A_fnc_localizar;
								destroyedSites pushBackUnique _markerX;
								publicVariable "destroyedSites";
								["TaskFailed", ["", format ["%1 Destroyed",_nameX]]] remoteExec ["BIS_fnc_showNotification",[teamPlayer,civilian]];
							};
						}];
					};
				};
				//_nul = [_markerX,_civs] spawn destroyCheck;
				_nul = [leader _groupCiv, _markerX, "SAFE", "SPAWNED","NOFOLLOW", "NOSHARE","DORELAX","NOVEH2"] execVM "scripts\UPSMON.sqf";//TODO need delete UPSMON link
			};
		};
	};
};

private _size = [_markerX] call A3A_fnc_sizeMarker;
_staticsX = staticsToSave select {_x distance2D _positionX < _size};

_garrison = [];
_garrison = _garrison + (garrison getVariable [_markerX,[]]);

// Don't create these unless required
private _groupStatics = grpNull;
private _groupSDKStatics = grpNull;

// Move riflemen into saved static weapons in area
{
	if !(isNil {_x getVariable "lockedForAI"}) then { continue };
	if ((_markerX in citiesX) && (typeOf _x in NATOMG) && (_prestigeBLUFOR > 50)) then {
		if (isNull _groupSDKStatics) then { _groupSDKStatics = createGroup teamPlayer };
		_unit = [_groupSDKStatics, SDKMil, _positionX, [], 0, "NONE"] call A3A_fnc_createUnit;
		_unit moveInGunner _x;
	};
	_USindex = _garrison findIf {_x == USMil};
	_UKindex = _garrison findIf {_x == UKMil};
	if ((_USindex == -1) && (_UKindex == -1)) exitWith {};
	private _unit = objNull;
	
	if (typeOf _x in [USMGStatic, UKMGStatic, staticATteamPlayer, staticAAteamPlayer]) then {
		if (isNull _groupStatics) then { _groupStatics = createGroup teamPlayer };
		if (typeOf _x in (NATOMG + staticAAOccupants + [USMGStatic, staticATOccupants])) then {_index = if (_USindex == -1) then {_UKindex} else {_USindex}};
		if (typeOf _x in [UKMGStatic, staticATteamPlayer, staticAAteamPlayer]) then {_index = if (_UKindex == -1) then {_USindex} else {_UKindex}};
		_unit = [_groupStatics, (_garrison select _index), _positionX, [], 0, "NONE"] call A3A_fnc_createUnit;
		_unit moveInGunner _x;
		_garrison deleteAT _index;
	};
	[_unit,_markerX] call A3A_fnc_FIAinitBases;
	_soldiers pushBack _unit;
	
	if (typeOf _x in [staticATteamPlayer, staticAAteamPlayer, staticATOccupants]) then {
		_USindex = _garrison findIf {_x == USMil};
		_UKindex = _garrison findIf {_x == UKMil};
		if ((_USindex == -1) && (_UKindex == -1)) exitWith {};
		_index = if (_UKindex == -1) then {_USindex} else {_UKindex};
		_unit = [_groupStatics, (_garrison select _index), _positionX, [], 0, "NONE"] call A3A_fnc_createUnit;
		_unit moveInAny _x;
		_garrison deleteAT _index;
		[_unit,_markerX] call A3A_fnc_FIAinitBases;
		_soldiers pushBack _unit;
	};
} forEach _staticsX;


// Make 8-man groups out of the remainder of the garrison
private _USgarrison = [];
private _UKgarrison = [];

{
if (_x in USTroops) then {_USgarrison pushBack _x};
if (_x in UKTroops) then {_UKgarrison pushBack _x};
} forEach _garrison;

_garrison = _USgarrison call A3A_fnc_garrisonReorg;

private _totalUnits = count _garrison;
private _countUnits = 0;
private _countGroup = 8;
private _groupX = grpNull;

while {(spawner getVariable _markerX != 2) and (_countUnits < _totalUnits)} do
{
	if (_countGroup == 8) then
	{
		_groupX = createGroup teamPlayer;
		_groups pushBack _groupX;
		_countGroup = 0;
	};
	private _typeX = _garrison select _countUnits;
	private _unit = [_groupX, _typeX, _positionX, [], 0, "NONE"] call A3A_fnc_createUnit;
	if (_typeX == SDKSL) then {_groupX selectLeader _unit};
	[_unit,_markerX] call A3A_fnc_FIAinitBases;
	_soldiers pushBack _unit;
	_countUnits = _countUnits + 1;
	_countGroup = _countGroup + 1;
	sleep 0.5;
};

_garrison = _UKgarrison call A3A_fnc_garrisonReorg;

private _totalUnits = count _garrison;
private _countUnits = 0;
private _countGroup = 8;
private _groupX = grpNull;

while {(spawner getVariable _markerX != 2) and (_countUnits < _totalUnits)} do
{
	if (_countGroup == 8) then
	{
		_groupX = createGroup teamPlayer;
		_groups pushBack _groupX;
		_countGroup = 0;
	};
	private _typeX = _garrison select _countUnits;
	private _unit = [_groupX, _typeX, _positionX, [], 0, "NONE"] call A3A_fnc_createUnit;
	if (_typeX == SDKSL) then {_groupX selectLeader _unit};
	[_unit,_markerX] call A3A_fnc_FIAinitBases;
	_soldiers pushBack _unit;
	_countUnits = _countUnits + 1;
	_countGroup = _countGroup + 1;
	sleep 0.5;
};

for "_i" from 0 to (count _groups) - 1 do
{
	_groupX = _groups select _i;
	if (_i == 0) then
	{
		//_nul = [leader _groupX, _markerX, "SAFE","SPAWNED","RANDOMUP","NOVEH2","NOFOLLOW"] execVM "scripts\UPSMON.sqf";//TODO need delete UPSMON link
		[_groupX, _positionX, _size, 3, 0, false] call A3A_fnc_cityGarrison;
	}
	else
	{
		//_nul = [leader _groupX, _markerX, "SAFE","SPAWNED","RANDOM","NOVEH2","NOFOLLOW"] execVM "scripts\UPSMON.sqf";//TODO need delete UPSMON link
		[_groupX, _positionX, _size, 3, 1, false] call A3A_fnc_cityGarrison;
	};
};
waitUntil {sleep 1; (spawner getVariable _markerX == 2)};

{ if (alive _x) then { deleteVehicle _x }; } forEach _soldiers;
{deleteVehicle _x} forEach _civs;

{deleteGroup _x} forEach _groups;
deleteGroup _groupStatics;
deleteGroup _groupSDKStatics;

{if (!(_x in staticsToSave)) then {deleteVehicle _x}} forEach _vehiclesX;
