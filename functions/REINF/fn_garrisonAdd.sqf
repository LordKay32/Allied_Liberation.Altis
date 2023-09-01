private ["_hr","_resourcesFIA","_typeX","_costs","_markerX","_positionX"];

_resourcesFIA = server getVariable "resourcesFIA";

_typeX = _this select 0;

private _costs = server getVariable _typeX;

switch (true) do {
	
	case (_typeX in UKTroops) : {
	_hr = server getVariable "UKhr";
	};

	case (_typeX in SASTroops) : {
	_hr = server getVariable "SAShr";
	};

	case (_typeX in USTroops) : {
	_hr = server getVariable "UShr";
	};
	
	case (_typeX in paraTroops) : {
	_hr = server getVariable "parahr";
	};
	
	case (_typeX in SDKTroops) : {
	_hr = server getVariable "SDKhr";
	};
};

if (_hr < 1) exitWith {
	["Garrison", "You do not have enough HR to garrison this base.", "FAIL"] call SCRT_fnc_ui_showDynamicTextMessage;
};

if (_costs > _resourcesFIA) exitWith {
	["Garrison",  format ["You do not have enough command points for this kind of unit (%1%2 needed).", _costs, currencySymbol], "FAIL"] call SCRT_fnc_ui_showDynamicTextMessage;
};

_markerX = positionXGarr;

if (_typeX in [USstaticCrewTeamPlayer, UKstaticCrewTeamPlayer] && _markerX in (watchpostsFIA + roadblocksFIA + aapostsFIA + atpostsFIA + mortarpostsFIA + hmgpostsFIA + lightroadblocksFIA + supportpostsFIA)) exitWith {
	["Garrison", "You cannot add mortars to a Roadblock, Watchpost, AA, AT, Mortar, Artillery, HMG emplacement garrisons.", "FAIL"] call SCRT_fnc_ui_showDynamicTextMessage;
};

_positionX = getMarkerPos _markerX;

if (surfaceIsWater _positionX) exitWith {
	["Garrison", "This Garrison is still updating, please try again in a few seconds.", "FAIL"] call SCRT_fnc_ui_showDynamicTextMessage;
};

if ([_positionX, 500] call A3A_fnc_enemyNearCheck) exitWith {
	["Garrison", "You cannot recruit with enemies near the zone.", "FAIL"] call SCRT_fnc_ui_showDynamicTextMessage;
};

// JB Code for limited gear
private ["_loadout","_fullUnitGear","_cannotAllocateList","_arsenalIndex"];
_loadout = rebelLoadouts get _typeX;

_fullUnitGear = _loadout call A3A_fnc_reorgLoadoutUnit;

_cannotAllocateList = [];
{
	_arsenalIndex = (_x select 0) call jn_fnc_arsenal_itemType;
	if (_arsenalIndex >= 0) then {
		private _number = [jna_dataList select (_arsenalIndex), _x select 0] call jn_fnc_arsenal_itemCount; 
		if (_number < ((2 * ((_x select 1) + 1))) && (_number != -1)) then { _cannotAllocateList pushBack (_x select 0) };
	};
} forEach _fullUnitGear;

if (count _cannotAllocateList > 0) exitWith {
	
	private _weaps = [];
	private _mags = [];
	private _strings = [];
	
	{
		_weaps = getText (configFile >> "CfgWeapons" >> _x >> "displayName");
		_strings pushBack _weaps;
		_mags = getText (configFile >> "CfgMagazines" >> _x >> "displayName");
		_strings pushBack _mags;
	} forEach _cannotAllocateList;
	
	_strings = _strings - [""];
	
	["Garrison", format ["The following gear has run too low for you to recruit this unit: <t color='#ffff00'>%1", _strings], "FAIL"] call SCRT_fnc_ui_showDynamicTextMessage;
};

{ 
	_arsenalIndex = (_x select 0) call jn_fnc_arsenal_itemType;
	if (_arsenalIndex >= 0) then {
		[_x select 0 call jn_fnc_arsenal_itemType, _x select 0, _x select 1] call jn_fnc_arsenal_removeItem ;
	};
} forEach _fullUnitGear;
//

[-1,-_costs, _typeX] remoteExec ["A3A_fnc_resourcesFIA",2];
teamPlayerDeployed = teamPlayerDeployed + 1;
publicVariable "teamPlayerDeployed";

private _countX = count (garrison getVariable [_markerX,[]]);
[_typeX,teamPlayer,_markerX,1] remoteExec ["A3A_fnc_garrisonUpdate",2];
waitUntil {(_countX < count (garrison getVariable [_markerX, []])) or (sidesX getVariable [_markerX,sideUnknown] != teamPlayer)};

if (sidesX getVariable [_markerX,sideUnknown] == teamPlayer) then {
	private _garrisonInfo = format ["Soldier has been recruited.%1", [_markerX] call A3A_fnc_garrisonInfo];
	["Garrison", _garrisonInfo] call SCRT_fnc_ui_showDynamicTextMessage;

	if (_markerX in (mortarpostsFIA + supportpostsFIA + watchpostsFIA)) exitWith {
		[_markerX,_typeX] remoteExec ["A3A_fnc_createSDKGarrisonsTemp",2];
	};

	if (spawner getVariable _markerX != 2) then {
		[_markerX,_typeX] remoteExec ["A3A_fnc_createSDKGarrisonsTemp",2];
	};

};
