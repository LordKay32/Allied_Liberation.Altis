private ["_minRange","_maxRange","_groups","_artyArray","_artyRoundsArr","_hasAmmunition","_areReady","_hasArtillery","_areAlive","_soldierX","_veh","_typeAmmunition","_typeArty","_positionTel","_artyArrayDef1","_artyRoundsArr1","_piece","_isInRange","_positionTel2","_rounds","_roundsMax","_markerX","_size","_forcedX","_textX","_mrkFinal","_mrkFinal2","_timeX","_eta","_countX","_pos"];

private _chosen = hcSelected player;
hcShowBar false;
hcShowBar true;
if (count _chosen == 0) exitWith {["Artillery Support", "Choose an artillery group in HC."] call A3A_fnc_customHint};
if (count _chosen > 1) exitWith {["Artillery Support", "Choose only one artillery group in HC."] call A3A_fnc_customHint};

private _grp = _chosen select 0;
private _artyType = if (typeOf (vehicle (leader _grp)) == SDKArtillery) then {"artillery"} else {"mortar"};

switch (_artyType) do {
    case "mortar": {
    	_minRange = 250;
    	_maxRange = 1600;
		_groups = [_grp]
	};
    case "artillery": {
    	_minRange = 800;
    	_maxRange = 10000;
    	_groups = [_grp]
    };
};

player hcSelectGroup [_grp];

switch (true) do {
	case (_artyType == "artillery"): {

		if ([(getPos (leader _grp)), 300] call A3A_fnc_enemyNearCheck) exitWith {
			["Artillery Support", "This artillery crew cannot fire while there are enemies nearby."] call A3A_fnc_customHint;
		};
	};

	case (_artyType == "mortar"): {

		if ([(getPos (leader _grp)), 300] call A3A_fnc_enemyNearCheck) exitWith {
			["Artillery Support", "This mortar crew cannot fire while there are enemies nearby."] call A3A_fnc_customHint;
		};
	};
};	

_unitsX = [];
{_groupX = _x;
{_unitsX pushBack _x} forEach units _groupX;
} forEach _groups;
typeAmmunition = nil;
_artyArray = [];
_artyRoundsArr = [];

_hasAmmunition = 0;
_areReady = false;
_hasArtillery = false;
_areAlive = false;

{
_soldierX = _x;
_veh = vehicle _soldierX;
if ((_veh != _soldierX) and (not(_veh in _artyArray))) then
	{
	//if ((_artyType == "mortar") && (typeOf _veh == vehSDKLightUnarmed)
	if (( "Artillery" in (getArray (configfile >> "CfgVehicles" >> typeOf _veh >> "availableForSupportTypes")))) then
		{
		_hasArtillery = true;
		if ((canFire _veh) and (alive _veh) and (isNil "typeAmmunition")) then
			{
			_areAlive = true;
			if (typeOf _veh == SDKMortar) then {
				_nul = createDialog "mortarType"};
			if (typeOf _veh == SDKArtillery) then {
				typeAmmunition = SDKArtilleryHEMag};	
			waitUntil {!dialog or !(isNil "typeAmmunition")};
			if !(isNil "typeAmmunition") then
				{
				_typeAmmunition = typeAmmunition;
				{
				if (_x select 0 == _typeAmmunition) then
					{
					_hasAmmunition = _hasAmmunition + 1;
					};
				} forEach magazinesAmmo _veh;
				};
			if (_hasAmmunition > 0) then
				{
				if (unitReady _veh) then
					{
					_areReady = true;
					_artyArray pushBack _veh;
					_artyRoundsArr pushBack (((magazinesAmmo _veh) select 0)select 1);
					};
				};
			};
		};
	};
} forEach _unitsX;

if (!_hasArtillery) exitWith {["Artillery Support", "This artillery group has been incapacitated."] call A3A_fnc_customHint;};
if (!_areAlive) exitWith {["Artillery Support", "All elements in this Battery cannot fire or are disabled."] call A3A_fnc_customHint;};
if ((_hasAmmunition < 2) and (!_areReady)) exitWith {["Artillery Support", "The Battery has no ammo to fire. Reload it on HQ."] call A3A_fnc_customHint;};
if (!_areReady) exitWith {["Artillery Support", "Selected Battery is busy right now."] call A3A_fnc_customHint;};
if (_typeAmmunition == "not_supported") exitWith {["Artillery Support", "Your current modset doesent support this strike type."] call A3A_fnc_customHint;};
if (isNil "_typeAmmunition") exitWith {};

if (_typeAmmunition != "LIB_60mm_M2_SmokeShell") then
	{
	closedialog 0;
	createDialog "strikeType";
	}
else
	{
	typeArty = "NORMAL";
	};

waitUntil {!dialog or (!isNil "typeArty")};

if (isNil "typeArty") exitWith {};

_typeArty = typeArty;
typeArty = nil;


positionTel = [];

["artillerySupport", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;

private _centrePos = getPos (_artyArray select 0);
_mrkMin = createMarkerLocal [format ["mrkMin%1", random 100], _centrePos]; 
_mrkMin setMarkerShapeLocal "ELLIPSE"; 
_mrkMin setMarkerTypeLocal "hd_destroy"; 
_mrkMin setMarkerColorLocal "ColorRed";  
_mrkMin setMarkerSizeLocal [_minRange, _minRange];
_mrkMin setMarkerAlphaLocal 0.5;

_mrkMax = createMarkerLocal [format ["mrkMax%1", random 100], _centrePos]; 
_mrkMax setMarkerShapeLocal "ELLIPSE"; 
_mrkMax setMarkerTypeLocal "hd_destroy"; 
_mrkMax setMarkerColorLocal "ColorGreen";  
_mrkMax setMarkerSizeLocal [_maxRange, _maxRange];
_mrkMax setMarkerAlphaLocal 0.5;

["Artillery Support", "Select the position on map where to perform the Artillery strike."] call A3A_fnc_customHint;

if (!visibleMap) then {openMap true};
onMapSingleClick "positionTel = _pos;";

waitUntil {sleep 1; (count positionTel > 0) or (!visibleMap)};
onMapSingleClick "";

deleteMarker _mrkMin;
deleteMarker _mrkMax;

if (!visibleMap) exitWith {};

_positionTel = positionTel;

_artyArrayDef1 = [];
_artyRoundsArr1 = [];

for "_i" from 0 to (count _artyArray) - 1 do
	{
	_piece = _artyArray select _i;
	_isInRange = ((_positionTel distance _piece > _minRange) and (_positionTel distance _piece < _maxRange));
	if (_isInRange) then
		{
		_artyArrayDef1 pushBack _piece;
		_artyRoundsArr1 pushBack (_artyRoundsArr select _i);
		};
	};

if (count _artyArrayDef1 == 0) exitWith {["Artillery Support", "The position you marked is out of bounds for that Battery."] call A3A_fnc_customHint;};

_mrkFinal = createMarkerLocal [format ["Arty%1", random 100], _positionTel];
_mrkFinal setMarkerShapeLocal "ICON";
_mrkFinal setMarkerTypeLocal "hd_destroy";
_mrkFinal setMarkerColorLocal "ColorRed";

private _static = "";

{
_soldierX = _x;
_static = vehicle _soldierX;
if (_static != _soldierX) exitWith {};
} forEach _unitsX;

/*if (typeOf _static == SDKArtillery) then {
	private _originPos = getPos _static;
	private _targetPos = getMarkerPos _mrkFinal;
	private _dirVeh = getDir _static;
	private _dirTotarget = _originPos getDir _targetPos;
	
	private _inAngle = [_originPos, _dirVeh, 80, _targetPos] call BIS_fnc_inAngleSector;
	if (_inAngle) exitWith {};
	
	private _delta = [_dirTotarget,_dirVeh] call BIS_fnc_getAngleDelta;
	private _num = if (_delta < 0) then {-1} else {1};
		
	while {true} do {
		_dirVeh = _dirVeh + _num;
		if (_dirveh < 0) then {_dirveh = _dirveh + 360};
		if (_dirveh > 360) then {_dirveh = _dirveh - 360};
		_static setDir _dirVeh;
		if (round _dirVeh == round _dirTotarget) exitWith {};
		sleep 0.1;
	};
};*/

if (_typeArty == "BARRAGE") then
	{
	_mrkFinal setMarkerTextLocal "Artillery Barrage Begin";
	positionTel = [];

	["Artillery Support", "Select the position to finish the barrage."] call A3A_fnc_customHint;

	if (!visibleMap) then {openMap true};
	onMapSingleClick "positionTel = _pos;";

	waitUntil {sleep 1; (count positionTel > 0) or (!visibleMap)};
	onMapSingleClick "";

	_positionTel2 = positionTel;
	};

if ((_typeArty == "BARRAGE") and (isNil "_positionTel2")) exitWith {deleteMarkerLocal _mrkFinal};

if (_typeArty != "BARRAGE") then
	{
	if (_typeAmmunition != "LIB_60mm_M2_SmokeShell") then
		{
		closedialog 0;
		createDialog "roundsNumber";
		}
	else
		{
		roundsX = 1;
		};
	waitUntil {!dialog or (!isNil "roundsX")};
	};

if ((isNil "roundsX") and (_typeArty != "BARRAGE")) exitWith {deleteMarkerLocal _mrkFinal};

if (_typeArty != "BARRAGE") then
	{
	_mrkFinal setMarkerTextLocal "Arty Strike";
	_rounds = roundsX;
	_roundsMax = _rounds;
	roundsX = nil;
	}
else
	{
	_rounds = round (_positionTel distance _positionTel2) / 10;
	_roundsMax = _rounds;
	};

_markerX = [markersX,_positionTel] call BIS_fnc_nearestPosition;
_size = [_markerX] call A3A_fnc_sizeMarker;
_forcedX = false;

if ((not(_markerX in forcedSpawn)) and (_positionTel distance (getMarkerPos _markerX) < _size) and ((spawner getVariable _markerX != 0))) then
	{
	_forcedX = true;
	forcedSpawn pushBack _markerX;
	publicVariable "forcedSpawn";
	};

_textX = format ["Requesting fire support on Grid %1. %2 Rounds.", mapGridPosition _positionTel, round _rounds];
[theBoss,"sideChat",_textX] remoteExec ["A3A_fnc_commsMP",[teamPlayer,civilian]];

private _ang = 0;
if (_typeArty == "BARRAGE") then
	{
	_mrkFinal2 = createMarkerLocal [format ["Arty%1", random 100], _positionTel2];
	_mrkFinal2 setMarkerShapeLocal "ICON";
	_mrkFinal2 setMarkerTypeLocal "hd_destroy";
	_mrkFinal2 setMarkerColorLocal "ColorRed";
	_mrkFinal2 setMarkerTextLocal "Artillery Barrage End";
	_ang = [_positionTel,_positionTel2] call BIS_fnc_dirTo;
	sleep 5;
	_eta = (_artyArrayDef1 select 0) getArtilleryETA [_positionTel, ((getArtilleryAmmo [(_artyArrayDef1 select 0)]) select 0)];
	_timeX = time + _eta;
	_textX = format ["Acknowledged. Fire mission is inbound. ETA %1 secs for the first impact.",round _eta];
	[petros,"sideChat",_textX]remoteExec ["A3A_fnc_commsMP",[teamPlayer,civilian]];
	[_timeX] spawn
		{
		private ["_timeX"];
		_timeX = _this select 0;
		waitUntil {sleep 1; time > _timeX};
		[petros,"sideChat","Splash. Out"] remoteExec ["A3A_fnc_commsMP",[teamPlayer,civilian]];
		};
	};

_pos = [_positionTel,random 10,random 360] call BIS_fnc_relPos;

for "_i" from 0 to (count _artyArrayDef1) - 1 do
	{
	if (_rounds > 0) then
		{
		_piece = _artyArrayDef1 select _i;
		_countX = _artyRoundsArr1 select _i;
		//hint format ["roundsX que faltan: %1, roundsX que tiene %2",_rounds,_countX];
		if (_typeAmmunition == SDKMortarHEMag) then {_piece loadMagazine [[0], "LIB_M2_60", "LIB_60mm_M2_SmokeShell"]};
		if (_countX >= _rounds) then
			{
			if (_typeArty != "BARRAGE") then
				{
				_piece commandArtilleryFire [_pos,_typeAmmunition,_rounds];
				}
			else
				{
				for "_r" from 1 to _rounds do
					{
					_piece commandArtilleryFire [_pos,_typeAmmunition,1];
					sleep 2;
					_pos = [_pos,10,_ang + 5 - (random 10)] call BIS_fnc_relPos;
					};
				};
			_rounds = 0;
			}
		else
			{
			if (_typeArty != "BARRAGE") then
				{
				_piece commandArtilleryFire [[_pos,random 10,random 360] call BIS_fnc_relPos,_typeAmmunition,_countX];
				}
			else
				{
				for "_r" from 1 to _countX do
					{
					_piece commandArtilleryFire [_pos,_typeAmmunition,1];
					sleep 2;
					_pos = [_pos,10,_ang + 5 - (random 10)] call BIS_fnc_relPos;
					};
				};
			_rounds = _rounds - _countX;
			};
		};
	};

if (_typeArty != "BARRAGE") then
	{
	sleep 5;
	_eta = (_artyArrayDef1 select 0) getArtilleryETA [_positionTel, ((getArtilleryAmmo [(_artyArrayDef1 select 0)]) select 0)];
	_timeX = time + _eta - 5;
	if (isNil "_timeX") exitWith {
        diag_log format ["%1: [Antistasi] | ERROR | ArtySupport.sqf | Params: %2,%3,%4,%5",servertime,_artyArrayDef1 select 0,_positionTel,((getArtilleryAmmo [(_artyArrayDef1 select 0)]) select 0),(_artyArrayDef1 select 0) getArtilleryETA [_positionTel, ((getArtilleryAmmo [(_artyArrayDef1 select 0)]) select 0)]];
	};
	_textX = format ["Acknowledged. Fire mission is inbound. %2 Rounds fired. ETA %1 secs.",round _eta,_roundsMax - _rounds];
	[petros,"sideChat",_textX] remoteExec ["A3A_fnc_commsMP",[teamPlayer,civilian]];
	};

if (_typeArty != "BARRAGE") then
	{
	waitUntil {sleep 1; time > _timeX};
	[petros,"sideChat","Splash. Out."] remoteExec ["A3A_fnc_commsMP",[teamPlayer,civilian]];
	};
sleep 10;
deleteMarkerLocal _mrkFinal;
if (_typeArty == "BARRAGE") then {deleteMarkerLocal _mrkFinal2};

if (_forcedX) then {
	sleep 20;
	if (_markerX in forcedSpawn) then {
		forcedSpawn = forcedSpawn - [_markerX];
		publicVariable "forcedSpawn";
	};
};
