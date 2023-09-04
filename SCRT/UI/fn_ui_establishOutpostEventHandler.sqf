params ["_mode"];
private ["_road"];

if(_mode == "ADD") then {
   
		private _nearX = [];

		sqdMrkFlsh = true;
	
		potMarkers = [];

			{
			if (sidesX getVariable [_x,sideUnknown] == teamPlayer) then {potMarkers pushBack _x};
			} forEach (["Synd_HQ"] + airportsX + milbases);

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
	
			while {sqdMrkFlsh == true} do {
				{
					_x setMarkerColorLocal "ColorYellow";
				} forEach _mrkList;
				sleep 1;
				{
					_x setMarkerColorLocal "colorGUER";
				} forEach _mrkList;
				sleep 1;
				if (sqdMrkFlsh == false) exitWith {{deleteMarkerLocal _x} forEach _mrkList};
			};
		};

		positionTel = [];

		onMapSingleClick "positionTel = _pos";

		[
        	"Info",
            "Establish Outpost",
            parseText "Select the base you want the outpost squad to deploy from (HQ, airbases or military bases).", 
            30
        ] spawn SCRT_fnc_ui_showMessage;

		waitUntil {sleep 0.5; (count positionTel > 0) or (isMenuOpen == false)};
		onMapSingleClick "";

		if (isMenuOpen == false) exitWith {sqdMrkFlsh = false};
		sqdMrkFlsh = false;
		private _positionTel = positionTel;

		_nearX = [(["Synd_HQ"] + airportsX + milbases),_positionTel] call BIS_fnc_nearestPosition;

		if ((getMarkerPos _nearX) distance _positionTel > 50) exitWith {
			[
    	    	"FAIL",
    	        "Establish Outpost",
    	        parseText "Select your HQ or a friendly airbase or military base.", 
    	        30
    	    ] spawn SCRT_fnc_ui_showMessage;
		};

		if (not(sidesX getVariable [_nearX,sideUnknown] == teamPlayer)) exitWith {
			[
    	    	"FAIL",
    	        "Establish Outpost",
    	        parseText "Select your HQ or a friendly airbase or military base.", 
    	        30
    	    ] spawn SCRT_fnc_ui_showMessage;
    	};
		{
			if (((side _x == Invaders) or (side _x == Occupants)) and (_x distance (getMarkerPos _nearX) < 500) and ([_x] call A3A_fnc_canFight) and !(isPlayer _x)) exitWith {["Establish Outpost", "You cannot deploy units when there are enemies near the base."] call A3A_fnc_customHint};
		} forEach allUnits;



positionTel = [];
positionDir = [];
	
private _circleMrk = createMarkerLocal ["BRCircle", (getMarkerPos _nearX)];
_circleMrk setMarkerShapeLocal "ELLIPSE";
_circleMrk setMarkerSizeLocal [250, 250];
_circleMrk setMarkerColorLocal "ColorGreen";
_circleMrk setMarkerAlphaLocal 0.5;

onMapSingleClick "positionTel = _pos";

[
   	"Info",
    "Establish Outpost",
    parseText "Select the location you want the squad vehicle to deploy at (must be within 250m of squad base).", 
	30
] spawn SCRT_fnc_ui_showMessage;

waitUntil {sleep 0.5; (count positionTel > 0) or (isMenuOpen == false)};
if (isMenuOpen == false) exitWith {deleteMarkerLocal _circleMrk};
		
deleteMarkerLocal _circleMrk;
_positionTel = positionTel;
		
if ((getMarkerPos _nearX) distance _positionTel > 250) exitWith {
	[
	   	"FAIL",
	    "Establish Outpost",
	    parseText "Location must be within 250m of squad base.", 
		30
	] spawn SCRT_fnc_ui_showMessage;
	deleteMarkerLocal _circleMrk;
};

private _originMrk = createMarkerLocal ["BRStart", _positionTel];
_originMrk setMarkerShapeLocal "ICON";
_originMrk setMarkerTypeLocal "hd_end";
_originMrk setMarkerTextLocal "Vehicle Position";

onMapSingleClick "positionDir = _pos";

[
  	"Info",
    "Establish Outpost",
    parseText "Select the direction you want the squad vehicle to face.", 
	30
] spawn SCRT_fnc_ui_showMessage;

waitUntil {sleep 0.5; (count positionDir > 0) or (isMenuOpen == false)};
if (isMenuOpen == false) exitWith {deleteMarkerLocal _originMrk};
		
private _positionDir = positionDir;
		
private _directionMrk = createMarkerLocal ["BRFin", _positionDir];
_directionMrk setMarkerShapeLocal "ICON";
_directionMrk setMarkerTypeLocal "hd_dot";
_directionMrk setMarkerTextLocal "Vehicle Direction";

sleep 1;
		
deleteMarkerLocal _originMrk;
deleteMarkerLocal _directionMrk;
private _dirVeh = [_positionTel, _positionDir] call BIS_fnc_dirTo;

startMarker = _nearX;
truckPos = _positionTel;
truckDir = _dirVeh;

[
    "INFO",
    "Establish Outpost",  
    parseText "Click on desired position on map to establish outpost there.", 
    60
] spawn SCRT_fnc_ui_showMessage;



	[
        "establishOutpost",
        "onMapSingleClick",
        {
            playSound "readoutClick";

            if (outpostType == "WATCHPOST" && {isOnRoad _pos}) exitWith {
                [
                    "FAIL",
                    "Establish Outpost",  
                    parseText "Watchpost should be not on road.", 
                    30
                ] spawn SCRT_fnc_ui_showMessage;
            };

            if (outpostType == "WATCHPOST") exitWith {
                [startMarker, truckPos, truckDir, _pos] spawn SCRT_fnc_outpost_createWatchpost;
            };

            if (outpostType in ["ROADBLOCK", "LIGHTROADBLOCK"] && {!isOnRoad _pos}) exitWith {
                [
                    "FAIL",
                    "Establish Outpost",  
                    parseText "Roadblock should be on road.", 
                    30
                ] spawn SCRT_fnc_ui_showMessage;
            };

			if (outpostType in ["ROADBLOCK"] && {(_pos isFlatEmpty  [-1, -1, 0.3, 15, -1] isEqualTo []);}) exitWith {
                [
                    "FAIL",
                    "Establish Outpost",  
                    parseText "This outpost must be built on flat land.", 
                    30
                ] spawn SCRT_fnc_ui_showMessage;
            };
            
            if (outpostType in ["SUPPORTPOST"] && {(_pos isFlatEmpty  [-1, -1, 0.3, 20, -1] isEqualTo []);}) exitWith {
                [
                    "FAIL",
                    "Establish Outpost",  
                    parseText "This outpost must be built on flat land.", 
                    30
                ] spawn SCRT_fnc_ui_showMessage;
            };
            
            if (getMarkerPos ([(markersX - controlsX), _pos] call BIS_fnc_nearestPosition) distance _pos < 600 && (not(sidesX getVariable [([(markersX - controlsX), _pos] call BIS_fnc_nearestPosition),sideUnknown] == teamPlayer))) exitWith {
                [
                    "FAIL",
                    "Establish Outpost",  
                    parseText "Outposts cannot be built closer than 600m to enemy positions.", 
                    30
                ] spawn SCRT_fnc_ui_showMessage;
            };

            if (isNil "outpostOrigin") then {
                outpostOrigin = createMarkerLocal ["BRStart", _pos];
                outpostOrigin setMarkerShapeLocal "ICON";
                outpostOrigin setMarkerTypeLocal "hd_end";
                if (outpostType == "MORTAR") then {outpostOrigin setMarkerTextLocal "ARTILLERY Position"} else {outpostOrigin setMarkerTextLocal format ["%1 Position", outpostType]};

                [
                    "Info",
                    "Establish Outpost",
                    parseText "Set outpost direction.", 
                    30
                ] spawn SCRT_fnc_ui_showMessage;
            } else {           
                outpostDirection = createMarkerLocal ["BRFin", _pos];
                outpostDirection setMarkerShapeLocal "ICON";
                outpostDirection setMarkerTypeLocal "hd_dot";
                if (outpostType == "MORTAR") then {outpostOrigin setMarkerTextLocal "ARTILLERY Direction"} else {outpostOrigin setMarkerTextLocal format ["%1 Direction", outpostType]};

                private _direction = [(getMarkerPos outpostOrigin), (getMarkerPos outpostDirection)] call BIS_fnc_dirTo;

                switch (outpostType) do {
                    case ("AA"): {
                        [startMarker, truckPos, truckDir, (getMarkerPos outpostOrigin), _direction] spawn SCRT_fnc_outpost_createAa;
                    };
                    case ("AT"): {
                        [startMarker, truckPos, truckDir, (getMarkerPos outpostOrigin), _direction] spawn SCRT_fnc_outpost_createAt;
                    };
                    case ("MORTAR"): {
                        [startMarker, truckPos, truckDir, (getMarkerPos outpostOrigin), _direction] spawn SCRT_fnc_outpost_createMortar;
                    };
                    case ("HMG"): {
                        [startMarker, truckPos, truckDir, (getMarkerPos outpostOrigin), _direction] spawn SCRT_fnc_outpost_createHmg;
                    };
                    case ("LIGHTROADBLOCK"): {
                        [startMarker, truckPos, truckDir, (getMarkerPos outpostOrigin), _direction] spawn SCRT_fnc_outpost_createLightRoadblock;
                    };
                    case ("ROADBLOCK"): {
                        [startMarker, truckPos, truckDir, (getMarkerPos outpostOrigin), _direction] spawn SCRT_fnc_outpost_createRoadblock;
                    };
                    case ("SUPPORTPOST"): {
                        [startMarker, truckPos, truckDir, (getMarkerPos outpostOrigin), _direction] spawn SCRT_fnc_outpost_createSupportPost;
                    };
                    default {
                        [1, "Bad outpost type.", "establishOutpostEventHandler"] call A3A_fnc_log;
                    };
                };
            }
        },
        []
	] call BIS_fnc_addStackedEventHandler;
} else {
    ["establishOutpost", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
};