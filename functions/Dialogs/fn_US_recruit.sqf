private ["_display","_childControl"];
createDialog "USRecruit";

sleep 1;
disableSerialization;

private _display = findDisplay 100;

if (str (_display) != "no display") then {
	_ChildControl = _display displayCtrl 104;
	_ChildControl  ctrlSetTooltip format ["Cost: %1%2",server getVariable USMil, currencySymbol];
	_ChildControl = _display displayCtrl 105;
	_ChildControl  ctrlSetTooltip format ["Cost: %1%2",server getVariable USMG, currencySymbol];
	_ChildControl = _display displayCtrl 126;
	_ChildControl  ctrlSetTooltip format ["Cost: %1%2",server getVariable USMedic, currencySymbol];
	_ChildControl = _display displayCtrl 107;
	_ChildControl  ctrlSetTooltip format ["Cost: %1%2",server getVariable USEng, currencySymbol];
	_ChildControl = _display displayCtrl 112;
	_ChildControl  ctrlSetTooltip format ["Cost: %1%2",server getVariable USPilot, currencySymbol];
	_ChildControl = _display displayCtrl 108;
	_ChildControl  ctrlSetTooltip format ["Cost: %1%2",server getVariable USExp, currencySymbol];
	_ChildControl = _display displayCtrl 109;
	_ChildControl  ctrlSetTooltip format ["Cost: %1%2",server getVariable USGL, currencySymbol];
	_ChildControl = _display displayCtrl 110;
	_ChildControl  ctrlSetTooltip format ["Cost: %1%2",server getVariable USSniper, currencySymbol];
	_ChildControl = _display displayCtrl 111;
	_ChildControl  ctrlSetTooltip format ["Cost: %1%2",server getVariable USATman, currencySymbol];
	_ChildControl = _display displayCtrl 113;
	_ChildControl  ctrlSetTooltip format ["Cost: %1%2",server getVariable USCrew, currencySymbol];
};