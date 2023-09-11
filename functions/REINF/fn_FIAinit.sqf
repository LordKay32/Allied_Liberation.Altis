private ["_victim","_killer","_idUnit"];

private _unit = _this select 0;

[_unit] call A3A_fnc_initRevive;
_unit setVariable ["spawner",true,true];

_unit allowFleeing 0;
private _typeX = _unit getVariable "unitType";

if (_typeX in [SDKUnarmed,SDKMedic,SDKMG,SDKMil,SDKSL,SDKEng]) then {
	_unit setSkill (0.3 + (0.012 * skillFIA));
};
if (_typeX in [UKstaticCrewTeamPlayer,UKUnarmed,UKsniper,UKMil,UKMedic,UKMG,UKExp,UKGL,UKSL,UKEng,UKATman,USstaticCrewTeamPlayer,USUnarmed,USsniper,USMil,USMedic,USMG,USExp,USGL,USSL,USEng,USATman]) then {
	_unit setSkill 0.66;
};
if (_typeX in [parasniper,paraMil,paraMedic,paraMG,paraExp,paraGL,paraSL,paraEng,paraATman]) then {
	_unit setSkill 0.75;
};
if (_typeX in [SASsniper,SASMil,SASMedic,SASMG,SASExp,SASSL,SASATman]) then {
	_unit setSkill 0.9;
	_unit setUnitTrait ["camouflageCoef",0.6];
	_unit setUnitTrait ["audibleCoef",0.6];
};
if (_typeX in [UKCrew,USCrew]) then {
	_unit setSkill 0.75;
};
if (_typeX in [UKPilot,USPilot]) then {
	_unit setSkill 0.9;
};

if (_typeX in [SDKSL,UKSL,USSL,paraSL,SASSL]) then {
	_unit setskill ["courage", (skill _unit) + 0.2];
	_unit setskill ["commanding", (skill _unit) + 0.2];
};
if (_typeX in [UKsniper,USsniper,SASsniper,parasniper]) then {
	_unit setskill ["aimingAccuracy", (skill _unit) + 0.2];
	_unit setskill ["aimingShake", (skill _unit) + 0.2];
};

if (_typeX in [USUnarmed,UKUnarmed,SDKUnarmed]) then {} else {[_unit, [0,1] select (leader _unit != player)] call A3A_fnc_equipRebel};
	
if (primaryWeapon _unit == "") then {
	_unit selectWeapon (secondaryWeapon _unit)} else {
	_unit selectWeapon (primaryWeapon _unit);
};

if (_typeX in SDKTroops) then {
	_unit addEventHandler ["Killed", {
		params ["_unit", "_killer", "_instigator", "_useEffects"];
		partizanKilled = partizanKilled + 1;
		publicVariable "partizanKilled";
		if (typeName _killer != "OBJECT") exitWith {};
		if (isPlayer _killer) then {
			partizanKilledFF = partizanKilledFF + 1;
			publicVariable "partizanKilledFF";
		};
	}];
} else {
	_unit addEventHandler ["Killed", {
		params ["_unit", "_killer", "_instigator", "_useEffects"];
		teamPlayerKilled = teamPlayerKilled + 1;
		publicVariable "teamPlayerKilled";
		if (typeName _killer != "OBJECT") exitWith {};
		if (isPlayer _killer) then {
			teamPlayerKilledFF = teamPlayerKilledFF + 1;
			publicVariable "teamPlayerKilledFF";
		};
	}];
};

private _victim = objNull;
private _killer = objNull;

if (player == leader _unit) then {
	_unit setVariable ["owner", player, true];
	_unit addEventHandler ["killed", {
		_victim = _this select 0;
		[_victim] spawn A3A_fnc_postmortem;
		_killer = _this select 1;
		
		if ((_unit getVariable "unitType") in [SDKMedic,SDKMG,SDKMil,SDKSL,SDKEng]) then {
			arrayGREids pushBackUnique (name _victim);} else {
			arrayENGids pushBackUnique (name _victim);
		};
		if (typeName _killer != "OBJECT") exitWith {};
		if (side _killer == Occupants) then {
			_nul = [0.25,0,getPos _victim] remoteExec ["A3A_fnc_citySupportChange",2];
		} else {
			if (side _killer == Invaders) then {
			} else {
				if (isPlayer _killer) then {
					_killer addRating 1000;
				};
			};
		};
		_victim setVariable ["spawner",nil,true];
	}];
	
	if !(_typeX in [SDKUnarmed,UKUnarmed,USUnarmed]) then {
		if (_typeX in SDKTroops) then {
			_idUnit = selectRandom arrayGREids;
			arrayGREids = arrayGREids - [_idUnit];
		};
		if (_typeX in (UKTroops + SASTroops)) then {
			_idUnit = selectRandom arrayUKids;
			arrayUKids = arrayUKids - [_idUnit];
		};
		if (_typeX in (USTroops + paraTroops)) then {
			_idUnit = selectRandom arrayUSids;
			arrayUSids = arrayUSids - [_idUnit];
		};
		_unit setIdentity _idUnit;
	};
	
	if (captive player) then {[_unit] spawn A3A_fnc_undercoverAI};

	_unit setVariable ["rearming",false];
	if (!haveRadio) then {
		[_unit] spawn {
			params ["_unit"];
			while {alive _unit} do {
				sleep 10;
				//if (([player] call A3A_fnc_hasRadio) && (_unit call A3A_fnc_hasARadio)) exitWith {_unit groupChat format ["This is %1, radiocheck OK",name _unit]};
				if (unitReady _unit) then {
					private _nearestBase = [((airportsX + milbases + ["Synd_HQ"]) select {sidesX getVariable [_x,sideUnknown] == teamPlayer}), position _unit] call BIS_fnc_nearestPosition;
					if ((alive _unit) and (_unit distance getMarkerPos _nearestBase > 100) and (_unit distance leader group _unit > 500) and ((vehicle _unit == _unit) or ((typeOf (vehicle _unit)) in arrayCivVeh))) then {
						["", format ["%1 lost communication, he will wait at his current position.", name _unit]] call A3A_fnc_customHint;
						[_unit] join stragglers;
						if ((vehicle _unit isKindOf "StaticWeapon") or (isNull (driver (vehicle _unit)))) then {unassignVehicle _unit; [_unit] orderGetIn false};
						doStop _unit;
						private _unitMarker = createMarkerLocal [format ["%1Marker", name _unit], position _unit];
						_unitMarker setMarkerTypeLocal "mil_dot_noShadow";
						_unitMarker setMarkerTextLocal format ["%1 last known position", name _unit];
						private _timeX = time + 900;
						waitUntil {sleep 1;(!alive _unit) or (_unit distance player < 500) or (time > _timeX)};
						if ((_unit distance player >= 500) and (alive _unit)) then {_unit setPos (getMarkerPos _nearestBase); ["", format ["%1 has returned to the nearest base.", name _unit]] call A3A_fnc_customHint;};
						[_unit] join group player;
						deleteMarkerLocal _unitMarker;
					};
				};
			};
		};		
	};
} else {
	_unit addEventHandler ["killed", {
		_victim = _this select 0;
		_killer = _this select 1;
		[_victim] remoteExec ["A3A_fnc_postmortem",2];
		if (typeName _killer != "OBJECT") exitWith {};
		if ((isPlayer _killer) and (side _killer == teamPlayer)) then {
			if (!isMultiPlayer) then {
				_nul = [0,20] remoteExec ["A3A_fnc_resourcesFIA",2];
				_killer addRating 1000;
			};
		} else {
			if (side _killer == Occupants) then {
				_nul = [0.25,0,getPos _victim] remoteExec ["A3A_fnc_citySupportChange",2];
			} else {
				if (side _killer == Invaders) then {
				} else {
					if (isPlayer _killer) then {
						_killer addRating 1000;
					};
				};
			};
		};
		_victim setVariable ["spawner",nil,true];
	}];
};
