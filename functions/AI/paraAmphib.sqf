/*
 * Name:	paraAmphib
 * Date:	10/03/2023
 * Version: 1.0
 * Author:  JB
 *
 * Description:
 * Para + Amphibious functions
 *
 * Parameter(s):
 * _PARAM1 (TYPE): - DESCRIPTION.
 * _PARAM2 (TYPE): - DESCRIPTION.
 */

scriptName "paraAmphib";

params ["_groupX", "_marker", "_pos", "_paras", "_numNonParas"];

_veh = vehicle leader _groupX;

deleteMarker _marker;

if (typeOf _veh in ["LIB_C47_Skytrain","LIB_C47_RAF"]) then {
	{ 
	[_veh,_x] spawn LIB_fnc_deployStaticLine; 
	sleep 0.3;
	[_x] spawn {		
    	_unit = _this select 0;
   		waitUntil {sleep 1; (getPos _unit) select 2 < 50};
   		waitUntil {sleep 0.1; (getPos _unit) select 2 < 20};
   		_unit allowDamage false;
   		waitUntil {sleep 1; isTouchingGround _unit};
   		sleep 2;
   		_unit allowDamage true;
   	};	
	} forEach _paras;

	if (_numNonParas > 0) then {["Paradrop", "There are some non-paratoopers on this plane, they will not, funnily enough, be jumping out..."] call A3A_fnc_customHint;};
} else {

	_veh = vehicle leader _groupX;
	waitUntil {sleep 1; isTouchingGround _veh};
	_veh forceSpeed 0;	
	waitUntil {sleep 1; speed _veh == 0}; 
	sleep 2;  
	private _cargoInf = fullCrew [_veh, "cargo"];  
 	private _cargoVeh = getVehicleCargo _veh;  
 
	if (count _cargoInf > 0) then {  
  		_Deployment_Actions = getArray (configFile >> "CfgVehicles" >> (typeOf _veh) >> "LIB_Deployment_Actions");  
  		{  
  		_veh spawn compile ("this = _this;" + (getText (configFile >> "CfgVehicles" >> (typeOf _veh) >> "UserActions" >> _x >> "statement")));    
  		} foreach _Deployment_Actions;  
 	};  
 	if ((count _cargoInf == 0) && (count _cargoVeh > 0)) then {  
		{  
  		_Deployment_Actions = getArray (configFile >> "CfgVehicles" >> (typeOf _veh) >> "LIB_Deployment_Actions");  
  		{  
  		_veh spawn compile ("this = _this;" + (getText (configFile >> "CfgVehicles" >> (typeOf _veh) >> "UserActions" >> _x >> "statement")));    
  		} foreach _Deployment_Actions;  
  		sleep 5;  
  		objNull setVehicleCargo _x;  
  		sleep 1;  
  		} forEach _cargoVeh;  
 		};  
		sleep 20; _veh animateSource ["ramp_rotate",0];
		_veh forceSpeed -1;
};

