if (!isServer and hasInterface) exitWith {};

private _markerX = _this select 0;
private _positionX = getMarkerPos _markerX;

private _radiusX = 1;
private _garrison = garrison getVariable [_markerX, []];
private _statics = garrison getVariable [(_markerX + "_statics"), []];
private _veh = objNull;
private _road = objNull;
private _staticDirection = 0;


if (isNil "_garrison") then {//this is for backward compatibility, remove after v12
    _garrison = [USSL,USGL,USMG,USATman,USEng,USMedic,USMil];
    garrison setVariable [_markerX,_garrison,true];
};

private _staticPositionInfo = staticPositions getVariable [_markerX, []];
private _staticDirection = _staticPositionInfo select 1;

while {true} do {
    _road = _positionX nearRoads _radiusX;
    if (count _road > 0) exitWith {};
    _radiusX = _radiusX + 5;
};

private _roadPosition = getPos (_road select 0);

//Spawn troops
private _pos = [_roadPosition, 9, _staticDirection + 90] call BIS_Fnc_relPos;
private _groupX = [_pos, teamPlayer, _garrison,true,false] call A3A_fnc_spawnGroup;
private _groupXUnits = units _groupX;
{
    [_x,_markerX] spawn A3A_fnc_FIAinitBases; 
    if ((_x getVariable "unitType") in squadLeaders) then {_x linkItem "ItemRadio"};
} forEach _groupXUnits;

sleep 1;
_groupX setFormDir _staticDirection;
sleep 1;
leader _groupX setDir _staticDirection;
sleep 1;
_groupX setFormation "STAG COLUMN";

//Vehicle
if (vehSDKLightArmed in _statics) then {
	_pos = [_roadPosition, 7, _staticDirection + 270] call BIS_Fnc_relPos; 
	_veh = vehSDKLightArmed createVehicle _pos;
	_veh setDir _staticDirection;
	[_veh, teamPlayer] call A3A_fnc_AIVEHinit;
	_veh addEventHandler ["Killed", {
		_markerX = [lightroadblocksFIA, _unit] call BIS_fnc_nearestPosition;
		_statics = garrison getVariable [(_markerX + "_statics"), []];
		_statics = _statics - [vehSDKLightArmed];
		garrison setVariable [(_markerX + "_statics"),_statics,true];
	}];
	_veh lock 3;

	sleep 1;

	private _crewManIndex = _groupXUnits findIf  {(_x getVariable "unitType") == USMil};
	if (_crewManIndex != -1) then {
	    private _crewMan = _groupXUnits select _crewManIndex;
	    _crewMan moveInGunner _veh;
	    _crewMan doWatch (_veh getRelPos [200, 0]);
	};
};

waitUntil {
	sleep 1; 
	((spawner getVariable _markerX == 2)) or 
	({alive _x} count units _groupX == 0) or (!(_markerX in lightroadblocksFIA))
};

if ({alive _x} count units _groupX == 0) then {
	lightroadblocksFIA = lightroadblocksFIA - [_markerX]; publicVariable "lightroadblocksFIA";
	markersX = markersX - [_markerX]; publicVariable "markersX";
	sidesX setVariable [_markerX,nil,true];
	_nul = [5,-5,_positionX] remoteExec ["A3A_fnc_citySupportChange",2];
	deleteMarker _markerX;
	["TaskFailed", ["", "Roadblock Lost"]] remoteExec ["BIS_fnc_showNotification", 0];
};

waitUntil {sleep 1; (spawner getVariable _markerX == 2) or (!(_markerX in lightroadblocksFIA))};

if (!isNull _veh) then { 
    deleteVehicle _veh;
};

{ 
    deleteVehicle _x 
} forEach units _groupX;
deleteGroup _groupX;