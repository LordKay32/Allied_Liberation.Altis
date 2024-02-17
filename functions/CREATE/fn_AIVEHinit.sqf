/*
	Installs various damage/smoke/kill/capture logic for vehicles
	Will set and modify the "originalSide" and "ownerSide" variables on the vehicle indicating side ownership
	If a rebel enters a vehicle, it will be switched to rebel side and added to vehDespawner

	Params:
	1. Object: Vehicle object
	2. Side: Side ownership for vehicle
*/

private _filename = "fn_AIVEHinit";
params ["_veh", "_side", ["_excludeTrails", false]];
if (isNil "_veh") exitWith {};

if !(isNil { _veh getVariable "ownerSide" }) exitWith
{
	// vehicle already initialized, just swap side and exit
	[_veh, _side] call A3A_fnc_vehKilledOrCaptured;
};

_veh setVariable ["originalSide", _side, true];
_veh setVariable ["ownerSide", _side, true];

// probably just shouldn't be called for these
if ((_veh isKindOf "Building") or (_veh isKindOf "ReammoBox_F")) exitWith {};

// this might need moving into a different function later
if (_side == teamPlayer) then
{
	clearMagazineCargoGlobal _veh;			// might need an exception on this for vehicle weapon mags?
	clearWeaponCargoGlobal _veh;
	clearItemCargoGlobal _veh;
	clearBackpackCargoGlobal _veh;
} else {
	clearWeaponCargoGlobal _veh;
};

// Sync the vehicle textures if necessary
_veh call A3A_fnc_vehicleTextureSync;

private _typeX = typeOf _veh;

//JB - add service vehicle functions
[_veh] remoteExec ["A3A_fnc_truckFunctions"];

if (_side != teamPlayer) then {
	//JB - unflip enemy Ai Vehs
	_veh addEventHandler ["GetOut", {
		private _vehicle = param [0, objNull, [objNull]];
		if !((crew _vehicle) isEqualTo []) exitWith {}; //skip if anyone still in veh
		(_vehicle call BIS_fnc_getPitchBank) params ["_vx","_vy"];
		if (([_vx,_vy] findIf {_x > 80 || _x < -80}) != -1) then {	
			0 = [_vehicle] spawn {
				private _vehicle = param [0, objNull, [objNull]];
				waitUntil {(_vehicle nearEntities ["Man", 5]) isEqualTo [] || !alive _vehicle};
				if (!alive _vehicle) exitWith {};
				_vehicle allowDamage false;
				_vehicle setVectorUp [0,0,1];
				_vehicle setPosATL [(getPosATL _vehicle) select 0, (getPosATL _vehicle) select 1, 0];
				_vehicle allowDamage true;
			};
		};
	}];
	//JB - kill count
	_veh addEventHandler ["Killed", {
	params ["_unit", "_killer", "_instigator", "_useEffects"];
	if (side (group _killer) == teamPlayer) then {
		occupantVehKilled = occupantVehKilled + 1;
		publicVariable "occupantVehKilled";
		if (typeName _killer != "OBJECT") exitWith {};
		if (isPlayer _killer) then {
			occupantVehKilledByPlayers = occupantVehKilledByPlayers + 1;
			publicVariable "occupantVehKilledByPlayers";
		};
	};
	}];
	[_veh, _side] spawn {
		params ["_veh", "_side"];
		waitUntil {sleep 5; _veh getVariable ["ownerSide", _side] == teamPlayer};
		vehiclesCaptured = vehiclesCaptured + 1;
		publicVariable "vehiclesCaptured";
		_veh removeEventHandler ["GetOut", 0];
		_veh removeEventHandler ["Killed", 0];
		_veh addEventHandler ["Killed", {
			teamPlayerVehKilled = teamPlayerVehKilled + 1;
			publicVariable "teamPlayerVehKilled";
		}];
	};
};

if (_side == teamPlayer) then {
	_veh addEventHandler ["Killed", {
		teamPlayerVehKilled = teamPlayerVehKilled + 1;
		publicVariable "teamPlayerVehKilled";
	}];
};

if (_typeX in (vehNATONormal + vehNATOAPC)) then {
	_veh addEventHandler ["GetIn", {private ["_veh"];_veh = _this select 0; _base = [((airportsX + milbases + outposts + seaports + factories + resourcesX + ["Synd_HQ"]) select {sidesX getVariable [_x,sideUnknown] == teamPlayer}), getPos _veh] call BIS_fnc_nearestPosition; if ((side (_this select 2) in [teamPlayer, civilian]) && (_veh inArea _base) && !(_veh getVariable ["friendly", false])) then {_veh setVariable ["friendly",true,true]}}];
};

if (_typeX in ["fow_w_mg42_deployed_high_ger_heer","fow_w_mg42_deployed_middle_ger_heer"]) then {
	_veh addEventHandler ["GetOut", {
		params ["_vehicle", "_role", "_unit", "_turret", "_isEject"];
		_vehicle setDamage 1;
	}];
};

if ((_side == teamPlayer) && (_typeX == staticATteamPlayer)) then {
_veh addEventHandler ["Fired", { 
params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"]; 

if !(isPlayer (gunner _unit)) then {
	_target = getAttackTarget _unit; 
	if (_target isKindOf "man") then { 
		_unit loadMagazine [[0], "fow_w_57mm_6Pdr", "fow_30Rnd_57mm_HE"]; 
	} else {
		_unit loadMagazine [[0], "fow_w_57mm_6Pdr", "fow_10Rnd_57mm_APCR"];
	};
};
}];
};

if (_typeX in vehNormal || {_typeX in (vehAttack + vehBoats + vehAA)}) then {

	if !(_typeX in vehAttack) then {
		if (_veh isKindOf "Car") then {
			_veh addEventHandler ["HandleDamage",{if (((_this select 1) find "wheel" != -1) and ((_this select 4=="") or (side (_this select 3) != teamPlayer)) and (!isPlayer driver (_this select 0))) then {0} else {(_this select 2)}}];
			if ({"SmokeLauncher" in (_veh weaponsTurret _x)} count (allTurrets _veh) > 0) then
			{
				_veh setVariable ["within",true];
				_veh addEventHandler ["GetOut", {private ["_veh"]; _veh = _this select 0; if (side (_this select 2) != teamPlayer) then {if (_veh getVariable "within") then {_veh setVariable ["within",false]; [_veh] call A3A_fnc_smokeCoverAuto}}}];
				_veh addEventHandler ["GetIn", {private ["_veh"]; _veh = _this select 0; if (side (_this select 2) != teamPlayer) then {_veh setVariable ["within",true]}}];
			};
		};
	}
	else {
		if (_typeX in vehAPCs) then
		{
			_veh addEventHandler ["HandleDamage",{private ["_veh"]; _veh = _this select 0; if (!canFire _veh) then {[_veh] call A3A_fnc_smokeCoverAuto; _veh removeEventHandler ["HandleDamage",_thisEventHandler]};if (((_this select 1) find "wheel" != -1) and (_this select 4=="") and (!isPlayer driver (_veh))) then {0;} else {(_this select 2);}}];
			_veh setVariable ["within",true];
			_veh addEventHandler ["GetOut", {private ["_veh"];  _veh = _this select 0; if (side (_this select 2) != teamPlayer) then {if (_veh getVariable "within") then {_veh setVariable ["within",false];[_veh] call A3A_fnc_smokeCoverAuto}}}];
			_veh addEventHandler ["GetIn", {private ["_veh"];_veh = _this select 0; if (side (_this select 2) != teamPlayer) then {_veh setVariable ["within",true]}}];
		}
		else
		{
			if (_typeX in vehTanks) then
			{
				_veh addEventHandler ["HandleDamage",{private ["_veh"]; _veh = _this select 0; if (!canFire _veh) then {[_veh] call A3A_fnc_smokeCoverAuto;  _veh removeEventHandler ["HandleDamage",_thisEventHandler]}}];
				_veh addEventHandler ["GetIn", {
					_veh = _this select 0;
					_role = _this select 1;
					_unit = _this select 2;
					if ((typeOf _veh in vehNATOTanks) and (side group _unit == teamPlayer)) exitWith 
					{
						moveOut _unit;
						["General", "You are not trained to operate German tanks"] call A3A_fnc_customHint;
					};
					if (!((_unit getVariable "unitType") in [USCrew,UKCrew]) and (!isPlayer _unit) and (_unit getVariable ["spawner",false]) and (side group _unit == teamPlayer) and !(_role == "cargo")) then
					{
						moveOut _unit;
						["General", "Only tank crews can crew tanks"] call A3A_fnc_customHint;
					};
				}];
			}
			else		// never called? vehAttack is APCs+tank
			{
				_veh addEventHandler ["HandleDamage",{if (((_this select 1) find "wheel" != -1) and ((_this select 4=="") or (side (_this select 3) != teamPlayer)) and (!isPlayer driver (_this select 0))) then {0} else {(_this select 2)}}];
			};
		};
	};
} else {
	if (_typeX in vehPlanes) then {
		
		if (_side == teamPlayer) then {
			[_veh] spawn {
				params ["_plane"];
				private _markerX = "";
				waitUntil {sleep 1; _markerX = ([(airportsX + milbases + outposts + seaports + resourcesX + factories) select {sidesX getVariable [_x,sideUnknown] != teamPlayer}, getPos _plane] call BIS_fnc_nearestPosition); _plane distance2D getMarkerPos _markerX < 2000};
				_sideX = sidesX getVariable [_markerX,sideUnknown];
				_typePlaneX = if (_sideX == Occupants) then {selectRandom vehNATOPlanesAA} else {selectRandom vehCSATPlanesAA};
				_potOrigins = if (_markerX in airportsX) then {(airportsX - [_markerX]) select {sidesX getVariable [_x,sideUnknown] == _sideX}} else {airportsX select {sidesX getVariable [_x,sideUnknown] == _sideX}};
				_origin = getMarkerPos ([_potOrigins, getPos _plane] call BIS_fnc_nearestPosition);
				_spawnPos = _origin vectorAdd [0, 0, 250];
				_planeInfo = [_spawnPos, 0, _typePlaneX, _sideX] call A3A_fnc_spawnVehicle;
				_enemyPlane = _planeInfo select 0;
				_planeCrew = _planeInfo select 1;
				_groupPlane = _planeInfo select 2;
				{_nul = [_x,""] call A3A_fnc_NATOinit} forEach _planeCrew;
				[_enemyPlane, _sideX] call A3A_fnc_AIVEHinit;
				_enemyPlane setVelocityModelSpace [0, 400, 0];
				_attackWP = _groupPlane addWaypoint [getPos _plane, 3];
	            _attackWP setWaypointType "DESTROY";
    	        _attackWP waypointAttachObject _plane;
    	        _attackWP setWaypointSpeed "FULL";
    	        _groupPlane setCurrentWaypoint _attackWP;
    	        _groupPlane setBehaviour "COMBAT";
    	        _groupPlane setCombatMode "RED";
			};
		};

		if (_side == teamPlayer) then {
			[_veh] spawn {
				params ["_plane"];
				private _markerX = "";
				while {alive _plane} do {
					waitUntil {sleep 1; _markerX = ([(airportsX + milbases + outposts + seaports) select {sidesX getVariable [_x,sideUnknown] != teamPlayer}, getPos _plane] call BIS_fnc_nearestPosition); _plane distance2D getMarkerPos _markerX < 2000 && spawner getVariable _markerX == 2};
					_sideX = sidesX getVariable [_markerX,sideUnknown];
					_type = if (_sideX == Occupants) then {selectRandom vehNATOAA} else {selectRandom vehCSATAA};
					_position = getMarkerPos _markerX findEmptyPosition [5,100,_type];
					_aaVehicleData = [_position, random 360, _type, _sideX] call A3A_fnc_spawnVehicle;
					_aaVehicle = _aaVehicleData select 0;
            		_aaVehicleCrew = _aaVehicleData select 1;
            		_aaVehicleGroup = _aaVehicleData select 2;
					{[_x,_markerX] call A3A_fnc_NATOinit} forEach _aaVehicleCrew;
            		[_aaVehicle, _sideX] call A3A_fnc_AIVEHinit;
            		_aaVehicleGroup reveal [_plane, 4];
					waitUntil {sleep 1; _plane distance getMarkerPos _markerX > 2000 || spawner getVariable _markerX == 0 || !alive _plane};
					{deleteVehicle _x} forEach _aaVehicleCrew;
					deleteGroup _aaVehicleGroup;
					deleteVehicle _aaVehicle;
				};
			};
		};

		_veh addEventHandler ["GetIn",
		{
			_veh = _this select 0;
			_unit = _this select 2;
			if ((typeOf _veh in (vehNATOPlanes + vehNATOPlanesAA + vehNATOTransportPlanes)) and (side group _unit == teamPlayer)) then 
			{
				moveOut _unit;
				["General", "You are not trained to operate German aircraft"] call A3A_fnc_customHint;
			};
			if (!((_unit getVariable "unitType") in [USPilot,UKPilot]) and (!isPlayer _unit) and (_unit getVariable ["spawner",false]) and (side group _unit == teamPlayer)) then
			{
				moveOut _unit;
				["General", "Only pilots can crew an aircraft"] call A3A_fnc_customHint;
			};
		}];
		
		_veh addEventHandler ["GetIn",
		{
			_unit = _this select 2;
			if (side group _unit == teamPlayer) then
			{
				_unit setVariable ["spawner",nil,true];
			};
		}];
		
		_veh addEventHandler ["GetOut",
		{
			_unit = _this select 2;
			if (side group _unit == teamPlayer) then
			{
				_unit setVariable ["spawner",true,true];
			};
		}];
		
		if (_veh isKindOf "Helicopter") then {
			if (_typeX in vehTransportAir) then {
				_veh setVariable ["within",true];
				_veh addEventHandler ["GetOut", {private ["_veh"];_veh = _this select 0; if ((isTouchingGround _veh) and (isEngineOn _veh)) then {if (side (_this select 2) != teamPlayer) then {if (_veh getVariable "within") then {_veh setVariable ["within",false]; [_veh] call A3A_fnc_smokeCoverAuto}}}}];
				_veh addEventHandler ["GetIn", {private ["_veh"];_veh = _this select 0; if (side (_this select 2) != teamPlayer) then {_veh setVariable ["within",true]}}];
			};
		};
	}
	else
	{
		if (_veh isKindOf "StaticWeapon") then
		{
			_veh setCenterOfMass [(getCenterOfMass _veh) vectorAdd [0, 0, -1], 0];

			if !(_typeX isKindOf "StaticMortar") then {
				[_veh, "static"] remoteExec ["A3A_fnc_flagAction", [teamPlayer,civilian], _veh];
				if (_side == teamPlayer && !isNil {serverInitDone}) then { [_veh] remoteExec ["A3A_fnc_updateRebelStatics", 2] };
			};
		};
	};
};

if (_side == civilian) then
{
	_veh addEventHandler ["HandleDamage",{if (((_this select 1) find "wheel" != -1) and (_this select 4=="") and (!isPlayer driver (_this select 0))) then {0;} else {(_this select 2);};}];
	_veh addEventHandler ["HandleDamage", {
		_veh = _this select 0;
		if (side(_this select 3) == teamPlayer) then
		{
			_driverX = driver _veh;
			if (side group _driverX == civilian) then {_driverX leaveVehicle _veh};
			_veh removeEventHandler ["HandleDamage", _thisEventHandler];
		};
	}];
};

private _artilleryTypes = vehMRLS + additionalShopArtillery + [CSATMortar, NATOMortar, SDKMortar, SDKArtillery];
if (NATOHowitzer != "not_supported") then {_artilleryTypes pushBack NATOHowitzer};
if (CSATHowitzer != "not_supported") then {_artilleryTypes pushBack CSATHowitzer};

if(_typeX in _artilleryTypes) then {
    [_veh, ["Fired", SCRT_fnc_common_triggerArtilleryResponseEH]] remoteExec ["addEventHandler", 2];
	if (!_excludeTrails) then {
		[_veh] call A3A_fnc_addArtilleryTrailEH;
	};
};

// EH behaviour:
// GetIn/GetOut/Dammaged: Runs where installed, regardless of locality
// Local: Runs where installed if target was local before or after the transition
// HandleDamage/Killed: Runs where installed, only if target is local
// MPKilled: Runs everywhere, regardless of target locality or install location
// Destruction is handled in an EntityKilled mission event handler, in case of locality changes

if (_side != teamPlayer) then
{
	// Vehicle stealing handler
	// When a rebel first enters a vehicle, fire capture function
	_veh addEventHandler ["GetIn", {
		params ["_veh", "_role", "_unit", "_turret"];
		if (typeName _unit != "OBJECT") exitWith {};
		if (side (group _unit) != teamPlayer) exitWith {};		// only rebels can flip vehicles atm
		private _oldside = _veh getVariable ["ownerSide", teamPlayer];
		if (_oldside != teamPlayer) then
		{
			[3, format ["%1 switching side from %2 to rebels", typeof _veh, _oldside], "fn_AIVEHinit"] call A3A_fnc_log;
			[_veh, teamPlayer, true] call A3A_fnc_vehKilledOrCaptured;
		};
		_veh removeEventHandler ["GetIn", _thisEventHandler];
	}];
};

if(_veh isKindOf "Air") then
{
    //Start airspace control script if rebel player enters
    _veh addEventHandler
    [
        "GetIn",
        {
            params ["_veh", "_role", "_unit"];
            if((side (group _unit) == teamPlayer) && {isPlayer _unit}) then
            {
                [_veh] spawn A3A_fnc_airspaceControl;
            };
        }
    ];


    _veh addEventHandler
    [
        "IncomingMissile",
        {
            params ["_target", "_ammo", "_vehicle", "_instigator"];

			if ((random 100) > 10) exitWith {}; 

            private _group = group driver _target;
            private _supportTypes = [_group, _vehicle] call A3A_fnc_chooseSupport;
            _supportTypes = _supportTypes - ["QRF"];
            private _reveal = [getPos _vehicle, side _group] call A3A_fnc_calculateSupportCallReveal;
            [_vehicle, 4, _supportTypes, side _group, _reveal] remoteExec ["A3A_fnc_sendSupport", 2];
        }
    ]
};

// Handler to prevent vehDespawner deleting vehicles for an hour after rebels exit them

_veh addEventHandler ["GetOut", {
	params ["_veh", "_role", "_unit"];
	if !(_unit isEqualType objNull) exitWith {
		[1, format ["GetOut handler weird input: %1, %2, %3", _veh, _role, _unit], "fn_AIVEHinit"] call A3A_fnc_log;
	};
	if (side group _unit == teamPlayer) then {
		_veh setVariable ["despawnBlockTime", time + 7200];			// despawner always launched locally
	};
}];


//add logistics loading to loadable objects
if([typeOf _veh] call A3A_fnc_logistics_isLoadable) then {[_veh] call A3A_fnc_logistics_addLoadAction;};

// deletes vehicle if it exploded on spawn...
[_veh] spawn A3A_fnc_cleanserVeh;