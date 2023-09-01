private _type = _this select 0;

disableSerialization;

createDialog "buyVehicleMenu";

private _display = findDisplay 110000;

if (str (_display) == "no display") exitWith {};

private _comboBox = _display displayCtrl 715;

switch(_type) do {
    case("MAIN"): {

	_comboBox lbAdd ("Light Vehicles");
	_comboBox lbSetData [0, "LIGHT"];

	_comboBox lbAdd ("Heavy Vehicles");
	_comboBox lbSetData [1, "HEAVY"];

	_comboBox lbAdd ("Tanks");
	_comboBox lbSetData [2, "TANK"];
	
	_comboBox lbAdd ("Static Weapons");
	_comboBox lbSetData [3, "STATIC"];

	_comboBox lbSetCurSel 0;
	};

	case("SDK"): {

	_comboBox lbAdd ("Civilian Vehicles");
	_comboBox lbSetData [0, "CIV"];

	_comboBox lbSetCurSel 0;
	};

    case("SEAPORT"): {

	_comboBox lbAdd ("Light Vehicles");
	_comboBox lbSetData [0, "LIGHT"];
	
	_comboBox lbAdd ("Boats");
	_comboBox lbSetData [1, "BOAT"];

	_comboBox lbAdd ("Static Weapons");
	_comboBox lbSetData [2, "STATIC"];

	_comboBox lbSetCurSel 0;
	};

    case("AIRPORT"): {

	_comboBox lbAdd ("Light Vehicles");
	_comboBox lbSetData [0, "LIGHT"];

	_comboBox lbAdd ("Heavy Vehicles");
	_comboBox lbSetData [1, "HEAVY"];

	_comboBox lbAdd ("Tanks");
	_comboBox lbSetData [2, "TANK"];

	_comboBox lbAdd ("Aircraft");
	_comboBox lbSetData [3, "AIRCRAFT"];
	
	_comboBox lbAdd ("Static Weapons");
	_comboBox lbSetData [4, "STATIC"];

	_comboBox lbSetCurSel 0;
	};

    case("AIRPORT3"): {

	_comboBox lbAdd ("Light Vehicles");
	_comboBox lbSetData [0, "LIGHT"];

	_comboBox lbAdd ("Heavy Vehicles");
	_comboBox lbSetData [1, "HEAVY"];

	_comboBox lbAdd ("Tanks");
	_comboBox lbSetData [2, "TANK"];

	_comboBox lbAdd ("Aircraft");
	_comboBox lbSetData [3, "AIRCRAFT3"];
	
	_comboBox lbAdd ("Static Weapons");
	_comboBox lbSetData [4, "STATIC"];

	_comboBox lbSetCurSel 0;
	};

    case("OUTPOST"): {

	_comboBox lbAdd ("Light Vehicles");
	_comboBox lbSetData [0, "LIGHT"];

	_comboBox lbAdd ("Static Weapons");
	_comboBox lbSetData [1, "STATIC"];

	_comboBox lbSetCurSel 0;
	};
	
	case("AMMOTRUCK"): {

	_comboBox lbAdd ("Static Weapons");
	_comboBox lbSetData [0, "STATIC"];

	_comboBox lbSetCurSel 0;
	};
};