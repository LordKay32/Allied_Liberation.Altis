/*
 * Name:	MG
 * Date:	20/02/2023
 * Version: 1.0
 * Author:  %AUTHOR%
 *
 * Description:
 * %DESCRIPTION%
 *
 * Parameter(s):
 * _PARAM1 (TYPE): - DESCRIPTION.
 * _PARAM2 (TYPE): - DESCRIPTION.
 */

private _markerX = _this select 0;
private _positionX = getMarkerPos _markerX;
private _groupX = createGroup Occupants;
private _soldiers = [];
private _vehiclesX = [];
private _typeUnit = (NATOMGMan call SCRT_fnc_unit_selectInfantryTier);

private _fnc_spawnStatic = {
    params ["_pos", "_dir"];
    private _veh = createVehicle ["fow_w_mg42_deployed_high_ger_heer", _positionX, [], 0, "CAN_COLLIDE"];
    if (!isNil "_dir") then {_veh setDir _dir};
    _veh setPos _pos;
    _veh setVectorUp [0,0,1];
    private _unit = [_groupX, _typeUnit, _positionX, [], 0, "NONE"] call A3A_fnc_createUnit;
    [_unit,_markerX] call A3A_fnc_NATOinit;
    _unit moveInGunner _veh;
    _soldiers pushBack _unit;
    _vehiclesX pushBack _veh;
    _veh addEventHandler ["GetOut", {
		params ["_vehicle", "_role", "_unit", "_turret"];
		deleteVehicle _vehicle;
	}];
};

private _radius = 0;
private _num = 0;

private _MGBigHousesList = ["Land_i_Stone_HouseSmall_V1_F","Land_i_Stone_HouseSmall_V3_F","Land_i_Stone_HouseSmall_V2_F"];
private _MGSmallHousesList = ["Land_i_Stone_Shed_V2_F","Land_i_Stone_Shed_V1_F","Land_i_Stone_Shed_V3_F"];
private _MGDestroyedHouse = ["Land_d_Stone_HouseSmall_V1_F"];

if (_markerX in majorCitiesX) then {_radius = 300; _num = 8};
if (_markerX in townsX) then {_radius = 200; _num = 4};
if (_markerX in villagesX) then {_radius = 100; _num = 2};

private _MGBigHouses = nearestObjects [(getMarkerPos _markerX), _MGBigHousesList, _radius]; 
private _MGSmallHouses = nearestObjects [(getMarkerPos _markerX), _MGSmallHousesList, _radius]; 
private _MGDestroyedHouses = nearestObjects [(getMarkerPos _markerX), _MGDestroyedHouse, _radius]; 
 
private _allMGPositions = []; 
 
{ 
_building = _x;
if (isObjectHidden _building) exitWith {};
 	{ 
 	_allMGPositions append [[_building,_x]]; 
 	} forEach [0,1,3,4]; 
} forEach _MGBigHouses; 
 
 
{ 
_building = _x; 
if (isObjectHidden _building) exitWith {};
 	{ 
 	_allMGPositions append [[_building,_x]]; 
 	} forEach [0,1]; 
} forEach _MGDestroyedHouses; 
 
 
{ 
_building = _x; 
if (isObjectHidden _building) exitWith {};
 	{ 
 	_allMGPositions append [[_building,_x]]; 
 	} forEach [0,1,2]; 
} forEach _MGSmallHouses; 
 
private _chosenArray = []; 
if (count _allMGPositions < _num) then { 
 	_chosenArray = _allMGPositions; 
} else { 
 	_chosenArray = []; 
 	for[ {_n=0},{_n<_num},{_n=_n+1} ] do { 
  	_arraySize   = count _allMGPositions; 
  	_randomIndex = round (random (_arraySize - 1)); 
  	_varToCopy   = [(_allMGPositions select _randomIndex)]; 
  	_chosenArray = _chosenArray  + _varToCopy; 
  	_allMGPositions   = _allMGPositions - _varToCopy; 
 	}; 
};
 
{ 
_building = _x select 0; 
_buildingPos = _x select 1; 
if (typeOf _building in (_MGBigHousesList + _MGDestroyedHouse)) then { 
 
 	if (_buildingPos == 0) then { 
  		private _dir = getDir _building;   
  		private _zpos = AGLToASL (_building buildingPos 0);  
  		private _pos = _zpos getPos [1.03, _dir]; 
  		private _xpos = _pos getPos [0.1, (_dir + 90)];  
  		_pos = ASLToATL ([_xpos select 0, _xpos select 1, _zpos select 2]); 
		[_pos, _dir] call _fnc_spawnStatic;
 	}; 
 
	if (_buildingPos == 1) then { 
	  	private _dir = (getDir _building) + 180;   
	  	private _zpos = AGLToASL (_building buildingPos 1);  
	  	private _pos = _zpos getPos [1.03, _dir]; 
	  	private _xpos = _pos getPos [-0.06, (_dir + 90)];  
	  	_pos = ASLToATL ([_xpos select 0, _xpos select 1, _zpos select 2]); 
		[_pos, _dir] call _fnc_spawnStatic;
 	}; 
 
 	if (_buildingPos == 3) then { 
  		private _dir = (getDir _building) + 180; 
  		private _zpos = AGLToASL (_building buildingPos 3);  
  		private _pos = _zpos getPos [0.85, _dir]; 
  		private _xpos = _pos getPos [0.04, (_dir + 90)]; 
  		_pos = ASLToATL ([_xpos select 0, _xpos select 1, _zpos select 2]); 
		[_pos, _dir] call _fnc_spawnStatic;
 	}; 
 
 	if (_buildingPos == 4) then { 
  		private _dir = getDir _building;   
  		private _zpos = AGLToASL (_building buildingPos 4);   
  		private _pos = _zpos getPos [0.85, _dir];  
  		private _xpos = _pos getPos [0.24, (_dir + 90)];  
  		_pos = ASLToATL ([_xpos select 0, _xpos select 1, _zpos select 2]);  
		[_pos, _dir] call _fnc_spawnStatic;
 	}; 
}; 
 
if (typeOf _building in _MGSmallHousesList) then { 
 
 	if (_buildingPos == 0) then { 
  		private _dir = (getDir _building);  
  		private _zpos = AGLToASL (_building buildingPos 0);   
  		private _pos = _zpos getPos [0.125, _dir];  
  		private _xpos = _pos getPos [0.45, (_dir + 90)];
		_dir = _dir + 90;  		
  		_pos = ASLToATL ([_xpos select 0, _xpos select 1, (_zpos select 2) - 0.15]); 
		[_pos, _dir] call _fnc_spawnStatic;
	}; 
 
 	if (_buildingPos == 1) then { 
  		private _dir = (getDir _building);   
  		private _zpos = AGLToASL (_building buildingPos 1);    
  		private _pos = _zpos getPos [0.82, _dir];   
  		private _xpos = _pos getPos [0.04, _dir + 90];    
  		_pos = ASLToATL ([_xpos select 0, _xpos select 1, (_zpos select 2) - 0.15]);  
		[_pos, _dir] call _fnc_spawnStatic;
 	}; 
 
 	if (_buildingPos == 2) then { 
  		private _dir = (getDir _building);  
  		private _zpos = AGLToASL (_building buildingPos 2);    
  		private _pos = _zpos getPos [-0.82, _dir];   
  		private _xpos = _pos getPos [-0.11, _dir + 90];  
		_dir = _dir + 180;  		
  		_pos = ASLToATL ([_xpos select 0, _xpos select 1, (_zpos select 2) - 0.1675]);  
		[_pos, _dir] call _fnc_spawnStatic;
 	}; 
}; 

} forEach _chosenArray;

[_groupX,_vehiclesX,_soldiers]