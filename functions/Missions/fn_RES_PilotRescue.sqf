//Mission: Rescue the pilots

if (!isServer and hasInterface) exitWith{};

private ["_unit","_markerX","_positionX","_countX", "_object", "_pilots", "_props"];

private _side = if (gameMode == 4) then {Invaders} else {Occupants};

_markerX = _this select 0;

	private _difficultX =if (aggressionLevelOccupants > 3) then {true} else {false};
	_leave = false;
	_contactX = objNull;
	_groupContact = grpNull;
	_tsk = "";
	_positionX = getMarkerPos _markerX;
	
	_pilots = [];
	_groups = [];
	_props = [];
	
	_timeLimit = if (_difficultX) then {60 * settingsTimeMultiplier} else {90 * settingsTimeMultiplier};
	
	_dateLimit = [date select 0, date select 1, date select 2, date select 3, (date select 4) + _timeLimit];
	
	_dateLimitNum = dateToNumber _dateLimit;
	_dateLimit = numberToDate [date select 0, _dateLimitNum];//converts datenumber back to date array so that time formats correctly
	_displayTime = [_dateLimit] call A3A_fnc_dateToTimeString;//Converts the time portion of the date array to a string for clarity in hints
	
	_nameDest = [_markerX] call A3A_fnc_localizar;

	//create position
	private _allPositions = [];
	private _chosenPos = [];
	private _dirX = 0;
	
	_outerObjects = nearestTerrainObjects [_positionX, ["Tree", "Bush", "Wall"], 300];
	_innerObjects = nearestTerrainObjects [_positionX, ["Tree", "Bush", "Wall"], 200];
	
	_selectedObjects = _outerObjects - _innerObjects;
	
	if (count _selectedObjects > 0) then {
		_object = selectRandom _selectedObjects;
		_dirX = _object getDir _positionX;
		_chosenPos = _object getRelPos [-3, _dirX];
	} else {
		for "i" from 1 to 10 do {
			_potPos = [_positionX, 200, 300, 1, 0, 0, 0] call BIS_fnc_findSafePos;
			_allPositions pushBack _potPos;
		};
	
		{
		if ((isOnRoad _x) || count _x == 3) then {_allPositions = _allPositions - [_x]};
		} forEach _allPositions;
	
		private _chosenPos = selectRandom _allPositions;
	};
	
	//create props
	_chute1Pos = [_positionX, 25, 50, 3, 0, 0, 0] call BIS_fnc_findSafePos;
	_chute1 = "LIB_US_ParachuteLanded" createVehicle _chute1Pos;
	_chute1 setDir (random 360);

	_chute2Pos = [_positionX, 25, 50, 3, 0, 0, 0] call BIS_fnc_findSafePos;
	_chute2 = "LIB_US_ParachuteLanded" createVehicle _chute2Pos;
	_chute2 setDir (random 360);
	
	_planePos = (_positionX getPos [600, _dirX]) findEmptyPosition [10,100,"LIB_P39_MRWreck"];
	_crater = createVehicle ["CraterLong", _planePos, [], 0, "CAN_COLLIDE"];
	_crater setDir _dirX;
	_crater setVectorUp surfaceNormal getPos _crater;
	_plane = createVehicle ["LIB_Pe2_MRWreck", _planePos, [], 0, "CAN_COLLIDE"];
	_plane setDir (_dirX + 180);
	_fire = createVehicle ["test_EmptyObjectForFireBig", _planePos, [], 0 , "CAN_COLLIDE"];
	_fireSound = createSoundSource ["Sound_Fire", getPos _fire, [], 0];
	
	{
	_props pushBack _x;
	} forEach [_chute1, _chute2, _crater, _plane, _fire];
	
	_randomDist = random 200;
	_randomDir = random 360;

	_markerPos = _chosenPos getPos [_randomDist, _randomDir];
	_pilotMarker = createMarker ["PilotLocationMarker", _markerPos];
	_pilotMarker setMarkerShape "ELLIPSE";
	_pilotMarker setMarkerType "hd_warning";
	_pilotMarker setMarkerSize [200, 200];
	_pilotMarker setMarkerText "Pilot Location";
	_pilotMarker setMarkerColor "colorGUER";
	_pilotMarker setMarkerBrush "Solid";
	_pilotMarker setMarkerAlpha 0.75;

	private _taskId = "RES" + str A3A_taskCount;
	[[teamPlayer,civilian],_taskId,[format ["A reconnaissance plane has been shot down behind enemy lines. The pilots managed to bail, we have an approximate location for them. Mount a rescue mission to save them, be aware that the Wehrmacht will also be looking for them.<br/><br/>Reward: 500CP per player per rescued pilot, and intel.",_nameDest],"Rescue Downed Pilots",_markerX],_markerPos,false,0,true,"run",true] call BIS_fnc_taskCreate;
	[_taskId, "RES", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];


	waitUntil {sleep 1; spawner getVariable _markerX != 2 || {dateToNumber date > _dateLimitNum}};

	if (spawner getVariable _markerX != 2) then {

	//create pilots
	_grpPOW = createGroup teamPlayer;
	for "_i" from 1 to 2 do
		{
		_unit = [_grpPOW, USPilot, _chosenPos, [], 0, "NONE"] call A3A_fnc_createUnit;
		_unit forceAddUniform "U_LIB_US_Pilot_2";
		_unit addHeadgear "H_LIB_US_Helmet_Pilot_Glasses_Up";
		_unit addMagazine "LIB_7Rnd_45ACP";
		_unit addWeapon "LIB_Colt_M1911";
		_unit addItemToUniform "LIB_US_M18_Yellow";
		for "_i" from 1 to 4 do {
			_unit addItemToVest "LIB_7Rnd_45ACP";
		};
		_unit setDamage 0.75;
		_unit allowDamage false;
		_unit allowFleeing 0;
		_unit setUnitPos "DOWN";
	};
	
	_pilots = units _grpPOW;
	_grpPOW setBehaviour "STEALTH";
	_grpPOW setCombatMode "GREEN";
	_dirX = _object getRelDir _positionX;	
	_grpPOW setFormDir _dirX;
	_groups pushBack _grpPOW;
	
	//Create enemy
	_typeEscortX = selectRandom ["LIB_SdKfz251_FFV", "fow_v_sdkfz_251_camo_ger_heer"];
	_safePos = _positionX findEmptyPosition [50,100,_typeEscortX];
	_escortVeh = [_safePos, 0, _typeEscortX, _side] call A3A_fnc_spawnVehicle;
	_APC = _escortVeh select 0;
	_APCCrew = _escortVeh select 1;
	_APCGgroup = _escortVeh select 2;
	{_nul = [_x,""] call A3A_fnc_NATOinit} forEach _APCCrew;
	[_APC, _side] call A3A_fnc_AIVEHinit;
	_groups pushBack _APCGgroup;
	
	_squad = selectRandom groupsFIAMid;
	_escortSquad = [_positionX,_side, _squad] call A3A_fnc_spawnGroup;
	{[_x,""] call A3A_fnc_NATOinit} forEach units _escortSquad;
	_groups pushBack _escortSquad;
	
	private _squad = if (_side == Invaders) then {CSATSquad} else {NATOSquad};
	_typeGroup = _squad call SCRT_fnc_unit_selectInfantryTier;
	
	_groupX = [_positionX,_side, _typeGroup] call A3A_fnc_spawnGroup;
	_nul = [leader _groupX, _markerX, "AWARE","SPAWNED", "NOVEH2", "NOFOLLOW"] execVM "scripts\UPSMON.sqf";
	{[_x,""] call A3A_fnc_NATOinit} forEach units _groupX;
	_groups pushBack _groupX;
	
	if (sunOrMoon < 1) then {[_groupX, _markerX] spawn {
		params ["_groupX", "_markerX"];
		waitUntil {sleep 1; spawner getVariable _markerX != 2};
		while {true} do {
		    private _flarePosition = (leader _groupX) getPos [random 75,random 360];
		    _flarePosition set [2,200];
		    _flareModel = "LIB_40mm_White";
			playSound3D [(selectRandom flareSounds), _flarePosition, false,  _flarePosition, 1.5, 1, 450, 0];
			
			sleep 2;
		    private _flare = _flareModel createVehicle _flarePosition;
		    _flare setVelocity [-10 + random 20 , -10 + random 20, -5];
		    
		    sleep (random [45,60,75]);
		    if (spawner getVariable _markerX == 2) exitWith {};
		};
	}};
	
	[_grpPOW, _APCGgroup] spawn {params ["_grpPOW", "_APCGgroup"]; sleep 600; if (combatMode _grpPOW == "GREEN") then {units _grpPOW allowDamage true; _APCGgroup addWaypoint [getPos (leader _grpPOW), 25]}};
		
	//waitUntil pilots captured, saved
	private _players = [];
	waitUntil {sleep 1; _players = (call BIS_fnc_listPlayers) select { side _x == teamPlayer || {side _x == civilian}};
    	(_players findIf {_x distance (leader _grpPOW) < 25} != -1 || combatMode _grpPOW != "GREEN") || 
    	((((leader _groupX) nearEntities 300) findIf {side _x == _side}) == -1 && _players findIf {_x distance (leader _grpPOW) < 300} != -1)};
	
	if (_players findIf {_x distance (leader _grpPOW) < 25} != -1 || combatMode _grpPOW != "GREEN") then {
		if (combatMode _grpPOW != "GREEN") then {
			_APCGgroup addWaypoint [getPos (leader _grpPOW), 10];
			_escortSquad addWaypoint [getPos (leader _grpPOW), 10];
			sleep 10;
			{
				_x setCaptive true;
				removeAllWeapons _x;
				removeAllAssignedItems _x;
				_x setUnitPos "UP";
				_x playMove "AmovPercMstpSnonWnonDnon_AmovPercMstpSsurWnonDnon";
				_x disableAI "ANIM";
				_x disableAI "MOVE";
				_x disableAI "AUTOTARGET";
				_x disableAI "TARGET";
				_x setBehaviour "CARELESS";
				_x setSpeaker "NoVoice";
				sleep 1;
			} forEach _pilots;
			sleep 3;
			{
				_x allowDamage true;
				[_x,"prisonerX"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_x];
			} forEach _pilots;
			_time = time + 1200;
			waitUntil {sleep 1; time > _time || _pilots findIf {captive _x} == -1};
			
			if (time > _time) then {
			deleteMarker _pilotMarker;
			_prisonerGrp = createGroup _side;
				{
				_x enableAI "ANIM";
				_x enableAI "MOVE";		
				_x switchMove "";
				[_x] joinsilent _prisonerGrp;
				_x assignAsCargo _APC;
				[_x] orderGetIn true;
				} forEach _pilots;
				_groups pushBack _prisonerGrp;
				
				{
				[_x] joinsilent _APCGgroup;
				_x assignAsCargo _APC;
				[_x] orderGetIn true;
				} forEach (units _escortSquad);
				sleep 60;
				_basePos = [((airportsX + milbases + seaports + outposts) select {(sidesX getVariable [_x,sideUnknown] == _side)}), _positionX] call BIS_fnc_nearestPosition;
				private _baseWp = _APCGgroup addWaypoint [getMarkerPos _basePos, 50];
				_baseWp setWaypointBehaviour "SAFE";
				[_APCGgroup, _pilots] spawn {params ["_APCGgroup", "_pilots"]; waitUntil {sleep 1;  ({!([_x] call A3A_fnc_canFight)} count units _APCGgroup) > ({[_x] call A3A_fnc_canFight}) count units _APCGgroup}; {[_x] orderGetIn false; unassignVehicle _x; _x setUnitPos "DOWN"} forEach _pilots;};
			};
			
		} else {
			_players = (call BIS_fnc_listPlayers) select { side _x == teamPlayer || {side _x == civilian}};
			_players select {_x distance (leader _grpPOW) < 25};
			_player = _players select 0;
			_pilots join group _player;
			doStop _pilots;
			{
			[_x] call A3A_fnc_FIAInit;
			_x removeItem "fow_i_fak_us";
			_x removeItem "fow_i_fak_us";
			removeVest _x;
			removeBackpack _x;
			_x allowDamage true;
			_x setUnitPos "DOWN";
			} forEach _pilots;
			deleteMarker _pilotMarker;
		};
	} else {
		{
		_x allowDamage true;
		_x setUnitPos "UP";
		_x setBehaviour "AWARE";
		_x setSpeedMode "FULL";
		} forEach _pilots;
		
		while {true} do {
			sleep 1;		
			_players = (call BIS_fnc_listPlayers) select { side _x == teamPlayer || {side _x == civilian}};
			_players select {_x distance (leader _grpPOW) < 325};
			_player = _players select 0;
			_pilots doMove (getPos _player);
			if ({_x distance _player < 30} count _pilots > 0) exitWith {};
		};
		
		waitUntil {sleep 1; _players = (call BIS_fnc_listPlayers) select { side _x == teamPlayer || {side _x == civilian}}; _players findIf {_x distance (leader _grpPOW) < 25} != -1};
		_player = _players select 0;
		_pilots join group _player;
		{
		[_x] call A3A_fnc_FIAInit;
		_x removeItem "fow_i_fak_us";
		_x removeItem "fow_i_fak_us";
		removeVest _x;
		removeBackpack  _x;
		} forEach _pilots;		
		doStop _pilots;
		deleteMarker _pilotMarker;
	};

	waitUntil {sleep 1; ({alive _x} count _pilots == 0) or ({(alive _x) and (_x distance getMarkerPos ([(((airportsX + milbases) select {(sidesX getVariable [_x,sideUnknown] == teamPlayer)}) + ["Synd_HQ"]),_x] call BIS_fnc_nearestPosition) < 50)} count _pilots > 0) or ({(alive _x) and (_x distance getMarkerPos ([(((airportsX + milbases + seaports + outposts) select {(sidesX getVariable [_x,sideUnknown] == _side)})),_x] call BIS_fnc_nearestPosition) < 100)} count _pilots > 0)};
	
	} else {
		_grpPOW = createGroup teamPlayer;
		for "_i" from 1 to 2 do
		{
		_unit = [_grpPOW, USPilot, _positionX, [], 0, "NONE"] call A3A_fnc_createUnit;
		};
		_groups pushBack _grpPOW;
		{
		_x setDamage 1;
		} forEach units _grpPOW;
	};
	
	_bonus = if (_difficultX) then {2} else {1};
		
	if (({alive _x} count _pilots == 0) or ({(alive _x) and (_x distance getMarkerPos ([(((airportsX + milbases + seaports + outposts) select {(sidesX getVariable [_x,sideUnknown] == _side)})),_x] call BIS_fnc_nearestPosition) < 100)} count _pilots > 0)) then
		{
		[_taskId, "RES", "FAILED"] call A3A_fnc_taskSetState;
		{[_x,false] remoteExec ["setCaptive",0,_x]; _x setCaptive false} forEach _pilots;
		[-20,theBoss] call A3A_fnc_playerScoreAdd;
		}
		else
		{
		sleep 5;
		[_taskId, "RES", "SUCCEEDED"] call A3A_fnc_taskSetState;
		_countX = {(alive _x) and (_x distance getMarkerPos ([(((airportsX + milbases) select {(sidesX getVariable [_x,sideUnknown] == teamPlayer)}) + ["Synd_HQ"]),_x] call BIS_fnc_nearestPosition) < 250)} count _pilots;
		_hr = _countX;
		_resourcesFIA = 500 * _countX;
		[_hr,_resourcesFIA,USPilot] remoteExec ["A3A_fnc_resourcesFIA",2];
		{ [_countX*50, _x] call A3A_fnc_playerScoreAdd } forEach (call BIS_fnc_listPlayers) select { side _x == teamPlayer || side _x == civilian};
		[round (_countX*20),theBoss] call A3A_fnc_playerScoreAdd;
		private _intelText = ["Medium", _side] call A3A_fnc_selectIntel;
        [_intelText] remoteExec ["A3A_fnc_showIntel", [teamPlayer, civilian]];
		{[_x] join _grpPOW; [_x] orderGetin false} forEach _pilots;
		};
	
	sleep 60;
	_items = [];
	_ammunition = [];
	_weaponsX = [];
	{
	_unit = _x;
	if (_unit distance getMarkerPos ([(((airportsX + milbases) select {(sidesX getVariable [_x,sideUnknown] == teamPlayer)}) + ["Synd_HQ"]),_x] call BIS_fnc_nearestPosition) < 250) then
		{
		{_weaponsX pushBack ([_x] call BIS_fnc_baseWeapon)} forEach weapons _unit;
		{_ammunition pushBack _x} forEach magazines _unit;
		_items = _items + (items _unit) + (primaryWeaponItems _unit) + (assignedItems _unit) + (secondaryWeaponItems _unit);
		};
	deleteVehicle _unit;
	} forEach _pilots;
	deleteGroup _grpPOW;
	{boxX addWeaponCargoGlobal [_x,1]} forEach _weaponsX;
	{boxX addMagazineCargoGlobal [_x,1]} forEach _ammunition;
	{boxX addItemCargoGlobal [_x,1]} forEach _items;
	
	if (!isNil "_pilotMarker") then {
	deleteMarker _pilotMarker;
	};
	
	{
	[_x] spawn A3A_fnc_groupDespawner;
	} forEach _groups;
	
	{
	deleteVehicle _x;
	} forEach _props;
	
	deleteMarkerLocal _mrk;
	
	[_taskId, "RES", 1200] spawn A3A_fnc_taskDelete;

