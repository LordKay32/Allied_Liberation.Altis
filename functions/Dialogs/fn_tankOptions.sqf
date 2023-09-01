private ["_display","_childControl","_costs","_costHR","_unitsX","_formatX"];
if (!([player] call A3A_fnc_hasRadio)) exitWith {["Squad Options", "You need a radio in your inventory to be able to give orders to other squads"] call A3A_fnc_customHint;};
createDialog "tankOptions";

sleep 1;
disableSerialization;

_display = findDisplay 100;

if (str (_display) != "no display") then
{
	_ChildControl = _display displayCtrl 104;
	_costs = 0;
	_costHR = 0;
	{_costs = _costs + (server getVariable _x); _costHR = _costHR +1} forEach tankUScrew;
	_costs = _costs + ([vehSDKTankUSM4] call A3A_fnc_vehiclePrice);
	_ChildControl  ctrlSetTooltip format ["Cost: %1%3. HR: %2", _costs, _costHR, currencySymbol];

	_ChildControl = _display displayCtrl 105;
	_costs = 0;
	_costHR = 0;
	{_costs = _costs + (server getVariable _x); _costHR = _costHR +1} forEach tankM5crew;
	_costs = _costs + ([vehSDKTankUSM5] call A3A_fnc_vehiclePrice);
	_ChildControl  ctrlSetTooltip format ["Cost: %1%3. HR: %2", _costs, _costHR, currencySymbol];

	_ChildControl = _display displayCtrl 106;
	_costs = 0;
	_costHR = 0;
	{_costs = _costs + (server getVariable _x); _costHR = _costHR +1} forEach tankUKcrew;
	_costs = _costs + ([vehSDKTankUKM4] call A3A_fnc_vehiclePrice);
	_ChildControl  ctrlSetTooltip format ["Cost: %1%3. HR: %2", _costs, _costHR, currencySymbol];

	_ChildControl = _display displayCtrl 107;
	_costs = 0;
	_costHR = 0;
	{_costs = _costs + (server getVariable _x); _costHR = _costHR +1} forEach tankUKcrew;
	_costs = _costs + ([vehSDKTankChur] call A3A_fnc_vehiclePrice);
	_ChildControl  ctrlSetTooltip format ["Cost: %1%3. HR: %2", _costs, _costHR, currencySymbol];
};
