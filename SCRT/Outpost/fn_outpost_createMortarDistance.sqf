if (!isServer and hasInterface) exitWith {};

private _markerX = _this select 0;
private _positionX = getMarkerPos _markerX;
private _garrison = garrison getVariable [_markerX, []];
private _statics = garrison getVariable [(_markerX + "_statics"), []];

private _props = [];

if (isNil "_garrison") then {
    _garrison = [USSL,USMG,USMedic,USATman,USMil,USMil,USMil];
    garrison setVariable [_markerX,_garrison,true];
};

private _groupX = [([_positionX, 50, (0)] call BIS_Fnc_relPos), teamPlayer, _garrison,true,false] call A3A_fnc_spawnGroup;
private _groupXUnits = units _groupX;
_groupXUnits apply { [_x,_markerX] spawn A3A_fnc_FIAinitBases; if ((_x getVariable "unitType") in squadLeaders) then {_x linkItem "ItemRadio"} };

{
    private _relativePosition = [_positionX, 4, _x] call BIS_Fnc_relPos;
    private _sandbag = createVehicle ["Land_BagFence_Round_F", _relativePosition, [], 0, "CAN_COLLIDE"];
    _sandbag setDir ([_sandbag, _positionX] call BIS_fnc_dirTo);
    _sandbag setVectorUp surfaceNormal position _sandbag;
    _props pushBack _sandbag;
} forEach [0, 90, 180, 270];

_GC = createVehicle ["ClutterCutter_small_EP1", _positionX, [],0, "CAN_COLLIDE"];
_props pushBack _GC;

private _veh = objNull;

//overriden static position and direction
private _groupE = createGroup teamPlayer;
if (SDKArtillery in _statics) then {
	private _staticPositionInfo = staticPositions getVariable [_markerX, []];
	if (!(_staticPositionInfo isEqualTo [])) then {
	    private _staticPosition = _staticPositionInfo select 0;
	    private _staticDirection = _staticPositionInfo select 1;
	    _veh = createVehicle [SDKArtillery, _positionX, [], 0, "CAN_COLLIDE"];
	    _veh setObjectTextureGlobal [0, "ww2\assets_t\vehicles\staticweapons_t\i44_lefh18\lefh18_2tone_co.paa"];
	    _veh setPosATL _staticPosition;
	    _veh setDir _staticDirection;
	} else {
	    _veh = SDKArtillery createVehicle _positionX;
	    _veh setObjectTextureGlobal [0, "ww2\assets_t\vehicles\staticweapons_t\i44_lefh18\lefh18_2tone_co.paa"];
	};
	_veh addEventHandler ["Killed", {
		_markerX = [mortarpostsFIA, _unit] call BIS_fnc_nearestPosition;
		_statics = garrison getVariable [(_markerX + "_statics"), []];
		_statics = _statics - [SDKArtillery];
		garrison setVariable [(_markerX + "_statics"),_statics,true];
	}];
	_veh lock 3;
	artySupport synchronizeObjectsAdd [_veh];
	
	sleep 1;

	[_veh,"Move_Outpost_Static"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian], _veh];

	private _mortarGroup = _groupXUnits;
	private _crewManIndex = _mortarGroup findIf  {(_x getVariable "unitType") == USMil};
	if (_crewManIndex != -1) then {
	    private _crewMan = _mortarGroup select _crewManIndex;
	    [_crewMan] joinSilent _groupE;
	    _crewMan moveInCargo _veh;
	    _mortarGroup deleteAT _crewManIndex;
	};
	private _crewManIndex = _mortarGroup findIf  {(_x getVariable "unitType") == USMil};
	if (_crewManIndex != -1) then {
	    private _crewMan = _mortarGroup select _crewManIndex;
	    _crewMan moveInAny _veh;
		[_crewMan] joinSilent _groupE;
	    _mortarGroup deleteAT _crewManIndex;
	};
	private _crewManIndex = _mortarGroup findIf  {(_x getVariable "unitType") == USMil};
	if (_crewManIndex != -1) then {
	    private _crewMan = _mortarGroup select _crewManIndex;
	    _crewMan moveInAny _veh;
		[_crewMan] joinSilent _groupE;
	};
};

private _groupId = groupId _groupE;
private _numberOfArtys = count mortarpostsFIA;
private _id = call {
		if (_numberOfArtys == 1) exitWith {"Able"};
   		if (_numberOfArtys == 2) exitWith {"Baker"};
   		if (_numberOfArtys == 3) exitWith {"Charlie"};
		if (_numberOfArtys == 4) exitWith {"Dog"};		
   		if (_numberOfArtys == 5) exitWith {"Easy"};
   		if (_numberOfArtys == 6) exitWith {"Fox"};
		_groupId;
};

_groupE setGroupIdGlobal [_id];

_groupX setBehaviour "SAFE";
_groupX setCombatMode "YELLOW"; 
_groupX setFormation "FILE";
private _wp0 = _groupX addWaypoint [[_positionX, 50, (0)] call BIS_Fnc_relPos, 0];
private _wp1 = _groupX addWaypoint [[_positionX, 50, (90)] call BIS_Fnc_relPos, 0];
private _wp2 = _groupX addWaypoint [[_positionX, 50, (180)] call BIS_Fnc_relPos, 0];
private _wp3 = _groupX addWaypoint [[_positionX, 50, (270)] call BIS_Fnc_relPos, 0];
private _wp4 = _groupX addWaypoint [[_positionX, 50, (0)] call BIS_Fnc_relPos, 0];
_wp4 setWaypointType "CYCLE";

[_veh, teamPlayer] call A3A_fnc_AIVEHinit;

waitUntil {
	sleep 1; 
	({alive _x} count units _groupX == 0) or (!(_markerX in mortarpostsFIA))
};

if ({alive _x} count units _groupX == 0) then {
	mortarpostsFIA = mortarpostsFIA - [_markerX]; publicVariable "mortarpostsFIA";
	markersX = markersX - [_markerX]; publicVariable "markersX";
	sidesX setVariable [_markerX,nil,true];
	_nul = [5,-5,_positionX] remoteExec ["A3A_fnc_citySupportChange",2];
	deleteMarker _markerX;
	["TaskFailed", ["", "Artillery Emplacement Lost"]] remoteExec ["BIS_fnc_showNotification", 0];
};

waitUntil {sleep 1; (!(_markerX in mortarpostsFIA))};

if (!isNull _veh) then { 
    deleteVehicle _veh;
};

{ 
    deleteVehicle _x 
} forEach units _groupX;
deleteGroup _groupX;

{ 
    deleteVehicle _x 
} forEach units _groupE;
deleteGroup _groupE;

{
	deleteVehicle _x;
} forEach _props;