if (!isServer and hasInterface) exitWith {};

private _markerX = _this select 0;
private _positionX = getMarkerPos _markerX;

private _garrison = garrison getVariable [_markerX, []];
private _statics = garrison getVariable [(_markerX + "_statics"), []];
private _veh = objNull;
private _props = [];
private _weaps = [];
private _staticDirection = 0;


if (isNil "_garrison") then {//this is for backward compatibility, remove after v12
    _garrison = [USSL,USMG,USATman,USMedic,USMil,USMG];
    garrison setVariable [_markerX,_garrison,true];
};

private _terrainObjs = [];
_terrainObjs = nearestTerrainObjects [_positionX, [], 32];

{
hideObjectGlobal _x;
} forEach _terrainObjs;

private _staticPositionInfo = staticPositions getVariable [_markerX, []];
private _staticPosition = _staticPositionInfo select 0;
private _staticDirection = _staticPositionInfo select 1;

//Spawn troops
_groupX = [_positionX, teamPlayer, _garrison,true,false] call A3A_fnc_spawnGroup;
private _groupXUnits = units _groupX;
{
    [_x,_markerX] spawn A3A_fnc_FIAinitBASES;
    if ((_x getVariable "unitType") in squadLeaders) then {_x linkItem "ItemRadio"};
} forEach _groupXUnits;

sleep 1;

//Bunker, barriers, trucks, flags
private _posObject = "Land_HelipadEmpty_F" createVehicle _staticPosition;
_posObject setDir _staticDirection;
_props pushBack _posObject;

private _bunker = "Land_BagBunker_Tower_F" createVehicle [0,0,0];        
_dir = _staticDirection;              
_pos = _posObject getRelPos [16, 8.5];
_bunker setDir (_dir + 90);       
_bunker setPos _pos;
_props pushBack _bunker;

private _GC = createVehicle ["ClutterCutter_small_EP1", (getPos _bunker), [],0, "CAN_COLLIDE"];
_props pushBack _GC;
       
private _barrier1 = "Land_HBarrier_5_F" createVehicle [0,0,0];        
_dir = _staticDirection;       
_pos = _posObject getRelPos [15.4, 331.8];     
_barrier1 setDir _dir;       
_barrier1 setPos _pos;
_props pushBack _barrier1;
      
private _barrier2 = "Land_HBarrier_5_F" createVehicle [0,0,0];        
_dir = _staticDirection + 45;       
_pos = _posObject getRelPos [15.4, 26.5];      
_barrier2 setDir _dir;       
_barrier2 setPos _pos;
_props pushBack _barrier2;
      
private _barrier3 = "Land_HBarrier_5_F" createVehicle [0,0,0];        
_dir = _staticDirection + 315;       
_pos = _posObject getRelPos [14.95, 313.5];
_barrier3 setDir _dir;       
_barrier3 setPos _pos;
_props pushBack _barrier3;
     
private _barrier4 = "Land_HBarrier_5_F" createVehicle [0,0,0];        
_dir = _staticDirection + 45;       
_pos =_posObject getRelPos [14.6, 48];      
_barrier4 setDir _dir;       
_barrier4 setPos _pos;
_props pushBack _barrier4;
      
private _barrier5 = "Land_HBarrier_5_F" createVehicle [0,0,0];        
_dir = _staticDirection + 315;       
_pos = _posObject getRelPos [16.15, 293.2]; 
_barrier5 setDir _dir;       
_barrier5 setPos _pos;
_props pushBack _barrier5;
     
private _barrier6 = "Land_HBarrier_5_F" createVehicle [0,0,0];        
_dir = _staticDirection + 180;       
_pos = _posObject getRelPos [15.4, 151.8];       
_barrier6 setDir _dir;       
_barrier6 setPos _pos;
_props pushBack _barrier6;
      
private _barrier7 = "Land_HBarrier_5_F" createVehicle [0,0,0];        
_dir = _staticDirection + 225;       
_pos = _posObject getRelPos [15.6, 210];       
_barrier7 setDir _dir;       
_barrier7 setPos _pos;
_props pushBack _barrier7;
      
private _barrier8 = "Land_HBarrier_5_F" createVehicle [0,0,0];        
_dir = _staticDirection + 135;       
_pos = _posObject getRelPos [14.95, 133.5];
_barrier8 setDir _dir;       
_barrier8 setPos _pos;
_props pushBack _barrier8;
     
private _barrier9 = "Land_HBarrier_5_F" createVehicle [0,0,0];        
_dir = _staticDirection + 225;       
_pos = _posObject getRelPos [15.15, 231];    
_barrier9 setDir _dir;       
_barrier9 setPos _pos;
_props pushBack _barrier9;
      
private _barrier10 = "Land_HBarrier_5_F" createVehicle [0,0,0];        
_dir = _staticDirection + 135;       
_pos = _posObject getRelPos [16.1, 113.2];   
_barrier10 setDir _dir;       
_barrier10 setPos _pos;
_props pushBack _barrier10;
    
private _barrier11 = "Land_HBarrier_5_F" createVehicle [0,0,0];        
_dir = _staticDirection + 180;       
_pos = _posObject getRelPos [14, 192];      
_barrier11 setDir _dir;       
_barrier11 setPos _pos;
_props pushBack _barrier11;
  
_pos = _posObject getRelPos [12, 355];
private _flag1 = "Flag_US_F" createVehicle _pos;  
_flag1 setDir _staticDirection;
_props pushBack _flag1;

sleep 0.5;

if (vehSDKAmmo in _statics) then {
	_pos = _posObject getRelPos [12, 310];
	_dir = _staticDirection + 225; 
	private _veh1 = vehSDKAmmo createVehicle _positionX; 
	_veh1 setDir _dir;       
	_veh1 setPos _pos;
	[_veh1, teamPlayer] call A3A_fnc_AIVEHinit;
	_veh1 addEventHandler ["Killed", {
		_markerX = [supportpostsFIA, _unit] call BIS_fnc_nearestPosition;
		_statics = garrison getVariable [(_markerX + "_statics"), []];
		_statics = _statics - [vehSDKAmmo];
		garrison setVariable [(_markerX + "_statics"),_statics,true];
	}];
	_weaps pushBack _veh1;
};

sleep 0.5;

if (vehSDKRepair in _statics) then {
	_pos = _posObject getRelPos [11.5, 40];
	_dir = _staticDirection + 315; 
	private _veh2 = vehSDKRepair createVehicle _positionX; 
	_veh2 setDir _dir;       
	_veh2 setPos _pos;
	[_veh2, teamPlayer] call A3A_fnc_AIVEHinit;
	_veh2 addEventHandler ["Killed", {
		_markerX = [supportpostsFIA, _unit] call BIS_fnc_nearestPosition;
		_statics = garrison getVariable [(_markerX + "_statics"), []];
		_statics = _statics - [vehSDKRepair];
		garrison setVariable [(_markerX + "_statics"),_statics,true];
	}];
	_weaps pushBack _veh2;
};

sleep 0.5;

if (vehSDKFuel in _statics) then {
	_pos = _posObject getRelPos [12, 230];
	_dir = _staticDirection + 315; 
	private _veh3 = vehSDKFuel createVehicle _positionX; 
	_veh3 setDir _dir;       
	_veh3 setPos _pos;
	[_veh3, teamPlayer] call A3A_fnc_AIVEHinit;
	_veh3 addEventHandler ["Killed", {
		_markerX = [supportpostsFIA, _unit] call BIS_fnc_nearestPosition;
		_statics = garrison getVariable [(_markerX + "_statics"), []];
		_statics = _statics - [vehSDKFuel];
		garrison setVariable [(_markerX + "_statics"),_statics,true];
	}];
	_weaps pushBack _veh3;
};

sleep 0.5;

if (vehSDKMedical in _statics) then {
	_pos = _posObject getRelPos [12, 140];
	_dir = _staticDirection + 225; 
	private _veh4 = vehSDKMedical createVehicle _positionX; 
	_veh4 setDir _dir;       
	_veh4 setPos _pos;
	[_veh4, teamPlayer] call A3A_fnc_AIVEHinit;
	_veh4 addEventHandler ["Killed", {
		_markerX = [supportpostsFIA, _unit] call BIS_fnc_nearestPosition;
		_statics = garrison getVariable [(_markerX + "_statics"), []];
		_statics = _statics - [vehSDKMedical];
		garrison setVariable [(_markerX + "_statics"),_statics,true];
	}];
	_weaps pushBack _veh4;
};

sleep 0.5;

if (vehSDKLightUnarmed in _statics) then {
	_pos = _posObject getRelPos [11, 180];
	_dir = _staticDirection + 270; 
	private _veh5 = vehSDKLightUnarmed createVehicle _positionX; 
	_veh5 setDir _dir;       
	_veh5 setPos _pos;
	[_veh5, teamPlayer] call A3A_fnc_AIVEHinit;
	_veh5 addEventHandler ["Killed", {
		_markerX = [supportpostsFIA, _unit] call BIS_fnc_nearestPosition;
		_statics = garrison getVariable [(_markerX + "_statics"), []];
		_statics = _statics - [vehSDKLightUnarmed];
		garrison setVariable [(_markerX + "_statics"),_statics,true];
	}];
	_veh5 lock 3;
	//[_veh5, ["Transport to location", {[_veh5,_markerX] spawn A3A_fnc_SPTransport}]] remoteExec ["addAction"];
	_weaps pushBack _veh5;
};

//MGs
private _MGGroup = units _groupX;
if (USMGStatic in _statics) then {
	_veh = USMGStatic createVehicle _positionX;
	_veh setDir ((getDir _bunker) + 270);
	private _zOffset = [0, 0, 2.7];
	_pos = (_bunker getRelPos [2.6,325]) vectorAdd _zOffset;
	_veh setPos _pos;
	[_veh, teamPlayer] call A3A_fnc_AIVEHinit;
	_veh addEventHandler ["Killed", {
		_markerX = [supportpostsFIA, _unit] call BIS_fnc_nearestPosition;
		_statics = garrison getVariable [(_markerX + "_statics"), []];
		_statics = _statics - [USMGStatic];
		garrison setVariable [(_markerX + "_statics"),_statics,true];
	}];
	_weaps pushBack _veh;
};

sleep 1;

private _index = count (units _groupX) - 1;
private _MGMan = ((units _groupX) select _index);

if (_MGMan getVariable "unitType" == USMG) then {
	_MGMan disableAI "PATH";
	_MGMan setUnitPos "MIDDLE";
	_zOffset = [0, 0, 2.75];
	_pos = (_bunker getRelPos [1.9,193]) vectorAdd _zOffset;
	_MGMan setPos _pos;
   	_MGMan doWatch (_veh getRelPos [200, 0]);
   	_MGMan addEventHandler ["Reloaded", {
		params ["_unit", "_weapon", "_muzzle", "_newMagazine", "_oldMagazine"];
		if (count (magazines _unit) == 0) then {
			for "_i" from 1 to 4 do
			{
			_unit addItemToVest "LIB_20Rnd_762x63";
			};
			["LIB_20Rnd_762x63" call jn_fnc_arsenal_itemType, "LIB_20Rnd_762x63", 4] call jn_fnc_arsenal_removeItem;
		};
	}];
};

sleep 1;

_crewManIndex = _MGGroup findIf  {(_x getVariable "unitType") == USMil};
if (_crewManIndex != -1) then {
    private _crewMan = _MGGroup select _crewManIndex;
    _crewMan moveInGunner _veh;
    _crewMan doWatch (_veh getRelPos [200, 0]);
};

sleep 1;

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
	({alive _x} count (units _groupX) == 0) or (!(_markerX in supportpostsFIA))
};

if ({alive _x} count (units _groupX) == 0) then {
	supportpostsFIA = supportpostsFIA - [_markerX]; publicVariable "supportpostsFIA";
	markersX = markersX - [_markerX]; publicVariable "markersX";
	sidesX setVariable [_markerX,nil,true];
	_nul = [5,-5,_positionX] remoteExec ["A3A_fnc_citySupportChange",2];
	deleteMarker _markerX;
	["TaskFailed", ["", "Support Post Lost"]] remoteExec ["BIS_fnc_showNotification", 0];
	{
	_x hideObjectGlobal false;
	} forEach _terrainObjs;
};

waitUntil {sleep 1; (!(_markerX in supportpostsFIA))};

{ 
    deleteVehicle _x 
} forEach units _groupX;
deleteGroup _groupX;

{
	_x removeAllEventHandlers "Killed";
	if (_x distance _positionX < 25) then {deleteVehicle _x};
} forEach _weaps;

{
	deleteVehicle _x;
} forEach _props;

{
_x hideObjectGlobal false;
} forEach _terrainObjs;