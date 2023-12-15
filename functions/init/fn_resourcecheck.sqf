private _filename = "fn_citySupportChange";
if (!isServer) exitWith {
    [1, "Server-only function miscalled", _filename] call A3A_fnc_log;
};

while {true} do
{
	nextTick = time + 1800;
	waitUntil {sleep 15; time >= nextTick};
	if (isMultiplayer) then {waitUntil {sleep 10; isPlayer theBoss}};
	
	_NATOPoints = (({sidesX getVariable [_x,sideUnknown] == Occupants} count (seaports + airportsX + milbases)) / (count (seaports + airportsX + milbases))) * 5;
	
	aggressionOccupants = aggressionOccupants + 5 + (_NATOPoints);
	//aggressionInvaders = aggressionInvaders + 10;

	private _resAdd = 500;//0
	private _hrSDKAdd = 0;//0
	private _hrAllAdd = 2;
	private _planes = 0;
	private _vehicles = 2;
	private _civVehicles = 0;
	private _weapons = 0;
	private _magazines = 0;
	private _items = 0;
	private _popReb = 0;
	private _popGov = 0;
	private _popKilled = 0;
	private _popTotal = 0;

	private _suppBoost = 0.25 * (1 + ({sidesX getVariable [_x,sideUnknown] == teamPlayer} count seaports));

	private _governmentCitySide = if (gameMode == 4) then {Invaders} else {Occupants};
	private _governmentCityColor = if (gameMode == 4) then {colorInvaders} else {colorOccupants};
	private _governmentCityName = if (gameMode == 4) then {nameInvaders} else {nameOccupants};

	{
		private _city = _x;
		private _resAddCity = 0;
		private _hrAddCity = 0;
		private _cityData = server getVariable _city;
		_cityData params ["_numCiv", "_numVeh", "_supportGov", "_supportReb"];

		_popTotal = _popTotal + _numCiv;
		if (_city in destroyedSites) then { _popKilled = _popKilled + _numCiv; continue };

		_popReb = _popReb + (_numCiv * (_supportReb / 100));
		_popGov = _popGov + (_numCiv * (_supportGov / 100));

		private _radioTowerSide = [_city] call A3A_fnc_getSideRadioTowerInfluence;

		switch (_radioTowerSide) do
		{
			case teamPlayer: {[-1,_suppBoost,_city,false,true] spawn A3A_fnc_citySupportChange};
			case Occupants: {[1,-1,_city,false,true] spawn A3A_fnc_citySupportChange};
			case Invaders: {
				if (gameMode == 4) then {
					[1,-1,_city,false,true] spawn A3A_fnc_citySupportChange;
				} else {
					[-1,-1,_city,false,true] spawn A3A_fnc_citySupportChange;
				};
			};
		};
		
		_resAddCity = _numCiv * (_supportReb / 100);
		_hrAddCity = _numCiv * (_supportReb / 50000);

		if (sidesX getVariable [_city,sideUnknown] == _governmentCitySide) then
		{
			_resAddCity = _resAddCity / 2;
			_hrAddCity = _hrAddCity / 2;
		};
		if (_radioTowerSide != teamPlayer) then { _resAddCity = _resAddCity / 2 };

		_resAdd = _resAdd + _resAddCity;
		_hrSDKAdd = _hrSDKAdd + _hrAddCity;
		if (sidesX getVariable [_city,sideUnknown] == teamPlayer) then {
			_civVehicles = _civVehicles + ((_numCiv / 300) * (_supportReb / 100));
		};
	} forEach citiesX;

	if (_popKilled > (_popTotal / 3)) then {["destroyedSites",false,true] remoteExec ["BIS_fnc_endMission"]};

	_civVehicles = round _civVehicles;	
	
	for "_i" from 0 to _civVehicles do {
		private _civCarsCount = server getVariable (civCar + "_count");
		private _civTrucksCount = server getVariable (civTruck + "_count");
		if (_civCarsCount >= 4 && _civTrucksCount >= 4) exitWith {};
		_randomNum = random 100;
		
		if (_randomNum < 50) then {
			if (_civCarsCount < 4) then {
				_newCivCarsCount = _civCarsCount + 1;
				server setVariable [civCar + "_count", _newCivCarsCount, true]
			} else {
				_newCivTrucksCount = _civTrucksCount + 1;
				server setVariable [civTruck + "_count", _newCivTrucksCount, true]
			};
		} else {
			if (_civTrucksCount < 4) then {
				_newCivTrucksCount = _civTrucksCount + 1;
				server setVariable [civCar + "_count", _newCivTrucksCount, true]
			} else {
				_newCivCarsCount = _civCarsCount + 1;
				server setVariable [civTruck + "_count", _newCivCarsCount, true]
			};
		};
	};

	{
		if (sidesX getVariable [_x,sideUnknown] == teamPlayer) then
		{
			_resAdd = _resAdd + 2000;
			_hrAllAdd = _hrAllAdd + 8;
			_planes = _planes + 1;
			_weapons = _weapons + 50;
			_magazines = _magazines + 5000;
			_items = _items + 50;
		};
	} forEach airportsX;

	{
		if (sidesX getVariable [_x,sideUnknown] == teamPlayer) then
		{
			_resAdd = _resAdd + 2000;
			_hrAllAdd = _hrAllAdd + 8;
			_vehicles = _vehicles + 4;
			_weapons = _weapons + 50;
			_magazines = _magazines + 5000;
			_items = _items + 50;
		};
	} forEach (seaports - ["seaport_3","seaport_4","seaport_6","seaport_7","seaport_8"]);
	
	{
		if (sidesX getVariable [_x,sideUnknown] == teamPlayer) then
		{
			_resAdd = _resAdd + 1000;
			_hrAllAdd = _hrAllAdd + 4;
			_vehicles = _vehicles + 2;
			_weapons = _weapons + 25;
			_magazines = _magazines + 2500;
			_items = _items + 25;
		};
	} forEach ["seaport_3","seaport_4","seaport_6","seaport_7","seaport_8"];

	//rebel salary
    private _rebels = (call BIS_fnc_listPlayers) select {side _x == teamPlayer};
    private _rebelsCount = count _rebels;
    private _totalSalary = _resAdd / 2;

    if(_rebelsCount > 0) then {
        private _incomePerPlayer = round(_totalSalary / _rebelsCount);
        {
			private _playerMoney = round (((_x getVariable ["moneyX", 0]) + _incomePerPlayer) max 0);
			private _owner = owner _x;
            _x setVariable ["moneyX", _playerMoney, _owner];
            private _paycheckText = format [
                "<t size='0.6'>%1 earned <t color='#00FF00'>%2</t> command points</t>",
                name _x,
                _incomePerPlayer
            ];

            [petros, "income", _paycheckText] remoteExec ["A3A_fnc_commsMP", _x];
        } forEach _rebels;

        _resAdd = _resAdd - _totalSalary;
    };

    _resAdd = (round _resAdd);

	_hrSDKAdd = ceil _hrSDKAdd;
	_resAdd = ceil _resAdd;
	server setVariable ["SDKhr", _hrSDKAdd + (server getVariable "SDKhr"), true];
	server setVariable ["resourcesFIA", _resAdd + (server getVariable "resourcesFIA"), true];
	
	//Allied HR calc
	_hrAllAdd = round _hrAllAdd;
	for "_i" from 1 to _hrAllAdd do {
	private _UKhrR = (250 - (server getVariable "UKhr"))/250;
	private _SAShrR = (51 - (server getVariable "SAShr"))/51;
	private _UShrR = (251 - (server getVariable "UShr"))/251;
	private _parahrR = (101 - (server getVariable "parahr"))/101;

	private _hrToAdd = selectMax [_UKhrR,_SAShrR,_UShrR,_parahrR];
	
	switch (true) do {
	
		case (_hrToAdd == _UKhrR) : {
			if (server getVariable "UKhr" < 250) then {
				server setVariable ["UKhr", 1 + (server getVariable "UKhr"), true];
			};
		};
		case (_hrToAdd == _SAShrR) : {
			if (server getVariable "SAShr" < 50) then {
				server setVariable ["SAShr", 1 + (server getVariable "SAShr"), true];
			};
		};
		case (_hrToAdd == _UShrR) : {
			if (server getVariable "UShr" < 250) then {
				server setVariable ["UShr", 1 + (server getVariable "UShr"), true];
			};
		};
		case (_hrToAdd == _parahrR) : {
			if (server getVariable "parahr" < 100) then {
				server setVariable ["parahr", 1 + (server getVariable "parahr"), true];
			};
		};
	};
	};

	//Vehicle calc

	private _vehList = [vehSDKLightUnarmed, vehSDKLightArmed, vehSDKTruck, vehSDKTruckClosed, vehSDKRepair, vehSDKFuel, vehSDKAmmo, vehSDKMedical, vehSDKHeavyArmed, vehSDKAPCUK1, vehSDKAPCUS, vehSDKAPCUK2, vehSDKAT, vehSDKTankChur, vehSDKTankCroc, vehSDKTankHow, vehSDKTankUKM4, vehSDKTankUSM5, vehSDKTankUSM4, UKMGStatic, USMGStatic, staticATteamPlayer, staticAAteamPlayer, SDKMortar, SDKArtillery, vehInfSDKBoat, vehSDKBoat, vehSDKAttackBoat];
	private _planesList = [vehSDKPlaneUK2, vehSDKPlaneUK3, vehSDKPlaneUS1, vehSDKPlaneUS2, vehUKPayloadPlane, vehUSPayloadPlane, vehSDKTransPlaneUK, vehSDKTransPlaneUS];
	private _actual = 0;
	private _vehMax = 0;
	private _allWeights = [];

	for "_i" from 1 to _vehicles do {
	{
	if (_x in [vehSDKAttackBoat, vehSDKBoat, vehSDKTankChur, vehSDKTankUKM4, SDKArtillery, vehSDKTankCroc, vehSDKTankHow]) then {_vehMax = 2};
	if (_x in [vehInfSDKBoat, vehSDKHeavyArmed, vehSDKAPCUK1, vehSDKAPCUK2, vehSDKAPCUS, vehSDKTankUSM4, vehSDKTankUSM5, SDKMortar, vehSDKRepair, vehSDKFuel, vehSDKAmmo, vehSDKMedical, vehSDKAT]) then {_vehMax = 4};
	if (_x in [staticATteamPlayer, staticAAteamPlayer]) then {_vehMax = 6};
	if (_x in [vehSDKLightArmed, vehSDKTruck, vehSDKTruckClosed]) then {_vehMax = 8};
	if (_x in [UKMGStatic, USMGStatic]) then {_vehMax = 12};
	if (_x == vehSDKLightUnarmed) then {_vehMax = 16};

	_actual = server getVariable (_x + "_count");

	_weight = (_vehMax + 1) - _actual;

	if (_weight <= 1) then {_weight = 0.01};

	_allWeights pushBack _weight;

	} forEach _vehList;

	_selectedVeh = _vehList selectRandomWeighted _allWeights;
	
	_currentNum = server getVariable (_selectedVeh + "_count");
	_newNum = if (_currentNum < _vehMax) then {_currentNum + 1} else {_currentNum};

	server setVariable [_selectedVeh + "_count", _newNum, true];
	};

	//Plane calc
	for "_i" from 1 to _planes do {
	{
	if (_x in [vehUKPayloadPlane, vehUSPayloadPlane]) then {_vehMax = 1};
	if (_x in [vehSDKPlaneUK3,vehSDKPlaneUS2,vehSDKTransPlaneUK,vehSDKTransPlaneUS]) then {_vehMax = 2};
	if (_x in [vehSDKPlaneUS1, vehSDKPlaneUK2]) then {_vehMax = 4};

	_actual = server getVariable (_x + "_count");

	_weight = (_vehMax + 1) - _actual;

	if (_weight <= 1) then {_weight = 0.01};

	_allWeights pushBack _weight;

	} forEach _planesList;

	_selectedVeh = _planesList selectRandomWeighted _allWeights;

	_currentNum = server getVariable (_selectedVeh + "_count");
	_newNum = if (_currentNum < _vehMax) then {_currentNum + 1} else {_currentNum};

	server setVariable [_selectedVeh + "_count", _newNum, true];
	};
	//
	
	//Weapons, mags and items calc
	private _resupplyGear = {
		params ["_gearType", "_gearNumber", "_divider"];	
		_endList = [];
		{
		_max = (_x select 1) * 5;
		_number = [jna_dataList select (_x select 0 call jn_fnc_arsenal_itemType), _x select 0] call jn_fnc_arsenal_itemCount; 
		_ratio = _number/_max;
		_difference = _max - _number;
		_endList append [[_ratio, _difference, (_x select 0)]];
		} forEach _gearType;
	
		_endList sort true;
		private _maxAllocation = _gearNumber/_divider;
	
		while {_gearNumber > 1} do {	
			{
				_difference = _x select 1;
				_obj = _x select 2;
				_allocation = round (_difference/(_divider*2));
				if (_allocation > _maxAllocation) then {_allocation = _maxAllocation};
				_gearNumber = _gearNumber - _allocation;
				if (_gearNumber < 1) exitWith {_allocation = _allocation + _gearNumber; [_obj call jn_fnc_arsenal_itemType, _obj, _allocation] call jn_fnc_arsenal_addItem};
				[_obj call jn_fnc_arsenal_itemType, _obj, _allocation] call jn_fnc_arsenal_addItem;
			} forEach _endList;
		};
	};
	
	[WW2Weapons, _weapons, 5] call _resupplyGear;
	[WW2Magazines, _magazines, 10] call _resupplyGear;
	[WW2Items, _items, 5] call _resupplyGear;
	//
	
	bombRuns = bombRuns + 0.25 * ({sidesX getVariable [_x,sideUnknown] == teamPlayer} count airportsX);

	if (bombRuns > 5) then {
		bombRuns = 5;
	};

	publicVariable "bombRuns";

	if(tierWar > 2) then {
        supportPoints = supportPoints + 1;
    };

    if(supportPoints > 5) then {
        supportPoints = 5;
    };

	publicVariable "supportPoints";

	_hrAdd = _hrSDKAdd + _hrAllAdd;

	private _textX = format ["<t size='0.6' color='#C1C0BB'>Logistics Update.<br/> <t size='0.5' color='#C1C0BB'><br/>Manpower: +%1<br/>Command Points: +%2%3", _hrAdd, _resAdd, currencySymbol];
	private _textArsenal = [] call A3A_fnc_arsenalManage;
	if (_textArsenal != "") then {_textX = format ["%1<br/>Arsenal Updated<br/><br/>%2", _textX, _textArsenal]};
	[petros, "taxRep", _textX] remoteExec ["A3A_fnc_commsMP", [teamPlayer, civilian]];


	[] call A3A_fnc_FIAradio;
	[] call A3A_fnc_economicsAI;
    [] call A3A_fnc_cleanConvoyMarker;

	if (isMultiplayer) then
	{
		[] spawn A3A_fnc_promotePlayer;
		[] call A3A_fnc_assignBossIfNone;
		difficultyCoef = floor ((({side group _x == teamPlayer} count (call A3A_fnc_playableUnits)) - ({side group _x != teamPlayer} count (call A3A_fnc_playableUnits))) / 5);
		publicVariable "difficultyCoef";
	};

	//Removed from scheduler for now, as it errors on Headless Clients.
	//[[],"A3A_fnc_reinforcementsAI"] call A3A_fnc_scheduler;
	[] spawn A3A_fnc_reinforcementsAI;
	{
	_veh = _x;
	if ((_veh isKindOf "StaticWeapon") and ({isPlayer _x} count crew _veh == 0) and (alive _veh)) then
		{
		_veh setDamage 0;
		[_veh,1] remoteExec ["setVehicleAmmo",_veh];
		};
	} forEach vehicles;
	sleep 3;
    _numWreckedAntennas = count antennasDead;
	//Probability of spawning a mission in.
    _shouldSpawnRepairThisTick = round(random 100) < 20;
    if ((_numWreckedAntennas > 0) && _shouldSpawnRepairThisTick && !("REP" in A3A_activeTasks)) then
		{
		_potentials = [];
		{
		_markerX = [markersX, _x] call BIS_fnc_nearestPosition;
		if ((sidesX getVariable [_markerX,sideUnknown] == _governmentCitySide) and (spawner getVariable _markerX == 2)) exitWith
			{
			_potentials pushBack [_markerX,_x];
			};
		} forEach antennasDead;
		if (count _potentials > 0) then
			{
			_potential = selectRandom _potentials;
			[[_potential select 0,_potential select 1],"A3A_fnc_REP_Antenna"] call A3A_fnc_scheduler;
			};
		}
	else
		{
		_changingX = false;
		{
		_chance = 5;
		if ((_x in resourcesX) and (sidesX getVariable [_x,sideUnknown] == Invaders)) then {_chance = 20};
		if (random 100 < _chance) then
			{
			_changingX = true;
			destroyedSites = destroyedSites - [_x];
			_nameX = [_x] call A3A_fnc_localizar;
			["TaskSucceeded", ["", format ["%1 Rebuilt",_nameX]]] remoteExec ["BIS_fnc_showNotification",[teamPlayer,civilian]];
			sleep 2;
			};
		} forEach (destroyedSites - citiesX) select {sidesX getVariable [_x,sideUnknown] != teamPlayer};
		if (_changingX) then {publicVariable "destroyedSites"};
		};
	
	//city rebellion mission
	_potCities = townsX select {(sidesX getVariable [_x,sideUnknown] != teamPlayer) && ([_x] call A3A_fnc_isFrontline) && (spawner getVariable _x == 2)};

	if (count _potCities > 0 && (random 100 < 20) && rebelCity == "") then {_rebelCity = selectRandom _potCities; [_rebelCity] spawn A3A_fnc_cityRebel};

	if (isDedicated) then
		{
		{
		if (side _x == civilian) then
			{
			_var = _x getVariable "statusAct";
			if (isNil "_var") then
				{
				if (local _x) then
					{
					if ((_x getVariable "unitType") in arrayCivs) then
						{
						if (vehicle _x == _x) then
							{
							if (primaryWeapon _x == "") then
								{
								_groupX = group _x;
								deleteVehicle _x;
								if ({alive _x} count units _groupX == 0) then {deleteGroup _groupX};
								};
							};
						};
					};
				};
			};
		} forEach allUnits;
		};

	sleep 4;
};
