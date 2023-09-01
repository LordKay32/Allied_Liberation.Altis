#include "\A3\Ui_f\hpp\defineResinclDesign.inc"

disableSerialization;

private _display = findDisplay 60000;

if (str (_display) == "no display") exitWith {};

private _costTextBox = _display displayCtrl 2761;
private _comboBox = _display displayCtrl 2758;
private _index = lbCurSel _comboBox;
private _minefieldType =  lbData [2758, _index];

minefieldType = _minefieldType;
private _costs = 0;
private _hr = 0;

private _pool = jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_CARGOPUT;
private _quantity = 0;
private _minePool = APERSMineMags;
private _mine = "";

if (_minefieldType == "ATMine") then {
	_minePool = ATMineMags;
};

private _availableMinesPool = _pool select { 
	private _className = _x select 0;
	private _quantity = _x select 1;
	_className in _minePool && {_quantity >= 5};
};



if (count _availableMinesPool < 1) then {
	_quantity = 0;
} else {
	_mine = selectRandom (_availableMinesPool apply {_x select 0});
	private _mineQuantity = (_availableMinesPool select {(_x select 0) == _mine }) apply {_x select 1}; //quantity
	_quantity = floor ((_mineQuantity select 0)/2);
	if (_quantity > 25) then {_quantity = 25};
	if (_quantity < 5) then {_quantity = 5};
};

_costs = (2*(server getVariable USExp)) + ([vehSDKLightUnarmed] call A3A_fnc_vehiclePrice);
_hr = 2;
_costTextBox ctrlSetText format ["Cost: %1 mines, %2 HR and %3%4", _quantity, _hr, _costs, currencySymbol];

minefieldCost = [_costs, _hr, _quantity, _mine];
