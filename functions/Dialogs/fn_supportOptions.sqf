private ["_display","_childControl","_costs","_costHR","_unitsX","_formatX"];
if (!([player] call A3A_fnc_hasRadio)) exitWith {["Squad Options", "You need a radio in your inventory to be able to give orders to other squads"] call A3A_fnc_customHint;};
createDialog "supportOptions";

sleep 1;
disableSerialization;

_display = findDisplay 100;

if (str (_display) != "no display") then
{
	_ChildControl = _display displayCtrl 104;
	_costs = 0;
	_costHR = 0;
	{_costs = _costs + (server getVariable _x); _costHR = _costHR +1} forEach [USMil, USEng];
	_costs = _costs + ([vehSDKRepair] call A3A_fnc_vehiclePrice);
	_ChildControl  ctrlSetTooltip format ["Cost: %1%3. HR: %2", _costs, _costHR, currencySymbol];

	_ChildControl = _display displayCtrl 105;
	_costs = 0;
	_costHR = 0;
	{_costs = _costs + (server getVariable _x); _costHR = _costHR +1} forEach [USMil, USEng];
	_costs = _costs + ([vehSDKFuel] call A3A_fnc_vehiclePrice);
	_ChildControl  ctrlSetTooltip format ["Cost: %1%3. HR: %2", _costs, _costHR, currencySymbol];

	_ChildControl = _display displayCtrl 106;
	_costs = 0;
	_costHR = 0;
	{_costs = _costs + (server getVariable _x); _costHR = _costHR +1} forEach [USMil, USEng];
	_costs = _costs + ([vehSDKAmmo] call A3A_fnc_vehiclePrice);
	_ChildControl  ctrlSetTooltip format ["Cost: %1%3. HR: %2", _costs, _costHR, currencySymbol];

	_ChildControl = _display displayCtrl 107;
	_costs = 0;
	_costHR = 0;
	{_costs = _costs + (server getVariable _x); _costHR = _costHR +1} forEach [USMil, USMedic];
	_costs = _costs + ([vehSDKMedical] call A3A_fnc_vehiclePrice);
	_ChildControl  ctrlSetTooltip format ["Cost: %1%3. HR: %2", _costs, _costHR, currencySymbol];
	
	_ChildControl = _display displayCtrl 108;
	_costs = 0;
	_costHR = 0;
	{_costs = _costs + (server getVariable _x); _costHR = _costHR +1} forEach [USMil];
	_costs = _costs + ([vehInfSDKBoat] call A3A_fnc_vehiclePrice);
	_ChildControl  ctrlSetTooltip format ["Cost: %1%3. HR: %2", _costs, _costHR, currencySymbol];

	_ChildControl = _display displayCtrl 109;
	_costs = 0;
	_costHR = 0;
	{_costs = _costs + (server getVariable _x); _costHR = _costHR +1} forEach [USMil, USMil, USMil];
	_costs = _costs + ([vehSDKBoat] call A3A_fnc_vehiclePrice);
	_ChildControl  ctrlSetTooltip format ["Cost: %1%3. HR: %2", _costs, _costHR, currencySymbol];

	_ChildControl = _display displayCtrl 110;
	_costs = 0;
	_costHR = 0;
	{_costs = _costs + (server getVariable _x); _costHR = _costHR +1} forEach [USPilot, USPilot];
	_costs = _costs + ([vehSDKTransPlaneUS] call A3A_fnc_vehiclePrice);
	_ChildControl  ctrlSetTooltip format ["Cost: %1%3. HR: %2", _costs, _costHR, currencySymbol];

	_ChildControl = _display displayCtrl 111;
	_costs = 0;
	_costHR = 0;
	{_costs = _costs + (server getVariable _x); _costHR = _costHR +1} forEach [UKPilot, UKPilot];
	_costs = _costs + ([vehSDKTransPlaneUK] call A3A_fnc_vehiclePrice);
	_ChildControl  ctrlSetTooltip format ["Cost: %1%3. HR: %2", _costs, _costHR, currencySymbol];
};
