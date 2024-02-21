//NOTA: TAMBIÉN LO USO PARA FIA
if (!isServer and hasInterface) exitWith{};

private ["_markerX","_groups","_soldiers","_positionX","_num","_dataX","_prestigeOPFOR","_prestigeBLUFOR","_esAAF","_params","_frontierX","_array","_countX","_groupX","_dog","_grp","_sideX","_squad","_mid","_vehiclesX","_ret"];
_markerX = _this select 0;

_groups = [];
_soldiers = [];
_vehiclesX = [];
_minesX = [];

_positionX = getMarkerPos (_markerX);

_num = 0;
_size = [_markerX] call A3A_fnc_sizeMarker;
_sideX = sidesX getVariable [_markerX,sideUnknown];
if ((markersX - controlsX) findIf {(getMarkerPos _x inArea _markerX) and (sidesX getVariable [_x,sideUnknown] != _sideX)} != -1) exitWith {};

diag_log format ["[Antistasi] Spawning City Patrol in %1 (createAICities.sqf)", _markerX];

_dataX = server getVariable _markerX;
_prestigeOPFOR = _dataX select 2;
_prestigeBLUFOR = _dataX select 3;
_esAAF = true;
_frontierX = [_markerX] call A3A_fnc_isFrontline;
if ((_markerX in destroyedSites) && _sideX != teamPlayer) then {
	_esAAF = false;
	_params = [_positionX,Occupants,NATOSpecOp];
	_squad = NATOSquad call SCRT_fnc_unit_selectInfantryTier;
	_mid = ([_sideX, "MID"] call SCRT_fnc_unit_getGroupSet) select 0;
	_num = 1;
} else {
	switch (_sideX) do {
		case Occupants: {
			if (_markerX in majorCitiesX) then {_num = 2};
			if (_markerX in townsX) then {_num = 1};
			if (_markerX in villagesX) then {_num = 0};
			if (aggressionLevelOccupants > 2) then {_num = _num + 1};
			_squad = NATOSquad call SCRT_fnc_unit_selectInfantryTier;
			_mid = ([_sideX, "MID"] call SCRT_fnc_unit_getGroupSet) select 0;
			if (_frontierX) then {
				_num = _num + 1;
				private _sentry = groupsNATOSentry call SCRT_fnc_unit_selectInfantryTier;
				_params = [_positionX, Occupants, _sentry];
			} else {
				_params = [_positionX, Occupants, [policeOfficer, policeGrunt]];
			};
		};
		case Invaders: {
			if (_markerX in majorCitiesX) then {_num = 2};
			if (_markerX in townsX) then {_num = 1};
			if (_markerX in villagesX) then {_num = 0};
			if (agressionInvaders > 2) then {_num = _num + 1};
			_squad = CSATSquad call SCRT_fnc_unit_selectInfantryTier;
			_mid = ([_sideX, "MID"] call SCRT_fnc_unit_getGroupSet) select 0;
			if (_frontierX) then {
				_num = _num + 1;
				private _sentry = groupsCSATSentry call SCRT_fnc_unit_selectInfantryTier;
				_params = [_positionX, Invaders, _sentry];
			} else {
				_params = [_positionX, Invaders, [policeOfficer, policeGrunt]];
			};
		};
		case teamPlayer: {
			_esAAF = false;
			_num = round (_num * (_prestigeBLUFOR/100));
			_array = groupsSDKSentry;
			_params = [_positionX, teamPlayer, _array];
		};
	};
};

if (_frontierX) then {
	_MGs = [_markerX] call A3A_fnc_cityMGPlacement;
	_groups pushBack (_MGs select 0);
	_vehiclesX append (_MGs select 1);
	_soldiers append (_MGs select 2);
	
	_mineNum = ceil ((random 4) * _num);
	_radius = 100 * (_num - 1);
	if (_radius < 100) then {_radius = 100};
	for "_i" from 1 to _mineNum do {
		_randomMinePos = [[[_positionX, _radius]], [], { isOnRoad _this }] call BIS_fnc_randomPos;
		_mineType = if (_sideX == Occupants) then {(A3A_faction_occ getVariable "minefieldAPERS") select 0} else {(A3A_faction_inv getVariable "minefieldAPERS") select 0};
		_mine = createMine [ _mineType ,_randomMinePos,[],0];
		_sideX revealMine _mine;
		_minesX pushBack _mine;
		[_mine] spawn {
			_mine = _this select 0;
			while {true} do {
				waitUntil {sleep 0.5; (_mine nearEntities [["Man","Car"], 15] findIf {side _x == civilian} != -1)};
				_mine enableSimulationGlobal false;
				waitUntil {sleep 0.5; (_mine nearEntities [["Man","Car"], 15] findIf {side _x == civilian} == -1)};
				_mine enableSimulationGlobal true;
			};
		};			
	};
};

_ret = [_markerX,_size,_sideX,_frontierX] call A3A_fnc_milBuildings;

if ((_ret select 0) isEqualType []) then {_groups append (_ret select 0)};
_vehiclesX append (_ret select 1);
_soldiers append (_ret select 2);
{ [_x, _sideX] call A3A_fnc_AIVEHinit } forEach _vehiclesX;

_countX = 0;
if (_num < 1) then {_num = 1};
_num = round _num;
while {(spawner getVariable _markerX != 2) and (_countX < _num)} do
	{
	_groupX = _params call A3A_fnc_spawnGroup;
	sleep 1;
	if (_esAAF) then
		{
		if (random 10 < 2.5) then
			{
			_dog = [_groupX, "Fin_random_F",_positionX,[],0,"FORM"] call A3A_fnc_createUnit;
			[_dog] spawn A3A_fnc_guardDog;
			};
		};
	{_x allowDamage false} forEach units _groupX;
	_nul = [leader _groupX, _markerX, "SAFE", "RANDOM", "SPAWNED","NOVEH2", "NOFOLLOW"] execVM "scripts\UPSMON.sqf";//TODO need delete UPSMON link
	_groups pushBack _groupX;
	_groupY = [_positionX, _sideX, _squad] call A3A_fnc_spawnGroup;
	{_x allowDamage false} forEach units _groupY;
	_nul = [leader _groupY, _markerX, "SAFE", "RANDOM", "SPAWNED","NOVEH2", "NOFOLLOW"] execVM "scripts\UPSMON.sqf";//TODO need delete UPSMON link
	_groups pushBack _groupY;
	_groupZ = [_positionX, _sideX, _mid] call A3A_fnc_spawnGroup;
	{_x allowDamage false} forEach units _groupZ;
	[_groupZ, _positionX, 200, 3, 0, 0.5] call A3A_fnc_cityGarrison;
	_groups pushBack _groupZ;
	_countX = _countX + 1;
	};
if ((_esAAF) or (_markerX in destroyedSites)) then
	{
	{_grp = _x;
	// Forced non-spawner for performance and consistency with other garrison patrols
	{[_x,_markerX] call A3A_fnc_NATOinit; _soldiers pushBack _x} forEach units _grp;} forEach _groups;
	}
else
	{
	{_grp = _x;
	{[_x] spawn A3A_fnc_FIAinitBases; _soldiers pushBack _x} forEach units _grp;} forEach _groups;
	};

sleep 2;

{_grp = _x;
{_x allowDamage true} forEach units _grp;} forEach _groups;

{ _x setVariable ["originalPos", getPos _x] } forEach _vehiclesX;

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

if (_markerX in majorCitiesX) then {[_markerX] spawn A3A_fnc_partizanAttack};

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

waitUntil {sleep 1;	(spawner getVariable _markerX == 2)};

{if (alive _x and !(_x getVariable ["captured", false])) then {deleteVehicle _x}} forEach _soldiers;
{deleteGroup _x} forEach _groups;

{
	// delete all vehicles that haven't been stolen
	if (_x getVariable ["ownerSide", _sideX] == _sideX) then {
		if (_x distance2d (_x getVariable "originalPos") < 100) then { deleteVehicle _x }
		else { if !(_x isKindOf "StaticWeapon") then { [_x] spawn A3A_fnc_VEHdespawner } };
	};
} forEach _vehiclesX;

{
deleteVehicle _x;	
} forEach _minesX;
