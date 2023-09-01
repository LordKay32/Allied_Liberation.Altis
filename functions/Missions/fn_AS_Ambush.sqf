//Mission: Ambush Officer
if (!isServer && hasInterface) exitWith{};

params ["_missionOrigin"];

private _fileName = "fn_AS_Ambush";
[2, "Ambush Officer mission init.", _fileName, true] call A3A_fnc_log;

//arrays for cleanup
private _vehicles = [];
private _groups = [];

private _missionOriginPos = getMarkerPos _missionOrigin;
private _difficult = if (aggressionLevelOccupants > 3) then {true} else {false};
private _sideX = if (sidesX getVariable [_missionOrigin,sideUnknown] == Occupants) then {Occupants} else {Invaders};
private _sideName = if(_sideX == Occupants) then { nameOccupants } else { nameInvaders };
[3, format ["Origin: %1, Hardmode: %2, Controlling Side: %3", _missionOrigin, _difficult, _sideX], _filename] call A3A_fnc_log;

private _timeLimit = 90 * settingsTimeMultiplier;
private _dateLimit = [date select 0, date select 1, date select 2, date select 3, (date select 4) + _timeLimit];
private _dateLimitNum = dateToNumber _dateLimit;
_dateLimit = numberToDate [date select 0, _dateLimitNum]; //converts datenumber back to date array so that time formats correctly
private _displayTime = [_dateLimit] call A3A_fnc_dateToTimeString; //Converts the time portion of the date array to a string for clarity in hints

private _originName = [_missionOrigin] call A3A_fnc_localizar;

private _departingTimeLimit = 10 * settingsTimeMultiplier;
private _departingDateLimit = [date select 0, date select 1, date select 2, date select 3, (date select 4) + _departingTimeLimit];
private _departingDateLimitNum = dateToNumber _departingDateLimit;
_departingDateLimit = numberToDate [date select 0, _departingDateLimitNum]; //converts datenumber back to date array so that time formats correctly
private _departingDisplayTime = [_departingDateLimit] call A3A_fnc_dateToTimeString; //Converts the time portion of the date array to a string for clarity in hints

//choosing enemy destination site
private _potentialSites = ((citiesX - villagesX) + outposts + seaports) select {
    private _potentialPos = getMarkerPos _x;
    sidesX getVariable [_x,sideUnknown] == _sideX && _missionOriginPos distance _potentialPos < 5000 && _missionOriginPos distance _potentialPos > 1500
};

private _potentialFrontier = _potentialSites select {[_x] call A3A_fnc_isFrontline == true};

private _destinationSite = nil;
if (count _potentialFrontier > 0) then {
    _destinationSite = selectRandom _potentialFrontier;
} else {
	if (count _potentialSites > 0) then {
	_destinationSite = selectRandom _potentialSites;
	};
};

if (isNil "_destinationSite") exitWith {
    ["AS"] remoteExec ["A3A_fnc_missionRequest",2];
	[1, format ["Problems with finding proper delivery site, rerequesting new AS mission."], _filename] call A3A_fnc_log;
};

private _destinationName = [_destinationSite] call A3A_fnc_localizar;
private _destinationPosition = getMarkerPos _destinationSite;

private _markerColor = if(_sideX == Occupants) then {"colorBLUFOR"} else {"colorOPFOR"};
private _markerPosition = [_destinationPosition select 0, (_destinationPosition select 1) + 50, _destinationPosition select 2];

[3, format ["Origin: %1, Destination: %2", str _missionOrigin, str _destinationSite], _filename] call A3A_fnc_log;

// selecting classnames
private _officerClass = nil;
private _officerVehicleClass = nil;
private _escortVehicleClass = nil;
private _escortAPCClass = nil;
private _infantrySquadArray = nil;

private _squads = [_sideX, "SQUAD"] call SCRT_fnc_unit_getGroupSet;

if (_sideX == Occupants) then { 
    _officerClass = "LIB_GER_hauptmann";
    _escortVehicleClass = selectRandom ["fow_v_sdkfz_251_camo_ger_heer", "LIB_SdKfz251_FFV", "LIB_OpelBlitz_Open_Y_Camo", "LIB_OpelBlitz_Tent_Y_Camo"];
    _escortAPCClass = selectRandom ["fow_v_sdkfz_222_camo_ger_heer", "fow_v_sdkfz_250_camo_ger_heer", "fow_v_sdkfz_234_1"];
    _officerVehicleClass = selectRandom vehNATOLightArmed;
    _infantrySquadArray = selectRandom _squads;
} else { 
    _officerClass = CSATOfficer;
    _escortVehicleClass = if(_difficult) then { selectRandom vehCSATAPC } else {selectRandom vehCSATTrucks};
    _escortAPCClass = selectRandom ["fow_v_sdkfz_222_camo_ger_heer", "fow_v_sdkfz_250_camo_ger_heer", "fow_v_sdkfz_234_1"];
    _officerVehicleClass = if(_difficult) then { selectRandom vehCSATAPC } else { selectRandom vehCSATLightArmed };
    _infantrySquadArray = selectRandom _squads;
};

if (isNil "_officerClass" || {isNil "_officerVehicleClass"} || {isNil "_escortVehicleClass"} || {isNil "_infantrySquadArray"}) exitWith {
    ["AS"] remoteExec ["A3A_fnc_missionRequest",2];
    [1, format ["Classname problems, rerequesting new AS mission."], _filename] call A3A_fnc_log;
};

[
    2, 
    format ["Officer: %1, officer vehicle: %2, escort vehicle: %3, infantry squad: %4", 
        _officerClass, _officerVehicleClass, _escortVehicleClass, str _infantrySquadArray
    ], 
    _fileName, 
    true
] call A3A_fnc_log;

//creating Task
private _rebelTaskText = format [
    "A Wehrmacht officer is moving from %1 to %2 at %3 to oversee the defenses. Intercept his vehicle and eliminate him.<br/><br/>Reward: 1000 CP per player.", 
    _originName, 
    _destinationName,
    _departingDisplayTime
];
private _taskId = "AS" + str A3A_taskCount;

[
    [teamPlayer,civilian],
    _taskId,
    [_rebelTaskText, "Ambush Officer", _missionOrigin],
    _missionOrigin,
    false,
    0,
    true,
    "car",
    true
] call BIS_fnc_taskCreate;
[_taskId, "AS", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];

////////////////
//convoy spawn//
////////////////

//finding road
private _radiusX = 100;
private _roads = [];
while {true} do {
	_roads = _missionOriginPos nearRoads _radiusX;
	if (count _roads > 1) exitWith {};
	_radiusX = _radiusX + 50;
};
private _roadpos = (getRoadInfo(_roads select 0)) select 6;
//private _roadR = _roads select 0;
sleep 1;

private _route = [_roadpos, _destinationPosition] call A3A_fnc_findPath;
_route = _route apply { _x select 0 };			// reduce to position array
if (_route isEqualTo []) then { 
	[1, format ["AS Ambush mission does not have route!"], _filename, true] call A3A_fnc_log;
	_route = [_roadpos, _destinationPosition] ;
}else{
	_state = [];
	_state = [_route, 40, _state] call A3A_fnc_findPosOnRoute;
	_route = _route select [_state#2, count _route]; // Trim route down to start 40 m ahead
};
private _pathState = [];			// Set the scope so that state is preserved between findPosOnRoute calls

//spawning escort
_pathState = [_route, [20, 0] select (count _pathState == 0), _pathState] call A3A_fnc_findPosOnRoute; // Find location down route
while {true} do {
	// make sure there are no other vehicles within 10m
	if (count (ASLtoAGL (_pathState#0) nearEntities 10) == 0) exitWith {};
	_pathState = [_route, 10, _pathState] call A3A_fnc_findPosOnRoute;
};
private _escortVehicleData = [ASLtoAGL (_pathState#0) vectorAdd [0,0,0.5], 0, _escortVehicleClass, _sideX] call A3A_fnc_spawnVehicle;
private _escortVeh = _escortVehicleData select 0;
private _vecUp = (_pathState#1) vectorCrossProduct [0,0,1] vectorCrossProduct (_pathState#1);       // correct pitch angle
_escortVeh setVectorDirAndUp [_pathState#1, _vecUp];
_escortVeh limitSpeed 35;
[_escortVeh, "Officer Convoy", false] spawn A3A_fnc_inmuneConvoy;
private _escortVehCrew = crew _escortVeh;
{[_x] call A3A_fnc_NATOinit} forEach _escortVehCrew;
[_escortVeh, _sideX] call A3A_fnc_AIVEHinit;
private _escortVehicleGroup = _escortVehicleData select 2;
_groups pushBack _escortVehicleGroup;
_vehicles pushBack _escortVeh;

//spawning escort inf
private _groupX = [getPos _escortVeh, _sideX, _infantrySquadArray] call A3A_fnc_spawnGroup;
{
    [_x] join _escortVehicleGroup; 
    [_x] call A3A_fnc_NATOinit;
    [_x] orderGetIn true; 
} forEach units _groupX;
deleteGroup _groupX;


//spawning escortAPC
_pathState = [_route, [20, 0] select (count _pathState == 0), _pathState] call A3A_fnc_findPosOnRoute; // Find location down route
while {true} do {
	// make sure there are no other vehicles within 10m
	if (count (ASLtoAGL (_pathState#0) nearEntities 10) == 0) exitWith {};
	_pathState = [_route, 10, _pathState] call A3A_fnc_findPosOnRoute;
};
private _escortAPCData = [ASLtoAGL (_pathState#0) vectorAdd [0,0,0.5], 0, _escortAPCClass, _sideX] call A3A_fnc_spawnVehicle;
private _escortAPC = _escortAPCData select 0;
private _vecUp = (_pathState#1) vectorCrossProduct [0,0,1] vectorCrossProduct (_pathState#1);       // correct pitch angle
_escortAPC setVectorDirAndUp [_pathState#1, _vecUp];
_escortAPC limitSpeed 35;
[_escortAPC, "Officer Convoy", false] spawn A3A_fnc_inmuneConvoy;
private _escortAPCCrew = crew _escortAPC;
{[_x] call A3A_fnc_NATOinit} forEach _escortAPCCrew;
[_escortAPC, _sideX] call A3A_fnc_AIVEHinit;
private _escortAPCGroup = _escortAPCData select 2;
_groups pushBack _escortAPCGroup;
_vehicles pushBack _escortAPC;


//officer and his vehicle
_pathState = [_route, [20, 0] select (count _pathState == 0), _pathState] call A3A_fnc_findPosOnRoute; // Find location down route
while {true} do {
	// make sure there are no other vehicles within 10m
	if (count (ASLtoAGL (_pathState#0) nearEntities 10) == 0) exitWith {};
	_pathState = [_route, 10, _pathState] call A3A_fnc_findPosOnRoute;
};
private _officerVehicleData = [ASLtoAGL (_pathState#0) vectorAdd [0,0,0.5], 0, _officerVehicleClass, _sideX] call A3A_fnc_spawnVehicle;
private _officerVeh = _officerVehicleData select 0;
_vecUp = (_pathState#1) vectorCrossProduct [0,0,1] vectorCrossProduct (_pathState#1);       // correct pitch angle
_officerVeh setVectorDirAndUp [_pathState#1, _vecUp];
_officerVeh limitSpeed 35;
[_officerVeh, "Officer Convoy", false] spawn A3A_fnc_inmuneConvoy;
private _officerVehCrew = crew _officerVeh;
{[_x] call A3A_fnc_NATOinit} forEach _officerVehCrew;
[_officerVeh, _sideX] call A3A_fnc_AIVEHinit;
private _officerVehicleGroup = _officerVehicleData select 2;
_groups pushBack _officerVehicleGroup;
_vehicles pushBack _officerVeh;

private _groupOfficer = createGroup _sideX;
private _officer =  [_groupOfficer, _officerClass, getPos _officerVeh, [], 0, "NONE"] call A3A_fnc_createUnit;
_officer allowDamage false;

[_officer] join _officerVehicleGroup; 
[_officer] call A3A_fnc_NATOinit;
_officerVehicleGroup selectLeader _officer;
deleteGroup _groupOfficer;

sleep 2;


// All seats are full, remove someone from crew and replace with officer
// crew list is ordered with cargo last so should be ok to assume we remove the last
// person to replace with officer. If this is wrong then, meh, he's just become a gunner or commander
//_lastCrewMember = (crew _officerVeh) select ((count crew _officerVeh) - 1);
//[_lastCrewMember] orderGetIn false ;
//unassignVehicle _lastCrewMember ;
//deleteVehicle _lastCrewMember ;
//sleep 2;
_officer assignAsCargo _officerVeh; 
_officer moveInCargo _officerVeh; 
_officer allowDamage true;


[3, "Waiting for starting convoy movement...", _filename] call A3A_fnc_log;
waitUntil {
	sleep 1;
    private _position = position _officer;
    [3, format ["Officer Position: %1", str _position], _filename] call A3A_fnc_log;
	dateToNumber date > _dateLimitNum || {dateToNumber date > _departingDateLimitNum} || !(alive _officer)
};

[3, "Setting things in motion...", _filename] call A3A_fnc_log;

_route = _route select [_pathState#2, count _route];        // remove navpoints that we already passed while spawning
// This array is used to share remaining convoy vehicles between threads
private _convoyVehicles = +_vehicles; // make copy of vehicle array
reverse _convoyVehicles;
{
    (driver _x) stop false;
    [_x, _route, _convoyVehicles, 30, _x == _officerVeh] spawn A3A_fnc_vehicleConvoyTravel;
    sleep 3;
} forEach _convoyVehicles;
[3, format ["Officer and Escort Vehicle Waypoint: %1", str _destinationPosition], _filename] call A3A_fnc_log;

waitUntil {
	sleep 1;
	dateToNumber date > _dateLimitNum || _officer inArea _destinationSite || !(alive _officer)
};

switch(true) do {
    case (_officer inArea _destinationSite || dateToNumber date > _dateLimitNum): {
        [3, "Officer Reached destination or time is out, fail.", _filename] call A3A_fnc_log;

        [_taskId, "AS", "FAILED"] call A3A_fnc_taskSetState;

        [-900, _sideX] remoteExec ["A3A_fnc_timingCA",2];
        [-20,theBoss] call A3A_fnc_playerScoreAdd;
        if (_sideX == Occupants) then {aggressionOccupants = aggressionOccupants + 5} else {aggressionInvaders = aggressionInvaders + 5};
        [] call A3A_fnc_calculateAggression;
    };
    case (!alive _officer): {
        [3, "Officer died, success.", _filename] call A3A_fnc_log;
        [_taskId, "AS", "SUCCEEDED"] call A3A_fnc_taskSetState;
        [0, 1000,0] remoteExec ["A3A_fnc_resourcesFIA",2];
        [1800, _sideX] remoteExec ["A3A_fnc_timingCA",2];
        { [100,_x] call A3A_fnc_playerScoreAdd } forEach (call BIS_fnc_listPlayers) select { side _x == teamPlayer || side _x == civilian};
        if (_sideX == Occupants) then {aggressionOccupants = aggressionOccupants - 10} else {aggressionInvaders = aggressionInvaders - 10};
        [] call A3A_fnc_calculateAggression;
    };
    default {
        [3, "Unexpected behaviour, cancelling mission.", _filename] call A3A_fnc_log;
        [_taskId, "AS", "CANCELED"] call A3A_fnc_taskSetState;
    };
};

sleep 30;

[_taskId, "AS", 1200] spawn A3A_fnc_taskDelete;

{[_x] spawn A3A_fnc_vehDespawner} forEach _vehicles;
{[_x] spawn A3A_fnc_groupDespawner} forEach _groups;
[3, format ["Officer Ambush clean up complete."], _filename] call A3A_fnc_log;