params ["_vehicleType", "_typeOfAttack", "_landPosBlacklist", "_side", "_markerOrigin", "_posDestination", ["_isAirdrop", false]];

/*  Creates a vehicle for a QRF or small attack, including crew and cargo

    Execution on: HC or Server

    Scope: Internal

    Parameters:
        _vehicleType: STRING : The name of the vehicle to spawn
        _typeOfAttack: STRING : The type of the attack
        _landPosBlacklist: ARRAY : List of blacklisted position
        _side: SIDE : The side of the attacker
        _markerOrigin: STRING : The name of the marker marking the origin
        _posDestination: ARRAY : Target position (ASL or ATL? probably used as 2d anyway)

    Returns:
        ARRAY : [_vehicle, _crewGroup, _cargoGroup, _landPosBlacklist]
        or
        OBJECT : objNull if the spawning did not worked
*/

private _fileName = "createAttackVehicle";

//private _vehicle = [_markerOrigin, _vehicleType] call A3A_fnc_spawnVehicleAtMarker;


private _posOrigin = navGrid select ([_markerOrigin] call A3A_fnc_getMarkerNavPoint) select 0;

private _route = [(getMarkerPos _markerOrigin), _posDestination] call A3A_fnc_findPath;

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

private _vehicle = createVehicle [_vehicleType, ASLtoAGL (_pathState#0) vectorAdd [0,0,0.5]];               // Give it a little air
private _vecUp = (_pathState#1) vectorCrossProduct [0,0,1] vectorCrossProduct (_pathState#1);       // correct pitch angle
_vehicle setVectorDirAndUp [_pathState#1, _vecUp];
if (_vehicleType in vehNATOTransportPlanes) then {_vehicle setVelocityModelSpace [0, 100, 0]};

if(isNull _vehicle) exitWith {objNull};

private _crewGroup = [_side, _vehicle] call A3A_fnc_createVehicleCrew;
{
    [_x] call A3A_fnc_NATOinit
} forEach (units _crewGroup);
[_vehicle, _side] call A3A_fnc_AIVEHinit;

private _cargoGroup = if (_vehicleType in vehNATOTransportPlanes) then {[]} else {grpNull};
private _expectedCargo = ([_vehicleType, true] call BIS_fnc_crewCount) - ([_vehicleType, false] call BIS_fnc_crewCount);
if (_expectedCargo > 0) then
{
    //Vehicle is able to transport units
    private _groupType = if (_typeOfAttack == "Normal") then
    {
        [_vehicleType, _side] call A3A_fnc_cargoSeats;
    }
    else
    {
        if (_typeOfAttack == "Air") then
        {
            if (_side == Occupants) then {
                groupsNATOAA call SCRT_fnc_unit_selectInfantryTier
            } else {
                groupsCSATAA call SCRT_fnc_unit_selectInfantryTier
            };
        }
        else
        {
            if (_side == Occupants) then {
                groupsNATOAT call SCRT_fnc_unit_selectInfantryTier
            } else {
                groupsCSATAT call SCRT_fnc_unit_selectInfantryTier
            }
        };
    };
	if (_vehicleType in vehNATOTransportPlanes) then {
		for "_i" from 1 to 2 do {
	    	_singleGroup = [getMarkerPos _markerOrigin, _side, _groupType, true, false] call A3A_fnc_spawnGroup;         // force spawn, should be pre-checked
		    {
    		    _x moveInAny _vehicle;
    		    if !(isNull objectParent _x) then
    		    {
    		        [_x] call A3A_fnc_NATOinit;
    		        _x setVariable ["originX", _markerOrigin];
    		    }
    		    else
    		    {
    		        deleteVehicle _x;
    		    };
    		} forEach units _singleGroup;
    		_cargoGroup pushBack _singleGroup;
		}
	} else {
		_cargoGroup = [getMarkerPos _markerOrigin, _side, _groupType, true, false] call A3A_fnc_spawnGroup;         // force spawn, should be pre-checked
	    {
    	    _x assignAsCargo _vehicle;
    	    _x moveInCargo _vehicle;
    	    if !(isNull objectParent _x) then
    	    {
    	        [_x] call A3A_fnc_NATOinit;
    	        _x setVariable ["originX", _markerOrigin];
    	    }
    	    else
    	    {
    	        deleteVehicle _x;
    	    };
    	} forEach units _cargoGroup;
	};
};

_landPosBlacklist = [_vehicle, _crewGroup, _cargoGroup, _posDestination, _markerOrigin, _landPosBlacklist, _isAirdrop] call A3A_fnc_createVehicleQRFBehaviour;
[3, format ["Spawn Performed: Created vehicle %1 with %2 soldiers", typeof _vehicle, count crew _vehicle], _filename] call A3A_fnc_log;

private _driver = driver _vehicle;
private _crew = group _driver;

if (_vehicleType in vehNATOTransportPlanes) then {
	_crew setSpeedMode "FULL";
} else {
	_crew setBehaviourStrong "SAFE";
};

private _vehicleData = [_vehicle, _crewGroup, _cargoGroup, _landPosBlacklist];
_vehicleData;
