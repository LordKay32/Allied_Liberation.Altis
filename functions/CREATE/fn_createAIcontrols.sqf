if (!isServer and hasInterface) exitWith{};
private _filename = "fn_createAIcontrols";

private ["_pos","_veh","_roads","_conquered","_dirVeh","_markerX","_positionX","_vehiclesX","_soldiers","_radiusX","_bunker","_groupE","_unit","_typeGroup","_groupX","_timeLimit","_dateLimit","_dateLimitNum","_base","_dog","_sideX","_cfg","_isFIA","_leave","_isControl","_radiusX","_typeVehX","_typeUnit","_markersX","_frontierX","_uav","_groupUAV","_allUnits","_closest","_winner","_timeLimit","_dateLimit","_dateLimitNum","_size","_base","_mineX","_loser","_sideX"];

_markerX = _this select 0;
_positionX = getMarkerPos _markerX;
_markerDir = MarkerDir _markerX;
_sideX = sidesX getVariable [_markerX,sideUnknown];

[2, format ["Spawning Control Point %1", _markerX], _filename] call A3A_fnc_log;

if ((_sideX == teamPlayer) or (_sideX == sideUnknown)) exitWith {};
if ({if ((sidesX getVariable [_x,sideUnknown] != _sideX) and (_positionX inArea _x)) exitWith {1}} count markersX >1) exitWith {};
_vehiclesX = [];
_soldiers = [];
_pilots = [];
_conquered = false;
_groupX = grpNull;
_isFIA = false;
_leave = false;

_isControl = if (isOnRoad _positionX) then {true} else {false};

if (_isControl) then {

	if (!([_markerX] call A3A_fnc_isFrontline)) then {
		_groupE = grpNull;
		_typeVehX = if (_sideX == Occupants) then {selectRandom NATOMG} else {selectRandom CSATMG};

		_markerPos = getMarkerPos _markerX;
		
		_road = ([getMarkerPos _markerX, 25] call BIS_fnc_nearestRoad);
		_roadInfo = getRoadInfo _road;
		_roadWidth = _roadInfo select 1;
		_width = (_roadWidth/2) + 2;

		_posGun1 = _markerPos getPos [_width, _markerDir + 90];
		_posGun2 = _markerPos getPos [_width, _markerDir - 90];

		_gun1 = createVehicle [_typeVehX, _positionX, [], 0, "CAN_COLLIDE"];
		_gun1 setDir _markerDir - 180;
		_gun1 setPos _posGun1;

		_gun2 = createVehicle [_typeVehX, _positionX, [], 0, "CAN_COLLIDE"];
		_gun2 setDir _markerDir;
		_gun2 setPos _posGun2;

		_groupE = createGroup _sideX;
		_typeUnit = if (_sideX == Occupants) then {
			staticCrewOccupants call SCRT_fnc_unit_selectInfantryTier
		} else {
			staticCrewInvaders call SCRT_fnc_unit_selectInfantryTier
		};

		{
		_gc = createVehicle ["ClutterCutter_small_EP1", _positionX, [], 0, "CAN_COLLIDE"];
		_gc setDir _markerDir - 180;
		_gc setPos (getPos _x);
		
		_pos = _x getRelPos [1.5, 292];
		_dir = getDir _x;

		_sb = createVehicle ["Land_BagFence_Round_F", _positionX, [], 0, "CAN_COLLIDE"];
		_sb setDir _dir + 135;
		_sb setPos _pos;
		_vehiclesX pushBack _sb;
		_sb setVectorUp surfaceNormal position _sb;

		_pos = _x getRelPos [1.4, 70];
	
		_sb = createVehicle ["Land_BagFence_Round_F", _positionX, [], 0, "CAN_COLLIDE"];
		_sb setDir _dir + 225;
		_sb setPos _pos;
		_vehiclesX pushBack _sb;
		_sb setVectorUp surfaceNormal position _sb;

		_pos = _x getRelPos [2.4, 135];
	
		_sb = createVehicle ["Land_BagFence_Short_F", _positionX, [], 0, "CAN_COLLIDE"];
		_sb setDir _dir - 90;
		_sb setPos _pos;
		_vehiclesX pushBack _sb;
		_sb setVectorUp surfaceNormal position _sb;

		_pos = _x getRelPos [2.5, 229];

		_sb = createVehicle ["Land_BagFence_Short_F", _positionX, [], 0, "CAN_COLLIDE"];
		_sb setDir _dir + 90;
		_sb setPos _pos;
		_vehiclesX pushBack _sb;
		_sb setVectorUp surfaceNormal position _sb;

		_pos = _x getRelPos [2.5, 199];

		_sb = createVehicle ["Land_BagFence_Short_F", _positionX, [], 0, "CAN_COLLIDE"];
		_sb setDir _dir + 180;
		_sb setPos _pos;
		_vehiclesX pushBack _sb;
		_sb setVectorUp surfaceNormal position _sb;
	
		_pos = _x getRelPos [1.4, 225];
	
		_sb = createVehicle ["CamoNet_OPFOR_F", _positionX, [], 0, "CAN_COLLIDE"];

		_sb setDir _dir - 90;
		_sb setPos (_pos vectorAdd [0,0,-0.3]);
		_sb setObjectScale 0.7;
		_vehiclesX pushBack _sb;
		
		_unit = [_groupE, _typeUnit, _positionX, [], 0, "NONE"] call A3A_fnc_createUnit;
		_unit moveInGunner _x;
		_unit doWatch (_x getRelPos [200, 0]);
		_soldiers pushBack _unit;
		
		_vehiclesX pushBack _x;
		[_x, _sideX] call A3A_fnc_AIVEHinit;
		
		} forEach [_gun1, _gun2];

		sleep 1;
		
		_pos = _gun1 getRelPos [8, 180];
		_typeVehX = if (_sideX == Occupants) then {NATOFlag} else {CSATFlag};
		_veh = createVehicle [_typeVehX, _positionX, [],0, "NONE"];
		_vehiclesX pushBack _veh;
		_veh setPosATL _pos;
		_veh setDir _markerDir;
		sleep 1;

		private _squads = [_sideX, "SQUAD"] call SCRT_fnc_unit_getGroupSet;
		_spawnPos = [(getPos _gun1), 60, (_markerDir + 300)] call BIS_Fnc_relPos;
		_groupX = [_spawnPos,_sideX, (selectRandom _squads), true] call A3A_fnc_spawnGroup;
		if !(isNull _groupX) then {
				{[_x] join _groupX} forEach units _groupE;
				deleteGroup _groupE;
				if (random 10 < 2.5) then {
				_dog = [_groupX, "Fin_random_F",_spawnPos,[],0,"FORM"] call A3A_fnc_createUnit;
				[_dog,_groupX] spawn A3A_fnc_guardDog;
			};
			_groupX setBehaviour "SAFE";
			_groupX setFormation "FILE";
			private _wp1 = _groupX addWaypoint [[(getPos _gun1), 60, (_markerDir + 240)] call BIS_Fnc_relPos, 0];
			private _wp2 = _groupX addWaypoint [[_gun2, 60, (_markerDir + 120)] call BIS_Fnc_relPos, 0];
			private _wp3 = _groupX addWaypoint [[_gun2, 60, (_markerDir + 60)] call BIS_Fnc_relPos, 0];
			private _wp4 = _groupX addWaypoint [_spawnPos, 0];
			_wp4 setWaypointType "CYCLE";
			// Forced non-spawner as they're very static.
			{[_x,"",false] call A3A_fnc_NATOinit; _soldiers pushBack _x} forEach units _groupX;
		};
	} else {
		waitUntil {sleep 1; ((_positionX nearEntities 500) findIf {side _x == teamplayer} != -1) || (spawner getVariable _markerX == 2)};
		
		if (spawner getVariable _markerX == 2) exitWith {_leave = true};
		
		_dir = (markerDir _markerX) + 90;
		_ambushPos = (getMarkerPos _markerX) getPos [80, _dir];
		_ambushMarker = createMarker [format ["mineMarker_%1", random 1000], _ambushPos];
		_ambushMarker setMarkerShape "RECTANGLE";
		_ambushMarker setMarkerDir (markerDir _markerX);
		_ambushMarker setMarkerSize [10, 40];
		_ambushMarker setMarkerAlpha 0;
		
		_staticType = selectRandom ["LIB_MG42_Lafette_low_Deployed", "LIB_MG34_Lafette_low_Deployed"];
		private _MG = createVehicle [_staticType, _ambushPos, [], 0, "NONE"];
		_MG setDir (_dir - 180);
		_vehiclesX pushBack _MG;
		
		_groupX = createGroup _sideX;
		_ambushSquad = ["loadouts_occ_SF_SquadLeader","loadouts_occ_SF_AT","loadouts_occ_SF_AT","loadouts_occ_SF_MachineGunner","loadouts_occ_SF_MachineGunner","loadouts_occ_SF_ExplosivesExpert","loadouts_occ_SF_Rifleman"];
		private _posNum = 10;
		private _pos = _ambushPos;
		{
		_pos = _pos getPos [_posNum, _dir + 90];
		_unit = [_groupX, _x, _pos, [], 0, "NONE"] call A3A_fnc_createUnit;	
		[_unit,""] call A3A_fnc_NATOinit;
		_unit setUnitTrait ["camouflageCoef",0.1];
		_unit setUnitTrait ["audibleCoef",0.1];
		_unit setUnitPos "DOWN";
		_unit disableAI "PATH";
		_soldiers pushBack _unit;
		_posNum = (_posNum + 12.5) * -1;
		} forEach _ambushSquad;
		
		_MGMan = [_groupX, "loadouts_occ_SF_Rifleman", _ambushPos, [], 0, "NONE"] call A3A_fnc_createUnit;
		[_MGMan,""] call A3A_fnc_NATOinit;
		_MGMan setUnitTrait ["camouflageCoef",0.1];
		_MGMan setUnitTrait ["audibleCoef",0.1];
		_soldiers pushBack _MGMan;
		_MGMan moveInGunner _MG;
		
		_groupX setFormDir (_dir - 180);
		_groupX setBehaviour "STEALTH";
		_groupX setCombatMode "GREEN";
	
		_mineMarker = createMarker [format ["mineMarker_%1", random 1000], getMarkerPos _markerX];
		_mineMarker setMarkerShape "RECTANGLE";
		_mineMarker setMarkerDir (markerDir _markerX);
		_mineMarker setMarkerSize [8, 40];
		_mineMarker setMarkerAlpha 0;

		waitUntil {sleep 1; (((getMarkerPos _mineMarker) nearEntities 150) findIf {side _x == teamplayer} != -1) or (combatMode _groupX != "GREEN") or (spawner getVariable _markerX == 2)};
		
		if (spawner getVariable _markerX == 2) exitWith {};
		
		private _tanks = ((getMarkerPos _mineMarker) nearEntities ["tank", 250]) select {side _x == teamplayer};

		private _ATmen = (units _groupX) select {_x getVariable "unitType" == "loadouts_occ_SF_AT"};
		
		private _mines = [];
		private _bombs = [];
		private _mineType = (([A3A_faction_inv,A3A_faction_occ] select (_sideX == Occupants)) getVariable "minefieldAT") select 0;
		
		if (count _tanks > 0) then {
			
			_mineX = createMine [ _mineType ,getMarkerPos _mineMarker,[],0];
			for "_i" from 1 to 11 do { 
				_position =[[[_mineMarker]], [], { {_this distance _x > 20} forEach (allMines select {_x inArea _mineMarker})}] call BIS_fnc_randomPos;
				_mineX = createMine [ _mineType ,_position,[],0];
				_mines pushBack _mineX;
			}; 
			
			{
			_x setUnitPos "MIDDLE";
			_x commandTarget selectRandom _tanks;
			_x selectWeapon (secondaryWeapon _x);			
			} forEach _ATmen;
		} else {
			_bombX = "";
			_bombPos1 = _positionX getPos [55, _markerDir];
			_num = 30;
			for "_i" from 1 to 2 do {
				_pos = _bombPos1 getPos [16, (_markerDir + _num)];
				_bomb = createMine [ "IEDLandBig_F" ,_pos,[],0];
				_bombs pushBack _bomb;
				_num = _num + 180;
			};
			_bombPos2 = _positionX getPos [-55, _markerDir];
			_num = 30;
			for "_i" from 1 to 2 do {
				_pos = _bombPos2 getPos [16, (_markerDir + _num)];
				_bomb = createMine [ "IEDLandBig_F" ,_pos,[],0];
				_bombs pushBack _bomb;
				_num = _num + 180;
			};
		};
		waitUntil {sleep 1; (((getMarkerPos _mineMarker) nearEntities 40) findIf {side _x == teamplayer} != -1) or (combatMode _groupX != "GREEN") or (spawner getVariable _markerX == 2)};
		
		if (spawner getVariable _markerX == 2) exitWith {{deleteVehicle _x} forEach (_mines + _bombs)};
		
		if (count _bombs > 0) then {
		{
			if (((getPos _x) nearEntities 20) findIf {side _x == teamplayer} != -1) then {
				_x setDamage 1;
			} else {
				deleteVehicle _x;
			};
		} forEach _bombs;
		};
		_groupX setCombatMode "RED";
		{
		_x enableAI "PATH";
		_x setUnitPos "AUTO";
		} forEach units _groupX;
		deleteMarker _mineMarker;
		deleteMarker _ambushMarker;
	};
}
else
	{
	_markersX = markersX select {(getMarkerPos _x distance _positionX < distanceSPWN) and (sidesX getVariable [_x,sideUnknown] == teamPlayer)};
	_markersX = _markersX - ["Synd_HQ"] - watchpostsFIA - roadblocksFIA - aapostsFIA - atpostsFIA - mortarpostsFIA - lightroadblocksFIA - hmgpostsFIA - supportpostsFIA;
	_frontierX = if (count _markersX > 0) then {true} else {false};
	if (_frontierX) then
		{
		_cfg = CSATSpecOp;
		if (sidesX getVariable [_markerX,sideUnknown] == Occupants) then
			{
			_cfg = NATOSpecOp;
			_sideX = Occupants;
			};
		_size = [_markerX] call A3A_fnc_sizeMarker;
		if ({if (_x inArea _markerX) exitWith {1}} count allMines == 0) then
			{
			    diag_log format ["%1: [Antistasi]: Server | Creating a Minefield at %1", _markerX];
				private _mines = ([A3A_faction_inv,A3A_faction_occ] select (_sideX == Occupants)) getVariable "minefieldAPERS";
				private _revealTo = [Invaders,Occupants] select (_sideX == Occupants);
				for "_i" from 1 to 45 do {
					_mineX = createMine [ selectRandom _mines ,_positionX,[],_size];
					_revealTo revealMine _mineX;
				};
			};
		_groupX = [_positionX,_sideX, _cfg] call A3A_fnc_spawnGroup;
		_nul = [leader _groupX, _markerX, "SAFE","SPAWNED","RANDOM","NOVEH2","NOFOLLOW"] execVM "scripts\UPSMON.sqf";//TODO need delete UPSMON link

		    sleep 1;
		    {_soldiers pushBack _x} forEach units _groupX;
		    _typeVehX = if (_sideX == Occupants) then {vehNATOUAVSmall} else {vehCSATUAVSmall};
		    if (_typeVehX != "not_supported") then {
                _uav = createVehicle [_typeVehX, _positionX, [], 0, "FLY"];
                [_sideX, _uav] call A3A_fnc_createVehicleCrew;
                _vehiclesX pushBack _uav;
                _groupUAV = group (crew _uav select 1);
                {[_x] joinSilent _groupX; _pilots pushBack _x} forEach units _groupUAV;
                deleteGroup _groupUAV;
            };

		{[_x,""] call A3A_fnc_NATOinit} forEach units _groupX;
	}
	else
		{
		_leave = true;
		};
	};
if (_leave) exitWith {};

{ _x setVariable ["originalPos", getPos _x] } forEach _vehiclesX;

_spawnStatus = 0;
while {(spawner getVariable _markerX != 2) and ({[_x,_markerX] call A3A_fnc_canConquer} count _soldiers > 0)} do
	{
	if ((spawner getVariable _markerX == 1) and (_spawnStatus != spawner getVariable _markerX)) then
		{
		_spawnStatus = 1;
		if (isMultiplayer) then
			{
			{if (vehicle _x == _x) then {[_x,false] remoteExec ["enableSimulationGlobal",2]}} forEach _soldiers
			}
		else
			{
			{if (vehicle _x == _x) then {_x enableSimulationGlobal false}} forEach _soldiers
			};
		}
	else
		{
		if ((spawner getVariable _markerX == 0) and (_spawnStatus != spawner getVariable _markerX)) then
			{
			_spawnStatus = 0;
			if (isMultiplayer) then
				{
				{if (vehicle _x == _x) then {[_x,true] remoteExec ["enableSimulationGlobal",2]}} forEach _soldiers
				}
			else
				{
				{if (vehicle _x == _x) then {_x enableSimulationGlobal true}} forEach _soldiers
				};
			};
		};
	sleep 3;
	};

waitUntil {sleep 1;((spawner getVariable _markerX == 2)) or ({[_x] call A3A_fnc_canFight} count _soldiers == 0)};

_conquered = false;
_winner = Occupants;
if (spawner getVariable _markerX != 2) then
	{
	_conquered = true;
	_allUnits = allUnits select {(side _x != civilian) and (side _x != _sideX) and (alive _x) and (!captive _x)};
	_closest = [_allUnits,_positionX] call BIS_fnc_nearestPosition;
	_winner = side _closest;
	_loser = Occupants;
	diag_log format ["%1: [Antistasi]: Server | Control %2 captured by %3. Is Roadblock: %4",servertime, _markerX, _winner, _isControl];
	if (_isControl  && !([_markerX] call A3A_fnc_isFrontline)) then
		{
		["TaskSucceeded", ["", "Roadblock Destroyed"]] remoteExec ["BIS_fnc_showNotification",_winner];
		["TaskFailed", ["", "Roadblock Lost"]] remoteExec ["BIS_fnc_showNotification",_sideX];
		};
	if (sidesX getVariable [_markerX,sideUnknown] == Occupants) then
		{
		if (_winner == Invaders) then
			{
			_nul = [-5,0,_positionX] remoteExec ["A3A_fnc_citySupportChange",2];
			sidesX setVariable [_markerX,Invaders,true];
			}
		else
			{
			sidesX setVariable [_markerX,teamPlayer,true];
			};
		}
	else
		{
		_loser = Invaders;
		if (_winner == Occupants) then
			{
			sidesX setVariable [_markerX,Occupants,true];
			_nul = [5,0,_positionX] remoteExec ["A3A_fnc_citySupportChange",2];
			}
		else
			{
			sidesX setVariable [_markerX,teamPlayer,true];
			_nul = [0,5,_positionX] remoteExec ["A3A_fnc_citySupportChange",2];
			};
		};
	};

waitUntil {sleep 1;(spawner getVariable _markerX == 2)};


{ if (alive _x) then { deleteVehicle _x } } forEach (_soldiers + _pilots);
deleteGroup _groupX;

{
	// delete all vehicles that haven't been captured
	if (_x getVariable ["ownerSide", _sideX] == _sideX) then {
		if (_x distance2d (_x getVariable "originalPos") < 100) then { deleteVehicle _x }
		else { if !(_x isKindOf "StaticWeapon") then { [_x] spawn A3A_fnc_VEHdespawner } };
	};
} forEach _vehiclesX;

{
	// delete all vehicles that haven't been captured
	if !(_x getVariable ["inDespawner", false]) then { deleteVehicle _x };
} forEach _vehiclesX;

if (_conquered) then
	{
	_indexX = controlsX find _markerX;
	if (_indexX > defaultControlIndex) then
		{
		_timeLimit = 120;//120
		_dateLimit = [date select 0, date select 1, date select 2, date select 3, (date select 4) + _timeLimit];
		_dateLimitNum = dateToNumber _dateLimit;
		waitUntil {sleep 60;(dateToNumber date > _dateLimitNum)};
		_base = [(markersX - controlsX),_positionX] call BIS_fnc_nearestPosition;
		if (sidesX getVariable [_base,sideUnknown] == Occupants) then
			{
			sidesX setVariable [_markerX,Occupants,true];
			}
		else
			{
			if (sidesX getVariable [_base,sideUnknown] == Invaders) then
				{
				sidesX setVariable [_markerX,Invaders,true];
				};
			};
		};
	};
