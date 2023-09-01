//Mission: Rescue the prisoners

if (!isServer and hasInterface) exitWith{};

private ["_unit","_markerX","_positionX","_countX"];

private _side = if (gameMode == 4) then {Invaders} else {Occupants};

_markerX = _this select 0;

	private _difficultX =if (aggressionLevelOccupants > 3) then {true} else {false};
	_groupPart = grpNull;
	_positionX = getMarkerPos _markerX;
	
	_partizans = [];
	_groups = [];
	_players = [];
	
	_timeLimit = if (_difficultX) then {60 * settingsTimeMultiplier} else {90 * settingsTimeMultiplier};
	
	_dateLimit = [date select 0, date select 1, date select 2, date select 3, (date select 4) + _timeLimit];
	
	_dateLimitNum = dateToNumber _dateLimit;
	_dateLimit = numberToDate [date select 0, _dateLimitNum];//converts datenumber back to date array so that time formats correctly
	_displayTime = [_dateLimit] call A3A_fnc_dateToTimeString;//Converts the time portion of the date array to a string for clarity in hints
	
	_nameDest = [_markerX] call A3A_fnc_localizar;
	
	private _taskId = "RES" + str A3A_taskCount;
	[[teamPlayer,civilian],_taskId,[format ["A group of partizans has come under attack at an enemy %1. They are pinned down and have asked for help. Go and rescue them and bring them back to a friendly town.<br/><br/>Reward: 200CP per player per rescued partizan.",_nameDest],"Partizan Rescue",_markerX],_positionX,false,0,true,"run",true] call BIS_fnc_taskCreate;
	[_taskId, "RES", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];
	
	waitUntil {sleep 1; spawner getVariable _markerX != 2 || {dateToNumber date > _dateLimitNum}};

	if (spawner getVariable _markerX != 2) then {
	
	_roads1 = _positionX nearRoads 25;
	_roads2 = roadsConnectedTo (_roads1 select 0);
	_dirX = (_roads1 select 0) getRelDir (_roads2 select 0);
	
	_newPos = _positionX getPos [50, _dirX];
	_roadPos = getPos ([_newPos] call A3A_fnc_findNearestGoodRoad);

	_truck = "LIB_FRA_CitC4" createVehicle _roadPos;
	_truck setDir (_dirX + 170);
	_truck setDamage 1;
	
	_grpDead = createGroup teamPlayer;
	for "_i" from 1 to 2 do {
	_deadPos = [getPos _truck, 5, 10, 1, 0, 0, 0] call BIS_fnc_findSafePos;
	_unit = [_grpDead, SDKMil, _deadPos, [], 0, "NONE"] call A3A_fnc_createUnit;
	[_unit] call A3A_fnc_FIAInit;
	_unit setDamage 1;
	};
	
	sleep 1; 
	
	_squadPos = _truck getRelPos [125,100];
	_groupPart = [_squadPos,teamPlayer, groupsSDKSquad] call A3A_fnc_spawnGroup;
	_partizans = units _groupPart;
	{
	[_x] call A3A_fnc_FIAInit;
	_x setUnitPos "DOWN";
	_x setBehaviour "COMBAT";
	} forEach _partizans;
	_groups pushBack _groupPart;
	
	waitUntil {sleep 1; _players = (call BIS_fnc_listPlayers) select { side _x == teamPlayer || {side _x == civilian}};
    	(_players findIf {_x distance (leader _groupPart) < 20} != -1) || ({alive _x} count _partizans == 0)};
    	
    if (_players findIf {_x distance (leader _groupPart) < 20} != -1) then {
    		_players = (call BIS_fnc_listPlayers) select { side _x == teamPlayer || {side _x == civilian}};
			_players select {_x distance (leader _groupPart) < 25};
			_player = _players select 0;
			_partizans join group _player;
			doStop _partizans;
			{
			_x setUnitPos "DOWN";
			} forEach _partizans;
    };	
	
	} else {
		{
		_bonus = if (_difficultX) then {2} else {1};
		[_taskId, "RES", "FAILED"] call A3A_fnc_taskSetState;
		[-10*_bonus,theBoss] call A3A_fnc_playerScoreAdd;
		}
	};
	
	waitUntil {sleep 1; ({alive _x} count _partizans == 0) or ({(alive _x) and (_x distance getMarkerPos ([((CitiesX select {(sidesX getVariable [_x,sideUnknown] == teamPlayer)})),_x] call BIS_fnc_nearestPosition) < 100)} count _partizans > 0)};
	
	_bonus = if (_difficultX) then {2} else {1};
		
	if ({alive _x} count _partizans == 0) then
		{
		[_taskId, "RES", "FAILED"] call A3A_fnc_taskSetState;
		[-20,theBoss] call A3A_fnc_playerScoreAdd;
		[0,-10,_positionX] remoteExec ["A3A_fnc_citySupportChange",2];
		}
		else
		{
		sleep 5;
		[_taskId, "RES", "SUCCEEDED"] call A3A_fnc_taskSetState;
		_countX = {(alive _x) and (_x distance getMarkerPos ([(CitiesX select {(sidesX getVariable [_x,sideUnknown] == teamPlayer)}),_x] call BIS_fnc_nearestPosition) < 150)} count _partizans;
		_resourcesFIA = 200 * _countX;
		[0,_resourcesFIA,0] remoteExec ["A3A_fnc_resourcesFIA",2];
		[0,2*_countX,_positionX] remoteExec ["A3A_fnc_citySupportChange",2];
		{ [_countX*20, _x] call A3A_fnc_playerScoreAdd } forEach (call BIS_fnc_listPlayers) select { side _x == teamPlayer || side _x == civilian};
		[round (_countX*10),theBoss] call A3A_fnc_playerScoreAdd;
		{[_x] join _groupPart; [_x] orderGetin false; unassignVehicle _x; _x setUnitPos "UP"; _x setBehaviour "SAFE"} forEach _partizans;
		
		sleep 30;
		
		private _city = [CitiesX, _groupPart] call BIS_fnc_nearestPosition;
		if (_city in ["Kavala","Charkia","Sofia","Panochori","Athira","Telos","Zaros","Pyrgos","AgiosDionysios","Neochori","Paros"]) then {
				_church = nearestObjects [getMarkerPos _city, ["Land_Church_04_white_red_F","Land_Church_04_white_F","Land_Church_04_yellow_F"], 400]; 
				_SDKpos = (_church select 0) getRelPos [10, 0];
				_wp1 = _groupPart addWaypoint [_SDKpos, 5];
			} else {
				_church = nearestTerrainObjects [getMarkerPos _city, ["CHURCH"], 400];	
				_SDKpos = (_church select 0) getRelPos [8, 270];
				_wp1 = _groupPart addWaypoint [_SDKpos, 5];
		};
	};
	sleep 60;

	{
	[_x] spawn A3A_fnc_groupDespawner;
	} forEach _groups;
	
	[_taskId, "RES", 1200] spawn A3A_fnc_taskDelete;
	

