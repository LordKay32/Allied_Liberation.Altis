/*
 * Name:	fn_bomberAttack
 * Date:	12/04/2023
 * Version: 1.0
 * Author:  JB
 *
 * Description:
 * Bomber attack
 *
 * Parameter(s):
 * _PARAM1 (TYPE): DESCRIPTION.
 * _PARAM2 (TYPE): DESCRIPTION.
 *
 * Returns:
 * %RETURNS%
 */


params ["_markerX", "_side", "_airport"];

private _positionX = getMarkerPos _markerX;
private _plane = if (_side == Occupants) then {vehNATOPlanes select 2} else {selectRandom vehCSATPlanes}; 
private _crewUnits = if (_side == Occupants) then {NATOPilot} else {CSATPilot}; 

private _numPlanes = aggressionLevelOccupants - 2;
private _spawnPos = getMarkerPos _airport; 
private _targDir = _spawnPos getDir _positionX;
private _targetPos = if (_numPlanes == 3) then {_positionX getPos [-75, (90 + _targDir)]} else {_positionX};

private _allStrikePlanes = [];
private _strikeGroup = createGroup _side; 

for "_i" from 1 to _numPlanes do {
	private _strikePlane = createVehicle [_plane, _spawnPos, [], 0, "FLY"];    
 	_allStrikePlanes pushBack _strikePlane;
	_spawnPos = (_spawnPos getPos [100, (90 + _targDir)]) vectorAdd [0, 0, 1000];
	_strikePlane setDir _targDir;
	_strikePlane setPosASL _spawnPos;                                            
	_strikePlane setVelocityModelSpace [0, 400, 0]; 
	_strikePlane flyInHeightASL [1000,1000,1000]; 
 
 	private _strikeGroup = createGroup _side; 
 
	private _pilot1 = [_strikeGroup, _crewUnits, getPos _strikePlane] call A3A_fnc_createUnit; 
	private _pilot2 = [_strikeGroup, _crewUnits, getPos _strikePlane] call A3A_fnc_createUnit; 
	private _pilot3 = [_strikeGroup, _crewUnits, getPos _strikePlane] call A3A_fnc_createUnit; 
	private _pilot4 = [_strikeGroup, _crewUnits, getPos _strikePlane] call A3A_fnc_createUnit; 

	{_nul = [_x,""] call A3A_fnc_NATOinit} forEach units _strikeGroup;
	[_strikePlane, _side] call A3A_fnc_AIVEHinit;

	_pilot1 moveInDriver _strikePlane; 
	_pilot2 moveInAny _strikePlane; 
	_pilot3 moveInAny _strikePlane; 
	_pilot4 moveInAny _strikePlane; 

_strikeGroup deleteGroupWhenEmpty true; 
_strikeGroup setCombatBehaviour "CARELESS";  

private _wp1 = _strikeGroup addWaypoint [_targetPos, 0]; 
_wp1 setWaypointType "MOVE"; 
_wp1 setWaypointBehaviour "CARELESS"; 

private _wp2 = _strikeGroup addWaypoint [getMarkerPos _airport, 2];
_wp2 setWaypointType "MOVE";
_wp2 setWaypointSpeed "FULL";

_targetPos = _targetPos getPos [75, (90 + _targDir)];
sleep 2;
};
 
{ 
	_plane = _x;
	[_plane, _positionX] spawn {
		_plane = _this select 0;
		_positionX = _this select 1;
	 	waitUntil {sleep 1; _plane distance2D _positionX < 2150};  
	  	sleep 0.6; 
	  	for "_i" from 1 to 4 do {  
	  		_bombPos = (getPos _plane) vectorAdd [0, 0, -6];
			_bomb = "LIB_SC500_Bomb" createvehicle _bombPos;
            _bomb setDir (getDir _plane);
            _bomb setVelocityModelSpace [0,125,0];
			sleep 1.2;            
	  	};  
	}; 
} forEach _allStrikePlanes; 
 
{ 
	_plane = _x; 
	[_plane, _positionX] spawn {
		_plane = _this select 0;
		_positionX = _this select 1;
		waitUntil {sleep 1; _plane distance2D _positionX < 2150};
		sleep 1.2; 
 		for "_i" from 1 to 4 do {  
			[_plane, "sab_fl_bomb_weapon"] call bis_fnc_fire;  
			sleep 1.2;  
		}; 
	}; 
} forEach _allStrikePlanes;


{ 
	_plane = _x; 
	[_plane, _airport] spawn {
		_plane = _this select 0;
		_airport = _this select 1;
		_timeOut = time + 1200;
		waitUntil {sleep 1; _plane distance2D getMarkerPos _airport < 500 || time > _timeOut};
		{if (alive _x and !(_x getVariable ["captured", false])) then {deleteVehicle _x}} forEach crew _plane;
		if (alive _plane) then {deleteVehicle _plane};
	}; 
} forEach _allStrikePlanes;


