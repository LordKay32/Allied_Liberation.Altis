private ["_morty0","_mortarX","_pos","_typeX","_b0","_b1","_morty1", "_marker", "_ammoStatic"];

_groupX = _this select 0;
_morty0 = units _groupX select 0;
_morty1 = units _groupX select 1;
_morty2 = units _groupX select 2;
_morty3 = units _groupX select 3;
_typeX = _this select 1;
_ammoStatic = [];
if (_typeX == USMGStatic) then
	{
	_b0 = USMGStaticWeap;
	_b1 = USMGStaticSupp;
	_morty0 setVariable ["typeOfSoldier","StaticGunner"];
	_ammoStatic = [["fow_250Rnd_M1919",250],["fow_250Rnd_M1919",250],["fow_250Rnd_M1919",250],["fow_250Rnd_M1919",250]];
};
if (_typeX == UKMGStatic) then
	{
	_b0 = UKMGStaticWeap;
	_b1 = UKMGStaticSupp;
	_morty0 setVariable ["typeOfSoldier","StaticGunner"];
	_ammoStatic = [["fow_250Rnd_vickers",250],["fow_250Rnd_vickers",250],["fow_250Rnd_vickers",250],["fow_250Rnd_vickers",250]];
};
if (_typeX == SDKMortar) then
	{
	_b0 = "";
	_b1 = "";
	_morty0 setVariable ["typeOfSoldier","StaticMortar"];
	_ammoStatic = [["LIB_8Rnd_60mmHE_M2",8],["LIB_8Rnd_60mmHE_M2",8],["LIB_60mm_M2_SmokeShell",1],["LIB_60mm_M2_SmokeShell",1],["LIB_60mm_M2_SmokeShell",1],["LIB_60mm_M2_SmokeShell",1],["LIB_60mm_M2_SmokeShell",1],["LIB_60mm_M2_SmokeShell",1],["LIB_60mm_M2_SmokeShell",1],["LIB_60mm_M2_SmokeShell",1]];
};

_morty2 addBackpackGlobal _b0;
_morty3 addBackpackGlobal _b1;

while {(alive _morty2) and (alive _morty3)} do
	{
	waitUntil {sleep 1; {((unitReady _x) and (alive _x))} count units _groupX == count units _groupX};
	_pos = (_morty0 getRelPos [12,0]) findEmptyPosition [1,30,_typeX];
	_mortarX = _typeX createVehicle _pos;
	_mortarX setDir (getDir _morty0);
	_mortarX setVehicleAmmo 0;
	{
		_mortarX addMagazine [_x select 0, _x select 1]; 
	} forEach _ammoStatic;
	removeBackpackGlobal _morty2;
	removeBackpackGlobal _morty3;

// Removed as workaround for probable Arma AI bug with Podnos mortar + long distance (~200m) moves
// After a long move, non-gunner will attempt to move into the second mortar seat unless this is removed
//	_groupX addVehicle _mortarX;
	[_morty0] orderGetIn false;
	[_morty1] orderGetIn false;	
	_morty2 assignAsGunner _mortarX;
	[_morty2] orderGetIn true;
	[_morty2] allowGetIn true;
	if (_typeX == SDKMortar) then {
		
		private _textX = format ["%1 Mortar Squad", nameTeamPlayer];
		_marker = createMarker [format ["FIAMobilemortar%1", random 1000], getPos _morty2];
		_marker setMarkerShape "ICON";
		_marker setMarkerType "n_mortar";
		_marker setMarkerColor colorTeamPlayer;
		_marker setMarkerText _textX;
		mobilemortarsFIA = mobilemortarsFIA + [_marker]; publicVariable "mobilemortarsFIA";
		
		_morty3 assignAsCargo _mortarX;
		[_morty3] orderGetIn true;
		[_morty3] allowGetIn true;
	} else {[_morty3] orderGetIn false;};
	[_mortarX, side _groupX] call A3A_fnc_AIVEHinit;

	waitUntil {sleep 1; unitReady _morty0};
	waitUntil {sleep 1; ({!(alive _x)} count units _groupX != 0) or !(unitReady _morty0)};
	
	if ({!(alive _x)} count units _groupX != 0 && _typeX == SDKMortar) then {deleteMarker _marker};
	if (({(alive _x)} count units _groupX == count units _groupX) and !(unitReady _morty0)) then
		{
		unassignVehicle _morty2;
		moveOut _morty2;
		if (_typeX == SDKMortar) then {
			unassignVehicle _morty3;
			moveOut _morty3;
			deleteMarker _marker;
			mobilemortarsFIA = mobilemortarsFIA - [_marker]; publicVariable "mobilemortarsFIA";
		};
		_ammoStatic = magazinesAmmo _mortarX;
		deleteVehicle _mortarX;
		_morty2 addBackpackGlobal _b0;
		_morty3 addBackpackGlobal _b1;
		{
		[_x] orderGetIn true;
		} forEach units _groupX;
		};
	};