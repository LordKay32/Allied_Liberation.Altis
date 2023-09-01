private _fileName = "milBuildings.sqf";
private ["_positionX","_size","_buildings","_groupX","_typeUnit","_sideX","_building","_typeB","_frontierX","_typeVehX","_veh","_vehiclesX","_soldiers","_groups","_pos","_ang","_markerX","_unit","_return"];
_markerX = _this select 0;
_positionX = getMarkerPos _markerX;
_size = _this select 1;
_buildings = nearestObjects [_positionX, listMilBld, _size, true];
_buildings = _buildings inAreaArray _markerX;

if (count _buildings == 0) exitWith {[grpNull,[],[]]};

_sideX = _this select 2;
_frontierX = _this select 3;

_vehiclesX = [];
_soldiers = [];
_groups = [];

_groupX = grpNull;
_typeUnit = if (_sideX==Occupants) then {
    selectRandom [(staticCrewOccupants call SCRT_fnc_unit_selectInfantryTier), policeGrunt]
} else {
    staticCrewInvaders call SCRT_fnc_unit_selectInfantryTier
};

_aggression = if (_sideX == Occupants) then {aggressionLevelOccupants} else {aggressionLevelInvaders};

private _heavyMarkers = airportsX + milbases;
if (_markerX in _heavyMarkers) then {
    private _vehicleTypes = if (_sideX == Occupants) then { vehNATOAPC } else { vehCSATAPC };
    if (_aggression > 3) then {
        if (_sideX == Occupants) then {
            _vehicleTypes append vehNATOTanks;
        } else {
            _vehicleTypes append vehCSATTanks;
        };
    };

    private _spawnVehParameter = [_markerX, "Vehicle"] call A3A_fnc_findSpawnPosition;
    private _count = 1 + round (random 3); //Change these numbers as you want, first number is minimum, max is first plus second number
    while {_spawnVehParameter isEqualType [] && {_count > 0}} do {
        _typeVehX = selectRandom _vehicleTypes;
        _veh = createVehicle [_typeVehX, (_spawnVehParameter select 0), [],0, "CAN_COLLIDE"];
        _veh setDir (_spawnVehParameter select 1);
        _vehiclesX pushBack _veh;
        _spawnVehParameter = [_markerX, "Vehicle"] call A3A_fnc_findSpawnPosition;
        _count = _count - 1;
    };
};

//Spawning certain statics on fixed buildingPos of chosen buildings

private _fnc_spawnStatic = {
    params ["_type", "_pos", "_vectorUp", "_dir"];
    private _veh = createVehicle [_type, _positionX, [], 0, "CAN_COLLIDE"];
    if (!isNil "_dir") then {_veh setDir _dir};
    _veh setPos _pos;
    if (_vectorUp) then {_veh setVectorUp [0,0,1]};
    if (isNull _groupX) then {_groupX = createGroup Occupants};
    private _unit = [_groupX, _typeUnit, _positionX, [], 0, "NONE"] call A3A_fnc_createUnit;
    [_unit,_markerX] call A3A_fnc_NATOinit;
    _unit moveInGunner _veh;
    _soldiers pushBack _unit;
    _vehiclesX pushBack _veh;
};

private _fnc_spawnATStatic = {
    params ["_type", "_pos", "_vectorUp", "_dir"];
    private _veh = createVehicle [_type, _positionX, [], 0, "CAN_COLLIDE"];
    if (!isNil "_dir") then { _veh setDir _dir };
    _veh setPos _pos;
    if (_vectorUp) then {_veh setVectorUp [0,0,1]};
    private _crew = [];
	for "_i" from 1 to 2 do
	{
		private _unit = selectRandom [(staticCrewOccupants call SCRT_fnc_unit_selectInfantryTier), policeGrunt];
		_crew pushBack _unit;
	};
    private _groupAT = createGroup Occupants;
    {[_groupAT, _x, _positionX, [], 0, "NONE"] call A3A_fnc_createUnit;} forEach _crew;
    {[_x,_markerX] call A3A_fnc_NATOinit; _soldiers pushBack _x} forEach units _groupAT;
	leader _groupAT assignAsGunner _veh; leader _groupAT moveInGunner _veh;
	{_x moveInCargo _veh} forEach ((units _groupAT) - [leader _groupX]);
    _vehiclesX pushBack _veh;
    _groups pushBack _groupAT;
};

private _fnc_spawnMortar = {
    params ["_type", "_pos", "_vectorUp", "_dir"];
    private _veh = createVehicle [_type, _positionX, [], 0, "CAN_COLLIDE"];
    if (!isNil "_dir") then {_veh setDir _dir};
    _veh setPos _pos;
    _nul = [_veh] execVM "scripts\UPSMON\MON_artillery_add.sqf";//TODO need delete UPSMON link
    if (_vectorUp) then {_veh setVectorUp [0,0,1]};
    if (isNull _groupX) then {_groupX = createGroup Occupants};
    private _unit = [_groupX, _typeUnit, _positionX, [], 0, "NONE"] call A3A_fnc_createUnit;
    [_unit,_markerX] call A3A_fnc_NATOinit;
    _unit moveInGunner _veh;
    _soldiers pushBack _unit;
    _unit = [_groupX, _typeUnit, _positionX, [], 0, "NONE"] call A3A_fnc_createUnit;
    [_unit,_markerX] call A3A_fnc_NATOinit;
    _unit moveInAny _veh;
    _soldiers pushBack _unit;
	_vehiclesX pushBack _veh;
};

private _fnc_spawnVehicle = {
    params ["_type", "_pos", "_mobile", "_dir"];
    private _veh = createVehicle [_type, _positionX, [], 0, "CAN_COLLIDE"];
    if (!isNil "_dir") then {_veh setDir _dir};
    _veh setPos _pos;
    if (_mobile == false) then {_veh setFuel 0};
    private _groupVeh = createGroup Occupants;
    _crewType = if (_type in (vehNATOTanks + [vehNATOAA select 1])) then {NATOCrew} else {staticCrewOccupants call SCRT_fnc_unit_selectInfantryTier};
	_groupVeh = [_groupVeh, _veh, _crewType] call A3A_fnc_createVehicleCrew;
	{[_x,_markerX] call A3A_fnc_NATOinit; _soldiers pushBack _x} forEach units _groupVeh;
    _vehiclesX pushBack _veh;
    _groups pushBack _groupVeh;
};

private _fnc_spawnStaticUnit = {
    params ["_type", "_pos", "_kneel", "_dir"];
    if (isNull _groupX) then {_groupX = createGroup Occupants};
	private _unit = [_groupX, _type, _positionX, [], 0, "NONE"] call A3A_fnc_createUnit;
    if (!isNil "_dir") then { _unit setDir _dir };
    _unit disableAI "PATH"; //block moving
    if (_kneel) then {_unit setUnitPos "MIDDLE"} else {_unit setUnitPos "UP"}; //force standing/kneeling
    [_unit,_markerX] call A3A_fnc_NATOinit;
    _unit setPos _pos;
    _unit doWatch (_unit getPos [200, _dir]);
    _soldiers pushBack _unit;
};

for "_i" from 0 to (count _buildings) - 1 do
{
    if (spawner getVariable _markerX == 2) exitWith {};
    private _building = _buildings select _i;
    private _typeB = typeOf _building;

    call {
        if (isObjectHidden _building) exitWith {};			// don't put statics on destroyed buildings
        if ((_markerX in CitiesX) && ((markersX - (controlsX + citiesX)) findIf {(_building inArea _x)} != -1)) exitWith {};
        switch (true) do {
            //Statics
            case (_typeB == "Land_WW2_Bunker_H679"): {
                private _pos = _building modelToWorld ([-2.4, 0, 0.38]); 
				private _alreadySpawned = nearestObjects [_pos, NATOMG, 2];
				if (count _alreadySpawned > 0) exitWith {};
                private _type = if (_sideX == Occupants) then {selectRandom NATOMG} else {selectRandom CSATMG};
                private _dir = (getDir _building) - 90;
                private _vectorUp = true;
                [_type, _pos, _vectorUp, _dir] call _fnc_spawnStatic;
                
            };
            case (_typeB == "Land_Fort_Bagfence_Bunker"): {
                private _zOffset = [0, 0, -0.08];   
				private _pos = (_building getRelPos [1.2,0]) vectorAdd _zOffset;
				private _alreadySpawned = nearestObjects [_pos, NATOMG, 2];
				if (count _alreadySpawned > 0) exitWith {};
                private _type = if (_sideX == Occupants) then {selectRandom NATOMG} else {selectRandom CSATMG};
                private _dir = getDir _building;
                private _vectorUp = false;
                [_type, _pos, _vectorUp, _dir] call _fnc_spawnStatic;
            };
            case (_typeB in ["Land_I44_Bunker_R67_Right", "Land_I44_Bunker_R67_Left"]): {
                private _modifer = if (_frontierX) then {67} else {33};
                if (random 100 > _modifer) then {
                	private _pos = _building modelToWorld ([-0.25, -0.8, 0]);
					private _alreadySpawned = nearestObjects [_pos, NATOMG, 5];
					if (count _alreadySpawned > 0) exitWith {};
                	private _type = if (_sideX == Occupants) then {selectRandom NATOMG} else {selectRandom CSATMG};
               		private _dir = (getDir _building) + 180;
               		private _vectorUp = true;
	            	[_type, _pos, _vectorUp, _dir] call _fnc_spawnStatic;
                } else {
                	private _pos = _building modelToWorld ([-1.4, -0.8, 0]);
					private _alreadySpawned = nearestObjects [_pos, NATOMG, 5];
					if (count _alreadySpawned > 0) exitWith {};
                	private _type = if (_sideX == Occupants) then {selectRandom NATOMG} else {selectRandom CSATMG};
               		private _dir = (getDir _building) + 180;
               		private _vectorUp = true;
	            	[_type, _pos, _vectorUp, _dir] call _fnc_spawnStatic;
	            	
	            	_pos = _building modelToWorld ([0.8, -0.8, 0]);
					_vectorUp = true;
					[_type, _pos, _vectorUp, _dir] call _fnc_spawnStatic;
                };
            };
            case (_typeB == "Land_WW2_Bunker_Gun_R"): {
            	private _dir = (getDir _building) + 180;
                private _zpos = AGLToASL (getPos _building);    
				private _pos = _zpos getPos [0.85, _dir];   
				private _xpos = _pos getPos [1.4, _dir + 178];   
				_pos = ASLToATL ([_xpos select 0, _xpos select 1, (_zpos select 2) + 0.105]);
				private _alreadySpawned = nearestObjects [_pos, [staticATOccupants], 2];
				if (count _alreadySpawned > 0) exitWith {};
                private _type = if (_sideX == Occupants) then {staticATOccupants} else {staticATInvaders};
                private _vectorUp = true;
                [_type, _pos, _vectorUp, _dir] call _fnc_spawnATStatic;
            };
     		case (_typeB == "Land_WW2_Bunker_Gun_L"): {
     			private _dir = (getDir _building) + 180;
                private _zpos = AGLToASL (getPos _building);   
				private _pos = _zpos getPos [0.85, _dir];  
				private _xpos = _pos getPos [0.4, _dir + 140];  
				_pos = ASLToATL ([_xpos select 0, _xpos select 1, (_zpos select 2) + 0.105]); 
				private _alreadySpawned = nearestObjects [_pos, [staticATOccupants], 2];
				if (count _alreadySpawned > 0) exitWith {};
                private _type = if (_sideX == Occupants) then {staticATOccupants} else {staticATInvaders};
                private _vectorUp = true;
                [_type, _pos, _vectorUp, _dir] call _fnc_spawnATStatic;
            };
            case (_typeB == "Land_WW2_Bunker_Mg"): {
                private _modifer = if (_frontierX) then {67} else {33};
                if (random 100 > _modifer) then {
                	private _dir = (getDir _building) + 180;  
					private _zpos = AGLToASL (getPos _building);     
					private _xpos = _zpos getPos [4.84, _dir];   
					private _pos = ASLToATL ([_xpos select 0, _xpos select 1, _zpos select 2]);   
					private _alreadySpawned = nearestObjects [_pos, ["fow_w_mg42_deployed_high_ger_heer"], 5];
					if (count _alreadySpawned > 0) exitWith {};
                	private _type = "fow_w_mg42_deployed_high_ger_heer";
                	private _vectorUp = true;
	            	[_type, _pos, _vectorUp, _dir] call _fnc_spawnStatic;
                } else {
                	private _dir = (getDir _building) + 165;  
					private _zpos = AGLToASL (getPos _building);     
					private _xpos = _zpos getPos [4.9, _dir];   
					private _pos = ASLToATL ([_xpos select 0, _xpos select 1, _zpos select 2]);
					private _alreadySpawned = nearestObjects [_pos, ["fow_w_mg42_deployed_high_ger_heer"], 5];
					if (count _alreadySpawned > 0) exitWith {};
                	private _type = "fow_w_mg42_deployed_high_ger_heer";
                	private _vectorUp = true;
	            	[_type, _pos, _vectorUp, _dir] call _fnc_spawnStatic;
	            	
	            	_dir = (getDir _building) + 195;
	            	_zpos = AGLToASL (getPos _building);     
					_xpos = _zpos getPos [4.9, _dir];   
					_pos = ASLToATL ([_xpos select 0, _xpos select 1, _zpos select 2]);   
					_vectorUp = true;
					[_type, _pos, true, _dir] call _fnc_spawnStatic;
                };
            };
            case (_typeB == "fow_p_defenceposition_04"): {
                private _pos = _building modelToWorld ([-0.1, -0.9, 1.64]);  
                private _alreadySpawned = nearestObjects [_pos, NATOMG, 2];
				if (count _alreadySpawned > 0) exitWith {};
                private _type = if (_sideX == Occupants) then {selectRandom NATOMG} else {selectRandom CSATMG};
                private _dir = (getDir _building) + 180;
                private _vectorUp = false;
                [_type, _pos, _vectorUp, _dir] call _fnc_spawnStatic;
            };
            case (_typeB == "fow_p_defenceposition_05"): {   
				private _pos = _building modelToWorld ([-0.2, -1.8, 0]);    
                private _alreadySpawned = nearestObjects [_pos, ["fow_w_mg42_deployed_high_ger_heer"], 1];
				if (count _alreadySpawned > 0) exitWith {};
                private _type = "fow_w_mg42_deployed_high_ger_heer";
                private _dir = (getDir _building) + 180;
                private _vectorUp = false;
                [_type, _pos, _vectorUp, _dir] call _fnc_spawnStatic;
            };
            case (_typeB == "Land_PillboxBunker_01_big_F"): {
                private _pos = _building modelToWorld ([-0.76, 1.5, 3.75]); 
				private _alreadySpawned = nearestObjects [_pos, [staticAAOccupants select 1], 5];
				if (count _alreadySpawned > 0) exitWith {};
                private _type = staticAAOccupants select 1;
               	private _dir = getDir _building;
               	private _vectorUp = true;
	            [_type, _pos, _vectorUp, _dir] call _fnc_spawnStatic;
                sleep 0.5;			// why only here?
                _pos = _building modelToWorld ([-1.7, 2.8, 1.36]);
				private _Tdir = (_dir - 37);
				_type = "fow_w_mg42_deployed_high_ger_heer";
                [_type, _pos, _vectorUp, _Tdir] call _fnc_spawnStatic;
                sleep 0.5;
                _pos = _building modelToWorld ([0.65, 8.2, -0.88]);
                [_type, _pos, _vectorUp, _dir] call _fnc_spawnStatic;
            };
            case (_typeB == "Land_Rail_Platform_Start_F"): {
				private _pos = _building modelToWorld ([0, 2, 0.5]);     
                private _alreadySpawned = nearestObjects [_pos, [staticAAOccupants select 0], 5];
				if (count _alreadySpawned > 0) exitWith {};
                private _type = staticAAOccupants select 0;
                private _dir = getDir _building;
                private _vectorUp = true;
                [_type, _pos, _vectorUp, _dir] call _fnc_spawnStatic;
            };
            case (_typeB == "Land_I44_Buildings_Bunker_AA"): {
				private _pos = _building modelToWorld ([1.5,-2.4, 0.28]);     
                private _alreadySpawned = nearestObjects [_pos, [NATOMortar], 2];
				if (count _alreadySpawned > 0) exitWith {};
                private _type = NATOMortar;
                private _dir = (getDir _building) + 270;
                private _vectorUp = true;
                [_type, _pos, _vectorUp, _dir] call _fnc_spawnMortar;
                
   				_pos = _building modelToWorld ([-3.4,-1.55, 0.425]);     
                _alreadySpawned = nearestObjects [_pos, ["fow_w_mg42_deployed_high_ger_heer"], 2];
				if (count _alreadySpawned > 0) exitWith {};
                _type = "fow_w_mg42_deployed_high_ger_heer";
                _dir = (getDir _building) + 180;
                _vectorUp = true;
                [_type, _pos, _vectorUp, _dir] call _fnc_spawnStatic;
            };
            case (_typeB == "Land_WW2_BET_Flak_Bettung"): {
            	if (_markerX == "airport_3") exitWith {};
				private _pos = _building modelToWorld ([-1.01,0.8,-0.2]);    
                private _alreadySpawned = nearestObjects [_pos, ["LIB_FlaK_36"], 2];
				if (count _alreadySpawned > 0) exitWith {};
                private _type = "LIB_FlaK_36";
                private _dir = getDir _building;
                private _vectorUp = true;
                [_type, _pos, _vectorUp, _dir] call _fnc_spawnATStatic;
			};
            case (_typeB == "fow_p_defenceposition_02"): {
				private _pos = _building modelToWorld ([-0.5,0,-0.44]);
                private _alreadySpawned = nearestObjects [_pos, NATOMG, 2];
				if (count _alreadySpawned > 0) exitWith {};
                private _type = if (_sideX == Occupants) then {selectRandom NATOMG} else {selectRandom CSATMG};
                private _dir = (getDir _building) - 90;
                private _vectorUp = true;
                [_type, _pos, _vectorUp, _dir] call _fnc_spawnStatic;
			};
            case (_typeB == "Land_camonet01"): {
				private _pos = (_building getRelPos [0,270]);  
				private _alreadySpawned = nearestObjects [_pos, [staticATOccupants], 2];
				if (count _alreadySpawned > 0) exitWith {};
               	private _type = if (_sideX == Occupants) then {staticATOccupants} else {staticATInvaders};
                private _dir = (getDir _building) + 270;
                private _vectorUp = false;
                [_type, _pos, _vectorUp, _dir] call _fnc_spawnATStatic;
            };
            case (_typeB == "Land_ShellCrater_02_large_F"): {
				private _pos = _building modelToWorld ([-0.3, -0.3, 1.6]); 
                private _alreadySpawned = nearestObjects [_pos, [NATOMortar], 2];
				if (count _alreadySpawned > 0) exitWith {};
                private _type = NATOMortar;
                private _dir = (getDir _building) + 270;
                private _vectorUp = false;
                [_type, _pos, _vectorUp, _dir] call _fnc_spawnMortar;
            };
            
            //Vehicles
            case (_typeB == "Land_Setka_Car"): {
	            if (random 100 < (50 + (_aggression * 10))) then {
					private _pos = _building modelToWorld ([0.1, 0, -2.32]);
					private _alreadySpawned = nearestObjects [_pos, ["LIB_PzKpfwVI_E_tarn51d"], 5];
					if (count _alreadySpawned > 0) exitWith {};
					private _dir = getDir _building + 90;				
					private _type = "LIB_PzKpfwVI_E_tarn51d";
					private _mobile = true;
					[_type, _pos, _mobile, _dir] call _fnc_spawnVehicle;
    			};
		    };
            case (_typeB == "Land_WW2_CamoNet_Tank"): {
            	if  (random 100 < (25 + (_aggression * 15))) then {
					private _pos = _building modelToWorld ([0.1, 0, -1.76]);
					private _alreadySpawned = nearestObjects [_pos, vehFIATanks, 5];	
					if (count _alreadySpawned > 0) exitWith {};
					private _dir = getDir _building + 180;				
					private _type = selectRandom vehFIATanks;
					private _mobile = true;
					[_type, _pos, _mobile, _dir] call _fnc_spawnVehicle;
				};
            };
            case (_typeB == "Land_TimberPile_02_F"): {
				private _pos = _building modelToWorld ([-5, 0, -0.5]);
				private _alreadySpawned = nearestObjects [_pos, vehFIATanks, 5];
				if (count _alreadySpawned > 0) exitWith {};
				private _dir = getDir _building + 90;				
				private _type = selectRandom vehFIATanks;
				private _mobile = false;
				[_type, _pos, _mobile, _dir] call _fnc_spawnVehicle;
            };
            case (_typeB == "Land_WW2_TrenchTank"): {
				private _pos = _building getRelPos [1,180];
				private _alreadySpawned = nearestObjects [_pos, ["LIB_StuG_III_G"], 5];
				if (count _alreadySpawned > 0) exitWith {};
				private _dir = getDir _building;				
				private _type = "LIB_StuG_III_G";
				private _mobile = false;
				[_type, _pos, _mobile, _dir] call _fnc_spawnVehicle;
            };
            case (_typeB == "HeliHEmpty"): {
				private _pos = getPos _building;
				private _alreadySpawned = nearestObjects [_pos, (vehNATOLightArmed + vehNATOAA), 5];
				if (count _alreadySpawned > 0) exitWith {};
				private _dir = getDir _building;
				private _type = if (_markerX in citiesX) then {selectRandom vehNATOLightArmed} else {selectRandom vehNATOAA};
				private _mobile = true;
				[_type, _pos, _mobile, _dir] call _fnc_spawnVehicle;
            };
            case (_typeB == "Land_HelipadEmpty_F"): {
				if (_markerX in citiesX) then {
					private _pos = getPos _building;
					private _alreadySpawned = nearestObjects [_pos, (vehNATOTanks + vehNATOAA + ["fow_v_sdkfz_222_camo_ger_heer", "fow_v_sdkfz_250_camo_ger_heer", "fow_v_sdkfz_234_1"]), 5];
					if (count _alreadySpawned > 0) exitWith {};
					private _dir = getDir _building;
					private _vehTank = selectRandom vehNATOTanks;
					private _vehAPC = selectRandom ["fow_v_sdkfz_222_camo_ger_heer", "fow_v_sdkfz_250_camo_ger_heer", "fow_v_sdkfz_234_1"];
					private _vehAA = selectRandom vehNATOAA;
					private _type = if (_frontierX) then {[_vehTank, _vehAPC, _vehAA] selectRandomWeighted [0.4, 0.2, 0.4]} else {selectRandom [_vehTank, _vehAPC, _vehAA]};
					private _mobile = true;
					[_type, _pos, _mobile, _dir] call _fnc_spawnVehicle;
				} else {
					if (random 100 < (25 + (_aggression * 10))) then {
						private _pos = getPos _building;
						private _alreadySpawned = nearestObjects [_pos, vehNATOPlanes, 5];
						if (count _alreadySpawned > 0) exitWith {};
						private _dir = getDir _building;
						private _type = selectRandom vehNATOPlanes;
						private _veh = createVehicle [_type, _positionX, [], 0, "CAN_COLLIDE"];
						_veh setDir _dir;
    					_veh setPos _pos;
    					_vehiclesX pushBack _veh;
					};
				};
            };
            case (_typeB == "Land_smallhangaropen"): {
					private _pos = getPos _building;
					private _alreadySpawned = nearestObjects [_pos, vehNATOPlanesAA, 5];
					if (count _alreadySpawned > 0) exitWith {};
					private _dir = getDir _building;
					private _type = selectRandom vehNATOPlanesAA;
					private _veh = createVehicle [_type, _positionX, [], 0, "CAN_COLLIDE"];
					_veh setDir _dir;
    				_veh setPos _pos;
    				_vehiclesX pushBack _veh;
            };
        };
    };
};

//Spawning Marksmen/MG on fixed buildingPos of chosen buildings
for "_i" from 0 to (count _buildings) - 1 do
{
    if (spawner getVariable _markerX == 2) exitWith {};
    private _building = _buildings select _i;
    private _typeB = typeOf _building;

    call {
        if (isObjectHidden _building) exitWith {};            // don't put statics on destroyed buildings
        if ((_markerX in CitiesX) && ((markersX - (controlsX + citiesX)) findIf {(_building inArea _x)} != -1)) exitWith {};

        switch (true) do {
            //Church towers
            case (_typeB in ["Land_Church_04_white_red_F","Land_Church_04_white_F","Land_Church_04_yellow_F"]): {
                switch (true) do {
                	case (_markerX == "Kavala"): {
                		private _pos = _building buildingPos 4;
                		private _pool = NATOMGMan;
                		private _type = _pool call SCRT_fnc_unit_selectInfantryTier;
                		private _dir = (getDir _building) + 90;
                		private _kneel = true;
                		[_type, _pos, _kneel, _dir] call _fnc_spawnStaticUnit;

						_pos = _building buildingPos 7;
                		_pool = NATOMGMan;
                		_type = _pool call SCRT_fnc_unit_selectInfantryTier;
                		_dir = (getDir _building) - 90;
                		_kneel = true;
                		[_type, _pos, _kneel, _dir] call _fnc_spawnStaticUnit;

            			_pos = _building buildingPos 9;
                		_pool = NATOSniper;
                		_type = _pool call SCRT_fnc_unit_selectInfantryTier;
                		_dir = (getDir _building) + 180;
                		_kneel = true;
                		[_type, _pos, _kneel, _dir] call _fnc_spawnStaticUnit;
            		};
					case (_markerX == "Charkia"): {
                		private _pos = _building buildingPos 3;
                		private _pool = NATOSniper;
                		private _type = _pool call SCRT_fnc_unit_selectInfantryTier;
                		private _dir = (getDir _building) + 90;
                		private _kneel = true;
                		[_type, _pos, _kneel, _dir] call _fnc_spawnStaticUnit;

            		    _pos = _building buildingPos 9;
                		_pool = NATOMGMan;
                		_type = _pool call SCRT_fnc_unit_selectInfantryTier;
                		_dir = (getDir _building) + 180;
                		_kneel = true;
                		[_type, _pos, _kneel, _dir] call _fnc_spawnStaticUnit;
            		};
					case (_markerX == "Sofia"): {
                		private _pos = _building buildingPos 2;
                		private _pool = NATOSniper;
                		private _type = _pool call SCRT_fnc_unit_selectInfantryTier;
                		private _dir = (getDir _building) + 180;
                		private _kneel = true;
                		[_type, _pos, _kneel, _dir] call _fnc_spawnStaticUnit;

            		    _pos = _building buildingPos 4;
                		_pool = NATOMGMan;
                		_type = _pool call SCRT_fnc_unit_selectInfantryTier;
                		_dir = (getDir _building) + 90;
                		_kneel = true;
                		[_type, _pos, _kneel, _dir] call _fnc_spawnStaticUnit;
            		};
            		case (_markerX == "Panochori"): {
                		private _pos = _building buildingPos 2;
                		private _pool = NATOMGMan;
                		private _type = _pool call SCRT_fnc_unit_selectInfantryTier;
                		private _dir = (getDir _building) + 180;
                		private _kneel = true;
                		[_type, _pos, _kneel, _dir] call _fnc_spawnStaticUnit;

            		    _pos = _building buildingPos 4;
                		_pool = NATOSniper;
                		_type = _pool call SCRT_fnc_unit_selectInfantryTier;
                		_dir = (getDir _building) + 90;
                		_kneel = true;
                		[_type, _pos, _kneel, _dir] call _fnc_spawnStaticUnit;
            		};
            		case (_markerX == "Athira"): {
                		private _pos = _building buildingPos 5;
                		private _pool = NATOSniper;
                		private _type = _pool call SCRT_fnc_unit_selectInfantryTier;
                		private _dir = getDir _building;
                		private _kneel = true;
                		[_type, _pos, _kneel, _dir] call _fnc_spawnStaticUnit;

            		    _pos = _building buildingPos 9;
                		_pool = NATOMGMan;
                		_type = _pool call SCRT_fnc_unit_selectInfantryTier;
                		_dir = (getDir _building) + 180;
                		_kneel = true;
                		[_type, _pos, _kneel, _dir] call _fnc_spawnStaticUnit;
            		};
            		case (_markerX in ["Telos", "Zaros"]): {
                		private _pos = _building buildingPos 5;
                		private _pool = NATOMGMan;
                		private _type = _pool call SCRT_fnc_unit_selectInfantryTier;
                		private _dir = getDir _building;
                		private _kneel = true;
                		[_type, _pos, _kneel, _dir] call _fnc_spawnStaticUnit;

            		    _pos = _building buildingPos 9;
                		_pool = NATOSniper;
                		_type = _pool call SCRT_fnc_unit_selectInfantryTier;
                		_dir = (getDir _building) + 180;
                		_kneel = true;
                		[_type, _pos, _kneel, _dir] call _fnc_spawnStaticUnit;
            		};
            		case (_markerX == "Pyrgos"): {
                		private _pos = _building buildingPos 3;
                		private _pool = NATOSniper;
                		private _type = _pool call SCRT_fnc_unit_selectInfantryTier;
                		private _dir = (getDir _building) + 90;
                		private _kneel = true;
                		[_type, _pos, _kneel, _dir] call _fnc_spawnStaticUnit;

            		    _pos = _building buildingPos 4;
                		_pool = NATOMGMan;
                		_type = _pool call SCRT_fnc_unit_selectInfantryTier;
                		_dir = (getDir _building) + 90;
                		_kneel = true;
                		[_type, _pos, _kneel, _dir] call _fnc_spawnStaticUnit;
            		
            			_pos = _building buildingPos 7;
                		_pool = NATOMGMan;
                		_type = _pool call SCRT_fnc_unit_selectInfantryTier;
                		_dir = (getDir _building) - 90;
                		_kneel = true;
                		[_type, _pos, _kneel, _dir] call _fnc_spawnStaticUnit;
            		};
            		case (_markerX == "AgiosDionysios"): {
                		private _pos = _building buildingPos 2;
                		private _pool = NATOMGMan;
                		private _type = _pool call SCRT_fnc_unit_selectInfantryTier;
                		private _dir = (getDir _building) + 180;
                		private _kneel = true;
                		[_type, _pos, _kneel, _dir] call _fnc_spawnStaticUnit;

            		    _pos = _building buildingPos 5;
                		_pool = NATOMGMan;
                		_type = _pool call SCRT_fnc_unit_selectInfantryTier;
                		_dir = getDir _building;
                		_kneel = true;
                		[_type, _pos, _kneel, _dir] call _fnc_spawnStaticUnit;
                		
                		_pos = _building buildingPos 9;
                		_pool = NATOSniper;
                		_type = _pool call SCRT_fnc_unit_selectInfantryTier;
                		_dir = (getDir _building) + 180;
                		_kneel = true;
                		[_type, _pos, _kneel, _dir] call _fnc_spawnStaticUnit;
            		};
            		case (_markerX == "Neochori"): {
                		private _pos = _building buildingPos 3;
                		private _pool = NATOSniper;
                		private _type = _pool call SCRT_fnc_unit_selectInfantryTier;
                		private _dir = (getDir _building) + 90;
                		private _kneel = true;
                		[_type, _pos, _kneel, _dir] call _fnc_spawnStaticUnit;

            		    _pos = _building buildingPos 4;
                		_pool = NATOMGMan;
                		_type = _pool call SCRT_fnc_unit_selectInfantryTier;
                		_dir = (getDir _building) + 90;
                		_kneel = true;
                		[_type, _pos, _kneel, _dir] call _fnc_spawnStaticUnit;
            		};
            		case (_markerX == "Paros"): {
                		private _pos = _building buildingPos 3;
                		private _pool = NATOMGMan;
                		private _type = _pool call SCRT_fnc_unit_selectInfantryTier;
                		private _dir = (getDir _building) + 90;
                		private _kneel = true;
                		[_type, _pos, _kneel, _dir] call _fnc_spawnStaticUnit;

            		    _pos = _building buildingPos 9;
                		_pool = NATOSniper;
                		_type = _pool call SCRT_fnc_unit_selectInfantryTier;
                		_dir = (getDir _building) + 180;
                		_kneel = true;
                		[_type, _pos, _kneel, _dir] call _fnc_spawnStaticUnit;
            		};
            	};
            };
            case (_typeB == "Land_Castle_01_tower_F"): {
                switch (true) do {
                	case (_markerX == "outpost_29"): {
                		private _pos = _building buildingPos 2;
                		private _pool = NATOSniper;
                		private _type = _pool call SCRT_fnc_unit_selectInfantryTier;
                		private _dir = (getDir _building) + 180;
                		private _kneel = false;
                		[_type, _pos, _kneel, _dir] call _fnc_spawnStaticUnit;
            		};
                   	case (_markerX in ["outpost_7", "Pyrgos"]): {
                		private _pos = _building buildingPos 3;
                		private _pool = NATOSniper;
                		private _type = _pool call SCRT_fnc_unit_selectInfantryTier;
                		private _dir = (getDir _building) - 90;
                		private _kneel = true;
                		[_type, _pos, _kneel, _dir] call _fnc_spawnStaticUnit;
            		};
        		};
        	};
        };
    };
};

//Spawning Riflemen on fixed buildingPos of chosen buildings
for "_i" from 0 to (count _buildings) - 1 do
{
    if (spawner getVariable _markerX == 2) exitWith {};
    private _building = _buildings select _i;
    private _typeB = typeOf _building;

    call {
        if (isObjectHidden _building) exitWith {};            // don't put statics on destroyed buildings
		if ((_markerX in CitiesX) && ((markersX - (controlsX + citiesX)) findIf {(_building inArea _x)} != -1)) exitWith {};
        switch (true) do {
            case (_typeB == "Land_Hlaska"): {
            	if (random 100 > (_aggression * 20)) then {
	                private _pos = selectRandom [_building buildingPos 2, _building buildingPos 5];
	                private _alreadySpawned = nearestObjects [_pos, ["man"], 2];
					if (count _alreadySpawned > 0) exitWith {};
	                private _pool = if (_sideX == Occupants) then {NATOGrunt} else {CSATGrunt};
	                private _type = _pool call SCRT_fnc_unit_selectInfantryTier;
	                private _dir = getDir _building;
	                private _kneel = false;
	                [_type, _pos, _kneel, _dir] call _fnc_spawnStaticUnit;
                } else {
                	private _pos = _building buildingPos 2;
                	private _alreadySpawned = nearestObjects [_pos, ["man"], 2];
					if (count _alreadySpawned > 0) exitWith {};
	                private _pool = if (_sideX == Occupants) then {NATOGrunt} else {CSATGrunt};
	                private _type = _pool call SCRT_fnc_unit_selectInfantryTier;
	                private _dir = getDir _building;
	                private _kneel = false;
	                [_type, _pos, _kneel, _dir] call _fnc_spawnStaticUnit;
	                _pos = _building buildingPos 5;
	                _pool = if (_sideX == Occupants) then {NATOMGMan} else {CSATGrunt};
	                _type = _pool call SCRT_fnc_unit_selectInfantryTier;
	                _dir = getDir _building;
	                _kneel = false;
	                [_type, _pos, _kneel, _dir] call _fnc_spawnStaticUnit;
                };
            };
            case (_typeB in ["land_wx_guardtower_01","land_wx_guardtower_02"]): {
                private _pos = _building buildingPos 1;
                private _alreadySpawned = nearestObjects [_pos, ["man"], 5];
				if (count _alreadySpawned > 0) exitWith {};
				private _pool = if (_sideX == Occupants) then {NATOGrunt} else {CSATGrunt};
                private _type = _pool call SCRT_fnc_unit_selectInfantryTier;
                private _dir = getDir _building;
                private _kneel = false;
                [_type, _pos, _kneel, _dir] call _fnc_spawnStaticUnit;
            };
            case (_typeB in ["fow_p_defenceposition_03","fow_p_defenceposition_04"]): {
                private _pos = _building buildingPos (selectRandom [3,4,5,6,7]);
                private _alreadySpawned = nearestObjects [_pos, ["man"], 1];
				if (count _alreadySpawned > 0) exitWith {};
				private _pool = if (_sideX == Occupants) then {NATOGrunt} else {CSATGrunt};
                private _type = _pool call SCRT_fnc_unit_selectInfantryTier;
                private _dir = (getDir _building) + 180;
                private _kneel = false;
                [_type, _pos, _kneel, _dir] call _fnc_spawnStaticUnit;
                
                _pos = selectRandom [_building buildingPos 3, _building buildingPos 4, _building buildingPos 5, _building buildingPos 6, _building buildingPos 7];
                _alreadySpawned = nearestObjects [_pos, ["man"], 1];
				if (count _alreadySpawned > 0) exitWith {};
                _kneel = false;
                [_type, _pos, _kneel, _dir] call _fnc_spawnStaticUnit;
            };
            case (_typeB == "Land_WW2_Bunker_Mg"): {
            	private _multiplier = if (_frontierX) then {2} else {1};
            	if (((random 100) * _multiplier) > 67) then {
            		private _zpos = AGLToASL (getPos _building);
	                private _pos = _building modelToWorld ([-1.6, 1.4, 0]);
	                _pos = ASLToATL ([_pos select 0, _pos select 1, _zpos select 2]); 
    	            private _alreadySpawned = nearestObjects [_pos, ["man"], 1];
					if (count _alreadySpawned > 0) exitWith {};
    	            private _type = policeGrunt;
    	            private _dir = (getDir _building) + 90;
    	            private _kneel = true;
    	            [_type, _pos, _kneel, _dir] call _fnc_spawnStaticUnit;
    	        };
    	        if (((random 100) * _multiplier) > 50) then {
    	        	private _zpos = AGLToASL (getPos _building);
		            private _pos = _building modelToWorld ([2, 1.4, 0]);
		            _pos = ASLToATL ([_pos select 0, _pos select 1, _zpos select 2]);
    	            private _alreadySpawned = nearestObjects [_pos, ["man"], 1];
					if (count _alreadySpawned > 0) exitWith {};
					private _type = policeGrunt;
					private _dir = getDir _building;
					private _kneel = true;
    	            [_type, _pos, _kneel, _dir] call _fnc_spawnStaticUnit;
    	        };
    	        if (((random 100) * _multiplier) > 67) then {    
    	            private _zpos = AGLToASL (getPos _building);
    	            private _pos = _building modelToWorld ([2.2, -1.4, 0]);
    	            _pos = ASLToATL ([_pos select 0, _pos select 1, _zpos select 2]);
    	            private _alreadySpawned = nearestObjects [_pos, ["man"], 1];
					if (count _alreadySpawned > 0) exitWith {};
    	            private _type = policeGrunt;
					private _dir = (getDir _building) - 90;
					private _kneel = true;
    	            [_type, _pos, _kneel, _dir] call _fnc_spawnStaticUnit;
    	        };    
    	        if (((random 100) * _multiplier) > 50) then {   
    	            private _zpos = AGLToASL (getPos _building);
    	            private _pos = _building modelToWorld ([-1.9, -2.3, 0]);
    	            _pos = ASLToATL ([_pos select 0, _pos select 1, _zpos select 2]);
    	            private _alreadySpawned = nearestObjects [_pos, ["man"], 1];
					if (count _alreadySpawned > 0) exitWith {};
    	            private _type = policeGrunt;
					private _dir = (getDir _building) + 90;
					private _kneel = true;
    	            [_type, _pos, _kneel, _dir] call _fnc_spawnStaticUnit;
    	        };
			};
        };
    };
};

_groups pushback _groupX;
[_groups,_vehiclesX,_soldiers]