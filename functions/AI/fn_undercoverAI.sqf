private ["_unit","_LeaderX","_airportsX","_base","_loadOut", "_oldBehaviour"];

_unit = _this select 0;
if (isPlayer _unit) exitWith {};
_LeaderX = _unit getVariable ["owner",leader group _unit];
if (!isPlayer _LeaderX) exitWith {};
if (!captive _LeaderX) exitWith {};
if (captive _unit) exitWith {};

private _failed = [_unit] call A3A_fnc_AIMilUndercover;
if (_failed) exitWith {};

[_unit,true] remoteExec ["setCaptive",0,_unit];
_unit setCaptive true;
_unit disableAI "TARGET";
_unit disableAI "AUTOTARGET";

_oldBehaviour = behaviour _unit;

_unit setBehaviour "CARELESS";
_unit setUnitPos "UP";

if ((_unit getVariable "unitType") in SASTroops) then {
	_unit addEventHandler ["FiredMan", {
			params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_vehicle"];
			if (_muzzle in ["LIB_US_TNT_4pound_Muzzle","LIB_Ladung_Big_Muzzle","LIB_Ladung_Small_Muzzle","PipeBombMuzzle","LIB_US_M1A1_ATMINE_Muzzle","LIB_M3_Muzzle","LIB_US_M3_Muzzle","LIB_shumine_42_Muzzle","DemoChargeMuzzle","LIB_SMI_35_Muzzle","LIB_SMI_35_1_Muzzle","LIB_TMI_42_Muzzle"]) then {
				if ({((side _x == Invaders) || (side _x == Occupants)) && (_x knowsAbout _unit > 3.9)} count allUnits > 0) then {_unit setCaptive false; _unit removeEventHandler [_thisEvent, _thisEventHandler]};
			} else {
				_unit setCaptive false; _unit removeEventHandler [_thisEvent, _thisEventHandler];
			};
		}];
	while {(captive _LeaderX) and (captive _unit)} do
		{
		sleep 1;
		if ((vehicle _unit != _unit) and (not((typeOf vehicle _unit) in (vehNATONormal + vehNATOAPC)))) exitWith {};
		//_base = [_airportsX,player] call BIS_fnc_nearestPosition;
		//_size = [_base] call A3A_fnc_sizeMarker;
		//if ((_unit inArea _base) and (not(sidesX getVariable [_base,sideUnknown] == teamPlayer))) exitWith {[_unit,false] remoteExec ["setCaptive"]};
		};

	//_unit removeAllEventHandlers "FIRED";
	if (!captive _unit) then {_unit groupChat "Shit, they have spotted me!"} else {[_unit,false] remoteExec ["setCaptive",0,_unit]; _unit setCaptive false};
	if (captive player) then {sleep 5};
	_unit setBehaviour _oldBehaviour;
	_unit enableAI "TARGET";
	_unit enableAI "AUTOTARGET";
	_unit setUnitPos "AUTO";
};

if ((_unit getVariable "unitType") in SDKTroops) then {
	_loadOut = getUnitLoadout _unit;
	removeAllItems _unit;
	removeAllAssignedItems _unit;
	removeAllWeapons _unit;
	_unit forceAddUniform (selectRandom (A3A_faction_civ getVariable "uniforms"));
	removeVest _unit;
	removeBackpack _unit;
	removeHeadgear _unit;
	removeGoggles _unit;
	_unit addHeadgear (selectRandom (A3A_faction_civ getVariable "headgear"));

	_unit addEventHandler ["FiredMan", {
			params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_vehicle"];
			if (_muzzle in ["LIB_US_TNT_4pound_Muzzle","LIB_Ladung_Big_Muzzle","LIB_Ladung_Small_Muzzle","PipeBombMuzzle","LIB_US_M1A1_ATMINE_Muzzle","LIB_M3_Muzzle","LIB_US_M3_Muzzle","LIB_shumine_42_Muzzle","DemoChargeMuzzle","LIB_SMI_35_Muzzle","LIB_SMI_35_1_Muzzle","LIB_TMI_42_Muzzle"]) then {
				if ({((side _x == Invaders) || (side _x == Occupants)) && (_x knowsAbout _unit > 3.9)} count allUnits > 0) then {_unit setCaptive false; _unit removeEventHandler [_thisEvent, _thisEventHandler]};
			} else {
				_unit setCaptive false; _unit removeEventHandler [_thisEvent, _thisEventHandler];
			};
		}];

	while {(captive _LeaderX) and (captive _unit)} do
		{
		sleep 1;
		if ((vehicle _unit != _unit) and (not((typeOf vehicle _unit) in undercoverVehicles))) exitWith {};
		//_base = [_airportsX,player] call BIS_fnc_nearestPosition;
		//_size = [_base] call A3A_fnc_sizeMarker;
		//if ((_unit inArea _base) and (not(sidesX getVariable [_base,sideUnknown] == teamPlayer))) exitWith {[_unit,false] remoteExec ["setCaptive"]};
		if ((primaryWeapon _unit != "") or (secondaryWeapon _unit != "") or (handgunWeapon _unit != "")) exitWith {};
		};

	//_unit removeAllEventHandlers "FIRED";
	if (!captive _unit) then {_unit groupChat "Shit, they have spotted me!"} else {[_unit,false] remoteExec ["setCaptive",0,_unit]; _unit setCaptive false};
	if (captive player) then {sleep 5};
	_unit setBehaviour _oldBehaviour;
	_unit enableAI "TARGET";
	_unit enableAI "AUTOTARGET";
	_unit setUnitPos "AUTO";
	_unit setUnitLoadout _loadOut;
};