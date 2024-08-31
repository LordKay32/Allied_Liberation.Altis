if (!isServer and hasInterface) exitWith {};

private _markerX = _this select 0;
private _positionX = getMarkerPos _markerX;
private _garrison = garrison getVariable [_markerX, []];

private _props = [];

private _groupX = [_positionX, teamPlayer, _garrison] call A3A_fnc_spawnGroup;
_groupX setBehaviour "STEALTH";
_groupX setCombatMode "GREEN";
{
	[_x,_markerX] spawn A3A_fnc_FIAinitBASES;
	if ((_x getVariable "unitType") in squadLeaders) then {_x linkItem "ItemRadio"};
	_x setVariable ["spawner",true,true];
	_x setUnitTrait ["camouflageCoef",0.1];
	_x setUnitTrait ["audibleCoef",0.1];
	[_x] spawn {
		_unit = _this select 0;
		while {alive _unit} do {	
			waitUntil {sleep 1; ((_unit nearEntities 300) findIf {side _x == Occupants || side _x == Invaders}) != -1 and combatMode (group _unit) == "GREEN"};
			_unit setUnitPos "DOWN";
			waitUntil {sleep 1; ((_unit nearEntities 300) findIf {side _x == Occupants || side _x == Invaders}) == -1 or combatMode (group _unit) != "GREEN"};
			_unit setUnitPos "AUTO";
		};
	};
} forEach units _groupX;

private _index = watchpostsFIA findIf {_x == _markerX};
if (_index != -1) then {
	_groupX setGroupIdGlobal [format ["Recon_%1", _index]];
};

private _wp0 = _groupX addWaypoint [_positionX getPos [100,0], 0];
private _wp1 = _groupX addWaypoint [_positionX getPos [100,60], 0];
private _wp2 = _groupX addWaypoint [_positionX getPos [100,120], 0];
private _wp3 = _groupX addWaypoint [_positionX getPos [100,180], 0];
private _wp4 = _groupX addWaypoint [_positionX getPos [100,240], 0];
private _wp5 = _groupX addWaypoint [_positionX getPos [100,300], 0];
private _wp6 = _groupX addWaypoint [_positionX getPos [100,0], 0];
_wp6 setWaypointType "CYCLE";

[_positionX, _groupX] spawn SCRT_fnc_watchPostRecon;

private _campfire = createVehicle ["Land_Campfire_F", _positionX];
private _GC = createVehicle ["ClutterCutter_small_EP1", _positionX, [],0, "CAN_COLLIDE"];
_props pushBack _GC;
private _tent = ["Land_TentA_F", getPosWorld _campfire] call BIS_fnc_createSimpleObject;
_tent setDir (random 360);
_tent setPos [(getPos _tent select 0) + 4, (getPos _tent select 1) + 4, (getPos _tent select 2) - 0.2]; 
private _GC = createVehicle ["ClutterCutter_small_EP1", (getPos _tent), [],0, "CAN_COLLIDE"];
_props pushBack _GC;

_props pushBack _campfire;
_props pushBack _tent;

{
	_x setVectorUp surfaceNormal position _x;
} forEach _props;

waitUntil {
	sleep 1; 
	({alive _x} count units _groupX == 0) or (!(_markerX in watchpostsFIA))
};

if ({alive _x} count units _groupX == 0) then {
	watchpostsFIA = watchpostsFIA - [_markerX]; publicVariable "watchpostsFIA";
	markersX = markersX - [_markerX]; publicVariable "markersX";
	sidesX setVariable [_markerX,nil,true];
	_nul = [5,-5,_positionX] remoteExec ["A3A_fnc_citySupportChange",2];
	deleteMarker _markerX;
	["TaskFailed", ["", "Watchpost Lost"]] remoteExec ["BIS_fnc_showNotification", 0];
};

waitUntil {sleep 1; (!(_markerX in watchpostsFIA))};

{ 
    deleteVehicle _x 
} forEach units _groupX;
deleteGroup _groupX;

{
	deleteVehicle _x;
} forEach _props;