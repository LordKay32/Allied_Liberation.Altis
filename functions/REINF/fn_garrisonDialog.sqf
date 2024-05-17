params ["_typeX", "_site"];

private ["_garrison","_costs","_hr","_size", "_veh","_loadout"];

private _watchpostFIA = if (_site in watchpostsFIA) then {true} else {false};
private _roadblockFIA = if (_site in roadblocksFIA) then {true} else {false};
private _aapostFIA = if (_site in aapostsFIA) then {true} else {false};
private _atpostFIA = if (_site in atpostsFIA) then {true} else {false};
private _mortarpostFIA = if (_site in mortarpostsFIA) then {true} else {false};
private _hmgpostFIA = if (_site in hmgpostsFIA) then {true} else {false};
private _lightroadblockFIA = if (_site in lightroadblocksFIA) then {true} else {false};
private _supportpostsFIA = if (_site in supportpostsFIA) then {true} else {false};

_garrison = garrison getVariable [_site,[]];

_statics = garrison getVariable [(_site + "_statics"),[]];

if (_typeX == "rem") then {
	if ((count _garrison == 0) and {!(_watchpostFIA) || !(_roadblockFIA) || !(_aapostFIA) || !(_atpostFIA) || !(_lightroadblockFIA) || !(_supportpostsFIA) || !(_hmgpostFIA) || !(_mortarpostFIA)}) exitWith {
		[
			"FAIL",
			"Disband",
			parseText "This place has no garrisoned troops to remove.",
			30
		] spawn SCRT_fnc_ui_showMessage;
	};
	_costs = 0;
	_hr = 0;
	_veh = "";

	switch (true) do {
		case (_watchpostFIA): {
			_costs = 50;
			_hr = 0;
			{
				_costs = _costs + (server getVariable [_x,0]);
				_hr = _hr + 1;
			} forEach _garrison;
			_costs = round (_costs * 0.75);
		};
		case (_roadblockFIA): {
			_veh = garrison getVariable [(_site + "_statics"), []];
			_costs = 200;
			{
				_costs = _costs + ([_x] call A3A_fnc_vehiclePrice)	
			} forEach _veh;
			_hr = 0; //static gunner
			{
				_costs = _costs + (server getVariable [_x,0]);
				_hr = _hr + 1;
			} forEach _garrison;
			_costs = round (_costs * 0.75);
		};
		case (_aapostFIA): {
			_veh = garrison getVariable [(_site + "_statics"), []];
			_costs = 200;
			{
				_costs = _costs + ([_x] call A3A_fnc_vehiclePrice)	
			} forEach _veh;
			_hr = 0; //static gunner
			{
				_costs = _costs + (server getVariable [_x,0]);
				_hr = _hr + 1;
			} forEach _garrison;
			_costs = round (_costs * 0.75);
		};
		case (_atpostFIA): {
			_costs = [staticATteamPlayer] call A3A_fnc_vehiclePrice; //AT
			_hr = 0; //static gunner
			_veh = staticATteamPlayer;
			{
				_costs = _costs + (server getVariable [_x,0]);
				_hr = _hr +1;
			} forEach _garrison;
			_costs = round (_costs * 0.75);
		};
		case (_mortarpostFIA): {
			_costs = [SDKArtillery] call A3A_fnc_vehiclePrice; //Mortar
			_hr = 0; //static gunner
			_veh = SDKArtillery;
			{
				_costs = _costs + (server getVariable [_x,0]);
				_hr = _hr +1;
			} forEach _garrison;
			_costs = round (_costs * 0.75);
		};
		case (_hmgpostFIA): {
			_costs = [UKMGStatic] call A3A_fnc_vehiclePrice; //HMG
			_hr = 0; //static gunner
			_veh = UKMGStatic;
			{
				_costs = _costs + (server getVariable [_x,0]);
				_hr = _hr +1;
			} forEach _garrison;
			_costs = round (_costs * 0.75);
		};
		case (_lightroadblockFIA): {
			_costs = [vehSDKLightArmed] call A3A_fnc_vehiclePrice; //MG Car
			_hr = 0; //static gunner
			_veh = vehSDKLightArmed;
			{
				_costs = _costs + (server getVariable [_x,0]);
				_hr = _hr +1;
			} forEach _garrison;
			_costs = round (_costs * 0.75);
		};
		case (_supportpostsFIA): {
			_costs = 500 + ([vehSDKLightUnarmed] call A3A_fnc_vehiclePrice) + ([vehSDKRepair] call A3A_fnc_vehiclePrice) + ([vehSDKFuel] call A3A_fnc_vehiclePrice) + ([vehSDKAmmo] call A3A_fnc_vehiclePrice) + ([vehSDKMedical] call A3A_fnc_vehiclePrice) + ([USMGStatic] call A3A_fnc_vehiclePrice); //Mortar
			_hr = 0; //static gunner
			_veh = [vehSDKLightUnarmed,vehSDKRepair,vehSDKMedical,vehSDKFuel,vehSDKAmmo,USMGStatic];
			{
				_costs = _costs + (server getVariable [_x,0]);
				_hr = _hr +1;
			} forEach _garrison;
			_costs = round (_costs * 0.75);
		};
		default {
			{
				if (_x in [USstaticCrewTeamPlayer, UKstaticCrewTeamPlayer]) then {
					if (_outpostFIA) then {
						_costs = _costs + ([vehSDKLightArmed] call A3A_fnc_vehiclePrice)
					} else {
						_costs = _costs + ([SDKMortar] call A3A_fnc_vehiclePrice)
					};
				};
				_hr = _hr + 1;
				_costs = _costs + (server getVariable [_x,0]);
			} forEach _garrison;
		};
	};

	[_hr,_costs,_garrison] remoteExec ["A3A_fnc_resourcesFIA",2];

	
	if (_veh isEqualType []) then {
		{
			private _count = server getVariable (_x + "_count");
			_count = _count + 1;
			server setVariable [(_x + "_count"), _count, true];
		} forEach _veh;
	} else {
		if (_veh == "") then {} else {
			if (_veh in [vehSDKLightArmed, SDKArtillery]) then {
				private _count = server getVariable (_veh + "_count");
				_count = _count + 1;
				server setVariable [(_veh + "_count"), _count, true];
	    	} else {
				private _count = server getVariable (_veh + "_count");
				_count = _count + 2;
				server setVariable [(_veh + "_count"), _count, true];
    		};
    	};
	};
	
	{
	teamPlayerStoodDown = teamPlayerStoodDown + 1;
	publicVariable "teamPlayerStoodDown";
	} forEach _garrison;
	
	//JB code to return gear to arsenal
	private _allLoadouts = [];
	{
	_loadout = rebelLoadouts get _x;
	_allLoadouts pushBack _loadout;
	} forEach _garrison;

	_fullSquadGear = _allLoadouts call A3A_fnc_reorgLoadoutSquad;
 	
	{ [_x select 0 call jn_fnc_arsenal_itemType, _x select 0, _x select 1]call jn_fnc_arsenal_addItem } forEach _fullSquadGear;

	// JB code end
	
	switch (true) do {
		case (_watchpostFIA): {
			garrison setVariable [_site,nil,true];
			watchpostsFIA = watchpostsFIA - [_site]; publicVariable "watchpostsFIA";
			markersX = markersX - [_site]; publicVariable "markersX";
			deleteMarker _site;
			sidesX setVariable [_site,nil,true];
		};
		case (_roadblockFIA): {
			garrison setVariable [_site,nil,true];
			roadblocksFIA = roadblocksFIA - [_site]; publicVariable "roadblocksFIA";
			markersX = markersX - [_site]; publicVariable "markersX";
			deleteMarker _site;
			sidesX setVariable [_site,nil,true];
		};
		case (_aapostFIA): {
			garrison setVariable [_site,nil,true];
			aapostsFIA = aapostsFIA - [_site]; publicVariable "aapostsFIA";
			markersX = markersX - [_site]; publicVariable "markersX";
			deleteMarker _site;
			sidesX setVariable [_site,nil,true];
		};
		case (_atpostFIA): {
			garrison setVariable [_site,nil,true];
			atpostsFIA = atpostsFIA - [_site]; publicVariable "atpostsFIA";
			markersX = markersX - [_site]; publicVariable "markersX";
			deleteMarker _site;
			sidesX setVariable [_site,nil,true];
		};
		case (_mortarpostFIA): {
			garrison setVariable [_site,nil,true];
			mortarpostsFIA = mortarpostsFIA - [_site]; publicVariable "mortarpostsFIA";
			markersX = markersX - [_site]; publicVariable "markersX";
			deleteMarker _site;
			sidesX setVariable [_site,nil,true];
		};
		case (_hmgpostFIA): {
			garrison setVariable [_site,nil,true];
			hmgpostsFIA = hmgpostsFIA - [_site]; publicVariable "hmgpostsFIA";
			markersX = markersX - [_site]; publicVariable "markersX";
			deleteMarker _site;
			sidesX setVariable [_site,nil,true];
		};
		case (_lightroadblockFIA): {
			garrison setVariable [_site,nil,true];
			lightroadblocksFIA = lightroadblocksFIA - [_site]; publicVariable "lightroadblocksFIA";
			markersX = markersX - [_site]; publicVariable "markersX";
			deleteMarker _site;
			sidesX setVariable [_site,nil,true];
		};
		case (_supportpostsFIA): {
			garrison setVariable [_site,nil,true];
			supportpostsFIA = supportpostsFIA - [_site]; publicVariable "supportpostsFIA";
			markersX = markersX - [_site]; publicVariable "markersX";
			deleteMarker _site;
			sidesX setVariable [_site,nil,true];
		};
		default {
			garrison setVariable [_site,[],true];
			{if (_x getVariable ["markerX",""] == _site) then {deleteVehicle _x}} forEach allUnits;
		};
	};

	[_site] call A3A_fnc_mrkUpdate;

	[
		"SUCCESS",
		"Disband",
		parseText format ["Garrison removed.<br/>Recovered command points: %1%3<br/>Recovered HR: %2", _costs, _hr, currencySymbol],
		30
	] spawn SCRT_fnc_ui_showMessage;
} else {
	
	if (_site in watchpostsFIA) then {
		positionXGarr = _site;
		["Garrison", format ["Info%1",[_site] call A3A_fnc_garrisonInfo]] call A3A_fnc_customHint;
		_topUp = groupsSASRecon - _garrison;
		{
		[_x] spawn A3A_fnc_garrisonAdd;
		sleep 1;
		} forEach _topUp;
	} else {
		positionXGarr = _site;
		["Garrison", format ["Info%1",[_site] call A3A_fnc_garrisonInfo]] call A3A_fnc_customHint;
		createDialog "garrisonRecruit";
	};
};