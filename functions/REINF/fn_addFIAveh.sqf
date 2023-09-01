
if (!(isNil "placingVehicle") && {placingVehicle}) exitWith {["Deploy Vehicle", "Unable to deploy vehicle, you are already placing something."] call A3A_fnc_customHint;};
if (player != player getVariable ["owner",player]) exitWith {["Deploy Vehicle", "You cannot deploy vehicles while you are controlling AI."] call A3A_fnc_customHint;};
if ([player,300] call A3A_fnc_enemyNearCheck) exitWith {["Deploy Vehicle", "You cannot deploy vehicles with enemies nearby."] call A3A_fnc_customHint;};


private _typeVehX = _this select 0;
if (_typeVehX == "not_supported") exitWith {["Deploy Vehicle", "The vehicle you requested is not supported in your current modset."] call A3A_fnc_customHint;};

vehiclePurchase_cost = [_typeVehX] call A3A_fnc_vehiclePrice;

private _resourcesFIA = 0;


if (player != theBoss) then {
	_resourcesFIA = player getVariable "moneyX";
} else {
	private _factionMoney = server getVariable "resourcesFIA";
	if (vehiclePurchase_cost <= _factionMoney) then {
		_resourcesFIA = _factionMoney;
	} else {
		_resourcesFIA = player getVariable "moneyX";
	};
};

if (_resourcesFIA < vehiclePurchase_cost) exitWith {["Deploy Vehicle", format ["You do not have enough CP for this vehicle: %1%2 required.",vehiclePurchase_cost, currencySymbol]] call A3A_fnc_customHint;};
vehiclePurchase_nearestMarker = [markersX select {sidesX getVariable [_x,sideUnknown] == teamPlayer},player] call BIS_fnc_nearestPosition;

if (!(player inArea vehiclePurchase_nearestMarker) && count (nearestObjects [player, [vehSDKAmmo], 200]) == 0) exitWith {["Deploy Vehicle", "You need to be closer to the flag or ammo truck to be able to deploy a vehicle."] call A3A_fnc_customHint;};

if (server getVariable (_typeVehX + "_count") < 1) exitWith {["Deploy Vehicle", "There are none of this vehicle available."] call A3A_fnc_customHint;};

private _extraMessage =	format ["Deploying vehicle for %1%2.", vehiclePurchase_cost, currencySymbol];

[["UpdateState", "Buys vehicle at HQ"]] call SCRT_fnc_misc_updateRichPresence;

[_typeVehX, "BUYFIA", _extraMessage] call A3A_fnc_vehPlacementBegin;