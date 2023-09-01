private ["_display","_childControl"];
createDialog "paraRecruit";

sleep 1;
disableSerialization;

private _display = findDisplay 100;

if (str (_display) != "no display") then {
	_ChildControl = _display displayCtrl 104;
	_ChildControl  ctrlSetTooltip format ["Cost: %1%2",server getVariable paraMil, currencySymbol];
	_ChildControl = _display displayCtrl 105;
	_ChildControl  ctrlSetTooltip format ["Cost: %1%2",server getVariable paraMG, currencySymbol];
	_ChildControl = _display displayCtrl 126;
	_ChildControl  ctrlSetTooltip format ["Cost: %1%2",server getVariable paraMedic, currencySymbol];
	_ChildControl = _display displayCtrl 107;
	_ChildControl  ctrlSetTooltip format ["Cost: %1%2",server getVariable paraEng, currencySymbol];
	_ChildControl = _display displayCtrl 108;
	_ChildControl  ctrlSetTooltip format ["Cost: %1%2",server getVariable paraExp, currencySymbol];
	_ChildControl = _display displayCtrl 109;
	_ChildControl  ctrlSetTooltip format ["Cost: %1%2",server getVariable paraGL, currencySymbol];
	_ChildControl = _display displayCtrl 110;
	_ChildControl  ctrlSetTooltip format ["Cost: %1%2",server getVariable paraSniper, currencySymbol];
	_ChildControl = _display displayCtrl 111;
	_ChildControl  ctrlSetTooltip format ["Cost: %1%2",server getVariable paraATman, currencySymbol];
};