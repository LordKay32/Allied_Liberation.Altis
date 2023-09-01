if (!isServer and hasInterface) exitWith {};

private _markerX = _this select 0;
private _positionX = getMarkerPos _markerX;

private _radiusX = 1;
private _garrison = garrison getVariable [_markerX, []];
private _statics = garrison getVariable [(_markerX + "_statics"), []];
private _veh = objNull;
private _road = objNull;
private _props = [];
private _weaps = [];
private _staticDirection = 0;


if (isNil "_garrison") then {//this is for backward compatibility, remove after v12
    _garrison = [UKSL,UKMG,UKATman,UKMedic,UKMil,UKMil,UKMil,UKMG];
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

private _terrainObjs = [];
_terrainObjs = nearestTerrainObjects [_roadPosition, [], 15];

{
hideObjectGlobal _x;
} forEach _terrainObjs;

//Spawn troops
_groupX = [_positionX, teamPlayer, _garrison,true,false] call A3A_fnc_spawnGroup;
private _groupXUnits = units _groupX;
{
    [_x,_markerX] spawn A3A_fnc_FIAinitBases; 
    if ((_x getVariable "unitType") in squadLeaders) then {_x linkItem "ItemRadio"};
} forEach _groupXUnits;

sleep 1;

//Bunker
private _pos = [_roadPosition, 11, _staticDirection + 270] call BIS_Fnc_relPos; 
private _bunker = "Land_BagBunker_Tower_F" createVehicle _pos; 
_bunker setDir (_staticDirection + 90);
_bunker setVectorUp surfaceNormal position _bunker;
_props pushBack _bunker;
_pos = [(getPos _bunker), 8, ((getDir _bunker) + 90)] call BIS_fnc_relPos;
private _flag = createVehicle ["Flag_UK_F", _pos, [],0, "NONE"];
_props pushBack _flag;
private _GC = createVehicle ["ClutterCutter_small_EP1", (getPos _bunker), [],0, "CAN_COLLIDE"];
_props pushBack _GC;

//MGs
private _WeapGroup = units _groupX;
if (UKMGStatic in _statics) then {
	_veh = UKMGStatic createVehicle _positionX;
	_veh setDir ((getDir _bunker) + 270);
	private _zOffset = [0, 0, 2.7];
	_pos = (_bunker getRelPos [2.4,340]) vectorAdd _zOffset;
	_veh setPos _pos;
	[_veh, teamPlayer] call A3A_fnc_AIVEHinit;
	_veh addEventHandler ["Killed", {
		_markerX = [roadblocksFIA, _unit] call BIS_fnc_nearestPosition;
		_statics = garrison getVariable [(_markerX + "_statics"), []];
		_statics = _statics - [UKMGStatic];
		garrison setVariable [(_markerX + "_statics"),_statics,true];
	}];
	_weaps pushBack _veh;
	
	sleep 1;

	private _crewManIndex = _WeapGroup findIf  {(_x getVariable "unitType") == UKMil};
	if (_crewManIndex != -1) then {
	    private _crewMan = _WeapGroup select _crewManIndex;
	    _crewMan moveInGunner _veh;
	    _crewMan doWatch (_veh getRelPos [200, 0]);
	    _WeapGroup deleteAT _crewManIndex;
	};
};

sleep 1;

private _index = count (units _groupX) - 1;
private _MGMan = ((units _groupX) select _index);

if (_MGMan getVariable "unitType" == UKMG) then {
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
			_unit addItemToVest "LIB_30Rnd_770x56";
			};
			["LIB_30Rnd_770x56" call jn_fnc_arsenal_itemType, "LIB_30Rnd_770x56", 4] call jn_fnc_arsenal_removeItem;
		};
	}];
};

//Sandbags and camonet
private _relativePosition = [_roadPosition, 11, _staticDirection + 90] call BIS_Fnc_relPos; 
{ 
_pos = [_relativePosition, 3, (_staticDirection + _x)] call BIS_Fnc_relPos; 
private _sandbag = createVehicle ["Land_BagFence_Round_F", _pos, [], 0, "CAN_COLLIDE"]; 
_sandbag setDir ([_sandbag, _relativePosition] call BIS_fnc_dirTo); 
_sandbag setVectorUp surfaceNormal position _sandbag; 
_props pushBack _sandbag;
} forEach [45, 135, 225, 315];
private _camonet = createVehicle ["CamoNet_BLUFOR_F", _relativePosition, [], 0, "CAN_COLLIDE"]; 
_camonet setDir (_staticDirection + 90);
_props pushBack _camonet;
_GC = createVehicle ["ClutterCutter_small_EP1", _relativePosition, [],0, "CAN_COLLIDE"];
_props pushBack _GC;

//AT Gun
if (staticATteamPlayer in _statics) then {
	_pos = [_relativePosition, 1, _staticDirection] call BIS_Fnc_relPos; 
	private _veh = createVehicle [staticATteamPlayer, _pos, [], 0, "CAN_COLLIDE"];
	_veh setDir ((getDir _bunker) + 270);
	[_veh, teamPlayer] call A3A_fnc_AIVEHinit;
	_veh addEventHandler ["Killed", {
		_markerX = [roadblocksFIA, _unit] call BIS_fnc_nearestPosition;
		_statics = garrison getVariable [_markerX + "_statics", []];
		_statics = _statics - [staticATteamPlayer];
		garrison setVariable [(_markerX + "_statics"),_statics,true];
	}];
	_weaps pushBack _veh;

	sleep 1;

	_crewManIndex = _WeapGroup findIf  {(_x getVariable "unitType") == UKMil};
	if (_crewManIndex != -1) then {
    	private _crewMan = _WeapGroup select _crewManIndex;
    	_crewMan moveInGunner _veh;
    	_crewMan doWatch (_veh getRelPos [200, 0]);
    	_WeapGroup deleteAT _crewManIndex;
	};    
	_crewManIndex = _WeapGroup findIf  {(_x getVariable "unitType") == UKMil};
	if (_crewManIndex != -1) then {
    	private _crewMan = _WeapGroup select _crewManIndex;
    	_crewMan moveInDriver _veh;    
	};
};

_groupX setBehaviour "SAFE";
_groupX setFormation "FILE";
private _ukwp0 = _groupX addWaypoint [[(getPos _bunker), 60, (_staticDirection + 300)] call BIS_Fnc_relPos, 0];
private _ukwp1 = _groupX addWaypoint [[(getPos _bunker), 60, (_staticDirection + 240)] call BIS_Fnc_relPos, 0];
private _ukwp2 = _groupX addWaypoint [[_relativePosition, 60, (_staticDirection + 120)] call BIS_Fnc_relPos, 0];
private _ukwp3 = _groupX addWaypoint [[_relativePosition, 60, (_staticDirection + 60)] call BIS_Fnc_relPos, 0];
private _ukwp4 = _groupX addWaypoint [[(getPos _bunker), 60, (_staticDirection + 300)] call BIS_Fnc_relPos, 0];
_ukwp4 setWaypointType "CYCLE";

waitUntil {
	sleep 5; 
	((spawner getVariable _markerX == 2)) or 
	({alive _x} count (units _groupX) == 0) or (!(_markerX in roadblocksFIA))
};

if ({alive _x} count (units _groupX) == 0) then {
	roadblocksFIA = roadblocksFIA - [_markerX]; publicVariable "roadblocksFIA";
	markersX = markersX - [_markerX]; publicVariable "markersX";
	sidesX setVariable [_markerX,nil,true];
	_nul = [5,-5,_positionX] remoteExec ["A3A_fnc_citySupportChange",2];
	deleteMarker _markerX;
	["TaskFailed", ["", "Roadblock Lost"]] remoteExec ["BIS_fnc_showNotification", 0];
};

waitUntil {sleep 5; (spawner getVariable _markerX == 2) or (!(_markerX in roadblocksFIA))};

{ 
    deleteVehicle _x 
} forEach units _groupX;
deleteGroup _groupX;

{
	deleteVehicle _x;
} forEach _weaps;

{
	deleteVehicle _x;
} forEach _props;

{
_x hideObjectGlobal false;
} forEach _terrainObjs;