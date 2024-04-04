disableSerialization;

private _display = findDisplay 60000;

if (str (_display) == "no display") exitWith {};

private _costTextBox = _display displayCtrl 1751;
private _comboBox = _display displayCtrl 1750;
private _index = lbCurSel _comboBox;
private _supportType =  lbData [1750, _index];

supportType = _supportType;

switch (supportType) do {
    case ("SUPPLY");
    case ("SMOKE");
    case ("FLARE");
    case ("RECON"): {
        _costTextBox ctrlSetText "Costs 1 Support";
    };
    case ("VEH_AIRDROP"): {
        _costTextBox ctrlSetText format ["Costs 1 Support and 400%1", currencySymbol];
    };
    case ("LOOTCRATE_AIRDROP"): {
        _costTextBox ctrlSetText format ["Costs 1 Support and 200%1", currencySymbol];
    };
    case ("STATIC_MG_AIRDROP"): {
        _costTextBox ctrlSetText format ["Costs 1 Support and 800%1", currencySymbol];
    };
    case ("NAPALM");
    case ("HE");
    case ("FIGHTER");
    case ("CHEMICAL"): {
        _costTextBox ctrlSetText "Costs 1 Air Support";
    };
    case ("PARADROP"): {
        _costTextBox ctrlSetText format ["Costs 1 Support and 500%1", currencySymbol];
    };
    case ("LOOTHELI"): {
        _costTextBox ctrlSetText format ["Costs 1 Support and 2000%1", currencySymbol];
    };
    default {
        _costTextBox ctrlSetText "Costs 1 Support";
    };
};

if (supportType == "PARADROP") then {
    private _markersX = markersX select {sidesX getVariable [_x,sideUnknown] != teamPlayer};
    _markersX = _markersX - controlsX;

    forbiddenParadropZones = [];

    {
        private _localMarker = createMarkerLocal [format ["%1forbiddenzone", count forbiddenParadropZones], getMarkerPos _x];
        _localMarker setMarkerShapeLocal "ELLIPSE";
        _localMarker setMarkerSizeLocal [500,500];
        _localMarker setMarkerTypeLocal "hd_warning";
        _localMarker setMarkerColorLocal "ColorRed";
        _localMarker setMarkerBrushLocal "DiagGrid";
        forbiddenParadropZones pushBack _localMarker;
    } forEach _markersX;
} else { 
    if (!isNil "forbiddenParadropZones") then {
        {deleteMarkerLocal _x} forEach forbiddenParadropZones;
    };
};

if (supportType != "LOOTHELI" && {getMarkerColor "LootHeliAreaMarker" != ""}) then {
    deleteMarkerLocal "LootHeliAreaMarker";
};