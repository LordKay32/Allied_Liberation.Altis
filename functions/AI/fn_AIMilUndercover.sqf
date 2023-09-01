/*
 * Name:	fn_AIMilUndercover
 * Date:	3/07/2023
 * Version: 1.0
 * Author:  JB
 *
 * Description:
 * Change SAS into Wehrmacht gear
 *
 * Parameter(s):
 * _PARAM1 (TYPE): DESCRIPTION.
 * _PARAM2 (TYPE): DESCRIPTION.
 *
 * Returns:
 * nothing
 */

	

	private _unit = _this select 0;
	private _unitType = _unit getVariable "unitType";
	
	if (_unitType in SDKTroops) exitWith {_exit = false; _exit};
	
	private _availableUniforms = [];
	private _availableVests = [];
	private _availableBackpacks = [];
	private _availableHelmets = [];
	private _availableItems = [];
	private _availableWeapons = [];
	private _availableMagazines = [];
	private _availableExplosives = [];
	private _availableLaunchers = [];
	private _uniform = "";
	private _vest = "";
	private _helmet = "";
	private _weapon = "";	
	private _launcher = "";
	private _backPack = "";
	private _exit = false;

	{
	_number = [jna_dataList select (_x call jn_fnc_arsenal_itemType), _x] call jn_fnc_arsenal_itemCount;
	if (_number > 0) then {_availableUniforms pushBack _x};
	} forEach WehrmachtUniforms; 

	{
	_number = [jna_dataList select (_x call jn_fnc_arsenal_itemType), _x] call jn_fnc_arsenal_itemCount;
	if (_number > 0) then {_availableVests pushBack _x};
	} forEach WehrmachtVests; 
	
	{
	_number = [jna_dataList select (_x call jn_fnc_arsenal_itemType), _x] call jn_fnc_arsenal_itemCount;
	if (_number > 0) then {_availableBackpacks pushBack _x};
	} forEach WehrMachtBackpacks; 

	{
	_number = [jna_dataList select (_x call jn_fnc_arsenal_itemType), _x] call jn_fnc_arsenal_itemCount;
	if (_number > 0) then {_availableHelmets pushBack _x};
	} forEach WehrmachtHelmets; 

	{
	_number = [jna_dataList select (_x call jn_fnc_arsenal_itemType), _x] call jn_fnc_arsenal_itemCount;
	if (_number > 1) then {_availableItems pushBack _x};
	} forEach WehrmachtItems; 

	{
	_number = [jna_dataList select (_x call jn_fnc_arsenal_itemType), _x] call jn_fnc_arsenal_itemCount;
	if (_number > 1) then {_availableExplosives pushBack _x};
	} forEach WehrmachtExplosives; 

	{
	_numberWeaps = [jna_dataList select (_x call jn_fnc_arsenal_itemType), _x] call jn_fnc_arsenal_itemCount;
	_weaponMag = getArray (configFile / "CfgWeapons" / _x / "magazines") select 0;
	_numberRounds = [jna_dataList select (_weaponMag call jn_fnc_arsenal_itemType), _weaponMag] call jn_fnc_arsenal_itemCount;
	_magRounds = getNumber (configFile / "CfgMagazines" / _weaponMag / "count");
	
	_SASLoadout = getUnitLoadout _unit;
	_SASFullUnitGear = _SASLoadout call A3A_fnc_reorgLoadoutUnit;
	{ [_x select 0 call jn_fnc_arsenal_itemType, _x select 0, _x select 1] call jn_fnc_arsenal_addItem } forEach _SASFullUnitGear;
	
	private _minRounds = 0;

	if (_magRounds <= 10) then {_minRounds = (6 * _magRounds)};
	if ((_magRounds > 10) && (_magRounds < 50)) then {_minRounds = (4 * _magRounds)};
	if (_magRounds >= 50) then {_minRounds = (3 * _magRounds)};
	
	if (_numberWeaps > 0 && _numberRounds > _minRounds) then {_availableWeapons pushBack _x};
	} forEach (WehrmachtWeapons - ["LIB_M1908"]); 

	{
	_number = [jna_dataList select (_x call jn_fnc_arsenal_itemType), _x] call jn_fnc_arsenal_itemCount;
	_ammo = if (_x == "LIB_RPzB") then {getArray (configFile / "CfgWeapons" / _x / "magazines") select 0} else {""};
	_ammoCount = if (_x == "LIB_RPzB") then {[jna_dataList select (_ammo call jn_fnc_arsenal_itemType), _ammo] call jn_fnc_arsenal_itemCount} else {2};
	if ((_number > 0) && (_ammoCount > 1)) then {_availableLaunchers pushBack _x};
	} forEach WehrmachtLaunchers; 

	if (count _availableUniforms == 0) exitWith {["Undercover", "There are no more uniforms available for your unit to go undercover."] call A3A_fnc_customHint; _exit == true};
	if (count _availableVests == 0) exitWith {["Undercover", "There are no more vests available for your unit to go undercover."] call A3A_fnc_customHint; _exit == true};
	if (count _availableHelmets == 0) exitWith {["Undercover", "There are no more helmets available for your unit to go undercover."] call A3A_fnc_customHint; _exit == true};
	if (count _availableWeapons == 0) exitWith {["Undercover", "There are no more weapons available for your unit to go undercover."] call A3A_fnc_customHint; _exit == true};

	private _vest = "";

	switch (true) do {
    	case (_unitType == SASMil): {
			_uniform = if ("U_LIB_GER_Schutze" in _availableUniforms) then {"U_LIB_GER_Schutze"} else {selectRandom _availableUniforms};
			_vest = selectRandom (_availableVests - ["V_LIB_GER_SniperBelt"]);
			_helmet = selectRandom _availableHelmets;
			_weapon = if ("LIB_K98" in _availableWeapons) then {"LIB_K98"} else {selectRandom _availableWeapons};
		};
		case (_unitType == SASMedic): {
			_uniform = if ("U_LIB_GER_Medic" in _availableUniforms) then {"U_LIB_GER_Medic"} else {selectRandom _availableUniforms};
			_vest = selectRandom (_availableVests - ["V_LIB_GER_SniperBelt"]);
			_helmet = selectRandom _availableHelmets;
			_backPack = if ("B_LIB_GER_MedicBackpack_empty" in _availableBackpacks) then {"B_LIB_GER_MedicBackpack_empty"} else {selectRandom _availableBackpacks};
			_weapon = if ("LIB_K98" in _availableWeapons) then {"LIB_K98"} else {selectRandom _availableWeapons};
		};
		case (_unitType == SASMG): {
			_uniform = selectRandom _availableUniforms;
			_vest = selectRandom (_availableVests - ["V_LIB_GER_SniperBelt"]);
			_helmet = selectRandom _availableHelmets;
			_weapon = if (("LIB_MG34" in _availableWeapons) || ("LIB_MG42" in _availableWeapons)) then {if ("LIB_MG34" in _availableWeapons) then {"LIB_MG34"} else {"LIB_MG42"}} else {selectRandom _availableWeapons};
		};
		case (_unitType == SASATman): {
			_uniform = selectRandom _availableUniforms;
			_vest = selectRandom (_availableVests - ["V_LIB_GER_SniperBelt"]);
			_helmet = selectRandom _availableHelmets;
			_weapon = if ("LIB_MP40" in _availableWeapons) then {"LIB_MP40"} else {selectRandom _availableWeapons};
			_launcher = if ((("LIB_RPzB" in _availableLaunchers) && (count _availableBackpacks > 0)) || ("LIB_PzFaust_60m" in _availableLaunchers) || ("LIB_PzFaust_30m" in _availableLaunchers)) then {selectRandom _availableLaunchers} else {""};
			if (_launcher == "LIB_RPzB") then {
				_backPack = if ("B_LIB_GER_Panzer_Empty" in _availableBackpacks) then {"B_LIB_GER_Panzer_Empty"} else {selectRandom _availableBackpacks};
			};
		};
		case (_unitType == SASExp): {
			_uniform = selectRandom _availableUniforms;
			_vest = selectRandom (_availableVests - ["V_LIB_GER_SniperBelt"]);
			_helmet = selectRandom _availableHelmets;
			_backPack = if ("B_LIB_GER_SapperBackpack_empty" in _availableBackpacks) then {"B_LIB_GER_SapperBackpack_empty"} else {selectRandom _availableBackpacks};
			_weapon = if ("LIB_K98" in _availableWeapons) then {"LIB_K98"} else {selectRandom _availableWeapons};
		};
		case (_unitType == SASSniper): {
			_uniform = if ("U_LIB_GER_Scharfschutze" in _availableUniforms) then {"U_LIB_GER_Scharfschutze"} else {selectRandom _availableUniforms};
			_vest = if ("V_LIB_GER_SniperBelt" in _availableVests) then {"V_LIB_GER_SniperBelt"} else {selectRandom _availableVests};
			_helmet = if ("H_LIB_GER_HelmetCamo" in _availableHelmets) then {"H_LIB_GER_HelmetCamo"} else {selectRandom _availableHelmets};
			_weapon = if ("LIB_K98ZF39" in _availableWeapons) then {"LIB_K98ZF39"} else {selectRandom _availableWeapons};
		};
	};

	_magazine = getArray (configFile / "CfgWeapons" / _weapon / "magazines") select 0;
	_magazinesCount = 0;
	if (_weapon in ["LIB_K98","LIB_K98ZF39","LIB_G43"]) then {_magazinesCount = 5};
	if (_weapon in ["LIB_MP40","LIB_FG42G"]) then {_magazinesCount = 3};
	if (_weapon in ["LIB_MG34","LIB_MG42"]) then {_magazinesCount = 2};
	
	_firstAidKit = if ("fow_i_fak_ger" in _availableItems) then {"fow_i_fak_ger"} else {"fow_i_fak_uk"};
	_grenades = if (("LIB_Shg24" in _availableExplosives) || ("LIB_M39" in _availableExplosives)) then {if ("LIB_Shg24" in _availableExplosives) then {"LIB_Shg24"} else {"LIB_M39"}} else {"LIB_MillsBomb"};
	_explosive = if ("LIB_Ladung_Small_MINE_mag" in _availableExplosives) then {"LIB_Ladung_Small_MINE_mag"} else {"fow_e_tnt_onepound_mag"};

	_unit setUnitLoadout [ [], [], [],    ["", []], [], [],    "", "", [],
	["ItemMap","","","ItemCompass","ItemWatch",""] ];
	
	_unit forceAddUniform _uniform;
	_unit addVest _vest;
	_unit addHeadgear _helmet;
	_unit addMagazine _magazine;
	_unit addWeapon _weapon;
	_unit addItemToUniform "LIB_US_M18";
	for "_i" from 1 to _magazinesCount do 
		{
		_unit addItemToVest _magazine;
		};
	for "_i" from 1 to 2 do
		{
		_unit addItemToUniform _firstAidKit;
		_unit addItemToVest _grenades;
		};

	if (_unitType == SASMedic) then {
		if (_backPack != "") then {
			_unit addBackpack _backPack;
			_unit addItemToBackpack "Medikit";
			_unit addItemToBackpack "LIB_US_M18_Green";
		};
	};

	if (_unitType == SASATman) then {
		if (_launcher != "") then {
			if (_launcher == "LIB_RPzB") then {
				_x addBackPack _backPack;
				for "_i" from 1 to 2 do 
					{
					_unit addItemToBackpack "LIB_1Rnd_RPzB";
					};
				_unit addMagazine "LIB_1Rnd_RPzB";
			};
			_unit addWeapon _launcher;
		};
	};
	
	if (_unitType == SASExp) then {
		if (_backPack != "") then {
			_x addBackpack _backPack;
			_x addItemToBackpack "ToolKit";
			_x addItemToBackpack _explosive;
		};
	};
		
	_loadout = getUnitLoadout _unit;
	_fullUnitGear = _loadout call A3A_fnc_reorgLoadoutUnit;
	{ [_x select 0 call jn_fnc_arsenal_itemType, _x select 0, _x select 1] call jn_fnc_arsenal_removeItem } forEach _fullUnitGear;
	
	_exit;

