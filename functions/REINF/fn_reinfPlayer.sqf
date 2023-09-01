params ["_typeUnit"];

private ["_hr"];

if !(player call A3A_fnc_isMember) exitWith {["AI Recruitment", "Only Server Members can recruit AI units."] call A3A_fnc_customHint;};

if (recruitCooldown > time) exitWith {["AI Recruitment", format ["You need to wait %1 seconds to be able to recruit units again.",round (recruitCooldown - time)]] call A3A_fnc_customHint;};

if (player != player getVariable ["owner",player]) exitWith {["AI Recruitment", "You cannot buy units while you are controlling AI."] call A3A_fnc_customHint;};

if ([player,300] call A3A_fnc_enemyNearCheck) exitWith {["AI Recruitment", "You cannot Recruit Units with enemies nearby."] call A3A_fnc_customHint;};

if (player != leader group player) exitWith {["AI Recruitment", "You cannot recruit units as you are not your group leader."] call A3A_fnc_customHint;};

switch (true) do {
	
	case (_typeUnit in UKTroops) : {
	_hr = server getVariable "UKhr";
	};

	case (_typeUnit in SASTroops) : {
	_hr = server getVariable "SAShr";
	};

	case (_typeUnit in USTroops) : {
	_hr = server getVariable "UShr";
	};
	
	case (_typeUnit in paraTroops) : {
	_hr = server getVariable "parahr";
	};
	
	case (_typeUnit in SDKTroops) : {
	_hr = server getVariable "SDKhr";
	};
};

if (_hr < 1) exitWith {["AI Recruitment", "You do not have enough HR for this request."] call A3A_fnc_customHint;};
private _costs = server getVariable _typeUnit;
private _resourcesFIA = player getVariable ["moneyX", 0];

if (_costs > _resourcesFIA) exitWith {["AI Recruitment", format ["You do not have enough command points for this kind of unit (%1%2 needed).", _costs, currencySymbol]] call A3A_fnc_customHint;};

if ((count units group player) + (count units stragglers) > 9) exitWith {["AI Recruitment", "Your squad is full or you have too many scattered units with no radio contact."] call A3A_fnc_customHint;};

// JB Code for limited gear
private "_unit";

_loadout = rebelLoadouts get _typeUnit;

_fullUnitGear = _loadout call A3A_fnc_reorgLoadoutUnit;

_emptyList = [];
{
private "_number";
_number = [jna_dataList select (_x select 0 call jn_fnc_arsenal_itemType), _x select 0]call jn_fnc_arsenal_itemCount; 
if ((_number <= (_x select 1)) && !(_number == -1)) then { _emptyList pushBack (_x select 0) }
} forEach _fullUnitGear;
	
if (count _emptyList > 0) exitWith {
		
	equipUnit = false;
		
	private _weaps = [];
	private _mags = [];
	private _strings = [];
		
	{
	_weaps = getText (configFile >> "CfgWeapons" >> _x >> "displayName");
	_strings pushBack _weaps;
	_mags = getText (configFile >> "CfgMagazines" >> _x >> "displayName");
	_strings pushBack _mags;
	} forEach _emptyList;
		
	_strings = _strings - [""];

	titleText [format["<t color='#ff0000' size='2'>Recruit Squad<br/><t color='#ffffff' size='1.5'>The following gear has run too low for you to recruit this unit: <t color='#ffff00' size='1.5'>%1", _strings], "PLAIN DOWN", 1, true, true];
};

private _unit = [group player, _typeUnit, position player, [], 0, "NONE"] call A3A_fnc_createUnit;
{ [_x select 0 call jn_fnc_arsenal_itemType, _x select 0, _x select 1]call jn_fnc_arsenal_removeItem } forEach _fullUnitGear;

if (!isMultiPlayer) then {
	_nul = [-1, - _costs, _typeUnit] remoteExec ["A3A_fnc_resourcesFIA",2];
} else {
	_nul = [-1, 0, _typeUnit] remoteExec ["A3A_fnc_resourcesFIA",2];
	[- _costs] call A3A_fnc_resourcesPlayer;
	["AI Recruitment", "Soldier Recruited.<br/><br/>Remember: if you use the group menu to switch groups you will lose control of your recruited AI."] call A3A_fnc_customHint;
};

[_unit] call A3A_fnc_FIAinit;
_unit disableAI "AUTOCOMBAT";
teamPlayerDeployed = teamPlayerDeployed + 1;
publicVariable "teamPlayerDeployed";

private _name = name _unit;

//Map markers
[_unit, _name] spawn {
	params ["_unit", "_name"];
	while {alive _unit} do {
		waitUntil {sleep 0.5; visibleMap || {visibleGPS || {isMenuOpen}}};
		while {(visibleMap || {visibleGPS || {isMenuOpen}})} do {
			private _unitDir = getDir _unit;
			private _unitMarker = createMarkerLocal [format["unitMarker_%1", random 1000], position _unit];
			if (_unit getVariable ["incapacitated",false]) then {_unitMarker setMarkerColorLocal "colorRed"; _unitMarker setMarkerTypeLocal "plp_icon_cross"; _unitMarker setMarkerSizeLocal [0.5, 0.5]} else {_unitMarker setMarkerColorLocal "colorGUER"; _unitMarker setMarkerTypeLocal "mil_triangle"; _unitMarker setMarkerDirLocal _unitDir; _unitMarker setMarkerSizeLocal [0.5, 1];};
			if (isPlayer _unit) then {_unitMarker setMarkerTextLocal format ["%1 (%2)", _name, name _unit]} else {_unitMarker setMarkerTextLocal format ["%1", name _unit]};
			if (group _unit == stragglers || ((units group _unit) findIf {_x == player} == -1) || (player getVariable ["incapacitated", false])) then {_unitMarker setMarkerAlphaLocal 0} else {_unitMarker setMarkerAlphaLocal 1};
			sleep 0.5;
			deleteMarkerLocal _unitMarker;
		};
	};
};


sleep 1;
petros directSay "SentGenReinforcementsArrived";
