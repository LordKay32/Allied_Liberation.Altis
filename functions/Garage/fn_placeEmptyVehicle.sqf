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

_garageVeh setDir _dir;
//Set position exactly
_garageVeh setPosASL _pos;

clearMagazineCargoGlobal _garageVeh;
clearWeaponCargoGlobal _garageVeh;
clearItemCargoGlobal _garageVeh;
clearBackpackCargoGlobal _garageVeh;

_garageVeh allowDamage true;
_garageVeh enableSimulation true;

_garageVeh;
