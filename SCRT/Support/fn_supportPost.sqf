params ["_mrk", "_truckAmmo", "_truckRepair", "_truckFuel", "_truckAmbo", "_jeepWillys"];
private ["_vehsFIA", "_oldVehsFIA", "_newVehsFIA"];

_vehsFIA = [];
_oldVehsFIA = [];
private _start = true;
private _actionID = 0;

_truckAmmoGone = false;
_truckRepairGone =  false;
_truckFuelGone = false;

while {(_mrk in supportpostsFIA)} do {

	sleep 10;

	if (_truckAmmo distance (getMarkerPos _mrk) > 25) then {_truckAmmoGone = true};
	if (_truckRepair distance (getMarkerPos _mrk) > 25) then {_truckRepairGone = true};
	if (_truckFuel distance (getMarkerPos _mrk) > 25) then {_truckFuelGone = true};

	if (_start) then {_start = false} else {
	
		_oldVehsFIA = vehicles select { _x in _vehsFIA } inAreaArray [getMarkerPos _mrk, 15, 15];
		_vehsFIARemove = _vehsFIA - _oldVehsFIA;
	
		{
			_x removeAction _actionID;
		} forEach _vehsFIARemove;
	};
		
	_vehsFIA = vehicles select { (typeOf _x) in vehFIA } inAreaArray [getMarkerPos _mrk, 15, 15];
	_newVehsFIA = _vehsFIA - _oldVehsFIA;
		
	{
		_actionID = _x addAction [
			"Service Vehicle",	// title
			{
				params ["_target", "_caller", "_actionId", "_truckAmmo", "_truckRepair", "_truckFuel", "_truckAmmoGone", "_truckRepairGone", "_truckFuelGone"]; // script
				
				if ([_target,200] call A3A_fnc_enemyNearCheck) exitWith {["Service Vehicle", "This vehicle cannot be serviced with enemies nearby."] call A3A_fnc_customHint;};
				if (((_this select 6) == true) || ((_this select 7) == true) || ((_this select 8) == true)) exitWith {["Service Vehicle", "One or more of the support vehicles has left the support post."] call A3A_fnc_customHint;}; 
				if (!alive (_this select 3) || !alive (_this select 4) || !alive (_this select 5)) exitWith {["Service Vehicle", "One or more of the support vehicles has been destroyed."] call A3A_fnc_customHint;}; 
				
				[_target, true] remoteExec ["lock", 0];
				sleep 30;
				[_target, 1] remoteExec ["setFuel", 0];
				[_target, 0] remoteExec ["setDamage", 0];
				[_target, 1] remoteExec ["setVehicleAmmoDef", 0];
				
			},
			nil,		// arguments
			1000,		// priority
			true,		// showWindow
			true,		// hideOnUse
			"",			// shortcut
			"alive _target", 	// condition
			5,			// radius
			false,		// unconscious
			"",			// selection
			""			// memoryPoint
		];
	} forEach _newVehsFIA;	
};