params ["_vehicleType", "_pos", "_dir"];

private _garageVeh = createVehicle [_vehicleType, [0,0,1000], [], 0, "NONE"];

if (_vehicleType == "LIB_leFH18") then {
	_garageVeh setObjectTextureGlobal [0, "ww2\assets_t\vehicles\staticweapons_t\i44_lefh18\lefh18_2tone_co.paa"];
};

if (_garageVeh isKindOf "Air") then {
	for "_i" from 1 to 25 do { 
	_garageVeh setPylonLoadout [_i, ""]; 
	};
};

if (_vehicleType == "IG_supplyCrate_F") then {
	[_garageVeh] remoteExec ["A3A_fnc_truckFunctions", [teamPlayer,civilian], _garageVeh];
};

if (_vehicleType == vehSDKAA) then {
	_garageVeh animateSource ['stoiki_hide', 1];
	_aaMount = createVehicle ["LIB_FlaK_38", [0,0,1100], [], 0, "NONE"];
	_aaMount animateSource ['Hide_Shield', 1];
	_aaMount animateSource ['Hide_Shield_Sight', 1];
	_aaMount animateSource ['Hide_Shield_Small', 1];
	_aaMount attachTo [_garageVeh, [0,-2,0.175]];
};

if (_vehicleType == M2MGStatic) then {
	_garageVeh animateSource ['Hide_Shield', 1];
};


_garageVeh setDir _dir;
//Set position exactly

private _vectorAdd = [];
switch (true) do
{
	case (_vehicleType in [vehSDKBike,vehSDKLightUnarmed,vehSDKLightArmed]): {_vectorAdd = [0,0,-0.3]};
	case (_vehicleType in [vehSDKTruck,vehSDKTruckClosed,vehSDKAmmo]): {_vectorAdd = [0,0,-1.25]};
	case (_vehicleType in [vehSDKRepair]): {_vectorAdd = [0,0,-0.65]};
	case (_vehicleType in [vehSDKFuel]): {_vectorAdd = [0,0,-0.75]};
	case (_vehicleType in [vehSDKMedical]): {_vectorAdd = [0,0,-1.6]};
	case (_vehicleType in [vehSDKHeavyArmed]): {_vectorAdd = [0,0,-1.1]};
	case (_vehicleType in [vehSDKAPCUS,vehSDKAPCUK2]): {_vectorAdd = [0,0,-0.9]};
	case (_vehicleType in [vehSDKAA]): {_vectorAdd = [0,0,-0.96]};
	case (_vehicleType in [vehSDKAT]): {_vectorAdd = [0,0,-1.15]};
	case (_vehicleType in [vehSDKTankUSM4,vehSDKTankUKM4]): {_vectorAdd = [0,0,-0.1]};
	case (_vehicleType in [staticAAteamPlayer]): {_vectorAdd = [0,0,0.3]};
	case (_vehicleType in [vehSDKPlaneUK2]): {_vectorAdd = [0,0,-1.7]};
	case (_vehicleType in [vehSDKPlaneUK3]): {_vectorAdd = [0,0,-2.2]};
	case (_vehicleType in [vehSDKPlaneUS1,vehSDKPlaneUS2]): {_vectorAdd = [0,0,-1.9]};
	case (_vehicleType in [vehSDKTransPlaneUS,vehSDKTransPlaneUK]): {_vectorAdd = [0,0,-3.4]};
	case (_vehicleType in [vehUKPayloadPlane]): {_vectorAdd = [0,0,-3.3]};
	case (_vehicleType in [vehUSPayloadPlane]): {_vectorAdd = [0,0,-2.9]};		
	
	default {_vectorAdd = [0,0,0]};
};

_garageVeh setPosASL (_pos vectorAdd _vectorAdd);

clearMagazineCargoGlobal _garageVeh;
clearWeaponCargoGlobal _garageVeh;
clearItemCargoGlobal _garageVeh;
clearBackpackCargoGlobal _garageVeh;

_garageVeh allowDamage true;
_garageVeh enableSimulation true;

_garageVeh;
