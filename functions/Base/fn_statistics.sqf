if (!hasInterface) exitWith {};
private ["_textX","_display","_setText"];
disableSerialization;
if (isNull (uiNameSpace getVariable "H8erHUD")) exitWith {};
_display = uiNameSpace getVariable "H8erHUD";
if (isNil "_display") exitWith {};
waitUntil {sleep 0.5;!(isNil "theBoss")};
_setText = _display displayCtrl 1001;
_setText ctrlSetBackgroundColor [0,0,0,0];

private _player = player getVariable ["owner",player];		// different, if remote-controlling
private _ucovertxt = if (_player getVariable ["militaryUndercover",false]) then {
	["Off", "<t color='#A81D1D'>On</t>"] select ((captive _player) and !(_player getVariable ["incapacitated",false]));
} else {
	["Off", "<t color='#1DA81D'>On</t>"] select ((captive _player) and !(_player getVariable ["incapacitated",false]));
};
private _rallytxt = ["Absent", "<t color='#1DA81D'>Established</t>"] select (!isNil "isRallyPointPlaced" && {isRallyPointPlaced});

private _aggrString = nil;

switch (gameMode) do {
	case 3: {
		if (!areOccupantsDefeated) then {
			_aggrString = format ["| %1 Initiative: %2 |", nameOccupants, [aggressionLevelOccupants] call A3A_fnc_getAggroLevelString];
		} else {
			_aggrString = "";
		};
	};
	case 4: {
		if (!areInvadersDefeated) then {
			_aggrString = format ["| %1 Initiative: %2 |", nameInvaders, [aggressionLevelInvaders] call A3A_fnc_getAggroLevelString];
		} else {
			_aggrString = "";
		};
	};
	default {
		switch (true) do {
			case (!areOccupantsDefeated && {!areInvadersDefeated}): {
				_aggrString = format ["| %1 Initiative: %2 | %3 Initiative: %4 |", nameOccupants, [aggressionLevelOccupants] call A3A_fnc_getAggroLevelString,  nameInvaders, [aggressionLevelInvaders] call A3A_fnc_getAggroLevelString];
			};
			case (!areOccupantsDefeated && {areInvadersDefeated}): {
				_aggrString = format ["| %1 Initiative: %2 |", nameOccupants, [aggressionLevelOccupants] call A3A_fnc_getAggroLevelString];
			};
			case (!areInvadersDefeated && {areOccupantsDefeated}): {
				_aggrString = format ["| %1 Initiative: %2 |", nameInvaders, [aggressionLevelInvaders] call A3A_fnc_getAggroLevelString];
			};
			case (areOccupantsDefeated && {areOccupantsDefeated}): {
				_aggrString = "";
			};
		};
	};
};

if (_player != theBoss) then {
	private _nameC = if !(isNull theBoss) then {name theBoss} else {"None"};
	_textX = format ["<t size='0.67' shadow='2'>" + "Commander: %3 | %2 | US: %1 | UK: %10 | 82nd: %11 | SAS: %12 | Partizans: %13 | %15 CP: %16 | CP: %4 | IP: %14 %5 Undercover: %7 | Rally Point: %8</t>", server getVariable "UShr", rank _player, _nameC, _player getVariable "moneyX", _aggrString, tierWar, _ucovertxt, _rallytxt, currencySymbol, server getVariable "UKhr", server getVariable "parahr", server getVariable "SAShr", server getVariable "SDKhr", server getVariable "intelPoints", nameTeamPlayer, server getVariable "resourcesFIA"];
} else {
	if (_player call A3A_fnc_isMember) then {
		_textX = format ["<t size='0.67' shadow='2'>" + "%1 | US: %2 | UK: %11 | 82nd: %12 | SAS: %13 | Partizans: %14 | %3 CP: %4 | CP: %5 | IP: %15 %6 Undercover: %8 | Rally Point: %9</t>", rank _player, server getVariable "UShr", nameTeamPlayer, server getVariable "resourcesFIA", _player getVariable "moneyX", _aggrString, tierWar, _ucovertxt, _rallytxt, currencySymbol, server getVariable "UKhr", server getVariable "parahr", server getVariable "SAShr", server getVariable "SDKhr", server getVariable "intelPoints"];
	}
	else {
		_textX = format ["<t size='0.67' shadow='2'>" + "%1 | CP: %2 %9 | %3 CP: %4 | IP: %10 %5 WL: %6 | Undercover: %7 | Rally Point: %8</t>",rank _player,_player getVariable "moneyX",nameTeamPlayer,server getVariable "resourcesFIA", _aggrString, tierWar, _ucovertxt, _rallytxt, currencySymbol, server getVariable "intelPoints"];
	};
};

_setText ctrlSetStructuredText (parseText format ["%1", _textX]);
_setText ctrlCommit 0;
