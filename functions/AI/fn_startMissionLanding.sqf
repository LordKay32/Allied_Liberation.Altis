/*
 * Name:	fn_startMissionLanding
 * Date:	18/12/2023
 * Version: 1.0
 * Author:  JB
 *
 * Description:
 * %DESCRIPTION%
 *
 * Parameter(s):
 * _PARAM1 (TYPE): DESCRIPTION.
 * _PARAM2 (TYPE): DESCRIPTION.
 *
 * Returns:
 * %RETURNS%
 */

params ["_boat"];
while {true} do {
	sleep 1;
	_boat setVelocityModelSpace [0, 8, 0];
	if ((isTouchingGround _boat) && (_boat inArea "landingZone1" || _boat inArea "landingZone2")) exitWith {
	
		sleep 3;
	
		private _cargoInf = fullCrew [_boat, "cargo"];  
		private _cargo_veh = getvehicleCargo _boat;  
	
		if (count _cargoInf > 0) then {  
			_Deployment_Actions = getArray (configFile >> "Cfgvehicles" >> (typeOf _boat) >> "LIB_Deployment_Actions");  
			{  
			_boat spawn compile ("this = _this;" + (getText (configFile >> "Cfgvehicles" >> (typeOf _boat) >> "UserActions" >> _x >> "statement")));    
			} foreach _Deployment_Actions;  
		};  
 		if ((count _cargoInf == 0) && (count _cargo_veh > 0)) then {  
			{  
  			_Deployment_Actions = getArray (configFile >> "Cfgvehicles" >> (typeOf _boat) >> "LIB_Deployment_Actions");  
  			{  
  			_boat spawn compile ("this = _this;" + (getText (configFile >> "Cfgvehicles" >> (typeOf _boat) >> "UserActions" >> _x >> "statement")));    
  			} foreach _Deployment_Actions;  
  			sleep 5;  
  			objNull setvehicleCargo _x;  
  			sleep 1;  
  			} forEach _cargo_veh;  
 		};
	 	sleep random [20,30,40];
	 	{_boat animate [_x, 0]} foreach ['shutter_rotate','ramp_rotate'];
	 	sleep 5;
		private _timer = 0;
		while {_timer < 180}	do {
			sleep 1;
			_timer = _timer + 1;
			_boat setVelocityModelSpace [0,-6, 0];
		};
	{
	deletevehicle _x;
	} forEach units group (driver _boat);
	deletevehicle _boat;		
	};
};