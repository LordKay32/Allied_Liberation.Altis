params ["_markerDestination", "_side", "_super"];

/*  Sends an attack force towards the given marker

    Execution on: Server

    Scope: External

    Params:
        _markerDestination: MARKER : The target position where the attack will be send to
        _side: SIDE or MARKER : The start parameter of the attack
        _super: BOOLEAN : Determine if the attack should be super strong

    Returns:
        Nothing
*/

private _filename = "singleAttack";

[2, format ["Starting single attack with parameters %1", _this], _fileName] call A3A_fnc_log;


private _markerOrigin = "";
private _posOrigin = [];

private _posDestination = getMarkerPos _markerDestination;
private _isFIA = if (random 10 > (tierWar + difficultyCoef)) then {true} else {false};

//Don't attempt unless we have enough units spare on this machine to make a worthwhile attack
if ([_side] call A3A_fnc_remUnitCount < 16) exitWith
{
    [2, format ["SingleAttack to %1 cancelled because maximum unit count reached", _markerDestination], _fileName] call A3A_fnc_log;
};

if ([_posDestination,false] call A3A_fnc_fogCheck < 0.3) exitWith
{
    [2, format ["SingleAttack to %1 cancelled due to heavy fog", _markerDestination], _fileName] call A3A_fnc_log;
};

//Parameter is the starting base
if(_side isEqualType "") then
{
    _markerOrigin = _side;
    _posOrigin = getMarkerPos _markerOrigin;
    _side = sidesX getVariable [_markerOrigin, sideUnknown];
    [2, format ["Adapting attack params, side is %1, start base is %2", _side, _markerOrigin], _fileName] call A3A_fnc_log;
};

if(_side == sideUnknown) exitWith
{
    [1, format ["Could not retrieve side for %1", _markerOrigin], _fileName] call A3A_fnc_log;
};

if ((_side == Occupants && areOccupantsDefeated) || {(_side == Invaders && areInvadersDefeated)}) exitWith {
    [2, format ["%1 faction was defeated earlier, aborting single attack.", str _side], _fileName, true] call A3A_fnc_log;
};

private _typeOfAttack = [_posDestination, _side] call A3A_fnc_chooseAttackType;
if(_typeOfAttack == "") exitWith {};

//No start based selected by now
if(_markerOrigin == "") then
{
    _markerOrigin = [_posDestination, _side] call A3A_fnc_findBaseForQRF;
    _posOrigin = getMarkerPos _markerOrigin;
};

if (_markerOrigin == "") exitWith
{
    [2, format ["Small attack to %1 cancelled because no usable bases in vicinity",_markerDestination], _filename] call A3A_fnc_log
};

//Base selected, select units now
private _vehicles = [];
private _groups = [];
private _landPosBlacklist = [];

private _aggression = if (_side == Occupants) then {aggressionOccupants} else {aggressionInvaders};
private _playerScale = call A3A_fnc_getPlayerScale;
if (sidesX getVariable [_markerDestination, sideUnknown] != teamPlayer) then { _aggression = 100 - _aggression; _playerScale = 1; };
private _vehicleCount = (random 1) + (2*_playerScale) + (_aggression/50);
_vehicleCount = (((round (_vehicleCount)) max 2) min 4) + ([0, 2] select _super);

if (_markerOrigin in outposts) then {_vehicleCount = _vehicleCount - 2};

[
    3,
    format ["Due to %1 aggression and %2 player scale, sending %3 vehicles", _aggression, _playerScale, _vehicleCount],
    _fileName
] call A3A_fnc_log;

//Set idle times for marker
if (_markerOrigin in airportsX) then
{
    [_markerOrigin, 20] call A3A_fnc_addTimeForIdle;
}
else
{
    [_markerOrigin, 40] call A3A_fnc_addTimeForIdle;
};

private _vehPool = [];
private _replacement = [];
private _isAir = false;

if ((_posOrigin distance2D _posDestination < distanceForLandAttack) && {[_posOrigin, _posDestination] call A3A_fnc_arePositionsConnected}) then {
    //The attack will be carried out by land vehicles
	_vehPool = [_side] call A3A_fnc_getVehiclePoolForAttacks;
    _replacement = if(_side == Occupants) then {
        if (_isFIA) then {
            (vehFIATrucks + vehFIAAPC)
        } else {
            (vehNATOTrucks + vehNATOAPC)
        };
    } else {
         if (_isFIA) then {
            (vehWAMTrucks + vehWAMAPC)
        } else {
            (vehCSATTrucks + vehCSATAPC)
        };
    };
} else {
    //The attack will be carried out by air vehicles only
    _replacement = if(_side == Occupants) then {vehNATOTransportPlanes} else {vehCSATTransportPlanes};
    {_vehPool append [_x, 1]} forEach _replacement;
    _isAir = true;
};

//If vehicle pool is empty, fill it up
if(_vehPool isEqualTo []) then
{
    {_vehPool append [_x, 1]} forEach _replacement;
};

if (_isAir) then {if (_markerDestination in (airportsX + milbases)) then {_vehicleCount = 2} else {_vehicleCount = 1}};

//Spawn in the vehicles
for "_i" from 1 to _vehicleCount do
{
    if ([_side] call A3A_fnc_remUnitCount < 4) exitWith {
        [2, "Cancelling because maxUnits exceeded", _filename] call A3A_fnc_log;
    };

    private _vehicleType = if (_i <= (ceil (_vehicleCount/2)) && !(_isAir)) then {selectRandom vehNATOTrucks} else {selectRandomWeighted _vehPool};
    private _vehicleData = [_vehicleType, _typeOfAttack, _landPosBlacklist, _side, _markerOrigin, _posDestination] call A3A_fnc_createAttackVehicle;
    if (_vehicleData isEqualType []) then
    {
        _vehicles pushBack (_vehicleData select 0);
        _groups pushBack (_vehicleData select 1);
        
        if (_isAir) then {
       		_groups append (_vehicleData select 2);
        } else {
        	if !(isNull (_vehicleData select 2)) then
        	{
        		_groups pushBack (_vehicleData select 2);
        	};
        };        
        _landPosBlacklist = (_vehicleData select 3);
        sleep 2;
    };
};

if ((_posOrigin distance2D _posDestination < distanceForLandAttack) && {[_posOrigin, _posDestination] call A3A_fnc_arePositionsConnected}) then {
    private _heavyResponseChance =  if (_side == Occupants) then {aggressionOccupants/2} else {aggressionInvaders/2};
    if (_heavyResponseChance > 30) then {
        _heavyResponseChance = 30;
    };

    if ((random 100) < _heavyResponseChance) then {
        private _quantity =  round random 2;
        private _heavyVehPool = if (_side == Occupants) then {
            if (_isFIA) then {
                vehFIATanks + vehFIAAPC
            } else {
                vehNATOAttack
            };
        } else {
            if (_isFIA) then {
                vehWAMTanks + vehWAMAPC
            } else {
                vehCSATAttack
            };
        };
        private _additionalVehicleType = selectRandom _heavyVehPool;
        [2, format ["Heavy response rolled: added %1 attack vehicles to pool.", str _quantity], _filename] call A3A_fnc_log;
        for "_i" from 1 to _quantity do {
            private _vehicleData = [_additionalVehicleType, _typeOfAttack, _landPosBlacklist, _side, _markerOrigin, _posDestination] call A3A_fnc_createAttackVehicle;
            if (_vehicleData isEqualType []) then
            {
                _vehicles pushBack (_vehicleData select 0);
                _groups pushBack (_vehicleData select 1);
                if !(isNull (_vehicleData select 2)) then
                {
                    _groups pushBack (_vehicleData select 2);
                };
                _landPosBlacklist = (_vehicleData select 3);
            };
        };
    };
};

//add MRAP at start of all QRFs
if ((_posOrigin distance2D _posDestination < distanceForLandAttack) && {[_posOrigin, _posDestination] call A3A_fnc_arePositionsConnected} && (count _vehicles < 8)) then {
	if ([_side] call A3A_fnc_remUnitCount < 4) exitWith {
		[2, "Cancelling because maxUnits exceeded", _filename] call A3A_fnc_log;
	};

	private _vehicleType = selectRandom vehNATOLightArmed;
	private _vehicleData = [_vehicleType, _typeOfAttack, _landPosBlacklist, _side, _markerOrigin, _posDestination] call A3A_fnc_createAttackVehicle;
	if (_vehicleData isEqualType []) then
	{
	    _vehicles pushBack (_vehicleData select 0);
	    _groups pushBack (_vehicleData select 1);
	    if !(isNull (_vehicleData select 2)) then
	    {
	        _groups pushBack (_vehicleData select 2);
	    };
	    _landPosBlacklist = (_vehicleData select 3);
	};
		
};

sleep 1;

private _soldiers = [];

{
	_soldiers append (units _x);
} forEach _groups;

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
private _convoyVehicles = +_vehicles;
reverse _convoyVehicles;
{
    (driver _x) stop false;
    [_x, _route, _convoyVehicles, 30, true, _posDestination] spawn A3A_fnc_convoyScript;
	//[_x, _markNames#_forEachIndex, false] spawn A3A_fnc_inmuneConvoy;			// Disabled the stuck-vehicle hacks
    sleep 5;
} forEach _convoyVehicles;

[_vehicles, _markerDestination] spawn {
	params ["_vehicles", "_markerDestination"];
	private _posDestination = getMarkerPos _markerDestination;
	private _artySpawnDistance = if ((_vehicles select 0) in (vehNATOTransportPlanes + vehCSATTransportPlanes)) then {6000} else {2000};
	waitUntil {sleep 1; _vehicles findIf {_x distance _posDestination < _artySpawnDistance} != -1};
	[_posDestination] spawn A3A_fnc_artyAttack;
	if (spawner getVariable _markerDestination != 0) then {
		forcedSpawn pushBack _markerDestination; publicVariable "forcedSpawn";
	};
};

[2, format ["Spawn Performed: Small %1 attack sent with %2 vehicles", _typeOfAttack, count _vehicles], _filename] call A3A_fnc_log;

//Prepare despawn conditions
private _endTime = time + 2700;
private _qrfHasArrived = false;
private _qrfHasWon = false;

while {true} do
{
    private _markerSide = sidesX getVariable [_markerDestination, sideUnknown];

    if(_markerSide == _side) exitWith
    {
        [2, format ["Small attack to %1 captured the marker, starting despawn routines", _markerDestination], _fileName] call A3A_fnc_log;
    };

    //Trying to flip marker
    [3, "Checking whether small attack took marker", _fileName] call A3A_fnc_log;
    [_markerDestination, _markerSide] remoteExec ["A3A_fnc_zoneCheck", 2];

    private _groupAlive = false;
    {
        private _index = (units _x) findIf {[_x] call A3A_fnc_canFight};
        if(_index != -1) exitWith
        {
            _groupAlive = true;
        };
    } forEach _groups;

    if !(_groupAlive) exitWith
    {
        [2, format ["Small attack to %1 has been eliminated, starting despawn routines", _markerDestination], _fileName] call A3A_fnc_log;
    };

    sleep 60;
    if(_endTime < time) exitWith
    {
        [2, format ["Small attack to %1 timed out without winning or loosing, starting despawn routines", _markerDestination], _fileName] call A3A_fnc_log;
    };
};

{
_groups pushBackUnique group _x;
} forEach _soldiers;

{
    [_x] spawn A3A_fnc_VEHDespawner;
} forEach _vehicles;

{
    [_x] spawn A3A_fnc_groupDespawner;
} forEach _groups;

if (_markerDestination in forcedSpawn) then {
	forcedSpawn = forcedSpawn - [_markerDestination]; publicVariable "forcedSpawn";
};
