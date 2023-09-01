/*
 * Name:	teamMedicRevive
 * Date:	10/06/2023
 * Version: 1.0
 * Author:  JB
 *
 * Description:
 * Team medics to heal
 *
 * Parameter(s):
 * _PARAM1 (TYPE): DESCRIPTION.
 * _PARAM2 (TYPE): DESCRIPTION.
 *
 * Returns:
 * %RETURNS%
 */

params ["_target", "_caller"];

private _medics = ((units group _caller) - [_target, _caller]) select {_x getUnitTrait "Medic"};
private _medic = "";

switch (true) do {
    case (count _medics == 1):{
    	_medic = _medics select 0;

		if (!(alive _medic)) exitWith {["Revive", format ["Your team medic %1 is dead.",name _medic]] call A3A_fnc_customHint;};
		if (_medic getVariable ["incapacitated",false]) exitWith {["Revive", format ["Your team medic %1 is incapacitated and needs help first.",name _medic]] call A3A_fnc_customHint;};

		private _pos = getPos _target;
		_medic doMove _pos;
		waitUntil {sleep 1; (unitReady _medic && !(_medic getVariable ["helping",false]))};
		if (!(alive _medic) || (_medic getVariable ["incapacitated",false])) exitWith {doStop _medic; ["Revive", format ["Your team medic %1 has been killed or incapacitated, and can no longer help %2",name _medic, name _target]] call A3A_fnc_customHint;};
		[_target, _medic] spawn A3A_fnc_actionRevive;
		waitUntil {sleep 1; (unitReady _medic && !(_medic getVariable ["helping",false]))};
		if (!(alive _medic) || (_medic getVariable ["incapacitated",false])) exitWith {doStop _medic; ["Revive", format ["Your team medic %1 has been killed or incapacitated, and can no longer help %2",name _medic, name _target]] call A3A_fnc_customHint;};
 	};
	case (count _medics > 1):{
		
		if (_medics findIf {alive _x and !(_x getVariable ["incapacitated",false])} == -1) exitWith {["Revive", "Your team medics are either dead or incapacitated."] call A3A_fnc_customHint;};
		
		private _potMedics = _medics select {alive _x and !(_x getVariable ["incapacitated",false])};
		if (count _potMedics == 1) then {
			_medic = _potMedics select 0;
		} else {
			if ({_x getVariable ["helping",false]} count _potMedics == count _potMedics) then {
				private _targetPos = getPos _target;
				private _medicList = _potMedics apply {[_targetPos distanceSqr _x, _x]};
				_medicList sort true;
				_medic = (_medicList select 0) param [1, objNull];
			} else {
				_potMedics = _potMedics select {!(_x getVariable ["helping",false])};	
				private _targetPos = getPos _target;
				private _medicList = _potMedics apply {[_targetPos distanceSqr _x, _x]};
				_medicList sort true;
				_medic = (_medicList select 0) param [1, objNull];
			};		
		};
		private _pos = getPos _target;
		_medic doMove _pos;
		waitUntil {sleep 1; (unitReady _medic && !(_medic getVariable ["helping",false]))};
		if (!(alive _medic) || (_medic getVariable ["incapacitated",false])) exitWith {doStop _medic; ["Revive", format ["Your team medic %1 has been killed or incapacitated, and can no longer help %2",name _medic, name _target]] call A3A_fnc_customHint;};
		[_target, _medic] spawn A3A_fnc_actionRevive;
		waitUntil {sleep 1; (unitReady _medic && !(_medic getVariable ["helping",false]))};
		if (!(alive _medic) || (_medic getVariable ["incapacitated",false])) exitWith {doStop _medic; ["Revive", format ["Your team medic %1 has been killed or incapacitated, and can no longer help %2",name _medic, name _target]] call A3A_fnc_customHint;};
	};
};
