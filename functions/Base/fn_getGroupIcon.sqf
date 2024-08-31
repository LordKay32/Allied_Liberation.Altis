/*
 * Name:	fn_getGroupIcon
 * Date:	29/08/2024
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

params ["_veh", "_unit"];


private _group = group _unit;
private _vehType = typeOf _veh;
private _iconSide = if (side _unit == teamPlayer) then {"n"} else {"b"};
private _icon = call {
		if (_vehType in [vehSDKAT, vehSDKHeavyArmed,vehSDKAPCUK1,vehSDKAPCUK2,vehSDKAPCUS] + vehNATOAPC) exitWith {"mech_inf"};
   		if (_vehType in [vehSDKRepair,vehNATORepairTruck]) exitWith {"maint"};
   		if (_vehType in [vehSDKMedical,vehNATOMedical]) exitWith {"med"};
		if (_vehType in [vehSDKFuel,vehSDKAmmo,vehNATOFuelTruck,vehNATOAmmoTruck]) exitWith {"support"};		
   		if (_vehType in [vehSDKAA] + vehNATOAA) exitWith {"antiair"};
   		if (_vehType in [SDKArtillery,vehNATOMRLS]) exitWith {"art"};
		"antiair";
};
private _finalIcon = format ["%1_%2",_iconSide,_icon];

_finalIcon;