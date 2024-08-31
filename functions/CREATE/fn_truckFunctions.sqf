/*
 * Name:	fn_truckFunctions
 * Date:	17/02/2024
 * Version: 1.0
 * Author:  JB
 *
 * Description:
 * %DESCRIPTION%
 *
 * Parameter(s):
 * _PARAM1 (TYPE): DESCRIPTION.
 * _PARAM2 (TYPE): DESCRIPTION.
 *
 * Returns:
 * %RETURNS%
 */

params ["_veh"];
private _typeX = typeOf _veh;

//Allied services truck functions
if (_typeX in (vehFIA + ["LIB_FlaK_38"])) then {
	_veh addaction [ 
        "Repair at Repair Truck", 
        {
    	params ["_target", "_caller", "_actionId", "_arguments"];
	    	// if (isPlayer crew) then {play sound for player?};
    		[_target, 0] remoteExec ["setDamage"];
		}, 
        [], 
        6, 
        false, 
        true, 
        "", 
        "(damage _target > 0) && (vehicle _this == _target) && (count (_target nearEntities [vehSDKRepair, 25]) > 0);" 
    ];

	_veh addaction [ 
        "Refuel at Refuel Truck", 
        {
    	params ["_target", "_caller", "_actionId", "_arguments"];
   		_fuel = fuel _target;
    	// if (isPlayer crew) then {play sound for player?};
		while {_fuel < 1} do {
	    	_fuel = _fuel + 0.1;
	    	if (_fuel > 1) then {_fuel = 1};
    		[_target, _fuel] remoteExec ["setFuel"];
    		sleep 1;
    	};}, 
        [], 
        6, 
        false, 
        true, 
        "", 
        "(fuel _target < 1) && (vehicle _this == _target) && (count (_target nearEntities [vehSDKFuel, 25]) > 0);" 
    ];
    
    _veh addaction [ 
        "Rearm at Ammo Truck", 
        {
    	params ["_target", "_caller", "_actionId", "_arguments"];
   		[_target, 1] remoteExec ["setVehicleAmmoDef"];
    	// if (isPlayer crew) then {play sound for player?};
		}, 
        [], 
        6, 
        false, 
        true, 
        "", 
        "(count allTurrets [_target, false] > 0) && (vehicle _this == _target) && (count (_target nearEntities [vehSDKAmmo, 25]) > 0);" 
    ];
};

//German services trucks functions
if (_typeX in (vehNATONormal + vehNATOAir + vehNATOAttack + vehNATOAA + NATOMG + staticAAOccupants + [NATOMortar,NATOHowitzer,staticATOccupants,"LIB_FlaK_36","LIB_FlaK_36_AA"])) then {
	_veh addaction [ 
        "Repair at Repair Truck", 
        {
    	params ["_target", "_caller", "_actionId", "_arguments"];
    	// if (isPlayer crew) then {play sound for player?};
    		[_target, 0] remoteExec ["setDamage"];
		}, 
        [], 
        6, 
        false, 
        true, 
        "", 
        "(damage _target > 0) && (vehicle _this == _target) && (count (_target nearEntities [vehNATORepairTruck, 25]) > 0);" 
    ];
    
    _veh addaction [ 
        "Refuel at Refuel Truck", 
        {
    	params ["_target", "_caller", "_actionId", "_arguments"];
   		_fuel = fuel _target;
    	// if (isPlayer crew) then {play sound for player?};
		while {_fuel < 1} do {
	    	_fuel = _fuel + 0.1;
	    	if (_fuel > 1) then {_fuel = 1};
    		[_target, _fuel] remoteExec ["setFuel"];
    		sleep 1;
    	};}, 
        [], 
        6, 
        false, 
        true, 
        "", 
        "(fuel _target < 1) && (vehicle _this == _target) && (count (_target nearEntities [vehNATOFuelTruck, 25]) > 0);" 
    ];
    
    _veh addaction [ 
        "Rearm at Ammo Truck", 
        {
    	params ["_target", "_caller", "_actionId", "_arguments"];
   		[_target, 1] remoteExec ["setVehicleAmmoDef"];
    	// if (isPlayer crew) then {play sound for player?};
		}, 
        [], 
        6, 
        false, 
        true, 
        "", 
        "(count allTurrets [_target, false] > 0) && (vehicle _this == _target) && (count (_target nearEntities [vehNATOAmmoTruck, 25]) > 0);" 
    ];
};

//JB - add arsenal and statics to Ammo Trucks
if (_typeX == vehSDKAmmo) then {
	_veh setAmmoCargo 0;
	//add arsenal button
	_veh addaction [ 
        (format ["<img image='%1' size='1' color='#ffffff'/>", "\A3\ui_f\data\GUI\Rsc\RscDisplayArsenal\spaceArsenal_ca.paa"] + format["<t size='1'> %1</t>", (localize "STR_A3_Arsenal")]), 
        JN_fnc_arsenal_handleAction, 
        [], 
        6, 
        true, 
        false, 
        "", 
        "alive _target && {_target distance _this < 5} && {vehicle player == player}" 
    ];
	//[_veh] call HR_GRG_fnc_initGarage;
    _veh addAction ["Deploy Static", {if ([player,300] call A3A_fnc_enemyNearCheck) then {["Deploy Static", "You cannot deploy statics while there are enemies near you."] call A3A_fnc_customHint;} else {["AMMOTRUCK"] call SCRT_fnc_ui_createBuyVehicleMenu}},nil,0,false,true,"","(vehicle player == player) and (isPlayer _this) and (_this == _this getVariable ['owner',objNull])",4];
	_veh addaction [ 
        "Rearm nearby Allied vehicles", 
        {params ["_target", "_caller", "_actionId", "_arguments"];
        _list = ((getPos _target) nearEntities [(vehFIA + ["LIB_FlaK_38"]), 50]) select {count allTurrets [_x, false] > 0};
    	{
   		[_x, 1] remoteExec ["setVehicleAmmoDef"];
    	// if (isPlayer crew) then {play sound for player?};
    	} forEach _list;}, 
        [], 
        6, 
        true, 
        true, 
        "", 
        "alive _target && {_target distance _this < 5}" 
    ];
	
	_veh addEventHandler ["Killed", {
	params ["_unit", "_killer"];
	removeAllActions  _unit;
	}];
};

//JB add functions to refuel/repair trucks
if (_typeX == vehSDKFuel) then {
	_veh setFuelCargo 0;
	_veh addaction [ 
        "Refuel nearby Allied vehicles", 
        {params ["_target", "_caller", "_actionId", "_arguments"];
        _list = ((getPos _target) nearEntities [["Car", "Tank", "Air", "Ship"], 50]) select {(((side _x == teamPlayer) || (side _x == civilian)) && (typeOf _x in (vehFIA + ["LIB_FlaK_38"])))};
    	{
    	_fuel = fuel _x;
    	// if (isPlayer crew) then {play sound for player?};
		while {_fuel < 1} do {
	    	_fuel = _fuel + 0.1;
	    	if (_fuel > 1) then {_fuel = 1};
    		[_x, _fuel] remoteExec ["setFuel"];
    		sleep 1;
    	};
    	} forEach _list;}, 
        [], 
        6, 
        true, 
        true, 
        "", 
        "alive _target && {_target distance _this < 5}" 
    ];
};
if (_typeX == vehSDKRepair) then {
	_veh setRepairCargo 0;
	_veh addaction [ 
        "Repair nearby Allied vehicles", 
        {
    	params ["_target", "_caller", "_actionId", "_arguments"];
    	_list = ((getPos _target) nearEntities [(vehFIA + ["LIB_FlaK_38"]), 50]) select {(side _x == teamPlayer) || (side _x == civilian)};
    	{
    	// if (isPlayer crew) then {play sound for player?};
    		[_x, 0] remoteExec ["setDamage"];
    	} forEach _list}, 
        [], 
        6, 
        true, 
        true, 
        "", 
        "alive _target && {_target distance _this < 5}" 
    ];
};

//and German vehicles
if (_typeX == vehNATOAmmoTruck) then {
	_veh setAmmoCargo 0;
	_veh addaction [ 
        "Rearm nearby Wehrmacht vehicles", 
        {params ["_target", "_caller", "_actionId", "_arguments"];
        _list = ((getPos _target) nearEntities [(vehNATONormal + vehNATOAir + vehNATOAttack + vehNATOAA + NATOMG + staticAAOccupants + [NATOMortar,NATOHowitzer,staticATOccupants,"LIB_FlaK_36","LIB_FlaK_36_AA"]), 50]) select {count allTurrets [_x, false] > 0 && (side _x == teamPlayer) || (side _x == civilian)};
    	{
   		[_x, 1] remoteExec ["setVehicleAmmoDef"];
    	} forEach _list;
    	}, 
        [], 
        6, 
        true, 
        true, 
        "", 
        "alive _target && {_target distance _this < 5}" 
    ];
	
	_veh addEventHandler ["Killed", {
	params ["_unit", "_killer"];
	removeAllActions  _unit;
	}];
};

if (_typeX == vehNATOFuelTruck) then {
	_veh setFuelCargo 0;
	_veh addaction [ 
        "Refuel nearby Wehrmacht vehicles", 
        {params ["_target", "_caller", "_actionId", "_arguments"];
        _list = ((getPos _target) nearEntities ["Car", "Tank", "Air", "Ship", 50]) select {(((side _x == teamPlayer) || (side _x == civilian)) && (typeOf _x in [vehNATONormal + vehNATOAir + vehNATOAttack + vehNATOAA + NATOMG + staticAAOccupants + [NATOMortar,NATOHowitzer,staticATOccupants,"LIB_FlaK_36","LIB_FlaK_36_AA",civCar,civTruck,civBoat]]))};
    	{
    	_fuel = fuel _x;
    	// if (isPlayer crew) then {play sound for player?};
		while {_fuel < 1} do {
	    	_fuel = _fuel + 0.1;
	    	if (_fuel > 1) then {_fuel = 1};
    		[_x, _fuel] remoteExec ["setFuel"];
    		sleep 1;
    	};
    	} forEach _list;}, 
        [], 
        6, 
        true, 
        true, 
        "", 
        "alive _target && {_target distance _this < 5}" 
    ];
};
if (_typeX == vehNATORepairTruck) then {
	_veh setRepairCargo 0;
	_veh addaction [ 
        "Repair nearby Wehrmacht vehicles", 
        {
    	params ["_target", "_caller", "_actionId", "_arguments"];
    	_list = ((getPos _target) nearEntities [(vehNATONormal + vehNATOAir + vehNATOAttack + vehNATOAA + NATOMG + staticAAOccupants + [NATOMortar,NATOHowitzer,staticATOccupants,"LIB_FlaK_36","LIB_FlaK_36_AA",civCar,civTruck,civBoat]), 50]) select {(side _x == teamPlayer) || (side _x == civilian)};
    	{
    	// if (isPlayer crew) then {play sound for player?};
    		[_x, 0] remoteExec ["setDamage"];
    	} forEach _list}, 
        [], 
        6, 
        true, 
        true, 
        "", 
        "alive _target && {_target distance _this < 5}" 
    ];
};

if (_veh isKindOf "Car" || _veh isKindOf "Tank") then {
	[
	_veh,														// Object the action is attached to
	"Load vehicle into boat",													// Title of the action
	"\a3\data_f_destroyer\data\UI\IGUI\Cfg\holdactions\holdAction_loadVehicle_ca.paa",	// Idle icon shown on screen
	"\a3\data_f_destroyer\data\UI\IGUI\Cfg\holdactions\holdAction_loadVehicle_ca.paa",	// Progress icon shown on screen
	"(_this distance _target < 5) and (nearestObjects [_target, [vehSDKBoat], 50] findIf { _x canVehicleCargo _target select 0; } != -1)",									// Condition for the action to be shown
	"(_caller distance _target < 5) and (nearestObjects [_target, [vehSDKBoat], 50] findIf { _x canVehicleCargo _target select 0; } != -1)",									// Condition for the action to progress
	{},																// Code executed when action starts
	{},																// Code executed on every progress tick
	{
		params ["_target", "_caller", "_actionId", "_arguments"];
		_boats = nearestObjects [_target, [vehSDKBoat], 50];
		{
		_canLoad = _x canVehicleCargo _target;
		if (_canLoad select 0) exitWith {_x setVehicleCargo _target};
		} forEach _boats;
	},																// Code executed on completion
	{},																// Code executed on interrupted
	[],																// Arguments passed to the scripts as _this select 3
	6,																// Action duration in seconds
	0,																// Priority
	false,															// Remove on completion
	false															// Show in unconscious state
	] call BIS_fnc_holdActionAdd;	
};

if (_veh isKindOf "Ship") then {
	[
	_veh,														// Object the action is attached to
	"Load group into boat",													// Title of the action
	"\a3\data_f_destroyer\data\UI\IGUI\Cfg\holdactions\holdAction_loadVehicle_ca.paa",	// Idle icon shown on screen
	"\a3\data_f_destroyer\data\UI\IGUI\Cfg\holdactions\holdAction_loadVehicle_ca.paa",	// Progress icon shown on screen
	"(_this distance _target < 25) and (count units group _this < _target emptyPositions '') and (vehicle _this == _this)",									// Condition for the action to be shown
	"(_caller distance _target < 25) and (count units group _caller < _target emptyPositions '') and (vehicle _caller == _caller)",									// Condition for the action to progress
	{},																// Code executed when action starts
	{},																// Code executed on every progress tick
	{
		params ["_target", "_caller", "_actionId", "_arguments"];
		{
		_x moveInAny _target;
		sleep 0.5;
		} forEach units group _caller;
	},																// Code executed on completion
	{},																// Code executed on interrupted
	[],																// Arguments passed to the scripts as _this select 3
	6,																// Action duration in seconds
	0,																// Priority
	false,															// Remove on completion
	false															// Show in unconscious state
	] call BIS_fnc_holdActionAdd;	
};

if (_typeX == "IG_supplyCrate_F") then {
	//add arsenal button
	clearMagazineCargoGlobal _veh;
	clearWeaponCargoGlobal _veh;
	clearItemCargoGlobal _veh;
	clearBackpackCargoGlobal _veh;
	_veh addaction [ 
        (format ["<img image='%1' size='1' color='#ffffff'/>", "\A3\ui_f\data\GUI\Rsc\RscDisplayArsenal\spaceArsenal_ca.paa"] + format["<t size='1'> %1</t>", (localize "STR_A3_Arsenal")]), 
        JN_fnc_arsenal_handleAction, 
        [], 
        6, 
        true, 
        false, 
        "", 
        "alive _target && {_target distance _this < 5} && {vehicle player == player}" 
    ];

    //add vehicle/box filling button
    _veh addaction [
		(format ["<img image='%1' size='1' color='#ffffff'/>", "JeroenArsenal\Icons\JN_unloadVehicle.paa"] + format["<t size='1'> %1</t>", (localize "STR_JNA_ACT_CONTAINER_OPEN")]),
        {
			private _object = _this select 0;
			
			private _script =  {
				params ["_object"];
				
				//check if player is looking at some object
				private _objectSelected = cursorObject;
				if(isnull _objectSelected)exitWith{hint localize "STR_JNA_ACT_CONTAINER_SELECTERROR1"; };

				//check if object is in range
				if(_object distance cursorObject > 50) exitWith {hint localize "STR_JNA_ACT_CONTAINER_SELECTERROR2";};

				//check if object has inventory
				private _className = typeOf _objectSelected;
				private _tb = getNumber (configFile >> "CfgVehicles" >> _className >> "transportmaxbackpacks");
				private _tm = getNumber (configFile >> "CfgVehicles" >> _className >> "transportmaxmagazines");
				private _tw = getNumber (configFile >> "CfgVehicles" >> _className >> "transportmaxweapons");
				if !(_tb > 0  || _tm > 0 || _tw > 0) exitWith{hint localize "STR_JNA_ACT_CONTAINER_SELECTERROR3";};

				//set type and object to use later
				UINamespace setVariable ["jn_type", "containerArsenal"];
				UINamespace setVariable ["jn_object",_object];
				UINamespace setVariable ["jn_object_selected",_objectSelected];

                //start loading screen and timer to close it if something breaks
				["jn_fnc_arsenal", "Loading Nutz™ Arsenal"] call bis_fnc_startloadingscreen;
				[] spawn {
					uisleep 5;
					private _ids = missionnamespace getvariable ["BIS_fnc_startLoadingScreen_ids",[]];
					if("jn_fnc_arsenal" in _ids)then{
						private _display =  uiNamespace getVariable ["arsanalDisplay","No display"];
						titleText["ERROR DURING LOADING ARSENAL", "PLAIN"];
						_display closedisplay 2;
						["jn_fnc_arsenal"] call BIS_fnc_endLoadingScreen;
					};
				};

                //request server to open arsenal
                [clientOwner] remoteExecCall ["jn_fnc_arsenal_requestOpen",2];
			};
			private _conditionActive = {
				params ["_object"];
				alive player;
			};
			private _conditionColor = {
				params ["_object"];
				
				!isnull cursorObject
				&&{
					_object distance cursorObject < 10;
				}&&{
					//check if object has inventory
					private _className = typeOf cursorObject;
					private _tb = getNumber (configFile >> "CfgVehicles" >> _className >> "transportmaxbackpacks");
					private _tm = getNumber (configFile >> "CfgVehicles" >> _className >> "transportmaxmagazines");
					private _tw = getNumber (configFile >> "CfgVehicles" >> _className >> "transportmaxweapons");
					if (_tb > 0  || _tm > 0 || _tw > 0) then {true;} else {false;};
				
				}//return
			};

            ["Vehicle Arsenal", "Select vehicle to open arsenal for it allowing to fill it with it's cargo with any items from arsenal."] call A3A_fnc_customHint;
						
			[_script,_conditionActive,_conditionColor,_object] call jn_fnc_common_addActionSelect;
		},
        [],
        6,
        true,
        false,
        "",
        "alive _target && {_target distance _this < 5 && {vehicle player == player}}"
    ];
	_veh addAction ["Transfer Vehicle cargo to Arsenal", {[] spawn A3A_fnc_empty;}, 4];
	_veh addAction ["Move this asset", A3A_fnc_moveHQObject,nil,0,false,true,"","", 4];
};