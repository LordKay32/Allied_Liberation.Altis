//Mission: Destroy the vehicle
if (!isServer and hasInterface) exitWith{};

private ["_markerX","_positionX", "_sideX", "_dateLimit","_dateLimitNum","_nameDest","_typeVehX", "_escortShip"];

_markerX = _this select 0;

_difficultX = if (aggressionLevelOccupants > 3) then {true} else {false};
_bonus = if (_difficultX) then {2} else {1};
_positionX = getMarkerPos _markerX;
_sideX = if (sidesX getVariable [_markerX,sideUnknown] == Occupants) then {Occupants} else {Invaders};
_timeLimit = if (_difficultX) then {90 * settingsTimeMultiplier} else {120 * settingsTimeMultiplier};
_dateLimit = [date select 0, date select 1, date select 2, date select 3, (date select 4) + _timeLimit];
_dateLimitNum = dateToNumber _dateLimit;
_dateLimit = numberToDate [date select 0, _dateLimitNum];//converts datenumber back to date array so that time formats correctly
_displayTime = [_dateLimit] call A3A_fnc_dateToTimeString;//Converts the time portion of the date array to a string for clarity in hints

_nameDest = [_markerX] call A3A_fnc_localizar;

private _mission = if ((_markerX == "seaport_3") || ((_markerX == "seaport_2") && (random 100 > 25))) then {"convoy"} else {"subs"};

switch (true) do {
	case (_mission == "convoy"): {
		
		private _units = [];
		private _vehicles = [];
		private _objectives = [];
		private _groups = [];
		private _endMarker = "";

		_typeVehX = if (_sideX == Occupants) then {"sab_nl_liberty"} else {selectRandom vehCSATTransportPlanes};
		_escortShip = if (_sideX == Occupants) then {"sab_nl_t22"} else {selectRandom vehCSATPlanesAA};
		_crew = "sab_nl_sailor_blue";

		_reward = 2000;
		private _taskId = "DES" + str A3A_taskCount;
		[[teamPlayer,civilian],_taskId,[format ["An enemy sea convoy is bringing supplies and men to %1 from the mainland. Intercept it and destroy the transport ships. <br/><br/>Reward: %2CP per player",_nameDest, _reward],"Destroy Sea Convoy",_markerX],_positionX,false,0,true,"Destroy",true] call BIS_fnc_taskCreate;
		[_taskId, "DES", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];

	private _spawnShip = {
		params ["_markerX", "_vehType", "_spawnPos", "_sideX", "_grp", "_crew", "_vehicles"];
		_veh = createVehicle [_vehType,[0,0,0], [], 0, "NONE"];
		_dir = if (_markerX == "seaport_2") then {177} else {116};
		_veh setDir _dir;
		_veh setVehiclePosition [_spawnPos, [], 0, "NONE"];
		[_veh, _sideX] call A3A_fnc_AIVEHinit;
		_vehicles pushBack _veh;
		if (_vehType == "sab_nl_liberty") then {_objectives pushBack _veh};
		
		_veh engineOn true;

		_unit = [_grp, _crew, _spawnPos, [], 0, "NONE"] call A3A_fnc_createUnit;
		_unit moveInDriver _veh;
		[_unit,""] call A3A_fnc_NATOinit;
		_unit setCombatBehaviour "CARELESS";
		_unit disableAI "MOVE";
	};	

	//spawn convoy
	private _groupX = createGroup _sideX;
	if (_markerX == "seaport_2") then {
		private _posOrigin = getMarkerPos "NATO_carrier";
		private _spawnPos = _posOrigin;
		
		[_markerX, _escortShip, _spawnPos, _sideX, _groupX, _crew, _vehicles] call _spawnShip;
		_spawnPos = _spawnPos getPos [500, 357];
		
		[_markerX, _typeVehX, _spawnPos, _sideX, _groupX, _crew, _vehicles] call _spawnShip;
		_spawnPos = _spawnPos getPos [500, 357];
		
		[_markerX, _typeVehX, _spawnPos, _sideX, _groupX, _crew, _vehicles] call _spawnShip;
		
		{
		 _units pushBack _x;
		} forEach units _groupX;
		
		_groups pushBack _groupX;
		
		sleep 2;
	
		_endMarker = "seaConvoyMrk_2";
		
		_num = 0;
		{_num = _num + 7;
			[_x,_num] spawn {
				_ship = _this select 0;
				_num = _this select 1;
				while {alive _ship} do {
					_ship setVelocityModelSpace [0,10,0];
					sleep 0.5;
					if (_ship inArea "seaConvoy_change") exitWith {				
						if (typeOf _ship == "sab_nl_t22") then {
							sleep 30;
							_speed = 10; 
							while {_speed > 0} do {
								_ship setVelocityModelSpace [0,_speed,0]; 
								_speed = _speed - 0.5; 
								sleep 0.1;
							};
							_ship engineOn false;
						} else {
							driver _ship enableAI "MOVE"; 
							driver _ship doMove getMarkerPos "seaConvoyMrk_2"; 
							_dir = _ship getDir getMarkerPos "seaConvoyMrk_2"; 
							waitUntil {getDir _ship > (_dir - _num) && getDir _ship < (_dir + _num)}; 		
							driver _ship disableAI "MOVE"; while {alive _ship} do {
								_ship setVelocityModelSpace [0,10,0]; 
								sleep 0.5; 
								if ("030" in mapGridPosition _ship) exitWith {
									_speed = 10; 
									while {_speed > 0} do {
										_ship setVelocityModelSpace [0,_speed,0]; 
										_speed = _speed - 0.75; 
										sleep 0.1;
									};
									_ship engineOn false;
								};
							};
						};						
					};
				};
			};
			[_x, _crew] spawn {
				params ["_veh", "_crew"];
				waitUntil {sleep 1; ((_veh nearEntities 2000) findIf {side _x == teamPlayer}) != -1};
				_num = if (typeOf _veh == "sab_nl_t22") then {15} else {12};
				for "_i" from 1 to _num do {
					_unit = [group driver _veh, _crew, [0,0,0], [], 0, "NONE"] call A3A_fnc_createUnit;
					_unit moveInAny _veh;
					[_unit,""] call A3A_fnc_NATOinit;
				};
			};
		} forEach _vehicles;		
	} else {
		private _posOrigin = [2007.85,30301.1,0];
		private _spawnPos = _posOrigin;
		
		[_markerX, _escortShip, _spawnPos, _sideX, _groupX, _crew, _vehicles] call _spawnShip;
		_spawnPos = _spawnPos getPos [500, 296];
		
		[_markerX, _typeVehX, _spawnPos, _sideX, _groupX, _crew, _vehicles] call _spawnShip;
		_spawnPos = _spawnPos getPos [500, 296];
		
		[_markerX, _typeVehX, _spawnPos, _sideX, _groupX, _crew, _vehicles] call _spawnShip;
		
		{
	 	_units pushBack _x;
		} forEach units _groupX;
	
		sleep 2;
	
		_endMarker = "seaConvoyMrk_1";
	
		_num = 0;
		{_num = _num + 10;
			[_x,_num] spawn {
				_ship = _this select 0;
				_num = _this select 1;
				while {alive _ship} do {
					_ship setVelocityModelSpace [0,10,0];
					sleep 0.5;
					if (_ship inArea "seaConvoy_change_1") exitWith {
						if (typeOf _ship == "sab_nl_t22") then {
							sleep 30;
							_speed = 10; 
							while {_speed > 0} do {
								_ship setVelocityModelSpace [0,_speed,0]; 
								_speed = _speed - 0.5; 
								sleep 0.1;
							};
							_ship engineOn false;
						} else {		
							driver _ship enableAI "MOVE"; 
							driver _ship doMove getMarkerPos "seaConvoyMrk_1"; 
							_dir = _ship getDir getMarkerPos "seaConvoyMrk_1"; 
							waitUntil {getDir _ship > (_dir - _num) && getDir _ship < (_dir + _num)}; 
							driver _ship disableAI "MOVE"; while {alive _ship} do {
								_ship setVelocityModelSpace [0,10,0]; 
								sleep 0.5; 
								if (_ship inArea "seaConvoyMrk_1") exitWith {
									_speed = 10; 
									while {_speed > 0} do {
										_ship setVelocityModelSpace [0,_speed,0]; 
										_speed = _speed - 0.75; 
										sleep 0.1;
									};
									_ship engineOn false;
								};
							};
						};
					};
				};
			};
			[_x, _crew] spawn {
				params ["_veh", "_crew"];
				waitUntil {sleep 1; ((_veh nearEntities 2000) findIf {side _x == teamPlayer}) != -1};
				_num = if (typeOf _veh == "sab_nl_t22") then {15} else {12};
				for "_i" from 1 to _num do {
					_unit = [group driver _veh, _crew, [0,0,0], [], 0, "NONE"] call A3A_fnc_createUnit;
					_unit moveInAny _veh;
					[_unit,""] call A3A_fnc_NATOinit;
				};
			};
		} forEach _vehicles;
	};
	
	
		//Escort Planes
		[_groupX, _bonus, _sideX, _vehicles, _units ,_groups] spawn {
			params ["_groupX", "_bonus", "_sideX", "_vehicles", "_units", "_groups"];
			waitUntil {sleep 5; (((leader _groupX) nearEntities ["air", 2000]) findIf {side _x == teamPlayer}) != -1};
			for "i" from 1 to (2 * _bonus) do {
				_typeEscortX = if (_sideX == Occupants) then {selectRandom vehNATOPlanesAA} else {selectRandom vehCSATPlanesAA};
				_origin = getMarkerPos "airport_5";
				_spawnPos = _origin vectorAdd [0, 0, 250];
				_escortVeh = [_spawnPos, 0, _typeEscortX, _sideX] call A3A_fnc_spawnVehicle;
				_escort = _escortVeh select 0;
				_escortCrew = _escortVeh select 1;
				_groupEscort = _escortVeh select 2;
				{_nul = [_x,""] call A3A_fnc_NATOinit} forEach _escortCrew;
				[_escort, _sideX] call A3A_fnc_AIVEHinit;
				{_x setCombatBehaviour "COMBAT"} forEach _escortCrew;
				_vehicles pushBack _escort;
				_units append _escortCrew;
				_groups pushBack _groupEscort;
				_escort setVelocityModelSpace [0, 400, 0];
				sleep 3;
				_wp1 = _groupEscort addWaypoint [getPos (leader _groupX), 0];
				_wp1 setWaypointType "SAD";
			};
		};
		
		waitUntil {sleep 1; (_objectives findIf { alive _x } == -1) or (_objectives findIf {_x inArea _endMarker} != -1)};
	
		if (_objectives findIf { alive _x } == -1) then {
			[_taskId, "DES", "SUCCEEDED"] call A3A_fnc_taskSetState;
			[0,4000,0] remoteExec ["A3A_fnc_resourcesFIA",2];
			if (_sideX == Invaders) then {
    		        aggressionInvaders = aggressionInvaders - 20;
    		    } else {
    		        aggressionOccupants = aggressionOccupants - 20;
    		    };
    		    [] call A3A_fnc_calculateAggression;
			[1200*_bonus, _sideX] remoteExec ["A3A_fnc_timingCA",2];
			{ [200, _x] call A3A_fnc_playerScoreAdd } forEach (call BIS_fnc_listPlayers) select { side _x == teamPlayer || side _x == civilian};
		} else {
			_time = time + 600;
			waitUntil {sleep 1; (_objectives findIf { alive _x } == -1) or (time > _time)};
			if (_objectives findIf { alive _x } == -1) then {
				[_taskId, "DES", "SUCCEEDED"] call A3A_fnc_taskSetState;
				[0,4000,0] remoteExec ["A3A_fnc_resourcesFIA",2];
				if (_sideX == Invaders) then {
    		        aggressionInvaders = aggressionInvaders - 20;
    		    } else {
    		        aggressionOccupants = aggressionOccupants - 20;
    		    };
    		    [] call A3A_fnc_calculateAggression;
				[1200*_bonus, _sideX] remoteExec ["A3A_fnc_timingCA",2];
				{ [200, _x] call A3A_fnc_playerScoreAdd } forEach (call BIS_fnc_listPlayers) select { side _x == teamPlayer || side _x == civilian};
			} else {
		    	[_taskId, "DES", "FAILED"] call A3A_fnc_taskSetState;
				[0,-500*_bonus,0] remoteExec ["A3A_fnc_resourcesFIA",2];
				if (_sideX == Occupants) then {aggressionOccupants = aggressionOccupants + 20} else {aggressionInvaders = aggressionInvaders + 20};
				[] call A3A_fnc_calculateAggression;
				[-600*_bonus, _sideX] remoteExec ["A3A_fnc_timingCA",2];
			};
		};

		sleep 300;

		[_taskId, "DES", 1200] spawn A3A_fnc_taskDelete;
		
		{
		if (alive _x) then {deleteVehicle _x};
		} forEach _units;
		
		{[_x] spawn A3A_fnc_groupDespawner} forEach _groups;
		{[_x] spawn A3A_fnc_vehDespawner} forEach _vehicles;

	};

	case (_mission == "subs"): {
		
		private _vehicles = [];
		private _typeVehX = if (_sideX == Occupants) then {"sab_nl_u557"} else {selectRandom vehCSATPlanes};
		private _spawnArray = ["uboat_1","uboat_2","uboat_3","uboat_4"];

		private _taskId = "DES" + str A3A_taskCount;
		[[teamPlayer,civilian],_taskId,[format ["A U-boat is taking on fuel and supplies at %1. Destroy it before it goes back out to sea and threatens our convoys. <br/><br/>Reward: 1000CP per player.",_nameDest],"Destroy U-boat",_markerX],_positionX,false,0,true,"Destroy",true] call BIS_fnc_taskCreate;
		[_taskId, "DES", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];

		_bonus = if (_difficultX) then {2} else {1};
	
		private _spawnMarker = [_spawnArray, _markerX] call BIS_fnc_nearestPosition;
		private _spawnDir = markerDir _spawnMarker;
		private _spawnPos = getMarkerPos _spawnMarker;

		_sub = createVehicle [_typeVehX, [0,0,0], [], 0, "NONE"];
		_sub setDir _spawnDir;
		_sub setPos _spawnPos;
		[_sub, _sideX] call A3A_fnc_AIVEHinit;
		
		waitUntil {sleep 1;(dateToNumber date > _dateLimitNum) or !alive _sub};
	
		if (!alive _sub) then {	
			[_taskId, "DES", "SUCCEEDED"] call A3A_fnc_taskSetState;
			
			[0,2000,0] remoteExec ["A3A_fnc_resourcesFIA",2];
			if (_sideX == Invaders) then {
	            [0,10*_bonus,_positionX] remoteExec ["A3A_fnc_citySupportChange",2];
	            aggressionInvaders = aggressionInvaders - 10;
	        } else {
	            [0,5*_bonus,_positionX] remoteExec ["A3A_fnc_citySupportChange",2];
	            aggressionOccupants = aggressionOccupants - 10;
	        };
	        [] call A3A_fnc_calculateAggression;
			[1200*_bonus, _sideX] remoteExec ["A3A_fnc_timingCA",2];
			{ [100, _x] call A3A_fnc_playerScoreAdd } forEach (call BIS_fnc_listPlayers) select { side _x == teamPlayer || side _x == civilian};
		} else {
		    [_taskId, "DES", "FAILED"] call A3A_fnc_taskSetState;
			[-600*_bonus, _sideX] remoteExec ["A3A_fnc_timingCA",2];
		};

		[_taskId, "DES", 1200] spawn A3A_fnc_taskDelete;

		[_sub] spawn A3A_fnc_vehDespawner;
	};
};