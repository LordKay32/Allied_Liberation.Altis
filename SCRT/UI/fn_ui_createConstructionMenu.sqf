disableSerialization;

createDialog "constructionMenu";

private _display = findDisplay 80000;

if (str (_display) == "no display") exitWith {};

private _comboBox = _display displayCtrl 505;

_comboBox lbAdd "Small sandbags";
_comboBox lbSetData [0, "TRENCH"];
_comboBox lbAdd "Large sandbag barriers";
_comboBox lbSetData [1, "OBSTACLE"];
_comboBox lbAdd "Sandbag bunkers";
_comboBox lbSetData [2, "SANDBAG_BUNKER"];
_comboBox lbAdd "Large bunkers";
_comboBox lbSetData [3, "CONCRETE_BUNKER"];
_comboBox lbAdd "Misc";
_comboBox lbSetData [4, "MISC"];

_comboBox lbSetCurSel 0;