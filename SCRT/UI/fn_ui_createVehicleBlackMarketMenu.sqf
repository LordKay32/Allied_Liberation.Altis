disableSerialization;

createDialog "vehicleBlackMarketMenu";

private _addCategory = {
    params ["_comboBox", "_index", "_tiedArray", "_longTitle", "_shortTitle"];

    if (!isNil "_tiedArray" && {!(_tiedArray isEqualTo [])}) then {
        _comboBox lbAdd _longTitle;
        _comboBox lbSetData [_index, _shortTitle];
        _index = _index + 1;
    };

    _index;
};


private _display = findDisplay 90000;

if (str (_display) == "no display") exitWith {};

private _comboBox = _display displayCtrl 1015;

private _i = 0;

_i = [_comboBox, _i, shop_AA, "Anti-Air Vehicles", "AA"] call _addCategory;
_i = [_comboBox, _i, shop_MRAP, "MRAPs, Armored Wheeled Vehicles", "MRAP"] call _addCategory;
_i = [_comboBox, _i, shop_wheel_apc, "Wheeled APCs", "WHEELED_APC"] call _addCategory;
_i = [_comboBox, _i, shop_track_apc, "Tracked APCs", "TRACKED_APC"] call _addCategory;
_i = [_comboBox, _i, shop_heli, "Helicopters", "HELI"] call _addCategory;
_i = [_comboBox, _i, shop_tank, "Tanks", "TANK"] call _addCategory;
_i = [_comboBox, _i, shop_plane, "Planes", "PLANE"] call _addCategory;
_i = [_comboBox, _i, shop_UAV, "UAVs", "UAV"] call _addCategory;
_i = [_comboBox, _i, additionalShopLight, "Light Utility Vehicles", "LUV"] call _addCategory;
_i = [_comboBox, _i, additionalShopAtgmVehicles, "ATGM Carriers", "ATGM"] call _addCategory;
_i = [_comboBox, _i, additionalShopManpadsVehicles, "MANPADS Carriers", "MANPADS"] call _addCategory;
_i = [_comboBox, _i, additionalShopArtillery, "Artillery", "ARTILLERY"] call _addCategory;

_comboBox lbSetCurSel 0;