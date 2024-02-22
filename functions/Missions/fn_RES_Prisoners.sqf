//Mission: Rescue the prisoners

if (!isServer and hasInterface) exitWith{};

private ["_unit","_markerX","_positionX","_countX"];

private _side = if (gameMode == 4) then {Invaders} else {Occupants};

_markerX = _this select 0;

switch(true) do {
	case (_markerX in citiesX): {

	private _difficultX =if (aggressionLevelOccupants > 3) then {true} else {false};
	_leave = false;
	_contactX = objNull;
	_groupContact = grpNull;
	_tsk = "";
	_positionX = getMarkerPos _markerX;
	
	_POWs = [];
	_groups = [];
	
	_timeLimit = if (_difficultX) then {90 * settingsTimeMultiplier} else {120 * settingsTimeMultiplier};
	
	_dateLimit = [date select 0, date select 1, date select 2, date select 3, (date select 4) + _timeLimit];
	
	_dateLimitNum = dateToNumber _dateLimit;
	_dateLimit = numberToDate [date select 0, _dateLimitNum];//converts datenumber back to date array so that time formats correctly
	_displayTime = [_dateLimit] call A3A_fnc_dateToTimeString;//Converts the time portion of the date array to a string for clarity in hints
	
	_nameDest = [_markerX] call A3A_fnc_localizar;
	
	private _taskId = "RES" + str A3A_taskCount;
	[[teamPlayer,civilian],_taskId,[format ["The Werhmacht have rounded up some partizans and civilians for execution in %1. Rescue them and bring them back to an Allied controlled town.<br/><br/>Reward: 100CP per player per rescued civilian.",_nameDest],"Partizan POW Rescue",_markerX],_positionX,false,0,true,"run",true] call BIS_fnc_taskCreate;
	[_taskId, "RES", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];
	
	_officerClass = if (_side == Occupants) then {NATOOfficer} else {CSATOfficer};
	
	private _allPositions = [];
	private _potPos = [];
	
	for "i" from 1 to 5 do {
		_potPos = [_positionX, 1, 150, 12, 0, 0, 0] call BIS_fnc_findSafePos;
		_allPositions pushBack _potPos;
	};
	
	{
	if ((isOnRoad _x) || count _x == 3) then {_allPositions = _allPositions - [_x]};
	} forEach _allPositions;
	
	if (count _allPositions == 0) then {
		for "i" from 1 to 5 do {
			_potPos = [_positionX, 1, 250, 10, 0, 0, 0] call BIS_fnc_findSafePos;
			_allPositions pushBack _potPos;
		};
		{
		if ((isOnRoad _x) || count _x == 3) then {_allPositions = _allPositions - [_x]};
		} forEach _allPositions;
	};
	
	private _chosenPos = selectRandom _allPositions;
	private _POWposition = _chosenPos getPos [4,180];
	private _soldierPos = _chosenPos getPos [4,0];
	private _countX = round random [6,9,12];
	
	_grpPOW = createGroup teamPlayer;
	for "_i" from 0 to _countX do
		{
		_unit = [_grpPOW, SDKUnarmed, _POWposition, [], 0, "NONE"] call A3A_fnc_createUnit;
		_uniform = selectRandom [selectRandom ["U_GELIB_FRA_MGunner_gvnpFF13","U_GELIB_FRA_MGunner_gvmpFF14","U_GELIB_FRA_SoldierFF_gvmpFF15","U_GELIB_FRA_SoldierFF_gvmpFF16"], selectRandom (A3A_faction_civ getVariable "uniforms")];
		_unit forceAddUniform _uniform;
		_unit allowDamage false;
		_unit setCaptive true;
		_unit disableAI "MOVE";
		_unit disableAI "AUTOTARGET";
		_unit disableAI "TARGET";
		_unit setUnitPos "UP";
		_unit setBehaviour "CARELESS";
		_unit allowFleeing 0;
		//_unit disableAI "ANIM";
		removeAllWeapons _unit;
		removeAllAssignedItems _unit;
		sleep 1;
		//if (alive _unit) then {_unit playMove "UnaErcPoslechVelitele1";};
		_POWS pushBack _unit;
		[_unit,"prisonerX"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_unit];
	};
	
	for "_i" from 1 to 2 do {
		private _officerGroup = createGroup _side;
		private _officer = [_officerGroup, _officerClass, _soldierPos, [], 0, "NONE"] call A3A_fnc_createUnit;
		[_officer] call A3A_fnc_NATOinit;
		_officer setUnitPos "UP";
		_officer doWatch selectRandom _POWS;
	
		_groups pushBack _officerGroup;
	};
	
	sleep 5;
	
	{_x allowDamage true} forEach _POWS;
	
	_mrk = createMarkerLocal [format ["%1patrolarea", floor random 100], _chosenPos];
	_mrk setMarkerShapeLocal "RECTANGLE";
	_mrk setMarkerSizeLocal [75,75];
	_mrk setMarkerTypeLocal "hd_warning";
	_mrk setMarkerColorLocal "ColorRed";
	_mrk setMarkerBrushLocal "DiagGrid";
	_mrk setMarkerAlphaLocal 0;
	
	private _squad = if (_side == Invaders) then {CSATSquad} else {NATOSquad};
	_typeGroup = _squad call SCRT_fnc_unit_selectInfantryTier;
	
	_groupX = [_positionX,_side, _typeGroup] call A3A_fnc_spawnGroup;
	_nul = [leader _groupX, _mrk, "SAFE","SPAWNED", "NOVEH2", "NOFOLLOW"] execVM "scripts\UPSMON.sqf";
	{[_x,""] call A3A_fnc_NATOinit} forEach units _groupX;
	_groups pushBack _groupX;
	
	waitUntil {sleep 1; ({alive _x} count _POWs == 0) or ({(alive _x) and (_x distance getMarkerPos ([(citiesX select {(sidesX getVariable [_x,sideUnknown] == teamPlayer)}),_x] call BIS_fnc_nearestPosition) < 100)} count _POWs > 0) or (dateToNumber date > _dateLimitNum)};
	
	if (dateToNumber date > _dateLimitNum) then
		{
		if (spawner getVariable _markerX == 2) then
			{
			{
			if (group _x == _grpPOW) then
				{
				_x setCaptive false;
				};
			} forEach _POWS;
			}
		else
			{
			{
			if (group _x == _grpPOW) then
				{
				_x setCaptive false;
				_x enableAI "MOVE";
				_x doMove _positionX;
				};
			} forEach _POWS;
			};
		};
	
	waitUntil {sleep 1; ({alive _x} count _POWs == 0) or ({(alive _x) and (_x distance getMarkerPos ([(citiesX select {(sidesX getVariable [_x,sideUnknown] == teamPlayer)}),_x] call BIS_fnc_nearestPosition) < 100)} count _POWs > 0)};
	
	_bonus = if (_difficultX) then {2} else {1};
		
	if ({alive _x} count _POWs == 0) then
		{
		[_taskId, "RES", "FAILED"] call A3A_fnc_taskSetState;
		{[_x,false] remoteExec ["setCaptive",0,_x]; _x setCaptive false} forEach _POWs;
		[-20,theBoss] call A3A_fnc_playerScoreAdd;
		[0,-10,_positionX] remoteExec ["A3A_fnc_citySupportChange",2];
		}
		else
		{
		sleep 5;
		[_taskId, "RES", "SUCCEEDED"] call A3A_fnc_taskSetState;
		_countX = {(alive _x) and (_x distance getMarkerPos ([(citiesX select {(sidesX getVariable [_x,sideUnknown] == teamPlayer)}),_x] call BIS_fnc_nearestPosition) < 100)} count _POWs;
		_hr = _countX;
		_resourcesFIA = 200 * _countX;
		[_hr,_resourcesFIA,SDKUnarmed] remoteExec ["A3A_fnc_resourcesFIA",2];
		[0,2*_countX,_positionX] remoteExec ["A3A_fnc_citySupportChange",2];
		{ [_countX*20, _x] call A3A_fnc_playerScoreAdd } forEach (call BIS_fnc_listPlayers) select { side _x == teamPlayer || side _x == civilian};
		[round (_countX*10),theBoss] call A3A_fnc_playerScoreAdd;
		{[_x] join _grpPOW; [_x] orderGetin false} forEach _POWs;
		};
	
	sleep 60;
	_items = [];
	_ammunition = [];
	_weaponsX = [];
	{
	_unit = _x;
	if (_unit distance getMarkerPos ([(citiesX select {(sidesX getVariable [_x,sideUnknown] == teamPlayer)}),_x] call BIS_fnc_nearestPosition) < 1000) then
		{
		{_weaponsX pushBack ([_x] call BIS_fnc_baseWeapon)} forEach weapons _unit;
		{_ammunition pushBack _x} forEach magazines _unit;
		_items = _items + (items _unit) + (primaryWeaponItems _unit) + (assignedItems _unit) + (secondaryWeaponItems _unit);
		};
	deleteVehicle _unit;
	} forEach _POWs;
	deleteGroup _grpPOW;
	{boxX addWeaponCargoGlobal [_x,1]} forEach _weaponsX;
	{boxX addMagazineCargoGlobal [_x,1]} forEach _ammunition;
	{boxX addItemCargoGlobal [_x,1]} forEach _items;
	
	{
	[_x] spawn A3A_fnc_groupDespawner;
	} forEach _groups;
	
	deleteMarkerLocal _mrk;
	
	[_taskId, "RES", 1200] spawn A3A_fnc_taskDelete;
};

case (_markerX in outposts): {

	private _difficultX =if (aggressionLevelOccupants > 3) then {true} else {false};
	_leave = false;
	_contactX = objNull;
	_groupContact = grpNull;
	_tsk = "";
	_positionX = getMarkerPos _markerX;
	
	_POWs = [];
	_groups = [];
	
	_timeLimit = if (_difficultX) then {90 * settingsTimeMultiplier} else {120 * settingsTimeMultiplier};
	
	_dateLimit = [date select 0, date select 1, date select 2, date select 3, (date select 4) + _timeLimit];
	
	_dateLimitNum = dateToNumber _dateLimit;
	_dateLimit = numberToDate [date select 0, _dateLimitNum];//converts datenumber back to date array so that time formats correctly
	_displayTime = [_dateLimit] call A3A_fnc_dateToTimeString;//Converts the time portion of the date array to a string for clarity in hints
	
	_nameDest = [_markerX] call A3A_fnc_localizar;
	
	private _taskId = "RES" + str A3A_taskCount;
	[[teamPlayer,civilian],_taskId,[format ["A group of Allied POWs are located in %1. Rescue them and bring them back to an Allied base.<br/><br/>Reward: 100CP per player per POW rescued, and HR.",_nameDest],"POW Rescue",_markerX],_positionX,false,0,true,"run",true] call BIS_fnc_taskCreate;
	[_taskId, "RES", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];
	
	_officerClass = if (_side == Occupants) then {NATOOfficer} else {CSATOfficer};
	
	private _allPositions = [];
	private _potPos = [];
	
	for "i" from 1 to 5 do {
		_potPos = [_positionX, 1, 50, 12, 0, 0, 0] call BIS_fnc_findSafePos;
		_allPositions pushBack _potPos;
	};
	
	{
	if ((isOnRoad _x) || count _x == 3) then {_allPositions = _allPositions - [_x]};
	} forEach _allPositions;
	
	if (count _allPositions == 0) then {
		for "i" from 1 to 5 do {
			_potPos = [_positionX, 1, 150, 10, 0, 0, 0] call BIS_fnc_findSafePos;
			_allPositions pushBack _potPos;
		};
		{
		if ((isOnRoad _x) || count _x == 3) then {_allPositions = _allPositions - [_x]};
		} forEach _allPositions;
	};
	
	private _chosenPos = selectRandom _allPositions;
	private _POWposition = _chosenPos getPos [4,180];
	private _soldierPos = _chosenPos getPos [4,0];
	private _countX = round random [6,8,10];
	
	_grpPOW = createGroup teamPlayer;
	for "_i" from 0 to _countX do
		{
		_unitType = "";
		_uniform = "";
		if (random 100 < 50) then {_unitType = UKUnarmed; _uniform = "U_LIB_UK_P37"} else {_unitType = USUnarmed; _uniform = "U_LIB_US_Private"};
		_unit = [_grpPOW, _unitType, _POWposition, [], 0, "NONE"] call A3A_fnc_createUnit;
		_unit forceAddUniform _uniform;
		_unit allowDamage false;
		_unit setCaptive true;
		_unit disableAI "MOVE";
		_unit disableAI "AUTOTARGET";
		_unit disableAI "TARGET";
		_unit setUnitPos "UP";
		_unit setBehaviour "CARELESS";
		_unit allowFleeing 0;
		//_unit disableAI "ANIM";
		removeAllWeapons _unit;
		removeAllAssignedItems _unit;
		sleep 1;
		//if (alive _unit) then {_unit playMove "UnaErcPoslechVelitele1";};
		_POWS pushBack _unit;
		[_unit,"prisonerX"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_unit];
	};
	
	for "_i" from 1 to 2 do {
		private _officerGroup = createGroup _side;
		private _officer = [_officerGroup, _officerClass, _soldierPos, [], 0, "NONE"] call A3A_fnc_createUnit;
		[_officer] call A3A_fnc_NATOinit;
		_officer setUnitPos "UP";
		_officer doWatch selectRandom _POWS;
	
		_groups pushBack _officerGroup;
	};
	
	waitUntil {sleep 1; ({alive _x} count _POWs == 0) or ({(alive _x) and (_x distance getMarkerPos ([(((airportsX + milbases) select {(sidesX getVariable [_x,sideUnknown] == teamPlayer)}) + ["Synd_HQ"]),_x] call BIS_fnc_nearestPosition) < 50)} count _POWs > 0) or (dateToNumber date > _dateLimitNum)};
	
	if (dateToNumber date > _dateLimitNum) then
		{
		if (spawner getVariable _markerX == 2) then
			{
			{
			if (group _x == _grpPOW) then
				{
				_x setCaptive false;
				};
			} forEach _POWS;
			}
		else
			{
			{
			if (group _x == _grpPOW) then
				{
				_x setCaptive false;
				_x enableAI "MOVE";
				_x doMove _positionX;
				};
			} forEach _POWS;
			};
		};
	
	waitUntil {sleep 1; ({alive _x} count _POWs == 0) or ({(alive _x) and (_x distance getMarkerPos ([(((airportsX + milbases) select {(sidesX getVariable [_x,sideUnknown] == teamPlayer)}) + ["Synd_HQ"]),_x] call BIS_fnc_nearestPosition) < 50)} count _POWs > 0)};
	
	_bonus = if (_difficultX) then {2} else {1};
		
	if ({alive _x} count _POWs == 0) then
		{
		[_taskId, "RES", "FAILED"] call A3A_fnc_taskSetState;
		{[_x,false] remoteExec ["setCaptive",0,_x]; _x setCaptive false} forEach _POWs;
		[-20*_bonus,theBoss] call A3A_fnc_playerScoreAdd;
		}
		else
		{
		sleep 5;
		
		[_taskId, "RES", "SUCCEEDED"] call A3A_fnc_taskSetState;
		_alivePOWs = _POWs select {(alive _x) and (_x distance getMarkerPos ([(((airportsX + milbases) select {(sidesX getVariable [_x,sideUnknown] == teamPlayer)}) + ["Synd_HQ"]),_x] call BIS_fnc_nearestPosition) < 1000)};
		_countX = count _alivePOWs;
		_typeUnits = [];
		{
		_unitTypes pushBack (_x getVariable "unitType");
		} forEach _alivePOWs;
		_hr = _countX;
		_resourcesFIA = 200 * _countX;
		[_hr,_resourcesFIA,_unitTypes] remoteExec ["A3A_fnc_resourcesFIA",2];
		{ [_countX*10, _x] call A3A_fnc_playerScoreAdd } forEach (call BIS_fnc_listPlayers) select { side _x == teamPlayer || side _x == civilian};
		[round ((_countX)*10),theBoss] call A3A_fnc_playerScoreAdd;
		{[_x] join _grpPOW; [_x] orderGetin false} forEach _POWs;
		};
	
	sleep 60;
	_items = [];
	_ammunition = [];
	_weaponsX = [];
	{
	_unit = _x;
	if (_unit distance getMarkerPos ([(((airportsX + milbases) select {(sidesX getVariable [_x,sideUnknown] == teamPlayer)}) + ["Synd_HQ"]),_x] call BIS_fnc_nearestPosition) < 1000) then
		{
		{_weaponsX pushBack ([_x] call BIS_fnc_baseWeapon)} forEach weapons _unit;
		{_ammunition pushBack _x} forEach magazines _unit;
		_items = _items + (items _unit) + (primaryWeaponItems _unit) + (assignedItems _unit) + (secondaryWeaponItems _unit);
		};
	deleteVehicle _unit;
	} forEach _POWs;
	deleteGroup _grpPOW;
	{boxX addWeaponCargoGlobal [_x,1]} forEach _weaponsX;
	{boxX addMagazineCargoGlobal [_x,1]} forEach _ammunition;
	{boxX addItemCargoGlobal [_x,1]} forEach _items;
	
	{
	[_x] spawn A3A_fnc_groupDespawner;
	} forEach _groups;
	
	deleteMarkerLocal _mrk;
	
	[_taskId, "RES", 1200] spawn A3A_fnc_taskDelete;
	};
};