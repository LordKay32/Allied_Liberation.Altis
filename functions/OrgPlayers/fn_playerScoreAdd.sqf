if ((side player == Occupants) or (side player == Invaders)) exitWith {};
private ["_pointsX","_playerX","_pointsXJ","_moneyJ"];
_pointsX = _this select 0;
_playerX = _this select 1;

if (!isPlayer _playerX) exitWith {};

_playerX = _playerX getVariable ["owner",_playerX];
if (isMultiplayer) exitWith {
	_pointsXJ = _playerX getVariable ["score",0];
	_moneyJ = _playerX getVariable ["moneyX",0];
	if (_pointsX > 0) then {
		_moneyJ = _moneyJ + (_pointsX * 10);
		_playerX setVariable ["moneyX",_moneyJ,true];
		if (_pointsX > 1) then {
			_textX = format ["<br/><br/><br/><br/><br/><br/>Money <t color='#00FF00'>+%1%2</t>", _pointsX*10, currencySymbol];
			[petros,"income",_textX] remoteExec ["A3A_fnc_commsMP",_playerX];
		};
	};
	_pointsX = (_pointsX/5) + _pointsXJ;
	_playerX setVariable ["score",_pointsX,true];
};

if (_pointsX > 0) then {
	if (_pointsX != 1) then {[0,(_pointsX * 5),0] remoteExec ["A3A_fnc_resourcesFIA",2]} else {[0,20-(tierWar * 2),0] remoteExec ["A3A_fnc_resourcesFIA",2]};
};
