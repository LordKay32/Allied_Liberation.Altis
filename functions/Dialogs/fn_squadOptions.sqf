private ["_display","_childControl","_costs","_costHR","_unitsX","_formatX"];
if (!([player] call A3A_fnc_hasRadio)) exitWith {["Squad Options", "You need a radio in your inventory to be able to give orders to other squads"] call A3A_fnc_customHint;};
createDialog "squadOptions";

sleep 1;
disableSerialization;

_display = findDisplay 100;

if (str (_display) != "no display") then
{
	_ChildControl = _display displayCtrl 104;
	_costs = 0;
	_costHR = 0;
	{_costs = _costs + (server getVariable _x); _costHR = _costHR +1} forEach groupsUSSquad;
	_ChildControl  ctrlSetTooltip format ["Cost: %1%3. HR: %2", _costs, _costHR, currencySymbol];

	_ChildControl = _display displayCtrl 105;
	_costs = 0;
	_costHR = 0;
	{_costs = _costs + (server getVariable _x); _costHR = _costHR +1} forEach groupsparaSquad;
	_ChildControl  ctrlSetTooltip format ["Cost: %1%3. HR: %2", _costs, _costHR, currencySymbol];

	_ChildControl = _display displayCtrl 106;
	_costs = 0;
	_costHR = 0;
	{_costs = _costs + (server getVariable _x); _costHR = _costHR +1} forEach groupsUKSquad;
	_ChildControl  ctrlSetTooltip format ["Cost: %1%3. HR: %2", _costs, _costHR, currencySymbol];

	_ChildControl = _display displayCtrl 107;
	_costs = 0;
	_costHR = 0;
	{_costs = _costs + (server getVariable _x); _costHR = _costHR +1} forEach groupsSASSquad;
	_ChildControl  ctrlSetTooltip format ["Cost: %1%3. HR: %2", _costs, _costHR, currencySymbol];
};
