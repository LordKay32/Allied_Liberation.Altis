disableSerialization;

private _display = findDisplay 60000;

if (str (_display) == "no display") exitWith {};

private _costTextBox = _display displayCtrl 2751;
private _comboBox = _display displayCtrl 2750;
private _index = lbCurSel _comboBox;
private _outpostType =  lbData [2750, _index];

outpostType = _outpostType;
private _costs = 50;
private _hr = 0;
private _veh = "";
private _garrison = [];

switch (outpostType) do {
    case ("WATCHPOST"): {
        _costs = 50;
        _hr = 0;
        _garrison = groupsSASRecon;
        {
            _costs = _costs + (server getVariable [_x,0]);
            _hr = _hr + 1; 
        } forEach _garrison;
        _costTextBox ctrlSetText format ["Costs %1 HR and %2%3", _hr, _costs, currencySymbol];
    };
    case ("ROADBLOCK"): {
        _costs = 200 + ([UKMGStatic] call A3A_fnc_vehiclePrice) + ([staticATteamPlayer] call A3A_fnc_vehiclePrice); //MG car
        _hr = 0; //static gunner
        _veh = [UKMGStatic, staticATteamPlayer];
        _garrison = [UKSL,UKMG,UKATman,UKMedic,UKMil,UKMil,UKMil,UKMG];
        {
            _costs = _costs + (server getVariable [_x,0]);
            _hr = _hr + 1;
        } forEach _garrison;
        _costTextBox ctrlSetText format ["Costs 1 AT gun, 1 Vickers MG, %1 HR and %2%3", _hr, _costs, currencySymbol];
    };
    case ("AA"): {
        _costs = 2*([staticAAteamPlayer] call A3A_fnc_vehiclePrice);
        _hr = 0;
        _veh = staticAAteamPlayer;
        _garrison = [UKSL,UKMG,UKATman,UKMedic,UKMil,UKMil,UKMil,UKMil];
        {
            _costs = _costs + (server getVariable [_x,0]); 
            _hr = _hr +1;
        } forEach _garrison;
       _costTextBox ctrlSetText format ["Costs 2 AA guns, %1 HR and %2%3", _hr, _costs, currencySymbol];
    };
    case ("AT"): {
        _costs = 2*([staticAAteamPlayer] call A3A_fnc_vehiclePrice); //AT
        _hr = 0; //static gunner
        _veh = staticATteamPlayer;
        _garrison = [UKSL,UKATman,UKATman,UKMedic,UKMil,UKMil,UKMil,UKMil];
        {
            _costs = _costs + (server getVariable [_x,0]); 
            _hr = _hr +1;
        } forEach _garrison;
       _costTextBox ctrlSetText format ["Costs 2 AT guns, %1 HR and %2%3", _hr, _costs, currencySymbol];
    };
    case ("MORTAR"): {
        _costs = [SDKArtillery] call A3A_fnc_vehiclePrice; //Mortar
        _hr = 0; //static gunner
        _veh = SDKArtillery;
        _garrison = [USSL,USMG,USMedic,USATman,USMil,USMil,USMil];
        {
            _costs = _costs + (server getVariable [_x,0]); 
            _hr = _hr +1;
        } forEach _garrison;
       _costTextBox ctrlSetText format ["Costs 1 artillery piece, %1 HR and %2%3", _hr, _costs, currencySymbol];
    };
    case ("HMG"): {
        _costs = 2 * ([UKMGStatic] call A3A_fnc_vehiclePrice);
        _hr = 0; //static gunner
        _veh = UKMGStatic;
        _garrison = [UKSL,UKMG,UKMG,UKMedic,UKMil,UKMil];
        {
            _costs = _costs + (server getVariable [_x,0]); 
            _hr = _hr +1;
        } forEach _garrison;
       _costTextBox ctrlSetText format ["Costs 2 Vickers MGs, %1 HR and %2%3", _hr, _costs, currencySymbol];
    };
        case ("LIGHTROADBLOCK"): {
        _costs = [vehSDKLightArmed] call A3A_fnc_vehiclePrice; //Mortar
        _hr = 0; //static gunner
        _veh = vehSDKLightArmed;
        _garrison = [USSL,USGL,USMG,USATman,USEng,USMedic,USMil];
        {
            _costs = _costs + (server getVariable [_x,0]); 
            _hr = _hr +1;
        } forEach _garrison;
       _costTextBox ctrlSetText format ["Costs 1 MG jeep %1 HR and %2%3", _hr, _costs, currencySymbol];
    };
        case ("SUPPORTPOST"): {
        _costs = 500 + ([vehSDKLightUnarmed] call A3A_fnc_vehiclePrice) + ([vehSDKRepair] call A3A_fnc_vehiclePrice) + ([vehSDKFuel] call A3A_fnc_vehiclePrice) + ([vehSDKAmmo] call A3A_fnc_vehiclePrice) + ([vehSDKMedical] call A3A_fnc_vehiclePrice) + ([USMGStatic] call A3A_fnc_vehiclePrice); //Mortar
        _hr = 0; //static gunner
        _veh = [vehSDKLightUnarmed,vehSDKRepair,vehSDKMedical,vehSDKFuel,vehSDKAmmo,USMGStatic];
        _garrison = [USSL,USMG,USATman,USMedic,USMil,USMG];
        {
            _costs = _costs + (server getVariable [_x,0]); 
            _hr = _hr +1;
        } forEach _garrison;
       _costTextBox ctrlSetText format ["Costs 1 1919 MG, 5 support vehicles, %1 HR and %2%3", _hr, _costs, currencySymbol];
    };
    default {
		[1, "Bad outpost type.", "fn_setOutpostCost"] call A3A_fnc_log;
	};
};

outpostCost = [_costs, _hr, _veh, _garrison];