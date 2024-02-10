params ["_typeX"];

private _costs = server getVariable _typeX;

if (isNil "_costs") then {
	diag_log format ["%1: [Antistasi] | ERROR | vehiclePrice.sqf | Invalid vehicle price :%2.",servertime,_typeX];
	_costs = 0;
};

_costs