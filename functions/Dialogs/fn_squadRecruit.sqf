private ["_display","_childControl","_costs","_costHR","_unitsX","_formatX"];
if (!([player] call A3A_fnc_hasRadio)) exitWith {["Squad Recruit", "You need a radio in your inventory to be able to give orders to other squads"] call A3A_fnc_customHint;};
createDialog "squadRecruit";

sleep 1;
disableSerialization;

_display = findDisplay 100;

if (str (_display) != "no display") then
{
	_ChildControl = _display displayCtrl 104;
	_costs = 0;
	_costHR = 0;

	_ChildControl = _display displayCtrl 105;
	_costs = 0;
	_costHR = 0;
	{_costs = _costs + (server getVariable _x); _costHR = _costHR +1} forEach groupsSASRecon;
	_ChildControl  ctrlSetTooltip format ["Cost: %1%3. HR: %2",_costs,_costHR, currencySymbol];

	_ChildControl = _display displayCtrl 106;
	_costs = 0;
	_costHR = 0;
	{_costs = _costs + (server getVariable _x); _costHR = _costHR +1} forEach groupsUSAT;
	_ChildControl  ctrlSetTooltip format ["Cost: %1%3. HR: %2",_costs,_costHR, currencySymbol];

	_ChildControl = _display displayCtrl 107;
	_costs = 0;
	_costHR = 0;
	{_costs = _costs + (server getVariable _x); _costHR = _costHR +1} forEach groupSASSniper;
	_ChildControl  ctrlSetTooltip format ["Cost: %1%3. HR: %2",_costs,_costHR, currencySymbol];

	_ChildControl = _display displayCtrl 108;
	_costs = 0;
	_costHR = 0;
	{_costs = _costs + (server getVariable _x); _costHR = _costHR +1} forEach groupUSAACrew;
	_costs = _costs + ([vehSDKAA] call A3A_fnc_vehiclePrice);
	_ChildControl  ctrlSetTooltip format ["Cost: %1%3. HR: %2",_costs,_costHR, currencySymbol];

	_ChildControl = _display displayCtrl 110;
	_costs = 0;
	_costHR = 0;
	{_costs = _costs + (server getVariable _x); _costHR = _costHR +1} forEach vehUKAACrew;
	_costs = _costs + ([staticAAteamPlayer] call A3A_fnc_vehiclePrice) + ([staticAAteamPlayer] call A3A_fnc_vehiclePrice);
	_ChildControl  ctrlSetTooltip format ["Cost: %1%3. HR: %2",_costs,_costHR, currencySymbol];

	_ChildControl = _display displayCtrl 111;
	_costs = 0;
	_costHR = 0;
	{_costs = _costs + (server getVariable _x); _costHR = _costHR +1} forEach groupUSMortarCrew;
	_costs = _costs + ([SDKMortar] call A3A_fnc_vehiclePrice);
	_ChildControl  ctrlSetTooltip format ["Cost: %1%3. HR: %2",_costs,_costHR, currencySymbol];

	_ChildControl = _display displayCtrl 112;
	_costs = 0;
	_costHR = 0;
	{_costs = _costs + (server getVariable _x); _costHR = _costHR +1} forEach groupUKMGCrew;
	_costs = _costs + ([UKMGStatic] call A3A_fnc_vehiclePrice);
	_ChildControl  ctrlSetTooltip format ["Cost: %1%3. HR: %2",_costs,_costHR, currencySymbol];

	_ChildControl = _display displayCtrl 113;
	_costs = 0;
	_costHR = 0;
	{_costs = _costs + (server getVariable _x); _costHR = _costHR +1} forEach vehUSMGCrew;
	_costs = _costs + ([vehSDKLightArmed] call A3A_fnc_vehiclePrice);
	_ChildControl  ctrlSetTooltip format ["Cost: %1%3. HR: %2",_costs,_costHR, currencySymbol];
};
