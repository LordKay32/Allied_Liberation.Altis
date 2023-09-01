disableSerialization;

private _display = findDisplay 110000;

if (str (_display) == "no display") exitWith {};

private _vehicleTypeComboBox = _display displayCtrl 715;
private _index = lbCurSel _vehicleTypeComboBox;
private _vehicleType = _vehicleTypeComboBox lbData _index;
private _shopLookupArray = [];
private _vehNames = [];


switch(_vehicleType) do {
    case("LIGHT"): {
        private _avaialbleVehs = [vehSDKLightUnarmed, vehSDKLightArmed, vehSDKTruck, vehSDKTruckClosed, vehSDKRepair, vehSDKFuel, vehSDKAmmo, vehSDKMedical] select {_x != "not_supported"};
        _shopLookupArray = _avaialbleVehs;
        private _vehText = ["Willys MB Jeep", "Willys MB Jeep (M1919A4)", "GMC Truck (Open)", "GMC Truck (Covered)", "GMC Repair Truck", "GMC Fuel Truck", "GMC Ammo Truck", "GMC Medical Truck"];
    	_vehNames = _vehText;
    };
    case("HEAVY"): {
        private _avaialbleVehs = [vehSDKHeavyArmed, vehSDKAPCUK1, vehSDKAPCUS, vehSDKAPCUK2, vehSDKAT] select {_x != "not_supported"};
        _shopLookupArray = _avaialbleVehs;
        private _vehText = ["M3 Scout Car", "Universal Carrier", "US M3 Halftrack", "UK M3 Halftrack", "M8 Greyhound"];
        _vehNames = _vehText;
    };
    case("TANK"): {
        private _avaialbleVehs = [vehSDKTankChur, vehSDKTankCroc, vehSDKTankHow, vehSDKTankUKM4, vehSDKTankUSM5, vehSDKTankUSM4] select {_x != "not_supported"};
        _shopLookupArray = _avaialbleVehs;
        private _vehText = ["Churchill Mk VII", "Churchill Mk VII Crocodile", "Churchill Mk VII Howitzer", "UK M4 Sherman III", "M5A1 Stuart Light Tank" , "US M4A3 Sherman"];
        _vehNames = _vehText;
    };
    case("AIRCRAFT"): {
        private _avaialbleVehs = [vehSDKPlaneUK2, vehSDKPlaneUK3, vehSDKPlaneUS1, vehSDKPlaneUS2, vehSDKTransPlaneUK, vehSDKTransPlaneUS] select {_x != "not_supported"};
        _shopLookupArray = _avaialbleVehs;
        private _vehText = ["RAF Hawker Hurricane", "RAF de Havilland DH.98 Mosquito", "USAAF P-51 Mustang", "USAAF P-38 Lightning", "RAF C-47 Dakota Transport", "USAAF C-47 Skytrain Transport"];
        _vehNames = _vehText;
    };
    case("AIRCRAFT3"): {
        private _avaialbleVehs = [vehSDKPlaneUK2, vehSDKPlaneUK3, vehUKPayloadPlane, vehSDKPlaneUS1, vehSDKPlaneUS2, vehUSPayloadPlane, vehSDKTransPlaneUK, vehSDKTransPlaneUS] select {_x != "not_supported"};
        _shopLookupArray = _avaialbleVehs;
        private _vehText = ["RAF Hawker Hurricane", "RAF de Havilland DH.98 Mosquito", "RAF Handley Page Halifax", "USAAF P-51 Mustang", "USAAF P-38 Lightning", "USAAF B-17 Flying Fortress", "RAF C-47 Dakota Transport", "USAAF C-47 Skytrain Transport"];
        _vehNames = _vehText;
    };
    case("STATIC"): {
        private _avaialbleVehs = [UKMGStatic, USMGStatic, staticATteamPlayer, staticAAteamPlayer, SDKMortar, SDKArtillery] select {_x != "not_supported"};
        _shopLookupArray = _avaialbleVehs;
        private _vehText = ["Vickers Machine Gun", "1919A4 Machine Gun", "6 Pounder AT Gun", "Bofors AA Gun", "M2 Mortar", "M101 Howitzer"];
        _vehNames = _vehText;
    };
    case("BOAT"): {
        private _avaialbleVehs = [vehInfSDKBoat, vehSDKBoat, vehSDKAttackBoat] select {_x != "not_supported"};
        _shopLookupArray = _avaialbleVehs;
        private _vehText = ["LCVP Infantry Landing Craft", "LCM-3 Vehicle Landing Craft", "Motor Torpedo Boat"];
        _vehNames = _vehText;
    };
    case("CIV"): {
        private _avaialbleVehs = [civCar, civTruck] select {_x != "not_supported"};
        _shopLookupArray = _avaialbleVehs;
        private _vehText = ["Car", "Truck"];
        _vehNames = _vehText;
    };
    default { 
        [1, format ["Bad Vehicle Type - %1 ", _vehicleType], "fn_ui_setAvailableBuyVehicleTypes"] call A3A_fnc_log;
    };
};

if (isNil "_shopLookupArray") exitWith {
    [1, "Fatal Error - no lookup array for vehicle store, aborting.", "fn_ui_setAvailableBuyVehicleTypes"] call A3A_fnc_log;
};


private _vehicleComboBox = _display displayCtrl 705;
lbClear _vehicleComboBox;

private _fillCombo = {
    params ["_shopArray", "_comboBox", "_names"];

    {
        //private _name = getText (configFile >> "CfgVehicles" >> _x >> "displayName");
        _countNum = server getVariable (_x + "_count");
        private _vehNum = _shopArray find _x;
        private _name = (_names select _vehNum);
        _comboBox lbAdd (_name + format [" [%1]",_countNum]);          
        _comboBox lbSetData [_forEachIndex, _x];
    } forEach _shopArray;
};

[_shopLookupArray, _vehicleComboBox, _vehNames] call _fillCombo;

_vehicleComboBox lbSetCurSel 0;