private ["_resourcesPlayer","_pointsXJ","_target","_selectedPlayer"];
_resourcesPlayer = player getVariable "moneyX";
if (_resourcesPlayer < 500) exitWith {["Donate CP", format ["You have less than 500%1 to donate.", currencySymbol]] call A3A_fnc_customHint;};

if (count _this == 0) exitWith {
	[0,500,0] remoteExec ["A3A_fnc_resourcesFIA",2];
	_pointsXJ = (player getVariable "score") + 1;
	player setVariable ["score",_pointsXJ,true];
	[-500] call A3A_fnc_resourcesPlayer;
	["Donate CP", format ["You have donated 100%1 to the command points pool.", currencySymbol]] call A3A_fnc_customHint;
};

showCommandingMenu "";

if (!visibleMap) then {openMap true};
positionTel = [];

onMapSingleClick "positionTel = _pos";

["Donate CP", "Select the player to transfer CP to."] call A3A_fnc_customHint;

waitUntil {sleep 0.5; (count positionTel > 0) or (not visiblemap)};
onMapSingleClick "";

if (!visibleMap) exitWith {};

_positionTel = positionTel;

_nearPlayers = [50, _positionTel, teamPlayer] call SCRT_fnc_common_getNearPlayers;

if (player in _nearPlayers) then {_nearPlayers = _nearPlayers - [player]};

if (count _nearPlayers == 0) exitWith {["Donate CP", "You must click near a player unit."] call A3A_fnc_customHint;};

if (count _nearPlayers > 1) then {
	{
	_distance = _x distance _positionTel;
	_distances pushBack _distance;
	} forEach _nearPlayers;
	_closestDistance = selectMin _distances;
	_index = _distances find _closestDistance;
	_selectedPlayer = _nearPlayers select _index;
} else {
	_selectedPlayer = _nearPlayers select 0;
};

if (visibleMap) then {openMap false};

_name = name _selectedPlayer;
if (lifeState _selectedPlayer == "INCAPACITATED") exitWith {[format ["Donate CP", "%1 is incapacitated.", _name]] call A3A_fnc_customHint;};

nameSelectedPlayer = _name;
createDialog "moneyTransferQuery";
sleep 1;
disableSerialization;
private _display = findDisplay 100;

if (str (_display) != "no display") then {
	private _ChildControl = _display displayCtrl 104;
	_ChildControl  ctrlSetTooltip format ["Donate 500CP to %1.", _name];
	_ChildControl = _display displayCtrl 105;
	_ChildControl  ctrlSetTooltip "Cancel donation";
};

while {true} do {
	_resourcesPlayer = player getVariable "moneyX";
	if (_resourcesPlayer < 500) exitWith {["Donate CP", format ["You have less than 500%1 to donate.", currencySymbol]] call A3A_fnc_customHint; nameSelectedPlayer = nil; closeDialog 0};

	waitUntil {(!dialog) or (!isNil "moneyTransferQuery")};
	if (!dialog) then {moneyTransferQuery = false};
	if !(moneyTransferQuery) exitWith {["Donate CP", "Transfer finished."] call A3A_fnc_customHint; moneyTransferQuery = nil; nameSelectedPlayer = nil};

	moneyTransferQuery = nil;

	[-500] call A3A_fnc_resourcesPlayer;
	[500] remoteExec ["A3A_fnc_resourcesPlayer", _selectedPlayer];
	["Donate CP", format ["You have donated 500 %2 to %1.", name _selectedPlayer, currencySymbol]] call A3A_fnc_customHint;
};

