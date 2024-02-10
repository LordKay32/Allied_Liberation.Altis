params ["_mode"];

if(_mode == "ADD") then {

	if (!visibleMap) then {openMap true};
	artilleryMarkers = mortarpostsFIA + mobilemortarsFIA;

	artyMrkFlsh = true;

	[] spawn {
		while {artyMrkFlsh == true} do {
			{
				_x setMarkerColorLocal "ColorYellow";
			} forEach artilleryMarkers;
			sleep 1;
			{
				_x setMarkerColorLocal "default";
			} forEach artilleryMarkers;
			sleep 1;
			if (artyMrkFlsh == false) exitWith {};
			if (!visibleMap) exitWith {["artillerySupport", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler; artyMrkFlsh = false};
		};
	};

	

[
	"artillerySupport",
	"onMapSingleClick",
	{
		playSound "readoutClick";
		private _site = [artilleryMarkers, _pos] call BIS_fnc_nearestPosition;
		
		if ((getMarkerPos _site) distance _pos > 50) exitWith {
			["Artillery Support", "You must click on a friendly mortar crew or artillery emplacement."] call A3A_fnc_customHint;
		};
	
			switch (true) do {
				case (_site in mortarpostsFIA): {

					if ([(getMarkerPos _site), 300] call A3A_fnc_enemyNearCheck) exitWith {
 						["Artillery Support", "This artillery crew cannot fire while there are enemies nearby."] call A3A_fnc_customHint;
					};

					private _arty = nearestObject [(getMarkerPos _site), SDKArtillery];
			
					private _groupE = group (gunner _arty);

					artyMrkFlsh = false;
	
					["artillery", _groupE] remoteExec ["A3A_fnc_artySupport",2];
					//["artillery", _groupE] spawn A3A_fnc_artySupport;
				};

				case (_site in mobilemortarsFIA): {

					if ([(getMarkerPos _site), 300] call A3A_fnc_enemyNearCheck) exitWith {
 						["Artillery Support", "This mortar crew cannot fire while there are enemies nearby."] call A3A_fnc_customHint;
					};

					private _arty = nearestObject [(getMarkerPos _site), SDKMortar];
			
					private _groupE = group (gunner _arty);

					artyMrkFlsh = false;

					["mortar", _groupE] spawn A3A_fnc_artySupport;
				};
			};	
		},
    []
] call BIS_fnc_addStackedEventHandler;
} else {
    ["artillerySupport", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
};