if (!isServer and hasInterface) exitWith {};

private ["_posOrigin","_typeGroup","_nameOrigin","_markTsk","_wp1","_soldiers","_landpos","_pad","_vehiclesX","_wp0","_wp3","_wp4","_wp2","_groupX","_groups","_typeVehX","_vehicle","_heli","_heliCrew","_groupHeli","_pilots","_rnd","_resourcesAAF","_nVeh","_radiusX","_roads","_Vwp1","_road","_veh","_vehCrew","_groupVeh","_Vwp0","_size","_Hwp0","_groupX1","_uwp0","_tsk","_vehicle","_soldierX","_pilot","_posDestination","_prestigeCSAT","_airportX","_nameDest","_timeX","_solMax","_nul","_costs","_typeX","_threatEvalAir","_threatEvalLand","_pos","_timeOut","_sideX","_countX","_tsk1","_spawnPoint","_vehPool", "_airportIndex"];

private _fileName = "wavedCA";

bigAttackInProgress = true;
publicVariable "bigAttackInProgress";

//_mrkOrigin can be an Airport or Carrier
//_originalSide is optional, side that should have their attack counter incremented
params ["_mrkDestination", "_mrkOrigin", "_waves", "_originalSide"];

_outposts = outposts select {(sidesX getVariable [_x,sideUnknown] == _originalSide) and ((getMarkerPos _x) distance (getMarkerPos _mrkDestination) < distanceForLandAttack) and ([_x, _mrkDestination] call A3A_fnc_arePositionsConnected)};
_outpost = if (count _outposts > 0) then {_outposts select 0} else {""};

_mrkOrigin = if (((getMarkerPos _mrkOrigin) distance (getMarkerPos _mrkDestination) > distanceForLandAttack) && (count _outposts > 0)) then {_outpost} else {_mrkOrigin};

_firstWave = true;
if (_waves <= 0) then {_waves = -1};
_size = [_mrkDestination] call A3A_fnc_sizeMarker;
_tsk = "";
_tsk1 = "";
_posDestination = getMarkerPos _mrkDestination;
_posOrigin = getMarkerPos _mrkOrigin;

diag_log format ["[Antistasi] Spawning Waved Attack Against %1 from %2 with %3 waves (wavedCA.sqf)", _mrkDestination, _mrkOrigin,	_waves];

_groups = []; 
_soldiersTotal = [];
_pilots = [];
_vehiclesX = [];
_forced = [];

_nameDest = [_mrkDestination] call A3A_fnc_localizar;
_nameOrigin = [_mrkOrigin] call A3A_fnc_localizar;

_sideX = sidesX getVariable [_mrkOrigin,sideUnknown];
if (isNil "_originalSide") then { _originalSide = _sideX };
_sideTsk = [teamPlayer,civilian,Invaders];
_sideTsk1 = [Occupants];
_nameENY = nameOccupants;
//_config = cfgNATOInf;
if (_sideX == Invaders) then
	{
	_nameENY = nameInvaders;
	//_config = cfgCSATInf;
	_sideTsk = [teamPlayer,civilian,Occupants];
	_sideTsk1 = [Invaders];
	};
_isSDK = if (sidesX getVariable [_mrkDestination,sideUnknown] == teamPlayer) then {true} else {false};
_SDKShown = false;
if (_isSDK) then
	{
	_sideTsk = [teamPlayer,civilian,Occupants,Invaders] - [_sideX];
	}
else
	{
	if (not(_mrkDestination in _forced)) then {_forced pushBack _mrkDestination};
	};

//forcedSpawn = forcedSpawn + _forced; publicVariable "forcedSpawn";
forcedSpawn pushBack _mrkDestination; publicVariable "forcedSpawn";
diag_log format ["%1: [Antistasi] | INFO | Side Attacker:%2, Side Defender: %3",servertime,_sideX,_isSDK];
_nameDest = [_mrkDestination] call A3A_fnc_localizar;

private _taskId = "rebelAttack" + str A3A_taskCount;
[_sideTsk,_taskId,[format ["The %2 is attacking from %1. Defend against them or we may lose a sector",_nameOrigin,_nameENY],format ["%1 Attack",_nameENY],_mrkOrigin],objNull,false,0,true,"Defend",true] call BIS_fnc_taskCreate;
[_sideTsk1,_taskId+"B",[format ["We are attacking %2 from the %1. Help the operation if you can",_nameOrigin,_nameDest],format ["%1 Attack",_nameENY],_mrkDestination],getMarkerPos _mrkDestination,false,0,true,"Attack",true] call BIS_fnc_taskCreate;
[_taskId, "rebelAttack", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];

[_mrkDestination, _sideX, _posOrigin] spawn {
	params ["_mrkDestination", "_sideX", "_posOrigin"];
	_posDestination = getMarkerPos _mrkDestination;
	if ((aggressionLevelOccupants > 2) && (random 100 > 50)) then {
		sleep ((_posOrigin distance _posDestination)/9);
		_startAirport = [((airportsX +["NATO_carrier","CSAT_carrier"]) select {(spawner getVariable _x != 0) && ((getMarkerPos _x) distance _posDestination > 4000) && (sidesX getVariable [_x,sideUnknown] == _sideX)}), _mrkDestination] call BIS_fnc_nearestPosition;
		[_mrkDestination, _sideX, _startAirport] spawn A3A_fnc_bomberAttack;
	} else {
		sleep ((_posOrigin distance _posDestination)/11);
		[_posDestination] spawn A3A_fnc_artyAttack;
	};
};

private _vehPoolLand = [];
private _vehPoolAirSupport = [];
private _vehPoolAirTransport = [];

// unlimited vehicle types, for later use
private _typePatrolHeli = if (_sideX == Occupants) then {vehNATOPatrolHeli} else {vehCSATPatrolHeli};
private _typesTruck = if (_sideX == Occupants) then {vehNATOTrucks} else {vehCSATTrucks};
private _typesMRAP = if (_sideX == Occupants) then {vehNATOLightArmed} else {vehCSATLightArmed};

// Just getting the variables out of scope
call {
	private _typesAPC = if (_sideX == Occupants) then {vehNATOAPC} else {vehCSATAPC};
	private _typesTank = if (_sideX == Occupants) then {vehNATOTanks} else {vehCSATTanks};
	private _typesAA = if (_sideX == Occupants) then {vehNATOAA} else {vehCSATAA};

	// Add up to 4 + tierWar APCs, selected randomly from available vehicles
	{
		private _vcount = floor (timer getVariable [_x, 0]);
		for "_i" from 1 to (_vcount) do { _vehPoolLand pushBack _x };
	} forEach _typesAPC;

	{
		private _vcount = tierWar min (timer getVariable [_x, 0]);
		for "_i" from 1 to (_vcount) do { _vehPoolLand pushBack _x };
	} forEach _typesTank;

	_vehPoolLand = _vehPoolLand call BIS_fnc_arrayShuffle;
	_vehPoolLand resize ((4 + tierWar) min (count _vehPoolLand));

	// Add in war-tier capped AA vehicles
	{
		private _aacount = (ceil (tierWar / 3)) min (timer getVariable [_x, 0]);
		for "_i" from 1 to (_aacount) do { _vehPoolLand pushBack _x };
	} forEach _typesAA;

	// Add some trucks and MRAPs
	private _truckCount = 8;
	for "_i" from 1 to (_truckCount) do { _vehPoolLand pushBack (selectRandom _typesTruck) };
	private _mrapCount = 4;
	for "_i" from 1 to (_mrapCount) do { _vehPoolLand pushBack (selectRandom _typesMRAP) };


	// Separate air support from transports because air support can't conquer

	private _typePlane = if (_sideX == Occupants) then {selectRandom vehNATOPlanes} else {selectRandom vehCSATPlanes};
	private _typePlaneAA = if (_sideX == Occupants) then {selectRandom vehNATOPlanesAA} else {selectRandom vehCSATPlanesAA};
	private _typesAttackHelis = if (_sideX == Occupants) then {vehNATOAttackHelis} else {vehCSATAttackHelis};
	private _typesTransportPlanes = if (_sideX == Occupants) then {vehNATOTransportPlanes} else {vehCSATTransportPlanes};
	private _typesTransportHelis = if (_sideX == Occupants) then {vehNATOTransportHelis} else {vehCSATTransportHelis};

	// Plus a handful of fixed-wing aircraft
	private _planeCount = if (_posOrigin distance _posDestination < distanceForLandAttack) then {3} else {5};
	for "_i" from 1 to (_planeCount) do { _vehPoolAirSupport pushBack _typePlane };
	for "_i" from 1 to (_planeCount) do { _vehPoolAirSupport pushBack _typePlaneAA };

	// Use up to 8 + tierWar/2 air transports, randomly selected from available vehicles
	{
		private _vcount = floor (timer getVariable [_x, 0]);
		for "_i" from 1 to (_vcount) do { _vehPoolAirTransport pushBack _x };
	} forEach (_typesTransportPlanes);
	_vehPoolAirTransport = _vehPoolAirTransport call BIS_fnc_arrayShuffle;
	_vehPoolAirTransport resize ((8 + tierWar/2) min (count _vehPoolAirTransport));
};

[3, format ["Land vehicle pool: %1", _vehPoolLand], _filename] call A3A_fnc_log;
[3, format ["Air transport pool: %1", _vehPoolAirTransport], _filename] call A3A_fnc_log;
[3, format ["Air support pool: %1", _vehPoolAirSupport], _filename] call A3A_fnc_log;

private _airSupport = [];
private _uav = objNull;

// First wave: half air support, half either air transports or ground vehicles.
// Subsequent waves: if live air support < half, top up. Otherwise, +1 air support. Fill out with transports/ground.
// Only one UAV at a time, rebuild if destroyed instead of one vehicle.
// Builds minimum 10 soldiers (air cargo or ground units) per wave.

while {(_waves > 0)} do
{
	_posOrigin = getMarkerPos _mrkOrigin;
	_soldiers = [];
	private _playerScale = if (_isSDK) then { call A3A_fnc_getPlayerScale } else { 1 };			// occ vs inv attacks shouldn't depend on player count
	_nVeh = round ((0.4 * aggressionLevelOccupants) + random 1 + (3 * _playerScale));
	if (_firstWave) then { _nVeh = _nVeh + 2 };

    [3, format ["Due to %1 player scale, wave will contain %2 vehicles", _playerScale, _nVeh], _fileName] call A3A_fnc_log;

	_posOriginLand = [];
	_pos = [];
	_dir = 0;
	_spawnPoint = "";
	if !(_mrkDestination in blackListDest) then {
		//Attempt land attack if origin is an airport in range
		_airportIndex = (airportsX + milbases + outposts) find _mrkOrigin;
		if (_airportIndex >= 0 and (_posOrigin distance _posDestination < distanceForLandAttack)
			and ([_posOrigin, _posDestination] call A3A_fnc_arePositionsConnected)) then
		{
			_spawnPoint = _mrkOrigin; //server getVariable (format ["spawn_%1", _mrkOrigin]);
			_pos = getMarkerPos _spawnPoint;
			_posOriginLand = _posOrigin;
			_dir = markerDir _spawnPoint;
		};
	};
	private _nVehLand = 0;
	if (!(_posOriginLand isEqualTo []) && (_posOrigin distance _posDestination < distanceForLandAttack)) then
	{
		_nVehLand = if (_mrkOrigin in outposts) then {ceil (_nVeh/2)} else {ceil _nVeh};
		_road = [_posDestination] call A3A_fnc_findNearestGoodRoad;
		_countX = 1;
		_landPosBlacklist = [];
		private _convoy = [];
		while {_countX <= _nVehLand} do
		{
			if (count _vehPoolLand == 0) then {
				_vehPoolLand append _typesTruck;
				_vehPoolLand append _typesMRAP;
				_waves = 0;
				[2, "Attack ran out of land vehicles", _filename] call A3A_fnc_log;
			};
			_typeVehX = if ((_countX < ((_nVehLand/2) min 3)) && ({_x in _typesTruck} count _vehPoolLand > 0)) then {selectRandom (_vehPoolLand select {_x in _typesTruck})} else {selectRandom _vehPoolLand};
			_vehPoolLand deleteAt (_vehPoolLand find _typeVehX);
			[3, format ["Spawning vehicle type %1", _typeVehX], _filename] call A3A_fnc_log;

			if (true) then
			{
/*				_timeOut = 0;
				_pos = _pos findEmptyPosition [0,100,_typeVehX];
				while {_timeOut < 60} do
				{
					if (count _pos > 0) exitWith {};
					_timeOut = _timeOut + 1;
					_pos = _pos findEmptyPosition [0,100,_typeVehX];
					sleep 1;
				};
				if (count _pos == 0) then {_pos = getMarkerPos _spawnPoint};
				_vehicle=[_pos, _dir,_typeVehX, _sideX] call A3A_fnc_spawnVehicle;
*/
				_posOrigin = navGrid select ([_mrkOrigin] call A3A_fnc_getMarkerNavPoint) select 0;

				private _route = [(getMarkerPos _mrkOrigin), (getMarkerPos _mrkDestination)] call A3A_fnc_findPath;

				private _markers = [];

				_route = _route apply { _x select 0 };			// reduce to position array
				if (_route isEqualTo []) then { 
				  // find nearest road for origin
				  _roadpos = _posOrigin;
				  _roads = _posOrigin nearRoads 100;
				  if !(_roads isEqualTo []) then {
				    _roadpos = (getRoadInfo(_roads select 0)) select 6;
				  };
				  _route = [_roadpos, _posDestination] 
				};

				// AH - Move route forward by 40 m to ensure convoy isn't stuck in a base or other origin object
				if (count _route > 2) then {
				  // more than 2 nodes (assume proper path)
				  _state = [];
				  _state = [_route, 40, _state] call A3A_fnc_findPosOnRoute;
				  _route = _route select [_state#2, count _route]; // Trim route down to start 40 m ahead
				};
	
				// Find location down route
				private _pathState = [];
				_pathState = [_route, [40, 0] select (count _pathState == 0), _pathState] call A3A_fnc_findPosOnRoute;
				while {true} do {
				    // make sure there are no other vehicles within 10m
				    if (count (ASLtoAGL (_pathState#0) nearEntities 10) == 0) exitWith {};
				    _pathState = [_route, 10, _pathState] call A3A_fnc_findPosOnRoute;
				};
				private _spawnPos = ASLtoAGL (_pathState#0) vectorAdd [0,0,0.5];
				private _vehicle = [_spawnPos, _dir,_typeVehX, _sideX] call A3A_fnc_spawnVehicle;


				//private _vehicle = createVehicle [_vehicleType, ASLtoAGL (_pathState#0) vectorAdd [0,0,0.5]];             // Give it a little air
				private _vecUp = (_pathState#1) vectorCrossProduct [0,0,1] vectorCrossProduct (_pathState#1);       		// correct pitch angle
				//_vehicle setVectorDirAndUp [_pathState#1, _vecUp];

				_veh = _vehicle select 0;
				_veh setVectorDirAndUp [_pathState#1, _vecUp];
				_vehCrew = _vehicle select 1;
				{[_x] call A3A_fnc_NATOinit} forEach _vehCrew;
				[_veh, _sideX] call A3A_fnc_AIVEHinit;
				_groupVeh = _vehicle select 2;
				_groupVeh setBehaviourStrong "SAFE";
				_soldiers append _vehCrew;
				_soldiersTotal append _vehCrew;
				_groups pushBack _groupVeh;
				_convoy pushBack _veh;
				_vehiclesX pushBack _veh;
				_landPos = [_posDestination,_pos,false,_landPosBlacklist] call A3A_fnc_findSafeRoadToUnload;
				if (not(_typeVehX in vehTanks)) then
				{
					_landPosBlacklist pushBack _landPos;
					_typeGroup = [_typeVehX,_sideX] call A3A_fnc_cargoSeats;
					_grupo = grpNull;
					_grupo = [_posOrigin,_sideX, _typeGroup,true,false] call A3A_fnc_spawnGroup;
					{
                        _x assignAsCargo _veh;
                        _x moveInCargo _veh;
                        if (vehicle _x == _veh) then
                        {
                            _soldiers pushBack _x;
                            _soldiersTotal pushBack _x;
                            [_x] call A3A_fnc_NATOinit;
                            _x setVariable ["originX",_mrkOrigin];
                        }
                        else
                        {
                            deleteVehicle _x;
                        };
					} forEach units _grupo;
					if (not(_typeVehX in vehTrucks)) then
					{
						{_x disableAI "MINEDETECTION"} forEach (units _groupVeh);
						(units _grupo) joinSilent _groupVeh;
						deleteGroup _grupo;
						_groupVeh spawn A3A_fnc_attackDrillAI;
						/*[_posOriginLand,_landPos,_groupVeh] call A3A_fnc_WPCreate;
						_Vwp0 = _groupVeh addWaypoint [_landPos, count (wayPoints _groupVeh)];
						_Vwp0 setWaypointType "TR UNLOAD";
						_Vwp0 setWayPointCompletionRadius (10*_countX);
						_Vwp1 = _groupVeh addWaypoint [_posDestination, 1];
						_Vwp1 setWaypointType "SAD";
						_Vwp1 setWaypointStatements ["true","if !(local this) exitWith {}; {if (side _x != side this) then {this reveal [_x,4]}} forEach allUnits"];
						_Vwp1 setWaypointBehaviour "COMBAT";*/
						_veh allowCrewInImmobile true;
						private _typeName = if (_typeVehX in vehAPCs) then {"APC"} else {"MRAP"};
						[_veh,"APC"] spawn A3A_fnc_inmuneConvoy;
					}
					else
						{
						(units _grupo) joinSilent _groupVeh;
						deleteGroup _grupo;
						_groupVeh selectLeader (units _groupVeh select 1);
						_groupVeh spawn A3A_fnc_attackDrillAI;
						/*[_posOriginLand,_landPos,_groupVeh] call A3A_fnc_WPCreate;
						_Vwp0 = _groupVeh addWaypoint [_landPos, count (wayPoints _groupVeh)];
						_Vwp0 setWaypointType "GETOUT";
						_Vwp1 = _groupVeh addWaypoint [_posDestination, count (wayPoints _groupVeh)];
						_Vwp1 setWaypointType "SAD";*/
						[_veh,"Truck"] spawn A3A_fnc_inmuneConvoy;
					};
				}
				else
				{
					{_x disableAI "MINEDETECTION"} forEach (units _groupVeh);
					/*[_posOriginLand,_posDestination,_groupVeh] call A3A_fnc_WPCreate;
					_Vwp0 = _groupVeh addWaypoint [_posDestination, count (wayPoints _groupVeh)];
					_Vwp0 setWaypointType "MOVE";
					_Vwp0 setWaypointStatements ["true","if !(local this) exitWith {}; {if (side _x != side this) then {this reveal [_x,4]}} forEach allUnits"];
					_Vwp0 = _groupVeh addWaypoint [_posDestination, count (wayPoints _groupVeh)];
					_Vwp0 setWaypointType "SAD";*/
					private _typeName = if (_typeVehX in vehTanks) then {"Tank"} else {"AA"};
					[_veh, _typeName] spawn A3A_fnc_inmuneConvoy;
					_veh allowCrewInImmobile true;
				};
			};

			if ((count _soldiers >= 10) && ([_sideX] call A3A_fnc_remUnitCount < 5)) exitWith {
				[2, format ["Ground wave reached maximum units count after %1 vehicles", _countX], _filename] call A3A_fnc_log;
			};
			sleep 2;
			_countX = _countX + 1;
		};
	
	
		sleep 1;

		private _route = [_posOrigin, _posDestination] call A3A_fnc_findPath;

		_route = _route apply { _x select 0 };			// reduce to position array
		if (_route isEqualTo []) then { 
		  // find nearest road for origin
		  _roadpos = _posOrigin ;
		  _roads = _posOrigin nearRoads 100;
		  if !(_roads isEqualTo []) then {
		    _roadpos = (getRoadInfo(_roads select 0)) select 6;
		  };
		  _route = [_roadpos, _posDestination] 
		};

		// AH - Move route forward by 40 m to ensure convoy isn't stuck in a base or other origin object
		if (count _route > 2) then {
		  // more than 2 nodes (assume proper path)
		  _state = [];
		  _state = [_route, 40, _state] call A3A_fnc_findPosOnRoute;
		  _route = _route select [_state#2, count _route]; // Trim route down to start 40 m ahead
		};

		sleep 5;
		private _pathState = [];
		_pathState = [_route, [40, 0] select (count _pathState == 0), _pathState] call A3A_fnc_findPosOnRoute;
		_route = _route select [_pathState#2, count _route];        // remove navpoints that we already passed while spawning
	
		// This array is used to share remaining convoy vehicles between threads
		private _convoyVehicles = +_vehiclesX;
		reverse _convoyVehicles;
		{
		    (driver _x) stop false;
		    [_x, _route, _convoyVehicles, 30, true, _posDestination] spawn A3A_fnc_convoyScript;
			//[_x, _markNames#_forEachIndex, false] spawn A3A_fnc_inmuneConvoy;			// Disabled the stuck-vehicle hacks
		    sleep 5;
		} forEach _convoyVehicles;
	};

	_isSea = false;
	if (count seaAttackSpawn != 0) then
		{
		for "_i" from 0 to 3 do
			{
			_pos = _posDestination getPos [1000,(_i*90)];
			if (surfaceIsWater _pos) exitWith
				{
				if ({sidesX getVariable [_x,sideUnknown] == _sideX} count seaports > 1) then
					{
					_isSea = true;
					};
				};
			};
		};

	if ((_isSea) and (_firstWave)) then
		{
		_pos = getMarkerPos ([seaAttackSpawn,_posDestination] call BIS_fnc_nearestPosition);
		if (count _pos > 0) then
			{
			_vehPool = if (_sideX == Occupants) then {vehNATOBoats} else {vehCSATBoats};
			_vehPool = _vehPool select {[_x] call A3A_fnc_vehAvailable};
			_countX = 0;
			_spawnedSquad = false;
			while {(_countX < 3) and (count _soldiers <= 80)} do
				{
				_typeVehX = if (_vehPool isEqualTo []) then {if (_sideX == Occupants) then {vehNATORBoat} else {vehCSATRBoat}} else {selectRandom _vehPool};
				_proceed = true;
				if ((_typeVehX == vehNATOBoat) or (_typeVehX == vehCSATBoat)) then
					{
					_landPos = [_posDestination, 10, 1000, 10, 2, 0.3, 0] call BIS_Fnc_findSafePos;
					}
				else
					{
					_allUnits = {(local _x) and (alive _x)} count allUnits;
					_allUnitsSide = 0;
					_maxUnitsSide = maxUnits;
					if (gameMode <3) then
						{
						_allUnitsSide = {(local _x) and (alive _x) and (side group _x == _sideX)} count allUnits;
						_maxUnitsSide = round (maxUnits * 0.7);
						};
					if (((_allUnits + 4 > maxUnits) or (_allUnitsSide + 4 > _maxUnitsSide)) and _spawnedSquad) then
						{
						_proceed = false
						}
					else
						{
						_typeGroup = [_typeVehX,_sideX] call A3A_fnc_cargoSeats;
						_landPos = [_posDestination, 10, 1000, 10, 0, 0.3, 1] call BIS_Fnc_findSafePos;
						};
					};
				if ((count _landPos > 0) and _proceed) then
					{
					_spawnPos = [[[_pos, 200]], []] call BIS_fnc_randomPos;
					_vehicle = [_spawnPos, random 360,_typeVehX, _sideX] call A3A_fnc_spawnVehicle;

					_veh = _vehicle select 0;
					_vehCrew = _vehicle select 1;
					_groupVeh = _vehicle select 2;
					_pilots append _vehCrew;
					_groups pushBack _groupVeh;
					_vehiclesX pushBack _veh;
					{[_x] call A3A_fnc_NATOinit} forEach units _groupVeh;
					[_veh, _sideX] call A3A_fnc_AIVEHinit;
					if ((_typeVehX == vehNATOBoat) or (_typeVehX == vehCSATBoat)) then
						{
						_wp0 = _groupVeh addWaypoint [_landpos, 0];
						_wp0 setWaypointType "SAD";
						//[_veh,"Boat"] spawn A3A_fnc_inmuneConvoy;
						}
					else
						{
						_grupo = grpNull;
						if !(_spawnedSquad) then {_grupo = [_posOrigin,_sideX, _typeGroup,true,false] call A3A_fnc_spawnGroup;_spawnedSquad = true} else {_grupo = [_posOrigin,_sideX, _typeGroup,false,true] call A3A_fnc_spawnGroup};
						{
						_x assignAsCargo _veh;
						_x moveInCargo _veh;
						if (vehicle _x == _veh) then
							{
							_soldiers pushBack _x;
							_soldiersTotal pushBack _x;
							[_x] call A3A_fnc_NATOinit;
							_x setVariable ["originX",_mrkOrigin];
							}
						else
							{
							deleteVehicle _x;
							};
						} forEach units _grupo;
						if (_typeVehX in vehAPCs) then
							{
							_groups pushBack _grupo;
							_Vwp = _groupVeh addWaypoint [_landPos, 0];
							_Vwp setWaypointBehaviour "SAFE";
							_Vwp setWaypointType "TR UNLOAD";
							_Vwp setWaypointSpeed "FULL";
							_Vwp1 = _groupVeh addWaypoint [_posDestination, 1];
							_Vwp1 setWaypointType "SAD";
							_Vwp1 setWaypointStatements ["true","if !(local this) exitWith {}; {if (side _x != side this) then {this reveal [_x,4]}} forEach (allUnits select {!(_x getVariable 'unittype' in SASTroops)})"];
							_Vwp1 setWaypointBehaviour "COMBAT";
							_Vwp2 = _grupo addWaypoint [_landPos, 0];
							_Vwp2 setWaypointType "GETOUT";
							_Vwp2 setWaypointStatements ["true", "if !(local this) exitWith {}; (group this) spawn A3A_fnc_attackDrillAI"];
							//_grupo setVariable ["mrkAttack",_mrkDestination];
							_Vwp synchronizeWaypoint [_Vwp2];
							_Vwp3 = _grupo addWaypoint [_posDestination, 1];
							_Vwp3 setWaypointType "SAD";
							_veh allowCrewInImmobile true;
							//[_veh,"APC"] spawn A3A_fnc_inmuneConvoy;
							}
						else
							{
							(units _grupo) joinSilent _groupVeh;
							deleteGroup _grupo;
							_groupVeh selectLeader (units _groupVeh select 1);
							[_groupVeh,_veh] spawn {
								params ["_group","_veh"];
								waitUntil {sleep 1; isTouchingGround _veh};
								{unassignVehicle _x} forEach (units _group); [units _group] allowGetIn false;
							};	
							_Vwp = _groupVeh addWaypoint [_landPos, 0];
							_Vwp setWaypointBehaviour "SAFE";
							_Vwp setWaypointSpeed "FULL";
							_Vwp setWaypointType "GETOUT";
							_Vwp setWaypointStatements ["true", "if !(local this) exitWith {}; {unassignVehicle _x} forEach (units group this); [units group this] allowGetIn false; (group this) spawn A3A_fnc_attackDrillAI"];
							_Vwp1 = _groupVeh addWaypoint [_posDestination, 1];
							_Vwp1 setWaypointType "SAD";
							_Vwp1 setWaypointBehaviour "COMBAT";
							//[_veh,"Boat"] spawn A3A_fnc_inmuneConvoy;
							};
						};
					};
				sleep 15;
				_countX = _countX + 1;
				_vehPool = _vehPool select {[_x] call A3A_fnc_vehAvailable};
				};
			};
		};

	private _nVehAir = _nVeh;
	if !(_posOriginLand isEqualTo []) then {
		sleep ((_posOrigin distance _posDestination)/7);			// give land vehicles a head start
		_nVehAir = if (_posOrigin distance _posDestination < distanceForLandAttack) then {if ((_mrkDestination in (airportsX + milbases)) && (aggressionLevelOccupants > 3)) then {(round (_nVeh / 3)) + 1} else {round (_nVeh / 3)}} else {_nVeh - 1};				// fill out with air vehicles
	};
	_posGround = [_posOrigin select 0,_posOrigin select 1,0];
	_posOrigin set [2,300];

	_countX = 1;
	_pos = _posOrigin;
	private _airbase = if (_mrkOrigin in airportsX) then {_mrkOrigin} else {[((airportsX + ["NATO_carrier", "CSAT_carrier"]) select {(spawner getVariable _x != 0) && ((getMarkerPos _x) distance _posDestination > 4000) && (sidesX getVariable [_x,sideUnknown] == _sideX)}), _mrkDestination] call BIS_fnc_nearestPosition;};
	_ang = 0;
	_size = [_mrkOrigin] call A3A_fnc_sizeMarker;
	private _runwayTakeoff = [_airbase] call A3A_fnc_getRunwayTakeoffForAirportMarker;
	if (count _runwayTakeoff > 0) then {
		_pos = _runwayTakeoff select 0;
		_ang = _runwayTakeoff select 1;
	} else {
		_pos = getMarkerPos _airbase;
	};

	// Remove disabled air supports from active list
	_airSupport = _airSupport select { canMove _x };

	// Fill air supports up to half wave size, minimum +1
	private _countNewSupport = 1 max (floor (_nVeh / 2) - count _airSupport);
	[3, format ["Spawning %1 new support aircraft", _countNewSupport], _filename] call A3A_fnc_log;

	if (_countNewSupport > count _vehPoolAirSupport) then {
		_countNewSupport = count _vehPoolAirSupport;
		[2, "Attack ran out of air supports", _filename] call A3A_fnc_log;
		_waves = 0;
	};

	if !(canMove _uav) then
	{
		//75% chance to spawn a UAV, to give some variety.
		if (random 1 < 0.25) exitWith {};
		_typeVehX = if (_sideX == Occupants) then {vehNATOUAV} else {vehCSATUAV};
		if (_typeVehX isEqualTo "not_supported") exitWith {};
		_uav = createVehicle [_typeVehX, _posOrigin, [], 0, "FLY"];
		_vehiclesX pushBack _uav;
		_airSupport pushBack _uav;
		//[_uav,"UAV"] spawn A3A_fnc_inmuneConvoy;
		[_uav,_mrkDestination,_sideX] spawn A3A_fnc_VANTinfo;
		[_sideX, _uav] call A3A_fnc_createVehicleCrew;
		_pilots append (crew _uav);
		_groupVeh = group driver _uav;
		_groups pushBack _groupVeh;
		_uwp0 = _groupVeh addWayPoint [_posDestination,0];
		_uwp0 setWaypointBehaviour "AWARE";
		_uwp0 setWaypointType "SAD";
		{[_x] call A3A_fnc_NATOinit} forEach (crew _uav);
		[_uav, _sideX] call A3A_fnc_AIVEHinit;
		if (not(_mrkDestination in airportsX)) then {_uav removeMagazines "6Rnd_LG_scalpel"};
        [3, format ["Spawning vehicle type %1", _typeVehX], _filename] call A3A_fnc_log;
		sleep 5;
		_countX = _countX + 1;
	};
	
	private _paraPlane = [];
	
	while {_countX <= _nVehAir} do
	{
		private _typeVehX = "";
		if (_countX <= _countNewSupport) then {
			_typeVehX = selectRandom _vehPoolAirSupport;
			_vehPoolAirSupport deleteAt (_vehPoolAirSupport find _typeVehX);
		}
		else {
			if (count _vehPoolAirTransport == 0) then {
				for "_i" from 1 to 2 do { _vehPoolAirTransport pushBack (selectRandom vehNATOTransportPlanes) };
				[2, "Attack ran out of air transports", _filename] call A3A_fnc_log;
				_waves = 0;
			};
			_typeVehX = selectRandom _vehPoolAirTransport;
			_vehPoolAirTransport deleteAt (_vehPoolAirTransport find _typeVehX);
		};
		[3, format ["Spawning vehicle type %1", _typeVehX], _filename] call A3A_fnc_log;

		if (true) then
			{
			_vehicle=[_pos, _ang + 90,_typeVehX, _sideX] call A3A_fnc_spawnVehicle;
			_veh = _vehicle select 0;
			if (_veh isKindOf "Plane") then {
				_veh setVelocityModelSpace (velocityModelSpace _veh vectorAdd [0, 150, 50]);
			};
			if (_typeVehX in (vehNATOTransportPlanes + vehCSATTransportPlanes)) then {_paraPlane pushBack _veh};			
			_vehCrew = _vehicle select 1;
			_groupVeh = _vehicle select 2;
			_pilots append _vehCrew;
			_vehiclesX pushBack _veh;
			{[_x] call A3A_fnc_NATOinit} forEach units _groupVeh;
			[_veh, _sideX] call A3A_fnc_AIVEHinit;
			if (not (_typeVehX in vehTransportAir)) then
				{
				_airSupport pushBack _veh;
				_groups pushBack _groupVeh;
				_uwp0 = _groupVeh addWayPoint [_posDestination,0];
				_uwp0 setWaypointBehaviour "AWARE";
				_uwp0 setWaypointType "SAD";
				if (_typeVehX in vehNATOPlanes) then {
					private _AAGuns = (nearestObjects [_posDestination, [staticAAteamPlayer], 500]) select {side _x == teamPlayer};
					{
						_groupVeh reveal [_x, 4];
					} forEach _AAGuns
				};
				//[_veh,"Air Attack"] spawn A3A_fnc_inmuneConvoy;
				}
			else
				{
				_groups pushBack _groupVeh;
				_typeGroup = [_typeVehX,_sideX] call A3A_fnc_cargoSeats;
				_paraGroups = [];
				
				for "_i" from 1 to 2 do {
					_grupo = grpNull;
					_grupo = [_posGround,_sideX, _typeGroup,true,false] call A3A_fnc_spawnGroup;
					_groups pushBack _grupo;
					{
					_x moveInAny _veh;
					if (vehicle _x == _veh) then
						{
						_soldiers pushBack _x;
						_soldiersTotal pushBack _x;
						[_x] call A3A_fnc_NATOinit;
						_x setVariable ["originX",_mrkOrigin];
						}
					else
						{
						deleteVehicle _x;
						};
					} forEach units _grupo;
					_paraGroups pushBack _grupo;
				};
				if (!(_veh isKindOf "Helicopter") or (_posOrigin distance _posDestination > distanceForLandAttack)) then
					{
					[_veh,_paraGroups,_mrkDestination,_mrkOrigin] spawn A3A_fnc_paradrop;
					}
				else
					{
					_landPos = _posDestination getPos [150, random 360];
					_landPos = [_landPos, 0, 550, 10, 0, 0.20, 0,[],[[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
					if !(_landPos isEqualTo [0,0,0]) then
						{
						_landPos set [2, 0];
						_pad = createVehicle ["Land_HelipadEmpty_F", _landPos, [], 0, "NONE"];
						_vehiclesX pushBack _pad;
						_wp0 = _groupVeh addWaypoint [_landpos, 0];
						_wp0 setWaypointType "TR UNLOAD";
						_wp0 setWaypointStatements ["true", "if !(local this) exitWith {}; (vehicle this) land 'GET OUT';[vehicle this] call A3A_fnc_smokeCoverAuto"];
						_wp0 setWaypointBehaviour "CARELESS";
						_wp3 = _grupo addWaypoint [_landpos, 0];
						_wp3 setWaypointType "GETOUT";
						_wp3 setWaypointStatements ["true", "if !(local this) exitWith {}; (group this) spawn A3A_fnc_attackDrillAI"];
						_wp0 synchronizeWaypoint [_wp3];
						_wp4 = _grupo addWaypoint [_posDestination, 1];
						_wp4 setWaypointType "SAD";
						_wp4 = _grupo addWaypoint [_posDestination, 1];
						_wp2 = _groupVeh addWaypoint [_posOrigin, 1];
						_wp2 setWaypointType "MOVE";
						_wp2 setWaypointStatements ["true", "if !(local this) exitWith {}; deleteVehicle (vehicle this); {deleteVehicle _x} forEach thisList"];
						[_groupVeh,1] setWaypointBehaviour "AWARE";
						}
					else
						{
						{_x disableAI "TARGET"; _x disableAI "AUTOTARGET"} foreach units _groupVeh;
						if ((_typeVehX in vehFastRope) and ((count(garrison getVariable [_mrkDestination, []])) < 10)) then
							{
							//_grupo setVariable ["mrkAttack",_mrkDestination];
							[_veh,_grupo,_posDestination,_posOrigin,_groupVeh] spawn A3A_fnc_fastrope;
							}
						else
							{
							[_veh,_grupo,_mrkDestination,_mrkOrigin] spawn A3A_fnc_paradrop;
							}
						};
					};
				};
			};
		if ((_countX > _countNewSupport) && (count _soldiers >= 10) && ([_sideX] call A3A_fnc_remUnitCount < 5)) exitWith {
			[2, format ["Air wave reached maximum units count after %1 vehicles", _countX], _filename] call A3A_fnc_log;
		};
		sleep 2;
		_pos = [_pos, 80,_ang] call BIS_fnc_relPos;
		_countX = _countX + 1;
		private _paraPlaneNum = if (_firstWave) then {2} else {1};
		if ((_countX > _nVehAir) && (count _paraPlane < _paraPlaneNum) && (_posOrigin distance _posDestination > distanceForLandAttack)) then {_countX = _countX - 1};
		if ((count _paraPlane > 1) && (count _vehPoolAirSupport > 0)) then {_countNewSupport = _countX};
		if ((count _paraPlane > 1) && (count _vehPoolAirSupport == 0)) exitWith {};
		if ((_posOrigin distance _posDestination < distanceForLandAttack) && (count _paraPlane > 0)) exitWith {};
		};

	[2, format ["Spawn performed: %1 air vehicles inc. %2 supports, %3 land vehicles, %4 soldiers", _nVehAir, _countNewSupport, _nVehLand, count _soldiers], _filename] call A3A_fnc_log;

	private _planePool = if (_sideX == Occupants) then {vehNATOPlanes} else {vehCSATPlanes};
	private _isCasPlaneAvailable = (_planePool findIf {[_x] call A3A_fnc_vehAvailable} != -1);
	if (_sideX == Occupants) then
		{
		if ((not(_mrkDestination in outposts)) and (not(_mrkDestination in seaports)) and (_mrkOrigin != "NATO_carrier")) then
			{
            private _reveal = [getMarkerPos _mrkDestination, _sideX] call A3A_fnc_calculateSupportCallReveal;
            [getMarkerPos _mrkDestination, 4, ["MORTAR"], _sideX, _reveal] remoteExec ["A3A_fnc_sendSupport", 2];
			if (_isCasPlaneAvailable && {(!(_mrkDestination in citiesX)) && {_firstWave}}) then
				{
				sleep 60;
				_rnd = if (_mrkDestination in (airportsX + milbases)) then {round random 4} else {round random 2};
				for "_i" from 0 to _rnd do
					{
                        private _reveal = [getMarkerPos _mrkDestination, _sideX] call A3A_fnc_calculateSupportCallReveal;
                        [getMarkerPos _mrkDestination, 4, ["AIRSTRIKE"], _sideX, _reveal] remoteExec ["A3A_fnc_sendSupport", 2];
                        sleep 30;
					};
				};
			};
		}
	else
		{
		if ((not(_mrkDestination in resourcesX)) and (not(_mrkDestination in seaports)) and (_mrkOrigin != "CSAT_carrier")) then
			{
                private _reveal = [getMarkerPos _mrkDestination, _sideX] call A3A_fnc_calculateSupportCallReveal;
                    [getMarkerPos _mrkDestination, 4, ["MORTAR"], _sideX, _reveal] remoteExec ["A3A_fnc_sendSupport", 2];
			if (_isCasPlaneAvailable && {_firstWave}) then
				{
				sleep 60;
				_rnd = if (_mrkDestination in airportsX) then {if ({sidesX getVariable [_x,sideUnknown] == Invaders} count airportsX == 1) then {8} else {round random 4}} else {round random 2};
				for "_i" from 0 to _rnd do
					{
					if (_isCasPlaneAvailable) then
						{
                            private _reveal = [getMarkerPos _mrkDestination, _sideX] call A3A_fnc_calculateSupportCallReveal;
                            [getMarkerPos _mrkDestination, 4, ["AIRSTRIKE"], _sideX, _reveal] remoteExec ["A3A_fnc_sendSupport", 2];
						};
					};
				};
			};
		};

	_timeX = time + 600;		// wave timeout, 10 mins after the wave has finished spawning

	if (!_SDKShown) then
		{
		if !([true] call A3A_fnc_FIAradio) then {sleep 100};
		_SDKShown = true;
		["TaskSucceeded", ["", "Attack Destination Updated"]] remoteExec ["BIS_fnc_showNotification",teamPlayer];
		[_taskId, getMarkerPos _mrkDestination] call BIS_fnc_taskSetDestination;
		};
	_solMax = round ((count _soldiers)*0.6);
	_waves = _waves -1;
	_firstWave = false; 
	if (sidesX getVariable [_mrkDestination,sideUnknown] != teamPlayer) then {_soldiers spawn A3A_fnc_remoteBattle};
	if (_sideX == Occupants) then
		{
		waitUntil {sleep 5; (({!([_x] call A3A_fnc_canFight)} count _soldiers) >= _solMax) or (time > _timeX) or (sidesX getVariable [_mrkDestination,sideUnknown] == Occupants) or (({[_x,_mrkDestination] call A3A_fnc_canConquer} count _soldiers) > 3*({(side _x != _sideX) and (side _x != civilian) and ([_x,_mrkDestination] call A3A_fnc_canConquer)} count allUnits))};
		if  ((({[_x,_mrkDestination] call A3A_fnc_canConquer} count _soldiers) > 3*({(side _x != _sideX) and (side _x != civilian) and ([_x,_mrkDestination] call A3A_fnc_canConquer)} count allUnits)) or (sidesX getVariable [_mrkDestination,sideUnknown] == Occupants)) then
			{
			_waves = 0;
			if ((!(sidesX getVariable [_mrkDestination,sideUnknown] == Occupants)) and !(_mrkDestination in citiesX)) then {[Occupants,_mrkDestination] remoteExec ["A3A_fnc_markerChange",2]};
			[_taskId, "rebelAttack", "FAILED", true] call A3A_fnc_taskSetState;
			if (_mrkDestination in citiesX) then
			{
                //Impact the support on other cities in the area
                //They cant defend us, switch back to NATO
                {
                    if(_x != _mrkDestination) then
                    {
                        private _distance = (getMarkerPos _mrkDestination) distance2D (getMarkerPos _x);
                        private _supportChange = [0, 0];
                        if(_distance < 2000) then
                        {
                            _supportChange = [10, -10];
                        };
                        if(_distance < 1000) then
                        {
                            _supportChange = [20, -20];
                        };
                        if(_distance < 500) then
                        {
                            _supportChange = [30, -30];
                        };
                        if(_distance < 2000) then
                        {
                            _supportChange pushBack _x;
                            _supportChange remoteExec ["A3A_fnc_citySupportChange",2];
                        };
                    };
                } forEach citiesX;
				[60,-60,_mrkDestination,false] remoteExec ["A3A_fnc_citySupportChange",2];		// no pop scaling, force swing
				["TaskFailed", ["", format ["%1 joined %2",[_mrkDestination, false] call A3A_fnc_location,nameOccupants]]] remoteExec ["BIS_fnc_showNotification",teamPlayer];
				sidesX setVariable [_mrkDestination,Occupants,true];
				_mrkD = format ["Dum%1",_mrkDestination];
				_mrkD setMarkerColor colorOccupants;
				garrison setVariable [_mrkDestination,[],true];
				};
			};
		sleep 10;
		if (!(sidesX getVariable [_mrkDestination,sideUnknown] == Occupants)) then
			{
			if (sidesX getVariable [_mrkOrigin,sideUnknown] == Occupants) then
				{
				_killZones = killZones getVariable [_mrkOrigin,[]];
				_killZones append [_mrkDestination,_mrkDestination,_mrkDestination];
				killZones setVariable [_mrkOrigin,_killZones,true];
				};

			if ((_waves <= 0) or (!(sidesX getVariable [_mrkOrigin,sideUnknown] == Occupants))) then
				{
				{_x doMove _posOrigin} forEach _soldiersTotal;
				if (_waves <= 0) then {[_mrkDestination,_mrkOrigin] call A3A_fnc_minefieldAAF};

				[_taskId, "rebelAttack", "SUCCEEDED", true] call A3A_fnc_taskSetState;
				};
			};
		}
	else
		{
		waitUntil {sleep 5; (({!([_x] call A3A_fnc_canFight)} count _soldiers) >= _solMax) or (time > _timeX) or (sidesX getVariable [_mrkDestination,sideUnknown] == Invaders) or (({[_x,_mrkDestination] call A3A_fnc_canConquer} count _soldiers) > 3*({(side _x != _sideX) and (side _x != civilian) and ([_x,_mrkDestination] call A3A_fnc_canConquer)} count allUnits))};
		if  ((({[_x,_mrkDestination] call A3A_fnc_canConquer} count _soldiers) > 3*({(side _x != _sideX) and (side _x != civilian) and ([_x,_mrkDestination] call A3A_fnc_canConquer)} count allUnits)) or (sidesX getVariable [_mrkDestination,sideUnknown] == Invaders))  then
			{
			_waves = 0;
			if (not(sidesX getVariable [_mrkDestination,sideUnknown] == Invaders)) then {[Invaders,_mrkDestination] remoteExec ["A3A_fnc_markerChange",2]};
			[_taskId, "rebelAttack", "FAILED", true] call A3A_fnc_taskSetState;
			};
		sleep 10;
		if (!(sidesX getVariable [_mrkDestination,sideUnknown] == Invaders)) then
			{
            diag_log format ["%1: [Antistasi] | INFO | Wave number %2 on wavedCA lost",servertime,_waves];
			if (sidesX getVariable [_mrkOrigin,sideUnknown] == Invaders) then
				{
				_killZones = killZones getVariable [_mrkOrigin,[]];
				_killZones append [_mrkDestination,_mrkDestination,_mrkDestination];
				killZones setVariable [_mrkOrigin,_killZones,true];
				};

			if ((_waves <= 0) or (sidesX getVariable [_mrkOrigin,sideUnknown] != Invaders)) then
				{
				{_x doMove _posOrigin} forEach _soldiersTotal;
				if (_waves <= 0) then {[_mrkDestination,_mrkOrigin] call A3A_fnc_minefieldAAF};
				[_taskId, "rebelAttack", "SUCCEEDED", true] call A3A_fnc_taskSetState;
				};
			};
		};
	};

diag_log "Antistasi: Reached end of winning conditions. Starting despawn";
sleep 30;
[_taskId, "rebelAttack", 0, true] spawn A3A_fnc_taskDelete;

[_mrkOrigin,60] call A3A_fnc_addTimeForIdle;
[5400, _originalSide] remoteExec ["A3A_fnc_timingCA", 2];
bigAttackInProgress = false; publicVariable "bigAttackInProgress";
forcedSpawn = forcedSpawn - [_mrkDestination]; publicVariable "forcedSpawn";


// Hand remaining aggressor units to the group despawner

{
_groups pushBackUnique group _x;
} forEach _soldiers;

{
	// order return to base if it's an air group, city attack or if it was unsuccessful
	private _isPilot = vehicle leader _x isKindOf "Air";
	if (_isPilot || _mrkDestination in citiesX || sidesX getVariable [_mrkDestination,sideUnknown] != _sideX) then {
		private _wp = _x addWaypoint [_posOrigin, 50];
		_wp setWaypointType "MOVE";
		_x setCurrentWaypoint _wp;
	};
	[_x] spawn A3A_fnc_groupDespawner;
} forEach _groups;

{ [_x] spawn A3A_fnc_VEHdespawner } forEach _vehiclesX;
