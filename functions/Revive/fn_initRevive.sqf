private ["_unit"];
//esto habrá que meterlo en onplayerrespawn también // ENGLISH: this will have to be put in onplayerrespawn too
_unit = _this select 0;
//_unit setVariable ["inconsciente",false,true];

_unit setVariable ["respawning",false];
[_unit] remoteExecCall ["A3A_fnc_punishment_FF_addEH",_unit,false];
_unit addEventHandler ["HandleDamage", A3A_fnc_handleDamage];

If (isPlayer _unit) then {
	[player] spawn { 
		params ["_unit"]; 
		while {true} do { 
			waitUntil {sleep 0.1; commandingMenu == "RscGroupRootMenu" && isPlayer cursorObject && cursorObject getVariable ["incapacitated",false] && count groupSelectedUnits _unit == 1}; 
			_target = cursorObject; 
			_medic = (groupSelectedUnits _unit) select 0; 
			while {true} do { 
				sleep 0.1; 
				if ((groupSelectedUnits _unit) select 0 != _medic || isNull cursorObject) exitWith {}; 
				if (currentCommand _medic == "HEAL SOLDIER") exitWith {AISFinishHeal [_target, _medic, true];["Revive", format ["%1 needs reviving first.",name _target]] call A3A_fnc_customHint;}; 
			}; 
		}; 
	};
};