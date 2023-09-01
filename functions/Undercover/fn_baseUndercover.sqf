/*
 * Name:	fn_baseUndercover
 * Date:	3/07/2023
 * Version: 1.0
 * Author:  JB
 *
 * Description:
 * Military Undercover on enemy base
 *
 * Parameter(s):
 * _PARAM1 (TYPE): DESCRIPTION.
 * _PARAM2 (TYPE): DESCRIPTION.
 *
 * Returns:
 * Nothing
 */

	private _number = 0;
	private _busted = round (random [300,450,600]);
	private _suspicious = _busted - (round (random [90,120,150]));
	private _base = _this select 0;
	
	while {true} do {
		sleep 1;
		
		if ({((side _x == Occupants) || (side _x == Invaders)) && (_x knowsAbout player > 3.9)} count allUnits > 0) then {
			_nearestEnemy = player findNearestEnemy player;
			_distEnemy = _nearestEnemy distance player;
			_increase = ((1 - (_distEnemy/50)) max 0.2) min 1;
			_speedModifier = if (vehicle player != player) then {2} else {((abs speed player/6) max 1) min 4};
			_number = _number + (_increase * _speedModifier);
		};
		private _distance = ((_number/4) max 20) min 70;
		private _nearUnits = ((player nearEntities (_distance + 5)) select {((side _x == Occupants) || (side _x == Invaders))});
		
		if ((_number >= _suspicious) && (_number < _busted)) then {
			{
			if (_x distance player < _distance) then {
				_x disableAI "PATH";
				_x doWatch player;
			} else {
				_x enableAI "PATH";
				_x doWatch objNull;
			};
			} forEach _nearUnits;
		};
		if (!(player inArea _base)) exitWith {};
		if (_number >= _busted) exitWith {
			
			/*_spawnPos = 
			_groupY = [_positionX, _sideX, _squad] call A3A_fnc_spawnGroup;
			{[_x,_markerX] call A3A_fnc_NATOinit; _soldiers pushBack _x} forEach units _grp;*/
			
			_nearEnemy = (nearestObjects [player, ["man"], 250]) select {((side _x == Occupants) || (side _x == Invaders)) && speed _x > 2};
			_nearestEnemy = _nearEnemy select 0;
			_enemyLeader = leader _nearestEnemy;
			_enemyGroup = group _nearestEnemy;
			
			{
				_x setCombatBehaviour "AWARE";
				_x setSpeedMode "FULL";
			} forEach units _enemyGroup;
			
			while {true} do {
				sleep 1;
				{
					_x doMove position player;
				} forEach units _enemyGroup;
				if (!(player inArea _base) || {_x distance player < 50} count (units _enemyGroup) > 0 || (_enemyLeader distance player > 350) || vehicle player != player) exitWith {};
			};
			
			sleep 1;
			
			player setCaptive false;
		};
	};

