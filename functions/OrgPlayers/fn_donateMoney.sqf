private ["_resourcesPlayer","_pointsXJ","_target"];
_resourcesPlayer = player getVariable "moneyX";
if (_resourcesPlayer < 100) exitWith {["Donate CP", format ["You have less than 100%1 to donate.", currencySymbol]] call A3A_fnc_customHint;};

if (count _this == 0) exitWith {
	[0,100,0] remoteExec ["A3A_fnc_resourcesFIA",2];
	_pointsXJ = (player getVariable "score") + 1;
	player setVariable ["score",_pointsXJ,true];
	[-100] call A3A_fnc_resourcesPlayer;
	["Donate CP", format ["You have donated 100%1 to the command points pool.", currencySymbol]] call A3A_fnc_customHint;
};
_target = cursortarget;

if (!isPlayer _target) exitWith {["Donate CP","You must be looking at a player in order to give him command points."] call A3A_fnc_customHint;};

[-100] call A3A_fnc_resourcesPlayer;
[100] remoteExec ["A3A_fnc_resourcesPlayer", _target];
["Donate CP", format ["You have donated 100 %2 to %1.", name _target, currencySymbol]] call A3A_fnc_customHint;
