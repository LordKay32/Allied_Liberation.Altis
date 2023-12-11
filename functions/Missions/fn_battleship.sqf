//Mission: Destroy the vehicle
if (!isServer and hasInterface) exitWith{};
if (battleshipDone == true) exitWith{};

private ["_positionX", "_sideX", "_dateLimit","_dateLimitNum","_nameDest","_typeVehX", "_escortShip"];

waitUntil {sleep 900; (["paros", "airport"] findIf {(sidesX getVariable [_x,sideUnknown] == teamPlayer)} != -1 || battleshipStarted == true)};
battleshipStarted = true;
sleep 120;
_difficultX = if (aggressionLevelOccupants > 3) then {true} else {false};
_bonus = if (_difficultX) then {2} else {1};
_positionX = [15512.5,13113.4,0];
_sideX = Occupants;
_timeLimit = if (_difficultX) then {90 * settingsTimeMultiplier} else {120 * settingsTimeMultiplier};
_dateLimit = [date select 0, date select 1, date select 2, date select 3, (date select 4) + _timeLimit];
_dateLimitNum = dateToNumber _dateLimit;
_dateLimit = numberToDate [date select 0, _dateLimitNum];//converts datenumber back to date array so that time formats correctly
_displayTime = [_dateLimit] call A3A_fnc_dateToTimeString;//Converts the time portion of the date array to a string for clarity in hints
		
		private _units = [];
		private _vehicles = [];
		private _objectives = [];
		private _groups = [];

		_typeVehX = if (_sideX == Occupants) then {"sab_nl_zara"} else {selectRandom vehCSATTransportPlanes};
		_escortShip = if (_sideX == Occupants) then {"sab_nl_vincenzo"} else {selectRandom vehCSATPlanesAA};
		_crew = "sab_nl_sailor_blue";
		
		_reward = 5000;
		private _taskId = "DES" + str A3A_taskCount;
		[[teamPlayer,civilian],_taskId,[format["A heavy cruiser of the Italian Regia Marina has been sheltering in the Pyrgos Gulf. Due to our recent advances, it is now threatened by Allied air power. It has weighed anchor and is heading for the open sea. Go and sink it. <br/><br/>Reward: %1CP per player", _reward],"Sink Heavy Cruiser","battleship_1"],_positionX,false,0,true,"Destroy",true] call BIS_fnc_taskCreate;
		[_taskId, "DES", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];

	private _spawnShip = {
		params ["_vehType", "_spawnPos", "_sideX", "_groups", "_crew", "_vehicles"];
		private _groupX = createGroup _sideX;
		_veh = createVehicle [_vehType,[0,0,0], [], 0, "NONE"];
		_dir = 210.759;
		_veh setDir _dir;
		_veh setVehiclePosition [_spawnPos, [], 0, "NONE"];
		[_veh, _sideX] call A3A_fnc_AIVEHinit;
		if (_vehType == "sab_nl_zara") then {_objectives pushBack _veh};
		
		_veh engineOn true;

		_unit = [_groupX, _crew, _spawnPos, [], 0, "NONE"] call A3A_fnc_createUnit;
		_unit moveInDriver _veh;
		[_unit,""] call A3A_fnc_NATOinit;
		_unit setCombatBehaviour "CARELESS";
		_unit disableAI "MOVE";
		_groups pushBack _groupX;
		_vehicles pushBack _veh;
	};	

	//spawn convoy
	
		private _posOrigin = [15512.5,13113.4,0];
		private _spawnPos = _posOrigin;
		
		[_typeVehX, _spawnPos, _sideX, _groups, _crew, _vehicles] call _spawnShip;
		_spawnPos = _spawnPos getPos [-650, 210.759];
		
		[_escortShip, _spawnPos, _sideX, _groups, _crew, _vehicles] call _spawnShip;
		_spawnPos = _spawnPos getPos [-500, 210.759];
		
		[_escortShip, _spawnPos, _sideX, _groups, _crew, _vehicles] call _spawnShip;	
		
		sleep 2;
		
		{
			[_x] spawn {
				_ship = _this select 0;
				_num = if (typeOf _ship == "sab_nl_zara") then {8} else {30};
				while {alive _ship} do {
					_ship setVelocityModelSpace [0,16,0];
					sleep 0.1;
					if (_ship inArea "battleship_1") exitWith {
						driver _ship enableAI "MOVE"; 
						driver _ship doMove getMarkerPos "battleship_2"; 
						_dir = _ship getDir getMarkerPos "battleship_2"; 
						waitUntil {getDir _ship > (_dir - _num) && getDir _ship < (_dir + _num)};		
						driver _ship disableAI "MOVE"; 
						while {alive _ship} do {
							_ship setVelocityModelSpace [0,16,0]; 
							sleep 0.1; 
							if (_ship inArea "battleship_2") exitWith {
								driver _ship enableAI "MOVE"; 
								driver _ship doMove getMarkerPos "battleship_3"; 
								_dir = _ship getDir getMarkerPos "battleship_3";
								waitUntil {getDir _ship > (_dir - _num) && getDir _ship < (_dir + _num)}; 		
								driver _ship disableAI "MOVE"; 
								while {alive _ship} do {
									_ship setVelocityModelSpace [0,16,0]; 
									sleep 0.1; 
									if (_ship inArea "battleship_3") exitWith {
										driver _ship enableAI "MOVE"; 
										driver _ship doMove getMarkerPos "battleship_4"; 
										_dir = _ship getDir getMarkerPos "battleship_4";
										waitUntil {getDir _ship > (_dir - _num) && getDir _ship < (_dir + _num)}; 		
										driver _ship disableAI "MOVE"; 
										while {alive _ship} do {
											_ship setVelocityModelSpace [0,16,0]; 
											sleep 0.1; 
											if (_ship inArea "battleship_4") exitWith {
												while {alive _ship} do {
												_ship setVelocityModelSpace [0,16,0]; 
												sleep 0.5;
												};	
											};
										};
									};
								};			
							};
						};	
					};						
				};
			};
			[_x, _crew] spawn {
				params ["_veh", "_crew"];
				waitUntil {sleep 1; ((_veh nearEntities 2000) findIf {side _x == teamPlayer}) != -1};
				_num = if (typeOf _veh == "sab_nl_vincenzo") then {10} else {19};
				for "_i" from 1 to _num do {
					_unit = [group driver _veh, _crew, [0,0,0], [], 0, "NONE"] call A3A_fnc_createUnit;
					_unit moveInAny _veh;
					[_unit,""] call A3A_fnc_NATOinit;
				};
			};		
		} forEach _vehicles;		

		//Escort Planes
		[_objectives, _bonus, _sideX, _vehicles, _units ,_groups] spawn {
			params ["_objectives", "_bonus", "_sideX", "_vehicles", "_units", "_groups"];
			waitUntil {sleep 5; (((_objectives select 0) nearEntities ["air", 2000]) findIf {side _x == teamPlayer}) != -1};
			for "i" from 1 to (2 * _bonus) do {
				_typeEscortX = if (_sideX == Occupants) then {selectRandom vehNATOPlanesAA} else {selectRandom vehCSATPlanesAA};
				_origin = getMarkerPos "airport_3";
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
				_wp1 = _groupEscort addWaypoint [getPos (_objectives select 0), 0];
				_wp1 setWaypointType "SAD";
			};
		};
		
		waitUntil {sleep 1; (_objectives findIf { alive _x } == -1) or (_objectives findIf {_x inArea "battleship_4"} != -1)};
	
		battleshipDone = true;
	
		if (_objectives findIf { alive _x } == -1) then {
			[_taskId, "DES", "SUCCEEDED"] call A3A_fnc_taskSetState;
			[0,5000*_bonus,0] remoteExec ["A3A_fnc_resourcesFIA",2];
   	        [0,10*_bonus,_positionX] remoteExec ["A3A_fnc_citySupportChange",2];
			[1200*_bonus, _sideX] remoteExec ["A3A_fnc_timingCA",2];
			{ [500*_bonus, _x] call A3A_fnc_playerScoreAdd } forEach (call BIS_fnc_listPlayers) select { side _x == teamPlayer || side _x == civilian};
			[100*_bonus,theBoss] call A3A_fnc_playerScoreAdd;
		} else {
	    	[_taskId, "DES", "FAILED"] call A3A_fnc_taskSetState;
			[0,-500*_bonus,0] remoteExec ["A3A_fnc_resourcesFIA",2];
			[0,-5*_bonus,_positionX] remoteExec ["A3A_fnc_citySupportChange",2];
			[-600*_bonus, _sideX] remoteExec ["A3A_fnc_timingCA",2];
			[-50*_bonus,theBoss] call A3A_fnc_playerScoreAdd;
		};

		sleep 300;

		[_taskId, "DES", 1200] spawn A3A_fnc_taskDelete;
		
		{
		if (alive _x) then {deleteVehicle _x};
		} forEach _units;
		
		{[_x] spawn A3A_fnc_groupDespawner} forEach _groups;
		{[_x] spawn A3A_fnc_vehDespawner} forEach _vehicles;
