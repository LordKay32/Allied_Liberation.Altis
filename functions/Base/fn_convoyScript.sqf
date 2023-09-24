/*
    A3A_fnc_vehicleConvoyTravel
    Make vehicle move down route, ignoring enemies and following other convoy vehicles

Parameters:
    <OBJECT> Vehicle.
    <ARRAY> Array of AGL(?) positions from start to end position.
    <ARRAY> Array of vehicles in convoy, first is lead vehicle. Note: Shared between scripts.
    <NUMBER> Maximum convoy (lead) speed in km/h.
    <BOOLEAN> True if vehicle is critical (shouldn't give up even if timed out)
*/

params ["_vehicle", "_route", "_convoy", "_maxSpeed", ["_critical", false],"_posDestination"];
private _fileName = "fn_vehicleConvoyTravel";

// Handle some broken input errors
private _error = call {
    if (count _route == 0) exitWith { "No route specified" };
    if !(alive _vehicle) exitWith { "Dead or missing vehicle input" };
    if !(alive driver _vehicle) exitWith { "Dead or missing driver in vehicle" };
};
if (!isNil "_error") exitWith {
    _convoy deleteAt (_convoy find _vehicle);
    [1, _error, _fileName, true] call A3A_fnc_log;
};

// Split driver from crew and make them ignore enemies
private _driverGroup = group driver _vehicle;
private _crewGroup = grpNull;
if (count units _driverGroup > 1) then {
    _crewGroup = createGroup (side _driverGroup);
    (units _driverGroup - [driver _vehicle]) joinSilent _crewGroup;
};
_driverGroup setCombatBehaviour "CARELESS";
_vehicle setEffectiveCommander (driver _vehicle);

// Navigation setup

private _destination = _route select (count _route - 1);
private _accuracy = 50;
private _currentNode = 0;
private _nextPos = _route select _currentNode;
private _waypoint = _driverGroup addWaypoint [ATLToASL _nextPos, -1, 0];
_driverGroup setCurrentWaypoint _waypoint;
private _timeout = time + (_vehicle distance2d _nextPos);

while {true} do
{
    sleep 0.5;
    private _vehIndex = _convoy find _vehicle;

	if ([(driver _vehicle), 400] call BIS_fnc_enemyDetected) then {
		if (typeOf _vehicle == "LIB_SdKfz_7_AA") exitWith {};
		private _driver = driver _vehicle;
		_driver disableAI "MOVE";

		private _cargoUnits = [];
		private _cargoArray = fullCrew [_vehicle, "cargo"];
		{
			private _unit = _x select 0;
			_cargoUnits pushBackUnique _unit;
		} forEach _cargoArray;
		{
		[_x] allowGetIn false;
		[_x] orderGetIn false;
		} forEach _cargoUnits;
		waitUntil {sleep 5; [_driver, 400] call BIS_fnc_enemyDetected == false};
		sleep 30;
		{
		[_x] allowGetIn true;
		[_x] orderGetIn true;
		[_x, _vehicle] spawn {
			params ["_unit", "_vehicle"];
			private _timer = 0;
			while {vehicle _unit == _unit} do {
				sleep 5;
				[_unit] orderGetIn true;
				_timer = _timer + 5;
				if (_timer > 60) exitWith {_unit assignAsCargo _vehicle; _unit moveInCargo _vehicle};
			};
		}
		} forEach _cargoUnits;
		waitUntil {sleep 5; (_cargoUnits select {[_x] call A3A_fnc_canFight}) findIf {vehicle _x ==_x} == -1};
		_driver enableAI "MOVE";
		if (vehicle _driver == _driver) then {_driver assignAsDriver _vehicle; [_driver] orderGetIn true};
		waitUntil {sleep 1; vehicle _driver != _driver || !alive _driver || { lifestate _driver == "INCAPACITATED" }};
		//|| !alive driver _vehicle || { lifestate driver _vehicle == "INCAPACITATED" }
	};

    // Exit conditions
    if (_vehicle getHitPointDamage "hitEngine" >= 0.9 || fuel _vehicle == 0) exitWith {
         [2, "Vehicle or driver died during travel, abandoning", _fileName, true] call A3A_fnc_log;
    };
    if (_vehIndex == -1) exitWith {};				// external abort
    if (_vehicle distance _posDestination < 1000) exitWith {
        [3, "Vehicle arrived at destination", _fileName, true] call A3A_fnc_log;
        (units  _driverGroup) joinSilent _crewGroup;
         _crewGroup setBehaviourStrong "AWARE";
    	deleteGroup _driverGroup;	
    	[_vehicle,_posDestination,_vehIndex] spawn {
    		params ["_vehicle","_posDestination","_vehIndex"];
    		private _distance = 400 + (50 * _vehIndex);
    		waitUntil {sleep 1; _vehicle distance _posDestination < _distance || [(driver _vehicle), 400] call BIS_fnc_enemyDetected};
			if (typeOf _vehicle in vehNATOTrucks) then {
				{
				[_x] allowGetIn false;
				[_x] orderGetIn false;
				} forEach crew _vehicle;
			} else {
				if (typeOf _vehicle == "LIB_SdKfz_7_AA") exitWith {};
				private _cargoUnits = [];
				private _cargoArray = fullCrew [_vehicle, "cargo"];
				{
				private _unit = _x select 0;
				_cargoUnits pushBackUnique _unit;
				} forEach _cargoArray;
				{
				[_x] allowGetIn false;
				[_x] orderGetIn false;
				} forEach _cargoUnits;
			};
	    };
	};
	
	// Reright flipped vehicles
	(_vehicle call BIS_fnc_getPitchBank) params ["_vx","_vy"];
	if (([_vx,_vy] findIf {_x > 80 || _x < -80}) != -1) then {	
		0 = [_vehicle] spawn {
			private _vehicle = param [0, objNull, [objNull]];
			_vehicle allowDamage false;
			_vehicle setVectorUp [0,0,1];
			_vehicle setPosATL [(getPosATL _vehicle) select 0, (getPosATL _vehicle) select 1, 0];
			_vehicle allowDamage true;
		};
	};
	
	// Transition to next waypoint if close
	while {_vehicle distance _nextPos < _accuracy} do
    {
        _currentNode = _currentNode + 1;
        _nextPos = _route select _currentNode;
        _waypoint setWaypointPosition [ATLToASL _nextPos, -1];
        _driverGroup setCurrentWaypoint _waypoint;
        _timeout = time + (_vehicle distance2d _nextPos);
    };
    if (!_critical && time > _timeout) exitWith {
        [2, "Vehicle stuck during travel, abandoning", _fileName, true] call A3A_fnc_log;
    };

    /* Hack to work around Arma bugging out and refusing to path
    // Moves vehicle 1m forwards and tries the same waypoint again
    if (unitReady driver _vehicle) then {
        _vehicle setPosWorld (getPosWorld _vehicle vectorAdd vectorDir _vehicle);
        _driverGroup setCurrentWaypoint _waypoint;
    };*/

    // Adjust speed by distance to vehicle in front
    if (_vehIndex == 0) then { _vehicle limitSpeed _maxSpeed } else
    {
        private _followVeh = _convoy select (_vehIndex - 1);
        private _dist = _vehicle distance _followVeh;

        // prevent some off-road passing
        if (_dist < 50) then {
            private _followDir = (getPos _vehicle) vectorFromTo (getPos _followVeh);
            private _targDir = (getpos _vehicle) vectorFromTo _nextPos;
            if (_followDir vectorDotProduct _targDir <= 0) then {_dist = 0};
        };

        private _speed = if (_dist < 30) then { linearConversion [15,30,_dist,0.01,_maxSpeed,true] }
            else { linearConversion [30,60,_dist,_maxSpeed,2*_maxSpeed,true] };
        _vehicle limitSpeed _speed;
        if (_dist < 30) then { _timeout = time + (_vehicle distance2d _nextPos) };

        //diag_log format ["Vehicle %1, follow %2, dist %3, speed %4", _vehicle, _followVeh, _dist, _speed];
    };
};

// Remove from convoy array
_convoy deleteAt (_convoy find _vehicle);

// Merge driver/crew back together
if (!isNull _driverGroup && !isNull _crewGroup) then {
    (units  _driverGroup) joinSilent _crewGroup;
    _crewGroup setBehaviourStrong "AWARE";
    deleteGroup _driverGroup;
};

for "_i" from 0 to (count waypoints _crewGroup - 1) do
{
deleteWaypoint [_crewGroup, 0];
};

sleep 1;

_attackWP = _crewGroup addWaypoint [_posDestination,0];
_attackWP setWaypointType "SAD";
{
_x commandMove _posDestination;
} forEach (units _crewGroup);
 _vehicle limitSpeed -1;
