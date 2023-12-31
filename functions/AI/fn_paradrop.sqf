/*
Maintainer: Wurzel0701
    Performs a paradrop with the given group and vehicle

Arguments:
    <OBJECT> The vehicle from which the drop will be performed
    <GROUP> The group that will jump and perform the drop (NOT THE PILOTS!)
    <MARKER> OR <POSITION> The designated target
    <MARKER> The origin location this vehicle is coming from
    (OPTIONAL) <BOOL> If this drop is there to reinforce (default false)

Return Value:
    <NIL>

Scope: Server/HC
Environment: Scheduled
Public: Yes
Dependencies:
    NONE

Example:
[_myPlane, _ODSTgroup, _targetPos, "CSAT_Carrier"] call A3A_fnc_initSupportCooldowns;
*/

params
[
    ["_vehicle", objNull, [objNull]],
    ["_groups", ["", []]],
    ["_target", "", ["", []]],
    ["_originMarker", "", [""]],
    ["_isReinforcement", false, [false]]
];

private _groupPilot = group driver _vehicle;
{
    _x disableAI "TARGET";
    _x disableAI "AUTOTARGET";
    _x setBehaviour "CARELESS";
} foreach (units _groupPilot);

/*{
    _x setVariable ["jumpSave_Backpack", backpack _x];
    _x setVariable ["jumpSave_BackpackItems", backpackItems _x];
    removebackpack _x;
} forEach (units _groupJumper);*/

private _targetPosition = if(_target isEqualType "") then {getMarkerPos _target} else {_target};
private _originPosition = getMarkerPos _originMarker;

private _entryDistance = 600;
_vehicle flyInHeight 600;
_vehicle setCollisionLight false;
if(_vehicle isKindOf "Helicopter") then
{
    _entryDistance = 150;
    _vehicle flyInHeight 500;
};

/*
private _normalAngle = (_originPosition getDir _targetPosition);
private _attackAngle = (random 120) - 60;
private _entryPos = [];
while {true} do
{
    _entryPos = _targetPosition getPos [_entryDistance, (_normalAngle - 180) - _attackAngle];
    if(!surfaceIsWater _entryPos) exitWith {};
    _attackAngle = (random 120) - 60;
};
private _exitPos = _targetPosition getPos [_entryDistance, _normalAngle + _attackAngle];
*/

private _normalAngle = (_originPosition getDir _targetPosition);
private _centre = _targetPosition getPos [200, (_normalAngle - 180)];

private _entryPos = [];
private _exitPos = [];

private _exitNumber = 0;
while {true} do {
	if (_exitNumber == 24) exitWith {
		_entryPos = _targetPosition getPos [200, (_normalAngle - 180)];
		_exitPos = _targetPosition getPos [200, _normalAngle];
	};
	_entryPos = [_centre, 400, 500, 0, 0, 0, 0] call BIS_fnc_findSafePos;
	private _attackAngle = (_originPosition getDir _entryPos);
	_exitPos = _entryPos getPos [_entryDistance, _attackAngle]; 
	if (!surfaceIsWater _exitPos) exitWith {};
	_exitNumber = _exitNumber + 1;
};

{
    _x set [2, 500];
} forEach [_entryPos, _exitPos, _originPosition];

private _wp = _groupPilot addWaypoint [_entryPos, 0];
_wp setWaypointType "MOVE";
_wp setWaypointSpeed "NORMAL";

private _wp1 = _groupPilot addWaypoint [_exitPos, 0];
_wp1 setWaypointType "MOVE";
_wp1 setWaypointSpeed "NORMAL";

private _wp2 = _groupPilot addWaypoint [_originPosition, 0];
_wp2 setWaypointType "MOVE";
_wp2 setWaypointSpeed "FULL";
_wp2 setWaypointStatements ["true", "if !(local this) exitWith {}; deleteVehicle (vehicle this); {deleteVehicle _x} forEach thisList"];

waitUntil {sleep 1; (_vehicle distance2d _entryPos < 200) || (!alive _vehicle) || (!canMove _vehicle)};

if(_vehicle distance2d _entryPos < 200) then
{
private _allUnits = [];
{
_allUnits append units _x;
} forEach _groups;

    [3, 'Drop pos reached', 'paradrop'] call A3A_fnc_log;
    _vehicle setCollisionLight true;
    {
		_x allowDamage false;
		[_vehicle,_x] spawn LIB_fnc_deployStaticLine;
		sleep 0.3;
		_x allowDamage true;
		[_x] spawn {		
    		_unit = _this select 0;
    		waitUntil {sleep 1; (getPos _unit) select 2 < 50};
    		waitUntil {sleep 0.1; (getPos _unit) select 2 < 20};
    		_unit allowDamage false;
    		waitUntil {sleep 1; isTouchingGround _unit};
    		sleep 2;
    		_unit allowDamage true;
    	};
    	/*[_x] ordergetin false; 
		[_x] allowGetIn false; 
        unAssignVehicle _x;
        moveOut _x;
        //Move them into alternating left/right positions, so their parachutes are less likely to kill each other
        private _pos = if (_forEachIndex % 2 == 0) then {_vehicle modeltoWorld [7, -20, -5]} else {_vehicle modeltoWorld [-7, -20, -5]};
        _x setPos _pos;
        _x spawn
        {
            waitUntil {sleep 0.25; ((getPos _this) select 2) < 450};
            _this addBackpack "B_Parachute";
            private _smokeGrenade = selectRandom allSmokeGrenades;
            private _smoke = _smokeGrenade createVehicle (getPosATL _this);
            waitUntil { sleep 1; isTouchingGround _this};
            _this addBackpack (_this getVariable "jumpSave_Backpack");
            {
                _this addItemToBackpack _x;
            } forEach (_this getVariable "jumpSave_BackpackItems");
        };
        sleep 0.5;*/
  	} forEach _allUnits;
};

{
private _groupJumper = _x;
if !(_isReinforcement) then
{
    private _posLeader = position (leader _groupJumper);
    _posLeader set [2,0];
    private _wpRegroup = _groupJumper addWaypoint [_posLeader,0];
    _wpRegroup setWaypointType "MOVE";
    _wpRegroup setWaypointSpeed "FULL";
    _wpRegroup setWaypointStatements ["true", "if !(local this) exitWith {}; (group this) spawn A3A_fnc_attackDrillAI"];
    private _wpCharge = _groupJumper addWaypoint [_targetPosition, 50];
    _wpCharge setWaypointType "MOVE";
    _wpCharge setWaypointBehaviour "COMBAT";
    _wpCharge setWaypointStatements ["true","if !(local this) exitWith {}; {if (side _x != side this) then {this reveal [_x,4]}} forEach allUnits"];
    _wpClear = _groupJumper addWaypoint [_targetPosition, 2];
    _wpClear setWaypointType "SAD";
}
else
{
    _wp4 = _groupJumper addWaypoint [_targetPosition, 0, 0];
    _wp4 setWaypointType "MOVE";
};
} forEach _groups;