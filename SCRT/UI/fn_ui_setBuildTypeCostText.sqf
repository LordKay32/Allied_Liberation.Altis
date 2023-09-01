disableSerialization;

private _display = findDisplay 80000;

if (str (_display) == "no display") exitWith {};

private _costLocalized = localize "STR_antistasi_dialogs_price";

private _costTextBox = _display displayCtrl 510;
private _comboBox = _display displayCtrl 505;
private _index = lbCurSel _comboBox;
private _buildType = _comboBox lbData _index;

switch (_buildType) do {
    case ("TRENCH"): {
        _costTextBox ctrlSetText format ["%1: 50%2", _costLocalized, currencySymbol];
    };
    case ("OBSTACLE"): {
        _costTextBox ctrlSetText format ["%1: 100%2", _costLocalized, currencySymbol];
    };
    case ("SANDBAG_BUNKER"): {
        _costTextBox ctrlSetText format ["%1: 250%2", _costLocalized, currencySymbol];
    };
    case ("CONCRETE_BUNKER"): {
        _costTextBox ctrlSetText format ["%1: 500%2", _costLocalized, currencySymbol];
    };
    case ("MISC"): {
        _costTextBox ctrlSetText format ["%1: 25%2", _costLocalized, currencySymbol];
    };
    default {
        [2,"Bad build type.", "fn_setBuildTypeCostText"] call A3A_fnc_log;
    };
};