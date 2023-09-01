//Mission: Destroy the vehicle
if (!isServer and hasInterface) exitWith{};

private ["_markerX","_positionX", "_sideX", "_dateLimit","_dateLimitNum","_nameDest","_typeVehX","_textX","_truckCreated","_size","_pos","_veh","_groupX"];

_markerX = _this select 0;

_difficultX = if (aggressionLevelOccupants > 3) then {true} else {false};
_bonus = if (_difficultX) then {2} else {1};
_positionX = getMarkerPos _markerX;
_sideX = if (sidesX getVariable [_markerX,sideUnknown] == Occupants) then {Occupants} else {Invaders};
_timeLimit = if (_difficultX) then {30 * settingsTimeMultiplier} else {120 * settingsTimeMultiplier};
_dateLimit = [date select 0, date select 1, date select 2, date select 3, (date select 4) + _timeLimit];
_dateLimitNum = dateToNumber _dateLimit;
_dateLimit = numberToDate [date select 0, _dateLimitNum];//converts datenumber back to date array so that time formats correctly
_displayTime = [_dateLimit] call A3A_fnc_dateToTimeString;//Converts the time portion of the date array to a string for clarity in hints

_nameDest = [_markerX] call A3A_fnc_localizar;

private _mission = if (random 100 < 50) then {"officer"} else {"bombers"};

switch (true) do {
	case (_mission == "officer"): {
	
		private _units = [];
		private _vehicles = [];
		private _timeVar = round (random [5,10,15]);
		private _departingTimeLimit = _timeVar * settingsTimeMultiplier;
		private _departingDateLimit = [date select 0, date select 1, date select 2, date select 3, (date select 4) + _departingTimeLimit];
		private _departingDateLimitNum = dateToNumber _departingDateLimit;
		_departingDateLimit = numberToDate [date select 0, _departingDateLimitNum]; //converts datenumber back to date array so that time formats correctly
		private _departingDisplayTime = [_departingDateLimit] call A3A_fnc_dateToTimeString; //Converts the time portion of the date array to a string for clarity in hints

		_typeVehX = if (_sideX == Occupants) then {selectRandom vehNATOTransportPlanes} else {selectRandom vehCSATTransportPlanes};
		_typeEscortX = if (_sideX == Occupants) then {selectRandom vehNATOPlanesAA} else {selectRandom vehCSATPlanesAA};

		_reward = (1000*_bonus);
		private _taskId = "DES" + str A3A_taskCount;
		[[teamPlayer,civilian],_taskId,[format ["A high ranking enemy officer is flying into %1, his transport plane will enter Altian airspace from the north-west at %2. Intercept it and shoot it down.<br/><br/>Reward: %3CP per player.",_nameDest,_departingDisplayTime,_reward],"Shoot down enemy officer",_markerX],_positionX,false,0,true,"Destroy",true] call BIS_fnc_taskCreate;
		[_taskId, "DES", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];
	
		waitUntil {sleep 1; dateToNumber date > _departingDateLimitNum};
	
		//spawn plane and officer
		private _posOrigin = getMarkerPos "Italy";
		private _spawnPos = (_posOrigin) vectorAdd [0, 0, 1000];
		private _targDir = _spawnPos getDir _positionX;
		private _vehicle = [_posOrigin, 0, _typeVehX, _sideX] call A3A_fnc_spawnVehicle;
		_plane = _vehicle select 0;
		_planeCrew = _vehicle select 1;
		_groupPlane = _vehicle select 2;
		{_nul = [_x,""] call A3A_fnc_NATOinit} forEach _planeCrew;
		[_plane, _sideX] call A3A_fnc_AIVEHinit;
		_units append _planeCrew;
		_vehicles pushBack _plane;
		_plane setDir _targDir;
		_plane setPosASL _spawnPos;                                            
		_plane setVelocityModelSpace [0, 400, 0]; 
		_plane flyInHeightASL [1000,500,500]; 

		_grp = createGroup _sideX;
		_typeX = if (_sideX == Occupants) then {"LIB_GER_oberst"} else {CSATOfficer};
		_official = [_grp, _typeX, _posOrigin, [], 0, "NONE"] call A3A_fnc_createUnit;
		_official forceAddUniform "U_LIB_GER_Oberst";
		removeVest _official;
		_official addVest "V_LIB_GER_OfficerVest";
		removeHeadgear _official;
		_official addHeadgear "H_LIB_GER_OfficerCap_LUFT_Co";
		removeAllWeapons _official;
		_official assignAsCargo _plane;
		_official moveInCargo _plane;
		_units pushBack _official;
		_nul = [_official,""] call A3A_fnc_NATOinit;
	
		sleep 1;
	
		//Escorts
		for "i" from 1 to 2 do {
			_spawnPos = (_spawnPos getPos [100, (90 + _targDir)]) vectorAdd [0, 0, 1000];
			_escortVeh = [_posOrigin, 0, _typeEscortX, _sideX] call A3A_fnc_spawnVehicle;
			_escort = _escortVeh select 0;
			_escortCrew = _escortVeh select 1;
			_groupEscort = _escortVeh select 2;
			{_nul = [_x,""] call A3A_fnc_NATOinit} forEach _escortCrew;
			[_escort, _sideX] call A3A_fnc_AIVEHinit;
			{_x setCombatBehaviour "AWARE"} forEach _escortCrew;
			_vehicles pushBack _escort;
			_units append _escortCrew;
			_escortCrew join _groupPlane;
			deleteGroup _groupEscort;
			_escort setDir _targDir;
			_escort setPosASL _spawnPos;                                            
			_escort setVelocityModelSpace [0, 400, 0];
			sleep 1;
		};
	
		{_x setCombatBehaviour "CARELESS"} forEach _planeCrew;
	
		private _wp1 = _groupPlane addWaypoint [_positionX, 0]; 
		_wp1 setWaypointType "MOVE"; 
		
		if (_difficultX) then {
			[_groupPlane, _sideX, _vehicles, _units] spawn {
				params ["_groupPlane", "_sideX", "_vehicles", "_units"];
				waitUntil {sleep 5; {side _x == teamPlayer} count (getPosASL (leader _groupPlane) nearEntities 500) > 0};  
				for "i" from 1 to 2 do {
					_typeEscortX = if (_sideX == Occupants) then {selectRandom vehNATOPlanesAA} else {selectRandom vehCSATPlanesAA};
					_origin = getMarkerPos ([(AirportsX select {sidesX getVariable [_x,sideUnknown] == _sideX}), (getPos leader _groupPlane)] call BIS_fnc_nearestPosition);
					_spawnPos = _origin vectorAdd [0, 0, 250];
					_escortVeh = [_origin, 0, _typeEscortX, _sideX] call A3A_fnc_spawnVehicle;
					_escort = _escortVeh select 0;
					_escortCrew = _escortVeh select 1;
					_groupEscort = _escortVeh select 2;
					{_nul = [_x,""] call A3A_fnc_NATOinit} forEach _escortCrew;
					[_escort, _sideX] call A3A_fnc_AIVEHinit;
					{_x setCombatBehaviour "COMBAT"} forEach _escortCrew;
					_vehicles pushBack _escort;
					_units append _escortCrew;
					_escortCrew join _groupPlane;
					deleteGroup _groupEscort;                                           
					_escort setVelocityModelSpace [0, 400, 0];
					sleep 1;
				};
			};
		};
	
		[_plane, _positionX] spawn {
			params ["_plane", "_positionX"];
			waitUntil {sleep 1; _plane distance2D _positionX < 5000};
			_plane flyInHeightASL [350,350,350];
			waitUntil {sleep 1; _plane distance2D _positionX < 1500};
			crew _plane orderGetIn false;
			{ unassignVehicle _x } forEach crew _plane;
		};

		waitUntil {sleep 1; (not alive _official) or (isTouchingGround _plane && _plane distance2D _positionX < 500)};
	
		if (not alive _official) then {
			[_taskId, "DES", "SUCCEEDED"] call A3A_fnc_taskSetState;
			[0,1000*_bonus,0] remoteExec ["A3A_fnc_resourcesFIA",2];
		    if (_sideX == Occupants) then {aggressionOccupants = aggressionOccupants - 20} else {aggressionInvaders = aggressionInvaders - 20};
			[] call A3A_fnc_calculateAggression;
			[1200*_bonus, _sideX] remoteExec ["A3A_fnc_timingCA",2];
			{ [100*_bonus, _x] call A3A_fnc_playerScoreAdd } forEach (call BIS_fnc_listPlayers) select { side _x == teamPlayer || side _x == civilian};
			[50*_bonus,theBoss] call A3A_fnc_playerScoreAdd;
		} else {
		    [_taskId, "DES", "FAILED"] call A3A_fnc_taskSetState;
			[0,-500*_bonus,0] remoteExec ["A3A_fnc_resourcesFIA",2];
			[-600*_bonus, _sideX] remoteExec ["A3A_fnc_timingCA",2];
			[-20*_bonus,theBoss] call A3A_fnc_playerScoreAdd;
		};

		sleep 300;

		[_taskId, "DES", 1200] spawn A3A_fnc_taskDelete;
	
		{[_x] spawn A3A_fnc_groupDespawner} forEach [_groupPlane,_grp];
		{[_x] spawn A3A_fnc_vehDespawner} forEach _vehicles;

	};

	case (_mission == "bombers"): {
		
		private _targetVehicles = [];
		private _vehicles = [];
		_typeVehX = if (_sideX == Occupants) then {vehNATOPlanes select 2} else {selectRandom vehCSATPlanes};
		_typeEscortX = if (_sideX == Occupants) then {selectRandom vehNATOPlanesAA} else {selectRandom vehCSATPlanesAA};

		_reward = (1000*_bonus);
		private _taskId = "DES" + str A3A_taskCount;
		[[teamPlayer,civilian],_taskId,[format ["Enemy JU-88 bombers have arrived from the mainland, they are parked at %1. Destroy as many as you can before they cause us trouble.<br/><br/>Reward: %2CP per player.",_nameDest,_reward],"Destroy Bombers",_markerX],_positionX,false,0,true,"Destroy",true] call BIS_fnc_taskCreate;
		[_taskId, "DES", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];

		private _spawnPoints = nearestObjects [_positionX, ["Land_HelipadEmpty_F"], 500]; 

		{
			_pos = getPos _x;
			_veh = createVehicle [_typeVehX, _pos, [], 0, "NONE"];
			[_veh, _sideX] call A3A_fnc_AIVEHinit;
			_targetVehicles pushBack _veh;
		} forEach _spawnPoints;
		
		_numberVehs = count _targetVehicles;
		_targetNum = _numberVehs/2;
		
		for "i" from 1 to _bonus do {
			_spawnPos = _positionX; 
			_spawnPos = _spawnPos vectorAdd [0, 0, 1000];
			_escortVeh = [_positionX, 0, _typeEscortX, _sideX] call A3A_fnc_spawnVehicle;
			_escort = _escortVeh select 0;
			_escortCrew = _escortVeh select 1;
			_groupEscort = _escortVeh select 2;
			{_nul = [_x,""] call A3A_fnc_NATOinit} forEach _escortCrew;
			[_escort, _sideX] call A3A_fnc_AIVEHinit;
			{_x setCombatBehaviour "AWARE"} forEach _escortCrew;
			_vehicles pushBack _escort;
			_escort setPosASL _spawnPos;                                            
			_escort setVelocityModelSpace [0, 400, 0];
			_escort flyInHeightASL [1000,1000,1000]; 
			sleep 2;
		};
		
		_vehicles append _targetVehicles;
		
		waitUntil {sleep 1;(dateToNumber date > _dateLimitNum) or ({!alive _x} count _targetVehicles >= _targetNum)};
	
		if ({!alive _x} count _targetVehicles > _targetNum) then {
		
			[_taskId, "DES", "SUCCEEDED"] call A3A_fnc_taskSetState;
			
			[0,1000*_bonus,0] remoteExec ["A3A_fnc_resourcesFIA",2];
	        if (_sideX == Occupants) then {aggressionOccupants = aggressionOccupants - 20} else {aggressionInvaders = aggressionInvaders - 20};
			[] call A3A_fnc_calculateAggression;
			if (_sideX == Invaders) then {
	            [0,10*_bonus,_positionX] remoteExec ["A3A_fnc_citySupportChange",2]
	        } else {
	            [0,5*_bonus,_positionX] remoteExec ["A3A_fnc_citySupportChange",2]
	        };
			[1200*_bonus, _sideX] remoteExec ["A3A_fnc_timingCA",2];
			{ [20*_bonus, _x] call A3A_fnc_playerScoreAdd } forEach (call BIS_fnc_listPlayers) select { side _x == teamPlayer || side _x == civilian};
			[50*_bonus,theBoss] call A3A_fnc_playerScoreAdd;
		} else {
		    [_taskId, "DES", "FAILED"] call A3A_fnc_taskSetState;
			[0,-500*_bonus,0] remoteExec ["A3A_fnc_resourcesFIA",2];
			if (_sideX == Occupants) then {aggressionOccupants = aggressionOccupants + 20} else {aggressionInvaders = aggressionInvaders + 20};
			[] call A3A_fnc_calculateAggression;
			[-600*_bonus, _sideX] remoteExec ["A3A_fnc_timingCA",2];
			[-20*_bonus,theBoss] call A3A_fnc_playerScoreAdd;
		};

		[_taskId, "DES", 1200] spawn A3A_fnc_taskDelete;

		[_groupX] spawn A3A_fnc_groupDespawner;
		[_veh] spawn A3A_fnc_vehDespawner;
	};
};