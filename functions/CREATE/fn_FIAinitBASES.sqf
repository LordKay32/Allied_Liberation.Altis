private ["_unit","_skill"];
_unit = _this select 0;
if (debug) then {
    diag_log format ["%1: [Antistasi] | DEBUG | FIAinitBASES.sqf | _unit:%2.",servertime,_unit];
};
if ((isNil "_unit") || (isNull _unit)) exitWith {
    diag_log format ["%1: [Antistasi] | ERROR | FIAinitBases.sqf | Problem with NATO Param: %2",servertime,_this];
};
_markerX = "";
if (count _this > 1) then
	{
	_markerX = _this select 1;
	_unit setVariable ["markerX",_markerX,true];
	if ((spawner getVariable _markerX != 0) and (vehicle _unit != _unit)) then
		{
		if (!isMultiplayer) then
			{
			_unit enableSimulation false
			}
		else
			{
			[_unit,false] remoteExec ["enableSimulationGlobal",2]
			}
		};
	};
[_unit] call A3A_fnc_initRevive;

_unit allowFleeing 0;
_typeX = _unit getVariable "unitType";

if (_typeX in [SDKMedic,SDKMG,SDKMil,SDKSL,SDKEng]) then {
	_unit setSkill 0.5;
};
if (_typeX in [UKstaticCrewTeamPlayer,UKsniper,UKMil,UKMedic,UKMG,UKExp,UKGL,UKSL,UKEng,UKATman,USstaticCrewTeamPlayer,USUnarmed,USsniper,USMil,USMedic,USMG,USExp,USGL,USSL,USEng,USATman]) then {
	_unit setSkill 0.66;
};
if (_typeX in [parasniper,paraMil,paraMedic,paraMG,paraExp,paraGL,paraSL,paraEng,paraATman]) then {
	_unit setSkill 0.75;
};
if (_typeX in [SASsniper,SASMil,SASMedic,SASMG,SASExp,SASSL,SASATman]) then {
	_unit setSkill 0.9;
	_unit setUnitTrait ["camouflageCoef",0.8];
	_unit setUnitTrait ["audibleCoef",0.8];
};
if (_typeX in [UKCrew,USCrew]) then {
	_unit setSkill 0.75;
};
if (_typeX in [UKPilot,USPilot]) then {
	_unit setSkill 0.9;
};

if (_typeX in [SDKSL,UKSL,USSL,paraSL,SASSL]) then {
	_unit setskill ["courage", (skill _unit) + 0.5];
	_unit setskill ["commanding", (skill _unit) + 0.5];
};
if (_typeX in [UKsniper,USsniper,SASsniper,parasniper]) then {
	_unit setskill ["aimingAccuracy", (skill _unit) + 0.5];
	_unit setskill ["aimingShake", (skill _unit) + 0.5];
};

private _voice = "";
if (_typeX in (UKTroops + SASTroops)) then {
	_voice = (selectRandom ["Male01ENGB","Male02ENGB","Male03ENGB","Male04ENGB","Male05ENGB"]);
};
if (_typeX in (USTroops + paraTroops)) then {
	_voice = (selectRandom ["Male01ENG","Male02ENG","Male03ENG","Male04ENG","Male05ENG","Male06ENG","Male07ENG","Male08ENG","Male09ENG","Male10ENG","Male11ENG","Male12ENG"])	
};
if (_typeX in (SDKTroops)) then {
	_voice = (selectRandom ["Male01GRE","Male02GRE","Male03GRE","Male04GRE","Male05GRE","Male06GRE"])	
};

[_unit, _voice] remoteExec ["setSpeaker", 0, _unit]; 

[_unit, 2] call A3A_fnc_equipRebel;			// 2 = garrison unit
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

_EHkilledIdx = _unit addEventHandler ["killed", {
	_victim = _this select 0;
	_killer = _this select 1;
	[_victim] remoteExec ["A3A_fnc_postmortem",2];
	if (typeName _killer != "OBJECT") exitWith {};
	if (isPlayer _killer) then
		{
		if (!isMultiPlayer) then
			{
			_nul = [0,20,0] remoteExec ["A3A_fnc_resourcesFIA",2];
			_killer addRating 1000;
			};
		};
	if (side _killer == Occupants) then
	{
		[0,-0.25,getPos _victim] remoteExec ["A3A_fnc_citySupportChange",2];
	};
	_markerX = _victim getVariable "markerX";
	if (!isNil "_markerX") then
		{
		if (sidesX getVariable [_markerX,sideUnknown] == teamPlayer) then
			{
			[_victim getVariable "unitType",teamPlayer,_markerX,-1] remoteExec ["A3A_fnc_garrisonUpdate",2];
			_victim setVariable [_markerX,nil,true];
			};
		};
	}];

_revealX = false;
if (vehicle _unit != _unit) then
	{
	if (_unit == gunner (vehicle _unit)) then
		{
			_revealX = true;
			if (debug) then {
                diag_log format ["%1: [Antistasi] | DEBUG | FIAinitBASES.sqf | Unit: %2 is mounted gunner.",servertime,_unit];
			};
		};
	}
else
	{
	if ((secondaryWeapon _unit) in allMissileLaunchers) then {
			_revealX = true;
			if (debug) then {
                diag_log format ["%1: [Antistasi] | DEBUG | FIAinitBASES.sqf | Unit: %2 has launcher: %3.",servertime,_unit, (secondaryWeapon _unit)];
			};
		};
	};

if (_revealX) then
	{
	{
	_unit reveal [_x,1.5];
	} forEach allUnits select {(vehicle _x isKindOf "Air") and (_x distance _unit <= distanceSPWN)};
	};
