private ["_display","_childControl"];
createDialog "UKRecruit";

sleep 1;
disableSerialization;

private _display = findDisplay 100;

if (str (_display) != "no display") then {
	_ChildControl = _display displayCtrl 104;
	_ChildControl  ctrlSetTooltip format ["Cost: %1%2",server getVariable UKMil, currencySymbol];
	_ChildControl = _display displayCtrl 105;
	_ChildControl  ctrlSetTooltip format ["Cost: %1%2",server getVariable UKMG, currencySymbol];
	_ChildControl = _display displayCtrl 126;
	_ChildControl  ctrlSetTooltip format ["Cost: %1%2",server getVariable UKMedic, currencySymbol];
	_ChildControl = _display displayCtrl 107;
	_ChildControl  ctrlSetTooltip format ["Cost: %1%2",server getVariable UKEng, currencySymbol];
	_ChildControl = _display displayCtrl 112;
	_ChildControl  ctrlSetTooltip format ["Cost: %1%2",server getVariable UKPilot, currencySymbol];
	_ChildControl = _display displayCtrl 108;
	_ChildControl  ctrlSetTooltip format ["Cost: %1%2",server getVariable UKExp, currencySymbol];
	_ChildControl = _display displayCtrl 109;
	_ChildControl  ctrlSetTooltip format ["Cost: %1%2",server getVariable UKGL, currencySymbol];
	_ChildControl = _display displayCtrl 110;
	_ChildControl  ctrlSetTooltip format ["Cost: %1%2",server getVariable UKSniper, currencySymbol];
	_ChildControl = _display displayCtrl 111;
	_ChildControl  ctrlSetTooltip format ["Cost: %1%2",server getVariable UKATman, currencySymbol];
	_ChildControl = _display displayCtrl 113;
	_ChildControl  ctrlSetTooltip format ["Cost: %1%2",server getVariable UKCrew, currencySymbol];
};