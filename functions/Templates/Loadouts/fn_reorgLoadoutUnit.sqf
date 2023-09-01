/*
 * Name:	fn_reorgLoadoutUnit
 * Date:	12/09/2022
 * Version: 1.0
 * Author:  JB
 *
 * Description:
 * converts loadout to usable array
 *
 * Parameter(s):
 * _PARAM1 (TYPE): DESCRIPTION.
 * _PARAM2 (TYPE): DESCRIPTION.
 *
 * Returns:
 * %RETURNS%
 */

	private ["_loadout", "_primary", "_secondary", "_handgun", "_uniform", "_backpack", "_headgear", "_facewear", "_binocular", "_items"];

	_loadout = _this;
	
	_primary = _loadout select 0;
	_secondary = _loadout select 1;
	_handgun = _loadout select 2;
	_uniform = _loadout select 3;
	_vest = _loadout select 4;
	_backpack =_loadout select 5;
	_headgear = _loadout select 6;
	_facewear = _loadout select 7;
	_binocular = _loadout select 8;
	_items = _loadout select 9;
	
	_loadoutArray = _primary + _secondary + _handgun + _binocular;
	_loadoutArray append _items;
	_loadoutArray pushBack _headgear;
	_loadoutArray pushBack _facewear;
	if !(count _uniform == 0) then { _loadoutArray pushBack (_uniform select 0); _loadoutArray append (_uniform select 1) };
	if !(count _vest == 0) then { _loadoutArray pushBack (_vest select 0); _loadoutArray append (_vest select 1) };
	if !(count _backpack == 0) then { _loadoutArray pushBack (_backpack select 0); _loadoutArray append (_backpack select 1) };
	
	while { !(_loadoutArray find [] == -1) } do { 
		_emptyElement = _loadoutArray find [];
		_loadoutArray deleteAt _emptyElement	
		};
	
	_loadoutArray = _loadoutArray - [""];
	
	_singleArray = [];
	_doubleArray = [];
	_tripleArray = [];

	{
	if (count _x == 2) then { _doubleArray pushBack _x };
	if (count _x == 3) then { _tripleArray pushBack _x }
	} forEach _loadoutArray;
	
	_singleArray = _loadoutArray - _doubleArray - _tripleArray;


//single code

_singleCons = _singleArray call BIS_fnc_consolidateArray;


//treble code

_tripleCons = [];	
	{
	_tripleCons append [[(_x select 0),(_x select 1) * (_x select 2)]]
	} foreach _tripleArray;

//consolidate all

_cons = _singleCons + _doubleArray + _tripleCons;


_fullUnitGear = [];   
 	{ 
 	_fullUnitGear = [_fullUnitGear, (_x select 0),(_x select 1)] call BIS_fnc_addToPairs 
 	} foreach _Cons;
 	
 	_fullUnitGear;

