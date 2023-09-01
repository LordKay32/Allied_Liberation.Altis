if (count hcSelected player != 1) exitWith {["Support Task", "You must select one support group only on the HC bar."] call A3A_fnc_customHint;};
if !((groupId (hcSelected player select 0) select [0,3]) == "Sup") exitWith {["Support Task", "Only support groups can perform this function."] call A3A_fnc_customHint;};

private ["_groupX","_veh","_owner","_list","_fuel","_injuredList","_incapacitatedPlayers","_incapacitatedPlayers","_medic"];

_groupX = hcSelected player select 0;
_veh = objNull;
_leader = leader _GroupX;
_veh = assignedVehicle _leader;

if ((typeOf _leader == USMil) || !(alive _leader) || (lifestate _leader == "INCAPACITATED")) exitWith {["Support Task", "This support team is incapacitated and cannot perform this task."] call A3A_fnc_customHint;};

if (isNull _veh) exitWith {["Support Task", "This support team has no vehicle."] call A3A_fnc_customHint;};

if !(_leader in _veh) exitWith {["Support Task", "This support team is busy."] call A3A_fnc_customHint;};

switch (typeOf _veh) do {

    case vehSDKRepair: {
    	_list = ((getPos _veh) nearEntities [["Car", "Turret", "Tank", "APC"], 50]) select {side _x != west};
    	{
    	[_x, 0] remoteExec ["setDamage"];
    	// if (isPlayer crew) then {play sound for player?};
    	} forEach _list;
    };
    
    case vehSDKAmmo: {
    	_list = ((getPos _veh) nearEntities [vehFIA, 50]) select {count allTurrets [_x, false] > 0};
    	{
    	[_x, 1] remoteExec ["setVehicleAmmoDef"];
    	// if (isPlayer crew) then {play sound for player?};
    	} forEach _list;
    };
    
    case vehSDKFuel: {
    	_list = ((getPos _veh) nearEntities [["Car", "Tank", "APC"], 50]) select {side _x != west};
    	{
    	_fuel = fuel _x;
    	// if (isPlayer crew) then {play sound for player?};
		while {_fuel < 0.99} do {
	    	_fuel = _fuel + 0.1;
	    	if (_fuel > 1) then {_fuel = 1};
    		[_x, _fuel] remoteExec ["setFuel"];
    		sleep 1;
    	};
    	} forEach _list;
    };
    
    case vehSDKMedical: {
    	_list = (entities [["Man"], [], true, true]) select {(_x distance _veh < 50) && (damage _x > 0)};
    	_incapacitatedList = _list select {(_x getVariable ["incapacitated",false])};
    	_injuredList = _list - _incapacitatedList;
    	_incapacitatedPlayers = _incapacitatedList select {isPlayer _x};
    	_medic = leader _groupX;
    	{
    	[_x, 0] remoteExec ["setDamage"];
    	} forEach _InjuredList;
    	if (count _incapacitatedList > 0) then {
    		{[_x] orderGetIn false; [_x] allowGetIn false} forEach units _groupX;
    		{
			_x enableAI "AUTOTARGET";
			_x enableAI "TARGET";
			_x setBehaviour "AWARE";
			} forEach units _groupX;
    		if (count _incapacitatedPlayers > 0) then {
    			{
    			_pos = getPos _x;
    			_medic doMove _pos;
    			waitUntil {sleep 1; (unitReady _medic && !(_medic getVariable ["helping",false]))};
    			if (!(alive _medic) || (_medic getVariable ["incapacitated",false])) exitWith {};
    			[_x, _medic] spawn A3A_fnc_actionRevive;
    			waitUntil {sleep 1; (unitReady _medic && !(_medic getVariable ["helping",false]))};
    			if (!(alive _medic) || (_medic getVariable ["incapacitated",false])) exitWith {};
    			} forEach _incapacitatedPlayers;
    			_incapacitatedList = _incapacitatedList - _incapacitatedPlayers;
    		};
    		if (count _incapacitatedList > 0) then {
    			{
    			_pos = getPos _x;
    			_medic doMove _pos;
    			waitUntil {sleep 1; (unitReady _medic && !(_medic getVariable ["helping",false]))};
    			if (!(alive _medic) || (_medic getVariable ["incapacitated",false])) exitWith {};
    			[_x, _medic] spawn A3A_fnc_actionRevive;
    			waitUntil {sleep 1; (unitReady _medic && !(_medic getVariable ["helping",false]))};
    			if (!(alive _medic) || (_medic getVariable ["incapacitated",false])) exitWith {};
    			} forEach _incapacitatedList;
    		};
    	{[_x] orderGetIn true; [_x] allowGetIn true} forEach units _groupX;
    	{
		_x disableAI "AUTOTARGET";
		_x disableAI "TARGET";
		_x setBehaviour "CARELESS";
		} forEach units _groupX;
    	};
    	waitUntil {sleep 1; unitReady _medic};
    	["Support Task", "The medical team has finished healing nearby units."] call A3A_fnc_customHint;
    };
};