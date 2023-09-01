private _positionOrigin = getMarkerPos supportMarkerOrigin;
private _positionDestination = getMarkerPos supportMarkerDestination;
private _angle = [_positionOrigin, _positionDestination] call BIS_fnc_dirTo;
private _angleOrigin = _angle - 180;

private _originPosition = [_positionOrigin, 5000, _angleOrigin] call BIS_fnc_relPos;
private _finPosition = [_positionDestination, 5000, _angle] call BIS_fnc_relPos;
private _groundHeight = getTerrainHeightASL _positionOrigin;

private _planeData = [_originPosition, _angle, selectRandom [vehUSPayloadPlane,vehUKPayloadPlane], teamPlayer] call A3A_fnc_spawnVehicle;
private _plane = _planeData select 0;
private _planeCrew = _planeData select 1;
private _groupPlane = _planeData select 2;
{[_x,""] call A3A_fnc_FIAInit; _x setVariable ["spawner",nil,true]} forEach _planeCrew;


private _isHelicopter = _plane isKindOf "helicopter";

_plane setPosATL [getPosATL _plane select 0, getPosATL _plane select 1, 500];
_plane disableAI "TARGET";
_plane disableAI "AUTOTARGET";
_plane setVelocityModelSpace [0,300,0];
//private _minAltASL = ATLToASL [_positionDestination select 0, _positionDestination select 1, 0];
//_plane flyInHeightASL [(_minAltASL select 2) +120, (_minAltASL select 2) +120, (_minAltASL select 2) +120];

driver _plane sideChat "Starting plane run. ETA 30 seconds.";
private _wp1 = group _plane addWaypoint [_positionOrigin, 0];
_wp1 setWaypointType "MOVE";
if (!_isHelicopter) then { _wp1 setWaypointSpeed "FULL" };
_wp1 setWaypointBehaviour "CARELESS";
private _text = nil;
private _sleeptime = 50;

switch (supportType) do {
	case ("STATIC_MG_AIRDROP"): {
		_planeHeight = 175 + _groundHeight;
    	_plane flyInHeightASL [_planeHeight,_planeHeight,_planeHeight];
    	_MGCount = server getVariable (UKMGStatic + "_count");
        _MGCount = _MGCount - 1;
        server setVariable [UKMGStatic + "_count", _MGCount, true];
		_wp1 setWaypointStatements ["true", format ["if !(local this) exitWith {}; [this, '%1', '%2'] spawn SCRT_fnc_common_supplyDrop", "LIB_BasicWeaponsBox_UK", supportType]];
		_text = format ["<t size='0.6'>Allied aircraft have dropped the <t size='0.6' color='#804000'>HMG</t> near your position.</t>"];
	};
	case ("SUPPLY"): {
		_planeHeight = 175 + _groundHeight;
    	_plane flyInHeightASL [_planeHeight,_planeHeight,_planeHeight];
		_wp1 setWaypointStatements ["true", format ["if !(local this) exitWith {}; [this, '%1', '%2'] spawn SCRT_fnc_common_supplyDrop", "LIB_BasicAmmunitionBox_US", supportType]];
		_text = format ["<t size='0.6'>Allied aircraft have dropped the <t size='0.6' color='#0000ff'>supply crate</t> near your position.</t>"];
	};
	case ("VEH_AIRDROP"): {
		_planeHeight = 175 + _groundHeight;
    	_plane flyInHeightASL [_planeHeight,_planeHeight,_planeHeight];
    	_vehCount = server getVariable (vehSDKLightUnarmed + "_count");
        _vehCount = _vehCount - 1;
        server setVariable [vehSDKLightUnarmed + "_count", _vehCount, true];
		_wp1 setWaypointStatements ["true", format ["if !(local this) exitWith {}; [this, '%1', '%2'] spawn SCRT_fnc_common_supplyDrop", vehSDKLightUnarmed, supportType]];
		_text = format ["<t size='0.6'>Allied aircraft have dropped the <t size='0.6' color='#804000'>light vehicle</t> near your position.</t>"];
	};
	case ("LOOTCRATE_AIRDROP"): {
		_planeHeight = 400 + _groundHeight;
    	_plane flyInHeightASL [_planeHeight,_planeHeight,_planeHeight];
		_wp1 setWaypointStatements ["true", format ["if !(local this) exitWith {}; [this, '%1', '%2'] spawn SCRT_fnc_common_supplyDrop", lootCrate, supportType]];
		_text = format ["<t size='0.6'>Allied aircraft have dropped the <t size='0.6' color='#010100'>loot crate</t> near your position.</t>"];
	};
	case ("NAPALM");
    case ("HE");
    case ("CLUSTER");
    case ("CHEMICAL"): {
    	_planeHeight = 800 + _groundHeight;
    	_plane flyInHeightASL [_planeHeight,_planeHeight,_planeHeight];
		_text = "<t size='0.6'>Allied aircraft are about to drop bombs near your position, take cover.";
		_sleeptime = 25;

		private _dropDistance = switch (supportType) do {
			case "CHEMICAL": {
				1;
			};
			case "NAPALM";
			case "CLUSTER": {
				1500;
			};
			default {
				1325;
			};
		};

		private _distance = _positionOrigin distance2D _positionDestination;
		private _bombParams = [_plane, supportType, _distance];

		(driver _plane) setVariable ["bombParams", _bombParams, true];

		[_positionOrigin, driver _plane, _dropDistance] spawn {
			params ["_pos", "_pilot", "_dropDistance"];
			waitUntil {sleep 0.1; ((_pos distance2D _pilot) < _dropDistance) || {isNull (objectParent _pilot)}};
			if(isNull (objectParent _pilot)) exitWith {};
			(_pilot getVariable 'bombParams') spawn A3A_fnc_airbombFIA;
		};
	};
};

_wp2 = group _plane addWaypoint [_positionDestination, 1];
if (!_isHelicopter) then { _wp2 setWaypointSpeed "LIMITED" };
_wp2 setWaypointType "MOVE";
_wp2 setWaypointStatements ["true", "isSupportMarkerPlacingLocked=false;publicVariable 'isSupportMarkerPlacingLocked';"];

_wp3 = group _plane addWaypoint [_finPosition, 2];
_wp3 setWaypointType "MOVE";
_wp3 setWaypointSpeed "FULL";

sleep _sleeptime;


if (canMove _plane && {alive _plane}) then {
	{
    	[petros, "support", _text] remoteExec ["A3A_fnc_commsMP", _x];
	} forEach ([1000, _positionDestination, teamPlayer] call SCRT_fnc_common_getNearPlayers);
};


private _timeOut = time + 600;
waitUntil { sleep 2; (currentWaypoint group _plane == 4) or (time > _timeOut) or !(canMove _plane) };

if (isSupportMarkerPlacingLocked) then {
    isSupportMarkerPlacingLocked = false;
    publicVariable "isSupportMarkerPlacingLocked";
};

if !(canMove _plane) then { sleep cleantime };
deleteVehicle _plane;
{deleteVehicle _x} forEach _planeCrew;
deleteGroup _groupPlane;