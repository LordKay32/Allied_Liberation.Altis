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
if (_typeX in vehFIA) then {
	_veh addaction [ 
        "Repair at Repair Truck", 
        {
    	params ["_target", "_caller", "_actionId", "_arguments"];
   		_damage = damage _target;
    	// if (isPlayer crew) then {play sound for player?};
		while {_damage > 0} do {
	    	_damage = _damage - 0.1;
	    	if (_damage < 0) then {_damage = 0};
    		[_target, _damage] remoteExec ["setDamage"];
    		sleep 1;
    	};}, 
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
    		[_x, _fuel] remoteExec ["setFuel"];
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
   		_damage = damage _target;
    	// if (isPlayer crew) then {play sound for player?};
		while {_damage > 0} do {
	    	_damage = _damage - 0.1;
	    	if (_damage < 0) then {_damage = 0};
    		[_target, _damage] remoteExec ["setDamage"];
    		sleep 1;
    	};}, 
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
    		[_x, _fuel] remoteExec ["setFuel"];
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
        _list = ((getPos _target) nearEntities [vehFIA, 50]) select {count allTurrets [_x, false] > 0};
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
        _list = ((getPos _target) nearEntities [["Car", "Tank", "APC"], 50]) select {(((side _x == teamPlayer) || (side _x == civilian)) && (typeOf _x in vehFIA))};
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
    	_list = ((getPos _target) nearEntities [vehFIA, 50]) select {(side _x == teamPlayer) || (side _x == civilian)};
    	{
   		_damage = damage _x;
    	// if (isPlayer crew) then {play sound for player?};
		while {_damage > 0} do {
	    	_damage = _damage - 0.1;
	    	if (_damage < 0) then {_damage = 0};
    		[_x, _damage] remoteExec ["setDamage"];
    		sleep 1;
    	};
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

if (_typeX == vehNATOFuelTruck) then {
	_veh setFuelCargo 0;
	_veh addaction [ 
        "Refuel nearby Wehrmacht vehicles", 
        {params ["_target", "_caller", "_actionId", "_arguments"];
        _list = ((getPos _target) nearEntities [["Car", "Tank", "APC"], 50]) select {(((side _x == teamPlayer) || (side _x == civilian)) && (typeOf _x in [vehNATONormal + vehNATOAir + vehNATOAttack + vehNATOAA + NATOMG + staticAAOccupants + [NATOMortar,NATOHowitzer,staticATOccupants,"LIB_FlaK_36","LIB_FlaK_36_AA"]]))};
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
    	_list = ((getPos _target) nearEntities [(vehNATONormal + vehNATOAir + vehNATOAttack + vehNATOAA + NATOMG + staticAAOccupants + [NATOMortar,NATOHowitzer,staticATOccupants,"LIB_FlaK_36","LIB_FlaK_36_AA"]), 50]) select {(side _x == teamPlayer) || (side _x == civilian)};
    	{
   		_damage = damage _x;
    	// if (isPlayer crew) then {play sound for player?};
		while {_damage > 0} do {
	    	_damage = _damage - 0.1;
	    	if (_damage < 0) then {_damage = 0};
    		[_x, _damage] remoteExec ["setDamage"];
    		sleep 1;
    	};
    	} forEach _list}, 
        [], 
        6, 
        true, 
        true, 
        "", 
        "alive _target && {_target distance _this < 5}" 
    ];
};

