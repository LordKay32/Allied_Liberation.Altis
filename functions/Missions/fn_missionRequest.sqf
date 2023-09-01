if (!isServer) exitWith {};

params ["_type", ["_requester", clientOwner], ["_silent", false]];

waitUntil {isNil "A3A_missionRequestInProgress"};
A3A_missionRequestInProgress = true;

if (_type == "requested") then {
	private _types = ["AS","DES","RES","CONVOY"];
	_type = selectRandom (_types - A3A_activeTasks);
	_silent = false;
	if (isNil "_type") then {[petros,"globalChat","There are currently no other misssions available for tasking."] remoteExec ["A3A_fnc_commsMP",_requester]};
};

if (isNil "_type") then {
	private _types = ["AS","DES","RES","CONVOY"];
	_type = selectRandom (_types - A3A_activeTasks);
	_silent = true;
};
if (isNil "_type" or leader group petros != petros) exitWith { A3A_missionRequestInProgress = nil };
if (_type in A3A_activeTasks) exitWith {
	if (!_silent) then {[petros,"globalChat","I already gave you a mission of this type."] remoteExec ["A3A_fnc_commsMP",_requester]};
	A3A_missionRequestInProgress = nil;
};

private _findIfNearAndHostile = {
	/*
	Input : single array of markers, do 'array + array' for multiple.
	Returns: array of markers within max mission distance and is not rebel.
	*/
	params ["_markers"];
	_finalList = [];
	_friendlyBases = ((airportsX + milbases) select {(sidesX getVariable [_x,sideUnknown] == teamPlayer)}) + ["Synd_HQ"];
	{
		_friendlyBase = _x;
		_MarkerList = _markers select {(getMarkerPos _x distance2D getMarkerPos _friendlyBase < distanceMission) && (sidesX getVariable [_x,sideUnknown] != teamPlayer)};
		{
			_finalList pushBackUnique _x;
		} forEach _MarkerList;
	} forEach _friendlyBases;
	_finalList
};

private _baseMarkerReveal = {
	params ["_site"];
	private _positionX = if (typeName _site == "OBJECT") then {getPos _site} else {getMarkerPos _site};
	private _baseMarker = [baseMarkersX, _positionX] call BIS_fnc_nearestPosition;
	if (markerAlpha _baseMarker == 0) then {
		[_baseMarker,_site] spawn {
			params ["_baseMarker","_site"];
			sleep 5;
			_baseMarker setMarkerAlpha 1;
			{
				if (getMarkerPos _x inArea _site) then {
					_x setMarkerAlpha 1;
				};
			} forEach mrkAntennas;
			
			_num = round random 1000;
			_task = format ["Task_%1", _num];
			[[teamPlayer, civilian], _task, ["", "New Wehrmacht base discovered", ""], objNull, "ASSIGNED", 2, true] call BIS_fnc_taskCreate;
			[_task,"SUCCEEDED", true] call BIS_fnc_taskSetState;
				
			private _circleMrk = createMarker [format ["MrkCircle_%1", _num], (getMarkerPos _baseMarker)];
			_circleMrk setMarkerShape "ICON";
			_circleMrk setMarkerType "mil_circle";
			_circleMrk setMarkerSize [1.5, 1.5];		
	
			_time = time + 30;
			while {true} do {
				_circleMrk setMarkerColor "ColorYellow";
				sleep 1;
				_circleMrk setMarkerColor "colorBLUFOR";
				sleep 1;
				if (time > _time) exitWith {deleteMarker _circleMrk, [_task] call BIS_fnc_deleteTask};
			};
		};
	};
};

private _possibleMarkers = [];
switch (_type) do {
	case "AS": {
		//find apropriate sites
		_cityMarkers = (townsX + villagesX) select {[_x] call A3A_fnc_isFrontline == false};
		_possibleMarkers = [airportsX + milbases + _cityMarkers] call _findIfNearAndHostile;
		_possibleMarkers = _possibleMarkers select {spawner getVariable _x != 0};
		//add controlsX not on roads and on the 'frontier'
		private _controlsX = [controlsX] call _findIfNearAndHostile;
		private _nearbyFriendlyMarkers = markersX select {
			(getMarkerPos _x inArea [getMarkerPos respawnTeamPlayer, distanceMission+distanceSPWN, distanceMission+distanceSPWN, 0, false])
			and (sidesX getVariable [_x,sideUnknown] isEqualTo teamPlayer)
		};
		_nearbyFriendlyMarkers deleteAt (_nearbyFriendlyMarkers find "Synd_HQ");
		{
			private _pos = getmarkerPos _x;
			if !(isOnRoad _pos) then {
				if (_nearbyFriendlyMarkers findIf {getMarkerPos _x distance _pos < distanceSPWN} != -1) then {_possibleMarkers pushBack _x};
			};
		}forEach _controlsX;

		private _nearbyCities = [citiesX] call _findIfNearAndHostile;

		if (count _possibleMarkers == 0) then {
			if (!_silent) then {
				[petros,"globalChat","There are currently no misssions available for tasking."] remoteExec ["A3A_fnc_commsMP",_requester];
			};
		} else {
			private _site = selectRandom _possibleMarkers;

			switch(true) do {
				case (_site in (airportsX + milbases)): {
					if ((random 100) < 50) then {
						[[_site],"A3A_fnc_AS_Official"] remoteExec ["A3A_fnc_scheduler",2];
					} else {
						[[_site],"A3A_fnc_AS_Ambush"] remoteExec ["A3A_fnc_scheduler",2];					
					};
				};
				case (_site in (_cityMarkers)): {
					[[_site],"A3A_fnc_AS_Traitor"] remoteExec ["A3A_fnc_scheduler",2];
				};
				default {
					[[_site],"A3A_fnc_AS_SpecOP"] remoteExec ["A3A_fnc_scheduler",2];
				};
			};
			if !(_site in (controlsX + citiesX)) then {[_site] call _baseMarkerReveal};			
		};
	};

	/*case "CON": {
		//find apropriate sites
		_possibleMarkers = [outposts + resourcesX + (controlsX select {isOnRoad (getMarkerPos _x)})] call _findIfNearAndHostile;

		if (count _possibleMarkers == 0) then {
			if (!_silent) then {
				[petros,"globalChat","There are currently no misssions available for tasking."] remoteExec ["A3A_fnc_commsMP",_requester];
			};
		} else {
			private _site = selectRandom _possibleMarkers;
			[[_site],"A3A_fnc_CON_Outpost"] remoteExec ["A3A_fnc_scheduler",2];
		};
	};*/

	case "DES": {
		//find apropriate sites
		_possibleMarkers = [airportsX + ["seaport", "seaport_2", "seaport_3", "seaport_8", "seaport_7"]] call _findIfNearAndHostile;
		
		{
		_artilleryPieces = nearestObjects [(getMarkerPos _x), [NATOHowitzer], 250];
		if (count _artilleryPieces > 1) then {_possibleMarkers pushBack _x};
		} forEach ["outpost_9", "outpost_20", "outpost_17", "outpost_12", "outpost_40"];
		_possibleMarkers = _possibleMarkers select {spawner getVariable _x != 0};

		//append all antennas to list
		{
			private _nearbyMarker = [markersX, getPos _x] call BIS_fnc_nearestPosition;
			_potMarker = [[_nearbyMarker]] call _findIfNearAndHostile;
			if (count _potMarker > 0) then {_possibleMarkers pushBack _x};
		} forEach antennas;
		if (count _possibleMarkers == 0) then {
			if (!_silent) then {
				[petros,"globalChat","There are currently no misssions available for tasking."] remoteExec ["A3A_fnc_commsMP",_requester];
			};
		} else {
			private _site = selectRandom _possibleMarkers;
			switch (true) do {
				case (_site in airportsX): {
					[[_site],"A3A_fnc_DES_Vehicle"] remoteExec ["A3A_fnc_scheduler",2];  // planes // officer plane
				};		
				case (_site in seaports): {	
					[[_site],"A3A_fnc_DES_Heli"] remoteExec ["A3A_fnc_scheduler",2]; //sea convoy //subs
				};
				case (_site in antennas): {
					[[_site],"A3A_fnc_DES_antenna"] remoteExec ["A3A_fnc_scheduler",2]; 
				};
				case (_site in outposts): {
					[[_site],"A3A_fnc_DES_Artillery"] remoteExec ["A3A_fnc_scheduler",2];
				};
			};
		if !(_site in (controlsX + citiesX)) then {[_site] call _baseMarkerReveal};
		};
	};

	case "LOG": {
		//Add unspawned outposts for ammo trucks, and seaports for salvage
		_possibleMarkers = [seaports + outposts] call _findIfNearAndHostile;
		_possibleMarkers = _possibleMarkers select {(_x in seaports) or (spawner getVariable _x != 0)};

		private _controlsX = ([controlsX] call _findIfNearAndHostile) select {!isOnRoad (getMarkerPos _x)};
		_possibleMarkers = _possibleMarkers + _controlsX;

		//append banks in hostile cities
		if (random 100 < 20) then {
			{
				private _nearbyMarker = [markersX, getPos _x] call BIS_fnc_nearestPosition;
				if (
					(sidesX getVariable [_nearbyMarker,sideUnknown] != teamPlayer)
					&& (getPos _x distance getMarkerPos respawnTeamPlayer < distanceMission)
					) then {_possibleMarkers pushBack _x};
			}forEach banks;
		};

		if (count _possibleMarkers == 0) then {
			if (!_silent) then {
				[petros,"globalChat","There are currently no misssions available for tasking."] remoteExec ["A3A_fnc_commsMP",_requester];
			};
		} else {
			private _site = selectRandom _possibleMarkers;
			switch(true) do {
                case(_site in outposts): {
                    [[_site],"A3A_fnc_LOG_Ammo"] remoteExec ["A3A_fnc_scheduler", 2];
                };
                case(_site in banks): {
                    [[_site],"A3A_fnc_LOG_Bank"] remoteExec ["A3A_fnc_scheduler", 2];
                };
                case(_site in seaports): {
                    [[_site],"A3A_fnc_LOG_Salvage"] remoteExec ["A3A_fnc_scheduler", 2];
                };
                case(_site in controlsX): {
					private _roll = random 100;
					if(_roll < 50) then {
						[[_site],"A3A_fnc_LOG_Airdrop"] remoteExec ["A3A_fnc_scheduler",2];
					} else {
						[[_site],"A3A_fnc_LOG_Helicrash"] remoteExec ["A3A_fnc_scheduler", 2];
					};
                };
                default {};
            };
		};
	};

	case "SUPP": {
		_possibleMarkers = [];
		private _weightedMarkers = [];
		{
			private _dist = getMarkerPos _x distance2D getMarkerPos respawnTeamPlayer;
			private _supportReb = (server getVariable _x) select 3;
			if (_dist < distanceMission && _supportReb < 90) then {
				private _weight = (100 - _supportReb) * ((distanceMission - _dist) ^ 2);
				_possibleMarkers pushBack _x;
				_weightedMarkers append [_x, _weight];
			};
		}forEach (citiesX - destroyedSites);

		if (count _possibleMarkers == 0) then {
			if (!_silent) then {
				[petros,"There are currently no misssions available for tasking."] remoteExec ["A3A_fnc_commsMP",_requester];
			};
		} else {
			[3, format ["City weights: %1", _weightedMarkers], "missionRequest"] call A3A_fnc_log;
			private _site = selectRandomWeighted _weightedMarkers;
			[[_site],"A3A_fnc_LOG_Supplies"] remoteExec ["A3A_fnc_scheduler",2];
		};
	};

	case "RES": {
		_possibleMarkers = [(CitiesX select {[_x] call A3A_fnc_isFrontline == false})] call _findIfNearAndHostile;
		{
			private _spawner = spawner getVariable _x;
			if (_spawner != 0) then {_possibleMarkers pushBack _x};
		} forEach ([outposts] call _findIfNearAndHostile);

		_possibleControlsX = [((ControlsX select {[_x] call A3A_fnc_isFrontline == false}) select {getMarkerPos _x distance getMarkerPos ([(milbases + airportsX + outposts + seaports + citiesX), _x] call BIS_fnc_nearestPosition) > 600})] call _findIfNearAndHostile; 
		if (count (citiesX select {(sidesX getVariable [_x,sideUnknown] == teamPlayer)}) == 0) then {_possibleControlsX = _possibleControlsX select {!(isOnRoad getMarkerPos _x)}};
		
		_possibleMarkers append _possibleControlsX;
		private _shorePosition = [];
		
		if (count _possibleMarkers == 0) then {
			if (!_silent) then {
				[petros,"There are currently no misssions available for tasking."] remoteExec ["A3A_fnc_commsMP",_requester];
			};
		} else {
			private _site = selectRandom _possibleMarkers;

			private _shipwreckRoll = random 100;
			if(_shipwreckRoll < 20) then {
				_shorePosition = [
					(getMarkerPos _site),
					0,
					2000,
					0,
					0,
					1,
					1,
					[],
					[[0,0,0], [0,0,0]]
				] call BIS_fnc_findSafePos;
			} else {
				_shorePosition isEqualTo [0,0,0];
			};

			if (!(_shorePosition isEqualTo [0,0,0])) then {
				[[_site],"A3A_fnc_RES_Shipwreck"] remoteExec ["A3A_fnc_scheduler",2]; //shipwreck
			} else {
				case(_site in citiesX): {
					if (sunOrMoon < 1) then {
						[[_site],"A3A_fnc_RES_Informer"] remoteExec ["A3A_fnc_scheduler",2]; //Informer
					} else {
						[[_site],"A3A_fnc_RES_Prisoners"] remoteExec ["A3A_fnc_scheduler",2]; //partizans 
					};
				};
				case(_site in controlsX): {
					if (isOnRoad getMarkerPos _site) then {
						[[_site],"A3A_fnc_RES_PartizanRescue"] remoteExec ["A3A_fnc_scheduler",2]; //engaged partizans
					} else {
						[[_site],"A3A_fnc_RES_PilotRescue"] remoteExec ["A3A_fnc_scheduler",2]; //downed pilot
					};
				};
				case(_site in outposts): {
					[[_site],"A3A_fnc_RES_Prisoners"] remoteExec ["A3A_fnc_scheduler",2]; //POWs
				};
			if !(_site in (controlsX + citiesX)) then {[_site] call _baseMarkerReveal};
			};
		};
	};

	case "CONVOY": {
		if (bigAttackInProgress) exitWith {
			if (!_silent) then {
				[petros,"globalChat","There are currently no misssions available for tasking."] remoteExec ["A3A_fnc_commsMP",_requester];
			};
		};
		// only do the city convoys on flip?
        private _markers = ([airportsX + seaports + outposts + milbases - blackListDest] call _findIfNearAndHostile) select {[_x] call A3A_fnc_isFrontline == true};
        // Pre-filter the possible source bases to make this less n-squared
        private _possibleBases = ([airportsX + milbases] call _findIfNearAndHostile) select {[_x] call A3A_fnc_isFrontline == false};
        private _convoyPairs = [];
        private _site = "";
        private _base = "";
        {
            _site = _x;
            if (sidesX getVariable [_site, teamPlayer] == teamPlayer) then {continue};
            _base = [_site, _possibleBases] call A3A_fnc_findBasesForConvoy;
            if (_base != "") then {
                _possibleMarkers pushBack _site;
                _convoyPairs pushBack [_site, _base];
            };
        } forEach _markers;

		if (count _possibleMarkers == 0) then
		{
			if (!_silent) then {
				[petros,"globalChat","There are currently no misssions available for tasking."] remoteExec ["A3A_fnc_commsMP",_requester];
			};
		} else {
			private _convoyPair = selectRandom _convoyPairs;
			[_convoyPair,"A3A_fnc_convoy"] remoteExec ["A3A_fnc_scheduler",2];
		};
	};

	default {
		[1, format ["%1 is not an accepted task type.", _type], "missionRequest"] call A3A_fnc_log;
	};
};

if (count _possibleMarkers > 0) then {
	if (!_silent) then {[petros,"globalChat","I have a mission for you!"] remoteExec ["A3A_fnc_commsMP",_requester]; server setVariable ["intelPoints", (server getVariable "intelPoints") - 50, true]; [] spawn A3A_fnc_statistics;};
	
	sleep 3;			// delay lockout until the mission is registered
};
A3A_missionRequestInProgress = nil;
