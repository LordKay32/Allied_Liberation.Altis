/*
 * Name:	fn_logistics
 * Date:	15/05/2023
 * Version: 1.0
 * Author:  JB
 *
 * Description:
 * Shows logistics
 *
 * Parameter(s):
 * _PARAM1 (TYPE): DESCRIPTION.
 * _PARAM2 (TYPE): DESCRIPTION.
 *
 * Returns:
 * %RETURNS%
 */


params ["_PARAM1", "_PARAM2"];
private ["_VAR1", "_VAR2"];

	private _resAdd = 1000;//0
	private _hrSDKAdd = 0;//0
	private _hrAllAdd = 4;
	private _planes = 0;
	private _vehicles = 2;
	private _weapons = 10;
	private _magazines = 500;
	private _items = 25;
	private _popReb = 0;
	private _popGov = 0;
	private _popKilled = 0;
	private _popTotal = 0;

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
		
		_resAddCity = _numCiv * (_supportReb / 100);
		_hrAddCity = _numCiv * (_supportReb / 100000);

		if (sidesX getVariable [_city,sideUnknown] == _governmentCitySide) then
		{
			_resAddCity = _resAddCity / 2;
			_hrAddCity = _hrAddCity / 2;
		};
		if (_radioTowerSide != teamPlayer) then { _resAddCity = _resAddCity / 2 };

		_resAdd = _resAdd + _resAddCity;
		_hrSDKAdd = _hrSDKAdd + _hrAddCity;

	} forEach citiesX;

	if (_popKilled > (_popTotal / 3)) then {["destroyedSites",false,true] remoteExec ["BIS_fnc_endMission"]};

	if (_popReb > _popGov && {((airportsX + milbases + outposts + seaports) findIf {sidesX getVariable [_x, sideUnknown] != teamPlayer} == -1)}) then {
		["end1",true,true,true,true] remoteExec ["BIS_fnc_endMission",0];
	};

	{
		if (sidesX getVariable [_x,sideUnknown] == teamPlayer) then
		{
			_resAdd = _resAdd + 2000;
			_hrAllAdd = _hrAllAdd + 8;
			_planes = _planes + 1;
			_weapons = _weapons + 20;
			_magazines = _magazines + 1000;
			_items = _items + 50;
		};
	} forEach airportsX;

	{
		if (sidesX getVariable [_x,sideUnknown] == teamPlayer) then
		{
			_resAdd = _resAdd + 2000;
			_hrAllAdd = _hrAllAdd + 8;
			_vehicles = _vehicles + 4;
			_weapons = _weapons + 20;
			_magazines = _magazines + 1000;
			_items = _items + 50;
		};
	} forEach (seaports - ["seaport_3","seaport_4","seaport_6","seaport_7","seaport_8"]);
	
	{
		if (sidesX getVariable [_x,sideUnknown] == teamPlayer) then
		{
			_resAdd = _resAdd + 1000;
			_hrAllAdd = _hrAllAdd + 4;
			_vehicles = _vehicles + 2;
			_weapons = _weapons + 10;
			_magazines = _magazines + 500;
			_items = _items + 25;
		};
	} forEach ["seaport_3","seaport_4","seaport_6","seaport_7","seaport_8"];

	//rebel salary
    private _rebels = (call BIS_fnc_listPlayers) select {side _x == teamPlayer};
    private _rebelsCount = count _rebels;
    private _totalSalary = _resAdd / 2;

    private _incomePerPlayer = round(_totalSalary / _rebelsCount);

    _resAdd = _resAdd - _totalSalary;

    _resAdd = (round _resAdd);

	_hrSDKAdd = ceil _hrSDKAdd;
	_resAdd = ceil _resAdd;

	_nextTick = numberToDate [date select 0, nextTick]; //converts datenumber back to date array so that time formats correctly
	private _displayTime = [_nextTick] call A3A_fnc_dateToTimeString; //Converts the time portion of the date array to a string for clarity in hints
	
	private _display = findDisplay 60000;
	if !(str (_display) == "no display") then {
    	private _title = _display displayCtrl 3106;
    	_title ctrlSetText format ["Next Tick: %1",_displayTime];
	};
	
	private _display = findDisplay 60000;
	if !(str (_display) == "no display") then {
    	private _title = _display displayCtrl 3107;
    	_title ctrlSetText format ["Allied CP: %1",_resAdd];
	};
	
	private _display = findDisplay 60000;
	if !(str (_display) == "no display") then {
    	private _title = _display displayCtrl 3108;
    	_title ctrlSetText format ["Player CP: %1",_incomePerPlayer];
	};
	
	private _display = findDisplay 60000;
	if !(str (_display) == "no display") then {
    	private _title = _display displayCtrl 3109;
    	_title ctrlSetText format ["Allied HR: %1",_hrAllAdd];
	};
	
	private _display = findDisplay 60000;
	if !(str (_display) == "no display") then {
    	private _title = _display displayCtrl 3110;
    	_title ctrlSetText format ["Partizan HR: %1",_hrSDKAdd];
	};
	
	private _display = findDisplay 60000;
	if !(str (_display) == "no display") then {
    	private _title = _display displayCtrl 3111;
    	_title ctrlSetText format ["Vehicles: %1",_vehicles];
	};
	
	private _display = findDisplay 60000;
	if !(str (_display) == "no display") then {
    	private _title = _display displayCtrl 3112;
    	_title ctrlSetText format ["Aircraft: %1",_planes];
	};
	
	private _display = findDisplay 60000;
	if !(str (_display) == "no display") then {
    	private _title = _display displayCtrl 3113;
    	_title ctrlSetText format ["Weapons: %1",_weapons];
	};
	
	private _display = findDisplay 60000;
	if !(str (_display) == "no display") then {
    	private _title = _display displayCtrl 3114;
    	_title ctrlSetText format ["Magazines: %1",_magazines];
	};
	
	private _display = findDisplay 60000;
	if !(str (_display) == "no display") then {
    	private _title = _display displayCtrl 3115;
    	_title ctrlSetText format ["Items: %1",_items];
	};