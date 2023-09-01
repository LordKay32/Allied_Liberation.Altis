private _unit = _this select 0;
private _playerX = _this select 1;
private _capturing = _this select 3;

private _sideX = if ("occ" in (_unit getVariable "unitType")) then {Occupants} else {Invaders};
private _group = grpNull;

[_unit,"remove"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_unit];

if (!alive _unit) exitWith {};

if (_capturing) then {
	_playerX globalChat localize "STR_recruit_text";
	[_unit] joinSilent group _playerX;
	_unit enableAI "ANIM";
	_unit enableAI "MOVE";
	_unit stop false;
	_unit switchMove "";
	_unit setVariable ["captured", true, true];
	prisonersCaptured = prisonersCaptured + 1;
	publicVariable "prisonersCaptured";
	while {alive _unit} do {
		sleep 30;
		private _friendly = ((nearestObjects [_unit, ["man", "Car", "Tank"], 1500]) select {side _x == teamPlayer}) select 1;
		private _distance = _unit distance _friendly;
		if ((random 100 < (_distance/5)) && (vehicle _unit == _unit)) exitWith {
			_group = createGroup _sideX;
			[_unit] joinSilent _group;
			_unit setCaptive false;
			_unit enableAI "all";
			_unit addMagazine "LIB_8Rnd_9x19_P08";
			_unit addWeapon "LIB_M1908";
			_unit addItemToUniform "LIB_8Rnd_9x19_P08";
			_unit setCombatBehaviour "COMBAT";
			[_unit, _sideX] remoteExec ["A3A_fnc_fleeToSide", _unit];
			_playerX globalChat localize "A prisoner is escaping!";
		};
		if (_unit distance flagX < 100) exitWith {
			sleep 10;
			_group = createGroup teamPlayer;
			[_unit] joinSilent _group;
			_unit setCombatBehaviour "CARELESS";
			_group setSpeedMode "LIMITED";
			if (vehicle _unit != _unit) then {unassignVehicle _unit; [_unit] orderGetin false;};
			_unit doMove (getMarkerPos "respawn_guerrila");
			waitUntil {sleep 0.5; moveToCompleted _unit};
			_unit playmove "AmovPercMstpSnonWnonDnon_AmovPsitMstpSnonWnonDnon_ground"; 
        	_unit disableAI "ANIM"; 
        	_unit disableAI "MOVE"; 
       		["Intel", "A prisoner has been interrogated."] call A3A_fnc_customHint;
       		private _intelType = if ((_unit getVariable "unitType") in (squadLeaders + [NATOPilot, CSATPilot])) then {"Medium"} else {"Small"};
       		private _intelText = [_intelType, _sideX] call A3A_fnc_selectIntel;
       		[_intelText] remoteExec ["A3A_fnc_showIntel", [teamPlayer, civilian]];
		};
	};	
} else {
	_playerX globalChat localize "Go, turn yourself into the nearest Allied Patrol...";
	[_unit, _sideX] remoteExec ["A3A_fnc_fleeToSide", _unit];
};

sleep 300;
deleteVehicle _unit;
deleteGroup _group;
