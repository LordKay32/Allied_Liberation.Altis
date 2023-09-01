private ["_display","_childControl"];
createDialog "SDKRecruit";

sleep 1;
disableSerialization;

private _display = findDisplay 100;

if (str (_display) != "no display") then {
	_ChildControl = _display displayCtrl 104;
	_ChildControl  ctrlSetTooltip format ["Cost: %1%2",server getVariable SDKMil, currencySymbol];
	_ChildControl = _display displayCtrl 105;
	_ChildControl  ctrlSetTooltip format ["Cost: %1%2",server getVariable SDKMG, currencySymbol];
	_ChildControl = _display displayCtrl 108;
	_ChildControl  ctrlSetTooltip format ["Cost: %1%2",server getVariable SDKMedic, currencySymbol];
	_ChildControl = _display displayCtrl 109;
	_ChildControl  ctrlSetTooltip format ["Cost: %1%2",server getVariable SDKEng, currencySymbol];
};