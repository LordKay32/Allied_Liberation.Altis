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
		if (_markerX in (outposts + resourcesX + factories)) then
		{
			[_veh,"outpost"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_veh];
		};
		_veh = createVehicle [SDKFlag2, _positionX, [],1, "NONE"];
		_veh allowDamage false;
		_vehiclesX pushBack _veh;
		if (_markerX in airportsX + milbases) then {[_veh,"SDKFlag2"] remoteExec ["A3A_fnc_flagaction",0,_veh]};
		if (_markerX in seaports + outposts + resourcesX + factories) then {[_veh,"SDKFlag2OP"] remoteExec ["A3A_fnc_flagaction",0,_veh]};
	} else {
		if (!(_markerX in destroyedSites)) then {[_markerX] spawn A3A_fnc_spawnPartizans};
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
	
	if (typeOf _x in ([USMGStatic, M2MGStatic, UKMGStatic, staticATteamPlayer, staticAAteamPlayer, staticATOccupants] + NATOMG + staticAAOccupants)) then {
		if (isNull _groupStatics) then { _groupStatics = createGroup teamPlayer };
		if (typeOf _x in (NATOMG + staticAAOccupants + [USMGStatic, M2MGStatic, staticATOccupants])) then {_index = if (_USindex == -1) then {_UKindex} else {_USindex}};
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



if (_markerX in citiesX) then {
	while {(spawner getVariable _markerX != 2)} do {

		private _markerSide = sidesX getVariable [_markerX, sideUnknown];
		switch (true) do
		{
		    case (_markerSide != teamPlayer):
		    {
				private _fnc_sidePower = {
			    params ["_positionX", "_sideX", "_size"];
				private _infArray = (_positionX nearEntities [["Man"], _size]) select {[_x] call A3A_fnc_canFight};
				private _inf = _sideX countSide _infArray;
				private _statics = _sideX countSide (_positionX nearEntities [["staticWeapon"], _size]);
				private _APCs = _sideX countSide (_positionX nearEntities [["Car"], _size]);
				private _tanks = _sideX countSide (_positionX nearEntities [["Tank"], _size]);
				private _sidePower = _inf + (_statics * 2) + (_APCs * 5) + (_tanks * 10); 
				_sidePower
				};

				waitUntil {sleep 1;	(spawner getVariable _markerX == 2) or (([_positionX,_sideX,_size] call _fnc_sidePower)/(([_positionX,teamPlayer,_size] call _fnc_sidePower) + ([_positionX,_sideX,_size] call _fnc_sidePower))) < 0.2};

				if ((([_positionX,_sideX,_size] call _fnc_sidePower)/(([_positionX,teamPlayer,_size] call _fnc_sidePower) + ([_positionX,_sideX,_size] call _fnc_sidePower))) < 0.2) then {
					if (_markerX in destroyedSites) then {
						["TaskSucceeded", ["", format ["%1 ruins captured",[_markerX, false] call A3A_fnc_location,nameTeamPlayer]]] remoteExec ["BIS_fnc_showNotification",teamPlayer];
					} else {
						["TaskSucceeded", ["", format ["%1 captured",[_markerX, false] call A3A_fnc_location,nameTeamPlayer]]] remoteExec ["BIS_fnc_showNotification",teamPlayer];
						[-100,25, _markerX] remoteExec ["A3A_fnc_citySupportChange",2];
					};
					sidesX setVariable [_markerX,teamPlayer,true];
					aggressionOccupants = aggressionOccupants - 5;
					_mrkD = format ["Dum%1",_markerX];
					_mrkD setMarkerColor colorTeamPlayer;
					sleep 5;
					garrison setVariable [_markerX,[],true];
					sleep 5;
					{_nul = [_markerX,_x] spawn A3A_fnc_deleteControls} forEach controlsX;
					
					private _remainers = _soldiers select {[_x] call A3A_fnc_canFight};
					{
					if (random 100 > 50) then {[_x] spawn A3A_fnc_surrenderAction} else {[_x, _sideX, false] remoteExec ["A3A_fnc_fleeToSide", _x]};
					} forEach _remainers;
				
					sectorsLiberated = sectorsLiberated + 1;
					publicVariable "sectorsLiberated";
		
					if ((airportsX + milbases + outposts + seaports + factories + resourcesX + citiesX) findIf {sidesX getVariable [_x, sideUnknown] != teamPlayer} == -1) exitWith {
					[] remoteExec ["A3A_fnc_endGame",0];
					};
		
					_super = if (_markerX in majorCitiesX) then {true} else {false};
					[_markerX, _sideX, _super] spawn
					{
						params ["_marker", "_loser", "_super"];
						private _waitTime = (6 - aggressionOccupants/20) * (0.5 + random 0.5);
						sleep (_waitTime * 60);
						if(sidesX getVariable [_marker, sideUnknown] == _loser) exitWith {};
						[[_marker, _loser, _super], "A3A_fnc_singleAttack"] call A3A_fnc_scheduler;
					};
				};

			};
	
		    case (_markerSide == teamPlayer):
		    {
				waitUntil {sleep 1; ((sidesX getVariable [_markerX, sideUnknown] != teamPlayer) || (spawner getVariable _markerX == 2))};
			};
		};
		sleep 60;
	};
};



waitUntil {sleep 1; (spawner getVariable _markerX == 2)};

{ if (alive _x) then { deleteVehicle _x }; } forEach _soldiers;
{deleteVehicle _x} forEach _civs;

{deleteGroup _x} forEach _groups;
deleteGroup _groupStatics;
deleteGroup _groupSDKStatics;

{if (!(_x in staticsToSave)) then {deleteVehicle _x}} forEach _vehiclesX;
