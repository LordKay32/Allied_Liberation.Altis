/*
 * Name:	fn_reorgLoadoutSquad
 * Date:	12/09/2022
 * Version: 1.0
 * Author:  JB
 *
 * Description:
 * converts loadout into usable array
 *
 * Parameter(s):
 * _PARAM1 (TYPE): DESCRIPTION.
 * _PARAM2 (TYPE): DESCRIPTION.
 *
 * Returns:
 * %RETURNS%
 */



	private ["_squadArray", "_loadout", "_primary", "_secondary", "_handgun", "_uniform", "_backpack", "_headgear", "_facewear", "_binocular", "_items"];


	_squadArray = _this;
	
	private _allSingle = []; 
	private _allDouble = [];
	private _allTriple = [];

{ 
	_loadout = _x; 
	
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
	
	_allSingle append _singleArray; 
	_allDouble append _doubleArray;
	_allTriple append _tripleArray;	
	
} forEach _squadArray;

//single code

_allSingleCons = _allSingle call BIS_fnc_consolidateArray;


//treble code

_allTripleCons = [];	
	{
	_allTripleCons append [[(_x select 0),(_x select 1) * (_x select 2)]]
	} foreach _allTriple;

//consolidate all

_allCons = _allSingleCons + _allDouble + _allTripleCons;

_fullSquadGear = [];   
 	{ 
 	_fullSquadGear = [_fullSquadGear, (_x select 0),(_x select 1)] call BIS_fnc_addToPairs 
 	} foreach _allCons;
 	
 	_fullSquadGear;

