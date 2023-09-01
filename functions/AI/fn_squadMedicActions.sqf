/*
 * Name:	fn_squadMedic
 * Date:	11/06/2023
 * Version: 1.0
 * Author:  JB
 *
 * Description:
 * Squad medic functions
 *
 * Parameter(s):
 * _PARAM1 (TYPE): DESCRIPTION.
 * _PARAM2 (TYPE): DESCRIPTION.
 *
 * Returns:
 * %RETURNS%
 */

_player = _this select 0;
_typeX = _this select 1;

switch _typeX do
{
    case "group":
    {

		private _medics = ((units group _player) - [_player]) select {_x getUnitTrait "Medic"};
		private _medic = "";

		switch (true) do {
		    case (count _medics == 1):{
		    	_medic = _medics select 0;
		
				if (!(alive _medic)) exitWith {["Revive", format ["Your team medic %1 is dead.",name _medic]] call A3A_fnc_customHint;};
				if (_medic getVariable ["incapacitated",false]) exitWith {["Revive", format ["Your team medic %1 is incapacitated and needs help first.",name _medic]] call A3A_fnc_customHint;};

				{	
					if (_x getVariable ["incapacitated",false]) then {
						private _pos = getPos _x;
						_medic doMove _pos;
						waitUntil {sleep 1; (unitReady _medic && !(_medic getVariable ["helping",false]))};
						if (!(alive _medic) || (_medic getVariable ["incapacitated",false])) exitWith {doStop _medic; ["Revive", format ["Your team medic %1 has been killed or incapacitated, and can no longer help %2",name _medic, name _x]] call A3A_fnc_customHint;};
						[_x, _medic] spawn A3A_fnc_actionRevive;
						waitUntil {sleep 1; (unitReady _medic && !(_medic getVariable ["helping",false]))};
						if (!(alive _medic) || (_medic getVariable ["incapacitated",false])) exitWith {doStop _medic; ["Revive", format ["Your team medic %1 has been killed or incapacitated, and can no longer help %2",name _medic, name _x]] call A3A_fnc_customHint;};
					};
					if (!(alive _medic) || (_medic getVariable ["incapacitated",false])) exitWith {};
				} forEach (units group _player);
			};
			case (count _medics > 1):{
				
				if (_medics findIf {alive _x and !(_x getVariable ["incapacitated",false])} == -1) exitWith {["Revive", "Your team medics are either dead or incapacitated."] call A3A_fnc_customHint;};
			
				private _potMedics = _medics select {alive _x and !(_x getVariable ["incapacitated",false])};
		
				private _injured = (units group _player) select {_x getVariable ["incapacitated",false]};
				private _numInjured = count _injured;
		
				if (count _potMedics == 1) then {
					_medic = _potMedics select 0;
		
					{
					if (_x getVariable ["incapacitated",false]) then {
						private _pos = getPos _x;
						_medic doMove _pos;
						waitUntil {sleep 1; (unitReady _medic && !(_medic getVariable ["helping",false]))};
						if (!(alive _medic) || (_medic getVariable ["incapacitated",false])) exitWith {doStop _medic; ["Revive", format ["Your team medic %1 has been killed or incapacitated, and can no longer help %2",name _medic, name _x]] call A3A_fnc_customHint;};
						[_x, _medic] spawn A3A_fnc_actionRevive;
						waitUntil {sleep 1; (unitReady _medic && !(_medic getVariable ["helping",false]))};
						if (!(alive _medic) || (_medic getVariable ["incapacitated",false])) exitWith {doStop _medic; ["Revive", format ["Your team medic %1 has been killed or incapacitated, and can no longer help %2",name _medic, name _x]] call A3A_fnc_customHint;};
						};
					if (!(alive _medic) || (_medic getVariable ["incapacitated",false])) exitWith {};
					} forEach (units group _player);
		
				} else {
					_medic1 = _potMedics select 0;
					_medic2 = _potMedics select 1;
		
					_medic1List = _injured select [0, (ceil (_numInjured / 2))];
					_medic2List = _injured select [(floor (_numInjured / 2)) , (_numInjured - 1)];

					[_medic1, _medic1List] spawn {
						params ["_medic1", "_medic1List"];
						{
							private _pos = getPos _x;
							_medic1 doMove _pos;
							waitUntil {sleep 1; (unitReady _medic1 && !(_medic1 getVariable ["helping",false]))};
							if (!(alive _medic1) || (_medic1 getVariable ["incapacitated",false])) exitWith {doStop _medic1; ["Revive", format ["Your team medic %1 has been killed or incapacitated, and can no longer help %2",name _medic1, name _x]] call A3A_fnc_customHint;};
							[_x, _medic1] spawn A3A_fnc_actionRevive;
							waitUntil {sleep 1; (unitReady _medic1 && !(_medic1 getVariable ["helping",false]))};
							if (!(alive _medic1) || (_medic1 getVariable ["incapacitated",false])) exitWith {doStop _medic1; ["Revive", format ["Your team medic %1 has been killed or incapacitated, and can no longer help %2",name _medic1, name _x]] call A3A_fnc_customHint;};
						} forEach _medic1List;
					};
			
					[_medic2, _medic2List] spawn {
						params ["_medic2", "_medic2List"];
						{
							private _pos = getPos _x;
							_medic2 doMove _pos;
							waitUntil {sleep 1; (unitReady _medic2 && !(_medic2 getVariable ["helping",false]))};
							if (!(alive _medic2) || (_medic2 getVariable ["incapacitated",false])) exitWith {doStop _medic2; ["Revive", format ["Your team medic %1 has been killed or incapacitated, and can no longer help %2",name _medic2, name _x]] call A3A_fnc_customHint;};
							[_x, _medic2] spawn A3A_fnc_actionRevive;
							waitUntil {sleep 1; (unitReady _medic2 && !(_medic2 getVariable ["helping",false]))};
							if (!(alive _medic2) || (_medic2 getVariable ["incapacitated",false])) exitWith {doStop _medic2; ["Revive", format ["Your team medic %1 has been killed or incapacitated, and can no longer help %2",name _medic2, name _x]] call A3A_fnc_customHint;};
						} forEach _medic2List;
					};
				};
			};
		};
	};
	
    case "area":
    {
		private _medics = ((units group _player) - [_player]) select {_x getUnitTrait "Medic"};
		private _medic = "";

		switch (true) do {
		    case (count _medics == 1):{
		    	_medic = _medics select 0;
		
				if (!(alive _medic)) exitWith {["Revive", format ["Your team medic %1 is dead.",name _medic]] call A3A_fnc_customHint;};
				if (_medic getVariable ["incapacitated",false]) exitWith {["Revive", format ["Your team medic %1 is incapacitated and needs help first.",name _medic]] call A3A_fnc_customHint;};

				private _injured = (entities [["Man"], [], true, true]) select {(_x distance _player < 50) && (_x getVariable ["incapacitated",false])};
    			private _injuredPlayers = _injured select {isPlayer _x};
    			private _injuredAllies = (_injured - _injuredPlayers) select {_x getVariable "unitType" in alliedTroops};
    			private _injuredEnemies = (_injured - (_injuredPlayers + _injuredAllies));

				{	
					if (_x getVariable ["incapacitated",false]) then {
						private _pos = getPos _x;
						_medic doMove _pos;
						waitUntil {sleep 1; (unitReady _medic && !(_medic getVariable ["helping",false]))};
						if (!(alive _medic) || (_medic getVariable ["incapacitated",false])) exitWith {doStop _medic; ["Revive", format ["Your team medic %1 has been killed or incapacitated, and can no longer help %2",name _medic, name _x]] call A3A_fnc_customHint;};
						[_x, _medic] spawn A3A_fnc_actionRevive;
						waitUntil {sleep 1; (unitReady _medic && !(_medic getVariable ["helping",false]))};
						if (!(alive _medic) || (_medic getVariable ["incapacitated",false])) exitWith {doStop _medic; ["Revive", format ["Your team medic %1 has been killed or incapacitated, and can no longer help %2",name _medic, name _x]] call A3A_fnc_customHint;};
					};
					if (!(alive _medic) || (_medic getVariable ["incapacitated",false])) exitWith {};
				} forEach (_injuredPlayers + _injuredAllies + _injuredEnemies);
			};
			case (count _medics > 1):{
				
				if (_medics findIf {alive _x and !(_x getVariable ["incapacitated",false])} == -1) exitWith {["Revive", "Your team medics are either dead or incapacitated."] call A3A_fnc_customHint;};
			
				private _potMedics = _medics select {alive _x and !(_x getVariable ["incapacitated",false])};
		
				private _injured = (entities [["Man"], [], true, true]) select {(_x distance _player < 50) && (_x getVariable ["incapacitated",false])};
    			private _injuredPlayers = _injured select {isPlayer _x};
    			private _injuredAllies = (_injured - _injuredPlayers) select {_x getVariable "unitType" in alliedTroops};
    			private _injuredEnemies = (_injured - (_injuredPlayers + _injuredAllies));
    			
    			private _injuredOrderedList = (_injuredPlayers + _injuredAllies + _injuredEnemies);
		
				if (count _potMedics == 1) then {
					_medic = _potMedics select 0;
		
					{
					if (_x getVariable ["incapacitated",false]) then {
						private _pos = getPos _x;
						_medic doMove _pos;
						waitUntil {sleep 1; (unitReady _medic && !(_medic getVariable ["helping",false]))};
						if (!(alive _medic) || (_medic getVariable ["incapacitated",false])) exitWith {doStop _medic; ["Revive", format ["Your team medic %1 has been killed or incapacitated, and can no longer help %2",name _medic, name _x]] call A3A_fnc_customHint;};
						[_x, _medic] spawn A3A_fnc_actionRevive;
						waitUntil {sleep 1; (unitReady _medic && !(_medic getVariable ["helping",false]))};
						if (!(alive _medic) || (_medic getVariable ["incapacitated",false])) exitWith {doStop _medic; ["Revive", format ["Your team medic %1 has been killed or incapacitated, and can no longer help %2",name _medic, name _x]] call A3A_fnc_customHint;};
						};
					if (!(alive _medic) || (_medic getVariable ["incapacitated",false])) exitWith {};
					} forEach _injuredOrderedList;
		
				} else {
					private _medic1 = _potMedics select 0;
					private _medic2 = _potMedics select 1;
					
					private _injuredCount = count _injuredOrderedList;
		
					private _evenIndex = [];
					private _oddIndex = [];
					
					for "_i" from 0 to (_injuredCount -1) step 2 do {_evenIndex pushBack _i};
					for "_i" from 1 to (_injuredCount -1) step 2 do {_oddIndex pushBack _i};
					
					private _medic1List = [];
					private _medic2List = [];
					
					{
					_medic1List pushBack (_injuredOrderedList select _x);
					} forEach _evenIndex;				
					{
					_medic2List pushBack (_injuredOrderedList select _x);
					} forEach _oddIndex;
					

					[_medic1, _medic1List] spawn {
						params ["_medic1", "_medic1List"];
						{
							private _pos = getPos _x;
							_medic1 doMove _pos;
							waitUntil {sleep 1; (unitReady _medic1 && !(_medic1 getVariable ["helping",false]))};
							if (!(alive _medic1) || (_medic1 getVariable ["incapacitated",false])) exitWith {doStop _medic1; ["Revive", format ["Your team medic %1 has been killed or incapacitated, and can no longer help %2",name _medic1, name _x]] call A3A_fnc_customHint;};
							[_x, _medic1] spawn A3A_fnc_actionRevive;
							waitUntil {sleep 1; (unitReady _medic1 && !(_medic1 getVariable ["helping",false]))};
							if (!(alive _medic1) || (_medic1 getVariable ["incapacitated",false])) exitWith {doStop _medic1; ["Revive", format ["Your team medic %1 has been killed or incapacitated, and can no longer help %2",name _medic1, name _x]] call A3A_fnc_customHint;};
						} forEach _medic1List;
					};
			
					[_medic2, _medic2List] spawn {
						params ["_medic2", "_medic2List"];
						{
							private _pos = getPos _x;
							_medic2 doMove _pos;
							waitUntil {sleep 1; (unitReady _medic2 && !(_medic2 getVariable ["helping",false]))};
							if (!(alive _medic2) || (_medic2 getVariable ["incapacitated",false])) exitWith {doStop _medic2; ["Revive", format ["Your team medic %1 has been killed or incapacitated, and can no longer help %2",name _medic2, name _x]] call A3A_fnc_customHint;};
							[_x, _medic2] spawn A3A_fnc_actionRevive;
							waitUntil {sleep 1; (unitReady _medic2 && !(_medic2 getVariable ["helping",false]))};
							if (!(alive _medic2) || (_medic2 getVariable ["incapacitated",false])) exitWith {doStop _medic2; ["Revive", format ["Your team medic %1 has been killed or incapacitated, and can no longer help %2",name _medic2, name _x]] call A3A_fnc_customHint;};
						} forEach _medic2List;
					};
				};
			};
		};	
	};
};
