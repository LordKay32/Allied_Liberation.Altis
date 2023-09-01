if (!isServer and hasInterface) exitWith {};

private _markerX = _this select 0;
private _positionX = getMarkerPos _markerX;
private _garrison = garrison getVariable [_markerX, []];
private _statics = garrison getVariable [(_markerX + "_statics"), []];

private _props = [];
private _weaps = [];

if (isNil "_garrison") then {//this is for backward compatibility, remove after v12
    _garrison = [UKSL,UKMG,UKMG,UKMedic,UKMil,UKMil];
    garrison setVariable [_markerX,_garrison,true];
};

private _groupX = [_positionX, teamPlayer, _garrison,true,false] call A3A_fnc_spawnGroup;
private _groupXUnits = units _groupX;
_groupXUnits apply { [_x,_markerX] spawn A3A_fnc_FIAinitBases; if ((_x getVariable "unitType") in squadLeaders) then {_x linkItem "ItemRadio"} };

private _staticPositionInfo = staticPositions getVariable [_markerX, []];
private _staticPosition = _staticPositionInfo select 0;
private _staticDirection = _staticPositionInfo select 1;

private _posRight = [_staticPosition, 3.5, (_staticDirection + 90)] call BIS_Fnc_relPos;

		_relativePosition = [_posRight, 2,(_staticDirection + 105)] call BIS_Fnc_relPos; 
    	_sandbag = createVehicle ["Land_BagFence_Round_F", _relativePosition, [], 0, "CAN_COLLIDE"]; 
    	_sandbag setDir ([_sandbag, _posRight] call BIS_fnc_dirTo); 
    	_sandbag setVectorUp surfaceNormal position _sandbag;
    	_props pushBack _sandbag;

		_relativePosition = [_posRight, 1.6,(_staticDirection + 255)] call BIS_Fnc_relPos; 
    	_sandbag = createVehicle ["Land_BagFence_Round_F", _relativePosition, [], 0, "CAN_COLLIDE"]; 
    	_sandbag setDir ([_sandbag, _posRight] call BIS_fnc_dirTo); 
    	_sandbag setVectorUp surfaceNormal position _sandbag;
    	_props pushBack _sandbag;

_GC = createVehicle ["ClutterCutter_small_EP1", _posRight, [],0, "CAN_COLLIDE"];
_props pushBack _GC;

private _groupMGUnits = _groupXUnits;

if (count _statics > 0) then {
	private _veh = objNull;
	_veh = createVehicle [UKMGStatic, _posRight, [], 0, "CAN_COLLIDE"];
	_veh setDir _staticDirection;
	_veh addEventHandler ["Killed", {
			_markerX = [hmgpostsFIA, _unit] call BIS_fnc_nearestPosition;
			_statics = garrison getVariable [(_markerX + "_statics"), []];
			if (count _statics == 2) then {_statics deleteAt 1} else {_statics deleteAt 0};
			garrison setVariable [(_markerX + "_statics"),_statics,true];
		}];
	_weaps pushBack _veh;

	sleep 1;

	[_veh,"Move_Outpost_Static"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian], _veh];

	private _crewManIndex = _groupMGUnits findIf  {(_x getVariable "unitType") == UKMil};
	if (_crewManIndex != -1) then {
	    private _crewMan = _groupMGUnits select _crewManIndex;
	    _crewMan moveInGunner _veh;
		_crewMan doWatch (_veh getRelPos [200, 0]);
	    _groupMGUnits deleteAT _crewManIndex;
	};
	[_veh, teamPlayer] call A3A_fnc_AIVEHinit;
};

private _posLeft = [_staticPosition, 4, (_staticDirection + 270)] call BIS_Fnc_relPos;

		_relativePosition = [_posLeft, 2,(_staticDirection + 105)] call BIS_Fnc_relPos; 
    	_sandbag = createVehicle ["Land_BagFence_Round_F", _relativePosition, [], 0, "CAN_COLLIDE"]; 
    	_sandbag setDir ([_sandbag, _posLeft] call BIS_fnc_dirTo); 
    	_sandbag setVectorUp surfaceNormal position _sandbag;
    	_props pushBack _sandbag;

		_relativePosition = [_posLeft, 1.6,(_staticDirection + 255)] call BIS_Fnc_relPos; 
    	_sandbag = createVehicle ["Land_BagFence_Round_F", _relativePosition, [], 0, "CAN_COLLIDE"]; 
    	_sandbag setDir ([_sandbag, _posLeft] call BIS_fnc_dirTo); 
    	_sandbag setVectorUp surfaceNormal position _sandbag;
    	_props pushBack _sandbag;

_GC = createVehicle ["ClutterCutter_small_EP1", _posLeft, [],0, "CAN_COLLIDE"];
_props pushBack _GC;

if (count _statics > 1) then {
	private _veh = objNull;
	_veh = createVehicle [UKMGStatic, _posLeft, [], 0, "CAN_COLLIDE"];
	_veh setDir _staticDirection;
	_veh addEventHandler ["Killed", {
			_markerX = [hmgpostsFIA, _unit] call BIS_fnc_nearestPosition;
			_statics = garrison getVariable [(_markerX + "_statics"), []];
			if (count _statics == 2) then {_statics deleteAt 1} else {_statics deleteAt 0};
			garrison setVariable [(_markerX + "_statics"),_statics,true];
		}];
	_weaps pushBack _veh;

	sleep 1;

	[_veh,"Move_Outpost_Static"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian], _veh];

	private _groupMGUnits = _groupXUnits;
	private _crewManIndex = _groupMGUnits findIf  {(_x getVariable "unitType") == UKMil};
	if (_crewManIndex != -1) then {
    	_crewMan = _groupMGUnits select _crewManIndex;
    	_crewMan moveInGunner _veh;
		_crewMan doWatch (_veh getRelPos [200, 0]);
	};
	[_veh, teamPlayer] call A3A_fnc_AIVEHinit;
};

private _camonet = createVehicle ["CamoNet_BLUFOR_open_F", _staticPosition, [], 0, "CAN_COLLIDE"];
_camonet setDir _staticDirection;
_props pushBack _camonet;

_groupX setBehaviour "SAFE";
_groupX setCombatMode "YELLOW"; 
_groupX setFormation "FILE";
private _wp0 = _groupX addWaypoint [[_staticPosition, 60, (_staticDirection + 45)] call BIS_Fnc_relPos, 0];
private _wp1 = _groupX addWaypoint [[_staticPosition, 60, (_staticDirection + 135)] call BIS_Fnc_relPos, 0];
private _wp2 = _groupX addWaypoint [[_staticPosition, 60, (_staticDirection + 225)] call BIS_Fnc_relPos, 0];
private _wp3 = _groupX addWaypoint [[_staticPosition, 60, (_staticDirection + 315)] call BIS_Fnc_relPos, 0];
private _wp4 = _groupX addWaypoint [[_staticPosition, 60, (_staticDirection + 45)] call BIS_Fnc_relPos, 0];
_wp4 setWaypointType "CYCLE";

waitUntil {
	sleep 1; 
	((spawner getVariable _markerX == 2)) or 
	({alive _x} count units _groupX == 0) or (!(_markerX in hmgpostsFIA))
};

if ({alive _x} count units _groupX == 0) then {
	hmgpostsFIA = hmgpostsFIA - [_markerX]; publicVariable "hmgpostsFIA";
	markersX = markersX - [_markerX]; publicVariable "markersX";
	sidesX setVariable [_markerX,nil,true];
	_nul = [5,-5,_positionX] remoteExec ["A3A_fnc_citySupportChange",2];
	deleteMarker _markerX;
	["TaskFailed", ["", "HMG Emplacement Lost"]] remoteExec ["BIS_fnc_showNotification", 0];
};

waitUntil {sleep 1; (spawner getVariable _markerX == 2) or (!(_markerX in hmgpostsFIA))};

{
	deleteVehicle _x;
} forEach _weaps;

{ 
    deleteVehicle _x 
} forEach units _groupX;
deleteGroup _groupX;

{
	deleteVehicle _x;
} forEach _props;