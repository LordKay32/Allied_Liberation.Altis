		private ["_nearX", "_groupX", "_groupArray"];
		
		_nearX = [];
		
		if (!visibleMap) then {openMap true};
		
		rcnMrkFlsh = true;
	
		potMarkers = [];

			{
			if (sidesX getVariable [_x,sideUnknown] == teamPlayer) then {potMarkers pushBack _x};
			} forEach watchpostsFIA;
			
		if (potMarkers isEqualTo []) exitWith {
			[
    	        "Recon Mission",
    	        parseText "You have not established any watchposts."
    	    ] call A3A_fnc_customHint;
		};

		[] spawn {
			private _mrkList = [];
			private _num = 0;
			{
			_num = _num + 1;
			private _circleMrk = createMarkerLocal [format ["MrkCircle_%1", _num], (getMarkerPos _x)];
			_circleMrk setMarkerShapeLocal "ICON";
			_circleMrk setMarkerTypeLocal "mil_circle";
			_circleMrk setMarkerSizeLocal [1.5, 1.5];
			_mrkList pushBack _circleMrk;
			} forEach potMarkers;
	
			while {rcnMrkFlsh == true} do {
				{
					_x setMarkerColorLocal "ColorYellow";
				} forEach _mrkList;
				sleep 1;
				{
					_x setMarkerColorLocal "colorGUER";
				} forEach _mrkList;
				sleep 1;
				if (rcnMrkFlsh == false) exitWith {{deleteMarkerLocal _x} forEach _mrkList};
			};
		};

		positionTel = [];

		onMapSingleClick "positionTel = _pos";

		[
            "Recon Mission",
            parseText "Select the watchpost you want to perform the recon mission."
        ] call A3A_fnc_customHint;

		waitUntil {sleep 0.5; count positionTel > 0};
		onMapSingleClick "";

		rcnMrkFlsh = false;
		private _positionTel = positionTel;

		_nearX = [watchpostsFIA,_positionTel] call BIS_fnc_nearestPosition;

		if ((getMarkerPos _nearX) distance _positionTel > 50) exitWith {
			[
    	        "Recon Mission",
    	        parseText "Select a friendly watchpost."
    	    ] call A3A_fnc_customHint;
		};

		if (not(sidesX getVariable [_nearX,sideUnknown] == teamPlayer)) exitWith {
			[
    	        "Recon Mission",
    	        parseText "Select a friendly watchpost."
    	    ] call A3A_fnc_customHint;
    	};
		
		private _index = watchpostsFIA findIf {_x == _nearX};
		if (_index != -1) then {
		_groupArray = allGroups select {groupId _x == format ["Recon_%1", _index]};
		_groupX = _groupArray select 0;
		};
		
		if (combatMode _groupX != "GREEN") exitWith {["Recon Mission", "This recon squad is engaged in combat."] call A3A_fnc_customHint};

positionTel = [];
positionDir = [];
	
private _circleMrk = createMarkerLocal ["BRCircle", (getMarkerPos _nearX)];
_circleMrk setMarkerShapeLocal "ELLIPSE";
_circleMrk setMarkerSizeLocal [600, 600];
_circleMrk setMarkerColorLocal "ColorGreen";
_circleMrk setMarkerAlphaLocal 0.5;

onMapSingleClick "positionTel = _pos";

[
    "Recon Mission",
    parseText "Click the location you want the recon squad to deploy to (click on watchpost to cancel mission)."
] call A3A_fnc_customHint;

waitUntil {sleep 0.5; count positionTel > 0};
		
deleteMarkerLocal _circleMrk;

_positionTel = positionTel;
		
if ((getMarkerPos _nearX) distance _positionTel > 600) exitWith {
	[
	    "Recon Mission",
	    parseText "Location must be within 600m of the watchpost."
	] call A3A_fnc_customHint;
	deleteMarkerLocal _circleMrk;
};

if ((getMarkerPos _nearX) distance _positionTel < 25) exitWith {
	[
	    "Recon Mission",
	    parseText "Recon squad returning to base."
	] call A3A_fnc_customHint;
	deleteMarkerLocal _circleMrk;
	
	[_groupX, (currentWaypoint _groupX)] setWaypointPosition [getPosASL ((units _groupX) select 0), -1];
	sleep 0.1;
	for "_i" from count waypoints _groupX - 1 to 0 step -1 do
	{
		deleteWaypoint [_groupX, _i];
	};
	sleep 1;

	private _wp0 = _groupX addWaypoint [(getMarkerPos _nearX) getPos [100,0], 0];
	private _wp1 = _groupX addWaypoint [(getMarkerPos _nearX) getPos [100,60], 0];
	private _wp2 = _groupX addWaypoint [(getMarkerPos _nearX) getPos [100,120], 0];
	private _wp3 = _groupX addWaypoint [(getMarkerPos _nearX) getPos [100,180], 0];
	private _wp4 = _groupX addWaypoint [(getMarkerPos _nearX) getPos [100,240], 0];
	private _wp5 = _groupX addWaypoint [(getMarkerPos _nearX) getPos [100,300], 0];
	private _wp6 = _groupX addWaypoint [(getMarkerPos _nearX) getPos [100,0], 0];
	_wp6 setWaypointType "CYCLE";

	[_positionX, _groupX] spawn SCRT_fnc_watchPostRecon;
};

private _originMrk = createMarkerLocal ["BRStart", _positionTel];
_originMrk setMarkerShapeLocal "ICON";
_originMrk setMarkerTypeLocal "hd_end";
_originMrk setMarkerTextLocal "Recon Position";

onMapSingleClick "positionDir = _pos";

[
    "Recon Mission",
    parseText "Select the direction you want the squad to recon (will return information for 800m in this direction)."
] call A3A_fnc_customHint;

waitUntil {sleep 0.5; count positionDir > 0};
		
private _positionDir = positionDir;
		
private _directionMrk = createMarkerLocal ["BRFin", _positionDir];
_directionMrk setMarkerShapeLocal "ICON";
_directionMrk setMarkerTypeLocal "hd_dot";
_directionMrk setMarkerTextLocal "Recon Direction";

sleep 1;

if (visibleMap) then {openMap false};

deleteMarkerLocal _originMrk;
deleteMarkerLocal _directionMrk;;

	[_groupX, (currentWaypoint _groupX)] setWaypointPosition [getPosASL ((units _groupX) select 0), -1];
	sleep 0.1;
	for "_i" from count waypoints _groupX - 1 to 0 step -1 do
	{
		deleteWaypoint [_groupX, _i];
	};
sleep 1;
private _wp1 = _groupX addWaypoint [_positionTel, 0];
_wp1 setWaypointStatements ["true", format ["[group this, %1, %2, '%3'] spawn SCRT_fnc_watchPostReconMission", _positionTel, _positionDir, _nearX]];

private _wpIndex = currentWaypoint _groupX;

waitUntil {sleep 1; ({alive _x} count units _groupX == 0) || (combatMode _groupX != "GREEN") || (currentWaypoint _groupX == _wpIndex + 1)};

if (combatMode _groupX != "GREEN") then {
	[
    "Recon Mission",
    parseText "Recon team spotted, recon mission aborted."
	] call A3A_fnc_customHint;
	for "_i" from 0 to (count waypoints _groupX - 1) do
	{
		deleteWaypoint [_groupX, 0];
	};
	private _wpEscape = _groupX addWaypoint [(getMarkerPos _nearX), 0];
	_wpEscape setWaypointSpeed "FULL";
	if ({alive _x} count units _groupX > 0) then {
		{
		[_x] spawn {
			params ["_unit"];
			sleep 2;
			while {true} do {	
				[_unit,_unit] spawn A3A_fnc_chargeWithSmoke;
				sleep 60;
				if (!(alive _unit) || (combatMode (group _unit) == "GREEN")) exitWith {};
			};
		};
		} forEach units _groupX;
		waitUntil {sleep 1; west knowsAbout (leader _groupX) < 4}; 
		_groupX setCombatMode "GREEN";
	};
};
