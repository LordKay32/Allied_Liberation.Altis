//Mission: Capture/destroy the convoy
if (!isServer and hasInterface) exitWith {};
params ["_mrkDest", "_mrkOrigin", ["_convoyType", ""], ["_startDelay", -1], ["_visible", false]];

private _fileName = "fn_convoy";

private _difficult = if (aggressionLevelOccupants > 3) then {true} else {false};
private _sideX = if (sidesX getVariable [_mrkOrigin,sideUnknown] == Occupants) then {Occupants} else {Invaders};
private _isMilitia = (_sideX == Occupants and (random 10 >= tierWar) and !_difficult);
private _isMilitia = switch(true) do {
    case (_sideX == Occupants and (random 10 >= tierWar) and !_difficult): {
        true;
    };
    case (gameMode == 4 && ({_sideX == Invaders && (random 10 >= tierWar) && !_difficult})): {
        true;
    };
    default  {
        false;
    };
};

private _posSpawn = getMarkerPos _mrkOrigin;			// used for spawning infantry before moving them into vehicles
private _posHQ = getMarkerPos respawnTeamPlayer;

private _soldiers = [];
private _vehiclesX = [];
private _markNames = [];
private _POWS = [];
private _reinforcementsX = [];


// Setup start time

if (_startDelay < 0) then { _startDelay = random 15 + ([30, 20] select _difficult) };
private _startDateNum = dateToNumber date + _startDelay * timeMultiplier / (365*24*60);
private _startDate = numberToDate [date select 0, _startDateNum];
private _displayTime = [_startDate] call A3A_fnc_dateToTimeString;

private _nameDest = [_mrkDest] call A3A_fnc_localizar;
private _nameOrigin = [_mrkOrigin] call A3A_fnc_localizar;
[_mrkOrigin, 30] call A3A_fnc_addTimeForIdle;

// Determine convoy type from destination
private _convoyTypes = [];
if (_mrkDest in (outposts + seaports)) then {
	_convoyTypes = ["Ammunition","Armor","Prisoners","Reinforcements"];
};

if (_mrkDest in (airportsX + milbases)) then {
	_convoyTypes = ["Ammunition","Armor","Fuel","Reinforcements"];
};

if (_convoyType == "") then { _convoyType = selectRandom _convoyTypes };

private _textX = "";
private _taskState = "CREATED";
private _taskTitle = "";
private _taskIcon = "";
private _taskState1 = "CREATED";
private _typeVehObj = "";

switch (_convoyType) do
{
    case "Ammunition":
    {
        _textX = format ["A convoy from %1 is about to depart at %2. It will provide weapons and ammunition to %3. Intercept and destroy the convoy before it reaches its desitnation.",_nameOrigin,_displayTime,_nameDest];
        _taskTitle = "Ammo Convoy";
        _taskIcon = "rearm";
        _typeVehObj = if (_sideX == Occupants) then {vehNATOAmmoTruck} else {vehCSATAmmoTruck};
    };
    case "Fuel":
	{
		_textX = format ["A convoy from %1 is about to depart at %2. It will provide fuel to %3. Intercept and destroy the convoy before it reaches its desitnation.",_nameOrigin,_displayTime,_nameDest];
		_taskTitle = "Fuel Convoy";
		_taskIcon = "refuel";
		_typeVehObj = if (_sideX == Occupants) then {vehNATOFuelTruck} else {vehCSATFuelTruck};
	};
    case "Armor":
    {
        _textX = format ["The Wehrmacht are moving armour to the front lines, a convoy is departing from %1 at %2, going to %3. Intercept and destroy the convoy before it reaches its desitnation.",_nameOrigin,_displayTime,_nameDest];
        _taskTitle = "Armored Convoy";
        _taskIcon = "Destroy";
        _typeVehObj = if (_sideX == Occupants) then {selectRandom vehNATOTanks} else {selectRandom vehNATOTanks};
    };
    case "Prisoners":
    {
        _textX = format ["A group of POWs is being transported away from the front, from %3 to %1, departing at %2. Intercept the convoy before it reaches its desitnation and rescue the prisoners. Bring them back to a friendly airbase, military base or HQ",_nameOrigin,_displayTime,_nameDest];
        _taskTitle = "Prisoner Convoy";
        _taskIcon = "run";
        _typeVehObj = if (_sideX == Occupants) then {selectRandom vehNATOTrucks} else {selectRandom vehCSATTrucks};
    };
    case "Reinforcements":
    {
        _textX = format ["The Wehrmacht are moving reinforcements to the front lines, they are being sent from %1 to %3 in a convoy, which is departing at %2. Intercept and destroy the convoy before it reaches its desitnation.",_nameOrigin,_displayTime,_nameDest];
        _taskTitle = "Reinforcements Convoy";
        _taskIcon = "run";
        _typeVehObj = if (_sideX == Occupants) then {selectRandom vehNATOTrucks} else {selectRandom vehCSATTrucks};
    };
    case "Money":
    {
        _textX = format ["A truck with plenty of money is being moved from %1 to %3, and it's about to depart at %2. Steal that truck and bring it to HQ. Those funds will be very welcome.",_nameOrigin,_displayTime,_nameDest];
        _taskTitle = "Money Convoy";
        _taskIcon = "move";
        _typeVehObj = civSupplyVehicle;
    };
    case "Supplies":
    {
        _textX = format ["A truck with medical supplies destination %3 it's about to depart at %2 from %1. Steal that truck bring it to %3 and let people in there know it is %4 who's giving those supplies.",_nameOrigin,_displayTime,_nameDest,nameTeamPlayer];
        _taskTitle = "Supply Convoy";
        _taskIcon = "heal";
        _typeVehObj = civSupplyVehicle;
    };
};


// Find suitable nav points for origin/dest
private _posOrigin = if (_convoyType == "Prisoners") then {navGrid select ([_mrkDest] call A3A_fnc_getMarkerNavPoint) select 0} else {navGrid select ([_mrkOrigin] call A3A_fnc_getMarkerNavPoint) select 0};
private _posDest = if (_convoyType == "Prisoners") then {navGrid select ([_mrkOrigin] call A3A_fnc_getMarkerNavPoint) select 0} else {navGrid select ([_mrkDest] call A3A_fnc_getMarkerNavPoint) select 0};



private _taskId = "CONVOY" + str A3A_taskCount;
[[teamPlayer,civilian],_taskId,[_textX,_taskTitle,_mrkDest],(getMarkerPos _mrkDest),false,0,true,_taskIcon,true] call BIS_fnc_taskCreate;
[_taskId, "CONVOY", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];

[2, format ["%1 convoy mission created from %2 to %3", _convoyType, _mrkOrigin, _mrkDest], _filename, true] call A3A_fnc_log;

_positionX = getMarkerPos _mrkDest;
private _baseMarker = [baseMarkersX, _positionX] call BIS_fnc_nearestPosition;
if (markerAlpha _baseMarker == 0) then {
	[_baseMarker,_mrkOrigin] spawn {
		params ["_baseMarker","_mrkOrigin"];
		sleep 5;
		_baseMarker setMarkerAlpha 1;
		{
			if (getMarkerPos _x inArea _mrkOrigin) then {
				_x setMarkerAlpha 1;
			};
		} forEach mrkAntennas;
		
		_num = round random 1000;
		_task = format ["Task_%1", _num];
		[[teamPlayer, civilian], _task, ["", "New Wehrmacht base discovered", ""], objNull, "ASSIGNED", 2, true] call BIS_fnc_taskCreate;
		[_task,"SUCCEEDED", true] call BIS_fnc_taskSetState;
			
		private _circleMrk = createMarker [format ["MrkCircle_%1", _num], (getMarkerPos _baseMarker)];
		_circleMrk setMarkerShape "ICON";
		_circleMrk setMarkerType "mil_circle";
		_circleMrk setMarkerSize [1.5, 1.5];		

		_time = time + 30;
		while {true} do {
			_circleMrk setMarkerColor "ColorYellow";
			sleep 1;
			_circleMrk setMarkerColor "colorBLUFOR";
			sleep 1;
			if (time > _time) exitWith {deleteMarker _circleMrk, [_task] call BIS_fnc_deleteTask};
		};
	};
};

// *********** Convoy vehicle spawning ***********************

private _route = if (_convoyType == "Prisoners") then {[(getMarkerPos _mrkDest), (getMarkerPos _mrkOrigin)] call A3A_fnc_findPath} else {[(getMarkerPos _mrkOrigin), (getMarkerPos _mrkDest)] call A3A_fnc_findPath};

private _markers = [];

_route = _route apply { _x select 0 };			// reduce to position array
if (_route isEqualTo []) then { 
  // find nearest road for origin
  [1, format ["%1 convoy mission does not have route!", _convoyType], _filename, true] call A3A_fnc_log;
  _roadpos = _posOrigin ;
  _roads = _posOrigin nearRoads 100;
  if !(_roads isEqualTo []) then {
    _roadpos = (getRoadInfo(_roads select 0)) select 6;
  };
  _route = [_roadpos, _posDest] 
};

// AH - Move route forward by 40 m to ensure convoy isn't stuck in a base or other origin object
if (count _route > 2) then {
  // more than 2 nodes (assume proper path)
  _state = [];
  _state = [_route, 40, _state] call A3A_fnc_findPosOnRoute;
  _route = _route select [_state#2, count _route]; // Trim route down to start 40 m ahead
};

// *********** Convoy vehicle spawning ***********************

private _vehPool = [_sideX, ["Air"]] call A3A_fnc_getVehiclePoolForQRFs;
private _pathState = [];			// Set the scope so that state is preserved between findPosOnRoute calls


// Spawning worker functions

private _fnc_getOut = {
	params ["_unit"];
	while {true} do {
		waitUntil {sleep 1; [_unit,400] call BIS_fnc_enemyDetected};
		[_unit] allowGetIn false;
	
		waitUntil {sleep 1; !([_unit,400] call BIS_fnc_enemyDetected)};
		[_unit] allowGetIn true;
	};
};

private _fnc_spawnConvoyVehicle = {
    params ["_vehType", "_markName"];
    [1, format ["Spawning vehicle type %1", _vehType], _filename, true] call A3A_fnc_log;

    // Find location down route
    _pathState = [_route, [40, 0] select (count _pathState == 0), _pathState] call A3A_fnc_findPosOnRoute;
    while {true} do {
        // make sure there are no other vehicles within 10m
        if (count (ASLtoAGL (_pathState#0) nearEntities 10) == 0) exitWith {};
        _pathState = [_route, 10, _pathState] call A3A_fnc_findPosOnRoute;
    };

    private _veh = createVehicle [_vehType, ASLtoAGL (_pathState#0) vectorAdd [0,0,0.5]];               // Give it a little air
    private _vecUp = (_pathState#1) vectorCrossProduct [0,0,1] vectorCrossProduct (_pathState#1);       // correct pitch angle
    _veh setVectorDirAndUp [_pathState#1, _vecUp];
    _veh allowDamage false;

    private _group = [_sideX, _veh] call A3A_fnc_createVehicleCrew;
    { [_x] call A3A_fnc_NATOinit; _x allowDamage false; } forEach (units _group);
    _soldiers append (units _group);
    (driver _veh) stop true;
    deleteWaypoint [_group, 0];													// groups often start with a bogus waypoint

    [_veh, _sideX] call A3A_fnc_AIVEHinit;
    if (_vehType in vehArmor) then { _veh allowCrewInImmobile true };			// move this to AIVEHinit at some point?
    _vehiclesX pushBack _veh;
    _markNames pushBack _markName;
    _veh;
};

private _fnc_spawnEscortVehicle = {
    private _typeVehEsc = selectRandomWeighted _vehPool;
    private _veh = [_typeVehEsc, "Convoy Escort"] call _fnc_spawnConvoyVehicle;

    private _typeGroup = [_typeVehEsc, _sideX] call A3A_fnc_cargoSeats;
    if (count _typeGroup == 0) exitWith {};
    private _groupEsc = [_posSpawn, _sideX, _typeGroup] call A3A_fnc_spawnGroup;				// Unit limit?
    {[_x] call A3A_fnc_NATOinit;[_x] spawn _fnc_getOut;_x assignAsCargo _veh;_x moveInCargo _veh;} forEach units _groupEsc;
    _soldiers append (units _groupEsc);
};

private _fnc_spawnAAVehicle = {
    private _typeVehEsc = if (_sideX == Occupants) then {selectRandomWeighted [vehNATOAA select 0, 66, vehNATOAA select 1, 33]} else {selectRandom vehCSATAA};
    private _veh = [_typeVehEsc, "Convoy Escort"] call _fnc_spawnConvoyVehicle;
	if (_typeVehEsc == vehNATOAA select 0) then {    
	    private _typeGroup = [_typeVehEsc, _sideX] call A3A_fnc_cargoSeats;
	    if (count _typeGroup == 0) exitWith {};
	    private _groupEsc = [_posSpawn, _sideX, _typeGroup] call A3A_fnc_spawnGroup;				// Unit limit?
	    {[_x] call A3A_fnc_NATOinit;_x assignAsCargo _veh;_x moveInCargo _veh;} forEach units _groupEsc;

	    _soldiers append (units _groupEsc);
	};
};

// Tail escort
[] call _fnc_spawnEscortVehicle;

if (_difficult) then {
	// AA escort vehicles
	sleep 2;
	[] call _fnc_spawnAAVehicle;
};

// Objective vehicle
private _num = if (_difficult) then {2} else {1};
private _vehObj = [];
for "_i" from 1 to _num do {
	sleep 2;
	private _objText = if (_difficult) then {" Convoy Objective"} else {"Convoy Objective"};
	_vehObj = [_typeVehObj, _objText] call _fnc_spawnConvoyVehicle;

	//if (_convoyType == "Armor") then {_vehObj allowCrewInImmobile true;};
	if (_convoyType == "Prisoners") then
	{
	    private _grpPOW = createGroup teamPlayer;
	    for "_i" from 1 to (4 + round (random 5)) do
	    {
	    	_unitType = if (random 100 > 50) then {UKUnarmed} else {USUnarmed};
	        private _unit =  [_grpPOW, _unitType, _posSpawn, [], 0, "NONE"] call A3A_fnc_createUnit;
	        _unit setCaptive true;
	        _unit disableAI "MOVE";
	        _unit setBehaviour "CARELESS";
	        _unit allowFleeing 0;
	        _unit assignAsCargo _vehObj;
	        _unit moveInCargo [_vehObj, _i + 3];
	        removeAllWeapons _unit;
	        removeAllAssignedItems _unit;
	        [_unit,"refugee"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_unit];
	        _POWS pushBack _unit;
	        _uniform = if (_unitType == UKUnarmed) then {"U_LIB_UK_P37"} else {"U_LIB_US_Private"};
	        _unit forceAddUniform _uniform;
	    };
	};
	if (_convoyType == "Reinforcements") then
	{
	    private _typeGroup = [_typeVehObj,_sideX] call A3A_fnc_cargoSeats;
	    private _groupEsc = [_posSpawn,_sideX,_typeGroup] call A3A_fnc_spawnGroup;
	    {[_x] call A3A_fnc_NATOinit;[_x] spawn _fnc_getOut;_x assignAsCargo _vehObj;_x moveInCargo _vehObj;} forEach units _groupEsc;
	    _soldiers append (units _groupEsc);
	    _reinforcementsX append (units _groupEsc);
	};
	if ((_convoyType == "Money") or (_convoyType == "Supplies")) then
	{
	    reportedVehs pushBack _vehObj;
	    publicVariable "reportedVehs";
	};
	if (_convoyType == "Ammunition") then
	{
    	[_vehObj] spawn A3A_fnc_fillLootCrate;
	};
};
	
// Initial escort vehicles
sleep 2;
[] call _fnc_spawnEscortVehicle;

// Lead vehicle
sleep 2;
private _typeVehX = if (_sideX == Occupants) then {
    if (!_isMilitia) then {
        selectRandom vehNATOLightArmed
    } else {
        selectRandom vehPoliceCars
    };
} else {
    if (!_isMilitia) then {
        selectRandom vehCSATLightArmed
    } else {
        selectRandom vehPoliceCars
    };
};

private _vehLead = [_typeVehX, "Convoy Lead"] call _fnc_spawnConvoyVehicle;

// Remove spawn-suicide protection
sleep 2;
{_x allowDamage true} forEach _vehiclesX;
{_x allowDamage true; if (vehicle _x == _x) then {deleteVehicle _x}} forEach _soldiers;

[2, format ["Spawn performed: %1 ground vehicles, %2 soldiers", count _vehiclesX, count _soldiers], _filename, true] call A3A_fnc_log;

// Send the vehicles after the delay 

sleep (60*_startDelay);
_route = _route select [_pathState#2, count _route];        // remove navpoints that we already passed while spawning
[2, "Convoy mission under way", _fileName] call A3A_fnc_log;

// This array is used to share remaining convoy vehicles between threads
private _convoyVehicles = +_vehiclesX;
reverse _convoyVehicles;
{
    (driver _x) stop false;
    [_x, _route, _convoyVehicles, 30, _x == _vehObj] spawn A3A_fnc_vehicleConvoyTravel;
	//[_x, _markNames#_forEachIndex, false] spawn A3A_fnc_inmuneConvoy;			// Disabled the stuck-vehicle hacks
    sleep 3;
} forEach _convoyVehicles;



// **************** Termination condition handling ********************************

private _bonus = if (_difficult) then {2} else {1};
private _arrivalDist = 100;
private _timeout = time + 3600;

private _fnc_applyResults =
{
    params ["_success", "_success1", "_adjustCA", "_adjustBoss", "_aggroMod", "_aggroTime", "_type"];

    _taskState = if (_success) then { "SUCCEEDED" } else { "FAILED" };
    _taskState1 = if (_success1) then { "SUCCEEDED" } else { "FAILED" };

    [_adjustCA, _sideX] remoteExec ["A3A_fnc_timingCA", 2];
    [_adjustBoss, theBoss] call A3A_fnc_playerScoreAdd;

    if (_sideX == Occupants) then {aggressionOccupants = aggressionOccupants - 20} else {aggressionInvaders = aggressionInvaders - 20};
	[] call A3A_fnc_calculateAggression;

    if !(_success1) then {
        _killZones = killZones getVariable [_mrkOrigin,[]];
        _killZones = _killZones + [_mrkDest,_mrkDest];
        killZones setVariable [_mrkOrigin,_killZones,true];
    };

    [1, format ["Rebels %1 a %2 convoy mission", ["lost", "won"] select _success, _type], _filename, true] call A3A_fnc_log;
};

if (_convoyType in ["Ammunition", "Fuel"]) then
{
    waitUntil {sleep 1; (time > _timeout) or (_vehObj distance _posDest < _arrivalDist) or (not alive _vehObj) or (side group driver _vehObj != _sideX)};
    if ((_vehObj distance _posDest < _arrivalDist) or (time > _timeout)) then
    {
        [false, true, -1200*_bonus, -10*_bonus, -5, 60, "ammo"] call _fnc_applyResults;
        clearMagazineCargoGlobal _vehObj;
        clearWeaponCargoGlobal _vehObj;
        clearItemCargoGlobal _vehObj;
        clearBackpackCargoGlobal _vehObj;
    }
    else
    {
        [true, false, 1800*_bonus, 5*_bonus, 25, 120, "ammo"] call _fnc_applyResults;
        [0,1000*_bonus,0] remoteExec ["A3A_fnc_resourcesFIA",2];
        {
            if (isPlayer _x) then
            {
                [50*_bonus,_x] call A3A_fnc_playerScoreAdd
            };
        } forEach ([500,0,_vehObj,teamPlayer] call A3A_fnc_distanceUnits);
    };
};

if (_convoyType == "Armor") then
{
    waitUntil {sleep 1; (time > _timeout) or (_vehObj distance _posDest < _arrivalDist) or (not alive _vehObj) or (side group driver _vehObj != _sideX)};
    if ((_vehObj distance _posDest < _arrivalDist) or (time > _timeout)) then
    {
        [false, true, -1200*_bonus, -10*_bonus, -5, 60, "armor"] call _fnc_applyResults;
        server setVariable [_mrkDest,dateToNumber date,true];
    }
    else
    {
        [true, false, 1800*_bonus, 5*_bonus, 20, 90, "armor"] call _fnc_applyResults;
        [0,1000*_bonus,0] remoteExec ["A3A_fnc_resourcesFIA",2];
        [0,5*_bonus,_posDest] remoteExec ["A3A_fnc_citySupportChange",2];
        {
            if (isPlayer _x) then
            {
                [50*_bonus,_x] call A3A_fnc_playerScoreAdd
            };
        } forEach ([500,0,_vehObj,teamPlayer] call A3A_fnc_distanceUnits);
    };
};

if (_convoyType == "Prisoners") then
{
    waitUntil {sleep 1; (time > _timeout) or (_vehObj distance _posDest < _arrivalDist) or (side group driver _vehObj != _sideX) or ({alive _x} count _POWs == 0)};
    if ((_vehObj distance _posDest < _arrivalDist) or ({alive _x} count _POWs == 0) or (time > _timeout)) then
    {
        [false, true, 0, -10*_bonus, -10, 60, "prisoner"] call _fnc_applyResults;
    };
    if (side group driver _vehObj != _sideX) then
    {
        {_x enableAI "MOVE"; [_x] orderGetin false} forEach _POWs;
        
        waitUntil {sleep 2; ({alive _x} count _POWs == 0) or ({(alive _x) and (_x distance (getMarkerPos ([(milbases + airportsX + ["Synd_HQ"]) select {sidesX getVariable [_x, sideUnknown] == teamPlayer}, _unit] call BIS_fnc_nearestPosition)) < 50)} count _POWs > 0) or (time > _timeout)};

        if (({alive _x} count _POWs == 0) or (time > _timeout)) then
        {
            [false, false, 0, -10*_bonus, 20, 120, "prisoner"] call _fnc_applyResults;
        }
        else
        {	
			_alivePOWs = _POWs select {(alive _x) and (_x distance getMarkerPos ([(((airportsX + milbases) select {(sidesX getVariable [_x,sideUnknown] == teamPlayer)}) + ["Synd_HQ"]),_x] call BIS_fnc_nearestPosition) < 1000)};
            _countX = count _alivePOWs;
            [true, false, 0, _bonus*_countX/2, 10, 120, "prisoner"] call _fnc_applyResults;
			{
			_unitTypes pushBack (_x getVariable "unitType");
			} forEach _alivePOWs;
			_hr = _countX;
			_resourcesFIA = 100*_countX;
			[_hr,_resourcesFIA*_bonus,_unitTypes] remoteExec ["A3A_fnc_resourcesFIA",2];
            [0,10*_bonus,_posSpawn] remoteExec ["A3A_fnc_citySupportChange",2];
            {[_countX*50*_bonus,_x] call A3A_fnc_playerScoreAdd} forEach (allPlayers - (entities "HeadlessClient_F"));
        };
    };
};

if (_convoyType == "Reinforcements") then
{
    waitUntil {sleep 1; (time > _timeout) or (_vehObj distance _posDest < _arrivalDist) or ({_x call A3A_fnc_canFight} count _reinforcementsX <= 2)};
    if ({_x call A3A_fnc_canFight} count _reinforcementsX <= 2) then
    {
        [true, false, 0, 5*_bonus, 10, 90, "reinforcement"] call _fnc_applyResults;
        [0,10*_bonus,_posSpawn] remoteExec ["A3A_fnc_citySupportChange",2];
        [0,1000*_bonus,0] remoteExec ["A3A_fnc_resourcesFIA",2];
        {if (_x distance _vehObj < 500) then {[50*_bonus,_x] call A3A_fnc_playerScoreAdd}} forEach (allPlayers - (entities "HeadlessClient_F"));
    }
    else
    {
        [false, true, 0, -10*_bonus, -10, 60, "reinforcement"] call _fnc_applyResults;
        _countX = {alive _x} count _reinforcementsX;
        if (_countX <= 8) then {_taskState1 = "FAILED"};
        if (sidesX getVariable [_mrkDest,sideUnknown] == _sideX) then
        {
            _typesX = [];
            {_typesX pushBack (_x getVariable "unitType")} forEach (_reinforcementsX select {alive _x});
            [_typesX,_sideX,_mrkDest,0] remoteExec ["A3A_fnc_garrisonUpdate",2];
        };
    };
};

if (_convoyType == "Money") then
{
    waitUntil {sleep 1; (time > _timeout) or (_vehObj distance _posDest < _arrivalDist) or (not alive _vehObj) or (side group driver _vehObj != _sideX)};
    if ((time > _timeout) or (_vehObj distance _posDest < _arrivalDist) or (not alive _vehObj)) then
    {
        if ((time > _timeout) or (_vehObj distance _posDest < _arrivalDist)) then
        {
            [false, true, -1200, -10*_bonus, -5, 60, "money"] call _fnc_applyResults;
        }
        else
        {
            [false, false, 1200, 0, -5, 60, "money"] call _fnc_applyResults;
        };
    }
    else
    {
        waitUntil {sleep 2; (_vehObj distance _posHQ < 50) or (not alive _vehObj) or (time > _timeout)};
        if ((not alive _vehObj) or (time > _timeout)) then
        {
            [false, false, 1200, 0, -5, 60, "money"] call _fnc_applyResults;
        };
        if (_vehObj distance _posHQ < 50) then
        {
            [true, false, 1200, 5*_bonus, 25, 120, "money"] call _fnc_applyResults;
            [0,5000*_bonus] remoteExec ["A3A_fnc_resourcesFIA",2];
            {if (_x distance _vehObj < 500) then {[10*_bonus,_x] call A3A_fnc_playerScoreAdd}} forEach (allPlayers - (entities "HeadlessClient_F"));
        };
    };
    reportedVehs = reportedVehs - [_vehObj];
    publicVariable "reportedVehs";
};

if (_convoyType == "Supplies") then
{
    waitUntil {sleep 1; (time > _timeout) or (_vehObj distance _posDest < _arrivalDist) or (not alive _vehObj) or (side group driver _vehObj != _sideX)};
    if (not alive _vehObj) then
    {
        [false, false, 0, -10*_bonus, 20, 120, "supply"] call _fnc_applyResults;
    }
    else
    {
        if (side group driver _vehObj != _sideX) then
        {
            waitUntil {sleep 1; (_vehObj distance _posDest < _arrivalDist) or (not alive _vehObj) or (time > _timeout)};
            if (_vehObj distance _posDest < _arrivalDist) then
            {
                [true, false, 0, 5*_bonus, 10, 90, "supply"] call _fnc_applyResults;
                [0,15*_bonus,_mrkDest] remoteExec ["A3A_fnc_citySupportChange",2];
                {if (_x distance _vehObj < 500) then {[10*_bonus,_x] call A3A_fnc_playerScoreAdd}} forEach (allPlayers - (entities "HeadlessClient_F"));
            }
            else
            {
                [false, false, 0, -10*_bonus, -10, 60, "supply"] call _fnc_applyResults;
                [5*_bonus,-10*_bonus,_mrkDest] remoteExec ["A3A_fnc_citySupportChange",2];
            };
        }
        else
        {
            [false, true, 0, -10*_bonus, -10, 60, "supply"] call _fnc_applyResults;
            [15*_bonus,0,_mrkDest] remoteExec ["A3A_fnc_citySupportChange",2];
        };
    };
    reportedVehs = reportedVehs - [_vehObj];
    publicVariable "reportedVehs";
};

[_taskId, "CONVOY", _taskState] call A3A_fnc_taskSetState;
[_taskId+"B",_taskState1] call BIS_fnc_taskSetState;		// Do this manually because both sides can fail


// Cleanup

{ deleteVehicle _x } forEach _POWs;

[_taskId, "CONVOY", 600, true] spawn A3A_fnc_taskDelete;

// Clear this array so the vehicleConvoyTravel spawns exit and merge groups
_convoyVehicles resize 0;
sleep 5;

// Groups change due to convoy crew group split/merge, so we recreate them
private _groups = [];
{ if (alive _x) then {_groups pushBackUnique (group _x)} } forEach _soldiers;
{ [_x] spawn A3A_fnc_groupDespawner } forEach _groups;
{ [_x] spawn A3A_fnc_VEHdespawner } forEach _vehiclesX;

{
    deleteMarker _x;
} forEach _markers;

// Hang around for a bit, and then send all escorts back to the source base
sleep 60;
{
    if (count units _x > 0) then {
        private _wp = _x addWaypoint [_posOrigin, 50];
        _wp setWaypointType "MOVE";
        _x setCurrentWaypoint _wp;
    };
} forEach _groups - [group driver _vehObj];