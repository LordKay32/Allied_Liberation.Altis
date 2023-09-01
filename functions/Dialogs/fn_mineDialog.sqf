params ["_typeX", "_position"];
private ["_moneyCost","_hrCost","_quantity","_mine"];

if (_typeX == "delete") exitWith {
		[[],"A3A_fnc_mineSweep"] remoteExec ["A3A_fnc_scheduler",2];
};

_moneyCost = minefieldCost select 0;
_hrCost = minefieldCost select 1;
_quantity = minefieldCost select 2;
_mine = minefieldCost select 3;

[-_hrCost,-_moneyCost,USExp] remoteExec ["A3A_fnc_resourcesFIA",2];

private _quantityMax = 40;
if (_typeX == "ATMine") then {
	_quantityMax = 25;
};

if (_quantity > _quantityMax) then {
	_quantity = _quantityMax;
};

[[_typeX,_position,_quantity,_mine],"A3A_fnc_buildMinefield"] remoteExec ["A3A_fnc_scheduler",2];
