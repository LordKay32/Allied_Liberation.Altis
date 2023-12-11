/*
 * Name:	fn_carrierLaunch
 * Date:	9/11/2023
 * Version: 1.0
 * Author:  JB
 *
 * Description:
 * Launch AI plane from carrier
 *
 * Parameter(s):
 * _PARAM1 (TYPE): DESCRIPTION.
 * _PARAM2 (TYPE): DESCRIPTION.
 *
 * Returns:
 * %RETURNS%
 */

params ["_vehicle"];
waitUntil {sleep 1; unitReady (driver _vehicle) == false};
    			
_carrierObjects = nearestObjects [_vehicle, ["Land_Carrier_01_hull_04_1_F","Land_Carrier_01_hull_04_2_F","Land_Carrier_01_hull_07_1_F"], 10];  
 
_carrierPart = _carrierObjects select 0;  
 
_launchSite = (nearestObjects [_vehicle, ["Land_ClutterCutter_medium_F"], 10]) select 0;  
 
_catapult = ""; 
_launchObject = ""; 
 
if (_launchSite == planeSpawn_1) then {_catapult = "Catapult1"; _launchObject = "Land_Carrier_01_hull_04_2_F"}; 
if (_launchSite == planeSpawn_2) then {_catapult = "Catapult1"; _launchObject = "Land_Carrier_01_hull_04_1_F"}; 
if (_launchSite == planeSpawn_3) then {_catapult = "Catapult3"; _launchObject = "Land_Carrier_01_hull_07_1_F"}; 
if (_launchSite == planeSpawn_4) then {_catapult = "Catapult4"; _launchObject = "Land_Carrier_01_hull_07_1_F"}; 
 
_carrierPartCfgCatapult = configfile >> "CfgVehicles" >> _launchObject >> "Catapults" >> _catapult;  
_carrierPartanimations = getArray (_carrierPartCfgCatapult >> "animations");  
 
[_carrierPart, _carrierPartanimations, 10] spawn BIS_fnc_Carrier01AnimateDeflectors;

sleep 15;

[_vehicle, (getDir _vehicle)] call BIS_fnc_aircraftCatapultLaunch;

sleep 5;

[_carrierPart, _carrierPartanimations, 0] spawn BIS_fnc_Carrier01AnimateDeflectors;