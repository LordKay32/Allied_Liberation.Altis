params ["_side", "_posDestination", "_supportName"];

/*  Sends a QRF force towards the given position

    Execution on: Server

    Scope: External

    Params:
        _posDestination: POSITION : The target position where the QRF will be send to
        _side: SIDE : The side of the QRF

    Returns:
        _coverageMarker : STRING : The name of the marker covering the support area, "" if not possible
*/

private _filename = "SUP_QRF";

private _typeOfAttack = [_posDestination, _side, _supportName] call A3A_fnc_chooseAttackType;
//If no type specified, exit here
if(_typeOfAttack == "") exitWith
{
    ""
};

private _markerOrigin = [_posDestination, _side] call A3A_fnc_findBaseForQRF;
if (_markerOrigin == "") exitWith
{
    [2, format ["QRF to %1 cancelled because no usable bases in vicinity",_posDestination], _filename] call A3A_fnc_log;
    ""
};
private _posOrigin = getMarkerPos _markerOrigin;

[
    3,
    format ["%1 will be send from %2", _supportName, _markerOrigin],
    _fileName
] call A3A_fnc_log;

private _targetMarker = createMarker [format ["%1_coverage", _supportName], _posDestination];

_targetMarker setMarkerShape "ELLIPSE";
_targetMarker setMarkerBrush "Grid";
_targetMarker setMarkerSize [300, 300];
if(_side == Occupants) then
{
    _targetMarker setMarkerColor colorOccupants;
};
if(_side == Invaders) then
{
    _targetMarker setMarkerColor colorInvaders;
};
_targetMarker setMarkerAlpha 0;

//Base selected, select units now
private _vehicles = [];
private _groups = [];
private _landPosBlacklist = [];

private _aggression = if (_side == Occupants) then {aggressionOccupants} else {aggressionInvaders};
private _playerScale = call A3A_fnc_getPlayerScale;
private _vehicleCount = random 1 + _playerScale + _aggression/50;
_vehicleCount = (round (_vehicleCount)) max 1;

[
    3,
    format ["Due to %1 aggression and %2 player scale, sending %3 vehicles", _aggression, _playerScale, _vehicleCount],
    _fileName
] call A3A_fnc_log;

//Set idle times for marker
if (_markerOrigin in airportsX) then
{
    [_markerOrigin, 10] call A3A_fnc_addTimeForIdle;
}
else
{
    [_markerOrigin, 20] call A3A_fnc_addTimeForIdle;
};

private _vehPool = [];
private _replacement = [];
private _isAir = false;

if ((_posOrigin distance2D _posDestination < distanceForLandAttack) && {[_posOrigin, _posDestination] call A3A_fnc_arePositionsConnected}) then
{
    //The attack will be carried out by land vehicles
	_vehPool = [_side, ["Air"]] call A3A_fnc_getVehiclePoolForQRFs;
    _replacement = if (_side == Occupants) then { vehNATOTrucks } else { vehCSATTrucks };
}
else
{
    //The attack will be carried out by air vehicles only
	_vehPool = [_side, ["LandVehicle"]] call A3A_fnc_getVehiclePoolForQRFs;
    _replacement = if (_side == Occupants) then {vehNATOTransportPlanes} else {vehCSATTransportPlanes};
    _isAir = true;
};

//If vehicle pool is empty, fill it up
if(_vehPool isEqualTo []) then
{
    {_vehPool append [_x, 1]} forEach _replacement;
};

//add truck at end of all QRFs
if ([_side] call A3A_fnc_remUnitCount < 4) exitWith {
	[2, "Cancelling because maxUnits exceeded", _filename] call A3A_fnc_log;
};

if ((_posOrigin distance2D _posDestination < distanceForLandAttack) && {[_posOrigin, _posDestination] call A3A_fnc_arePositionsConnected}) then 
{
	private _vehicleType = selectRandom vehNATOTrucks;
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

if (_isAir) then {_vehicleCount = 1};

for "_i" from 1 to _vehicleCount do
{
    if ([_side] call A3A_fnc_remUnitCount < 4) exitWith {
        [2, "Cancelling because maxUnits exceeded", _filename] call A3A_fnc_log;
    };

    private _vehicleType = selectRandomWeighted _vehPool;
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

sleep 5;

if ((_posOrigin distance2D _posDestination < distanceForLandAttack) && {[_posOrigin, _posDestination] call A3A_fnc_arePositionsConnected}) then {
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
};

[2, format ["Spawn Performed: %1 QRF sent with %2 vehicles, callsign %3", _typeOfAttack, count _vehicles, _supportName], _filename] call A3A_fnc_log;

[_side, _vehicles, _groups, _posDestination, _supportName] spawn A3A_fnc_SUP_QRFRoutine;

_markerOrigin spawn
{
    sleep 60;
    if(spawner getVariable _this == 2) then
    {
        [_this] call A3A_fnc_freeSpawnPositions;
    };
};

private _distance = _posOrigin distance2D _posDestination;
private _minTime = _distance / (300 / 3.6);
private _maxTime = _distance / (25 / 3.6);

private _result = [_targetMarker, _minTime, _maxTime];
_result;
