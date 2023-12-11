private ["_markerX","_mrkD"];

_markerX = _this select 0;

_mrkD = format ["Dum%1",_markerX];
if (sidesX getVariable [_markerX,sideUnknown] == teamPlayer) then {
	_textX = if (count (garrison getVariable [_markerX,[]]) > 0) then {format [": %1", count (garrison getVariable [_markerX,[]])]} else {""};
	_mrkD setMarkerColor colorTeamPlayer;

	switch (true) do {
		case (_markerX in airportsX): {
			_textX = format ["%2 Airbase%1",_textX,nameTeamPlayer];
			[_mrkD,format ["%1 Airbase",nameTeamPlayer]] remoteExec ["setMarkerTextLocal",[Occupants,Invaders],true];
			if (markerType _mrkD != "plp_mark_civ_airport2") then {_mrkD setMarkerType "plp_mark_civ_airport2"};
			_mrkD setMarkerColor colorTeamPlayer;
		};
		case(_markerX in outposts): {
			if (toLower worldName in ["enoch", "vn_khe_sanh"]) then {
				_textX = format ["%2 Artillery Post%1",_textX,nameTeamPlayer];
				[_mrkD,format ["%1 Artillery Post",nameTeamPlayer]] remoteExec ["setMarkerTextLocal",[Occupants,Invaders],true];
			} else {
				_textX = format ["%2 Outpost%1",_textX,nameTeamPlayer];
				[_mrkD,format ["%1 Outpost",nameTeamPlayer]] remoteExec ["setMarkerTextLocal",[Occupants,Invaders],true];
			};
		};
		case(_markerX in resourcesX): {
			_textX = format ["Industry%1",_textX];
		};
		case(_markerX in factories): {
			_textX = format ["Industry%1",_textX];
		};
		case(_markerX in seaports): {
			if (_markerX in ["seaport","seaport_1","seaport_2","seaport_3","seaport_5"]) then {
				_textX = format ["Port%1",_textX];
			} else {
				_textX = format ["Dock%1",_textX];
			};
		};
		case(_markerX in milbases): {
			_textX = format ["%2 Military Base%1",_textX,nameTeamPlayer];
			[_mrkD,format ["%1 Military Base", nameTeamPlayer]] remoteExec ["setMarkerTextLocal",[Occupants,Invaders],true];
		};
		case(_markerX in citiesX): {
			if (_markerX in destroyedSites) then {
				_mrkD setMarkerType "plp_mark_civ_ruins";
				_mrkD setMarkerText format ["%2 Ruins%1",_textX,_markerX];
			} else {
				_mrkD setMarkerText "";
			};
		};
		default {};
	};
	[_mrkD,_textX] remoteExec ["setMarkerTextLocal",[teamPlayer,civilian],true];
}
else {
	if (_markerX in citiesX) exitWith {
		if (_markerX in destroyedSites) then {
			_mrkD setMarkerType "plp_mark_civ_ruins";
			_mrkD setMarkerText format ["%1 Ruins",_markerX];
		} else {
			_mrkD setMarkerText "";
		};
		if (gameMode != 4) then {
		    _mrkD setMarkerColor colorOccupants;
		} else {
		    _mrkD setMarkerColor colorInvaders;
		};
	};
	if (sidesX getVariable [_markerX,sideUnknown] == Occupants) then {
		switch(true) do {
			case(_markerX in airportsX): {
				_mrkD setMarkerText format ["%1 Airbase",nameOccupants];
				_mrkD setMarkerType "plp_mark_civ_airport2";
				_mrkD setMarkerColor colorOccupants;
			};
			case(_markerX in outposts): {
				_mrkD setMarkerText format ["%1 Outpost",nameOccupants];
				_mrkD setMarkerColor colorOccupants;
			};
			case(_markerX in milbases): {
				_mrkD setMarkerText format ["%1 Military Base", nameOccupants];
				_mrkD setMarkerColor colorOccupants;
			};
			default {
				_mrkD setMarkerColor colorOccupants;
			};
		};
	}
	else {
		switch(true) do {
			case(_markerX in airportsX): {
				_mrkD setMarkerText format ["%1 Airbase",nameInvaders];
				_mrkD setMarkerType "plp_mark_civ_airport2";
				_mrkD setMarkerColor colorInvaders;
			};
			case(_markerX in outposts): {
				_mrkD setMarkerText format ["%1 Outpost",nameInvaders];
				_mrkD setMarkerColor colorInvaders;
			};
			case(_markerX in milbases): {
				_mrkD setMarkerText format ["%1 Military Base", nameInvaders];
				_mrkD setMarkerColor colorInvaders;
			};
			default {
				_mrkD setMarkerColor colorInvaders;
			};
		};
	};

	switch(true) do {
		case(_markerX in resourcesX): {
			_mrkD setMarkerText "Industry";
		};
		case(_markerX in factories): {
			_mrkD setMarkerText "Industry";
		};
		case(_markerX in seaports): {
			if (_markerX in ["seaport","seaport_1","seaport_2","seaport_3","seaport_5"]) then {
				_mrkD setMarkerText "Port";
			} else {
				_mrkD setMarkerText "Dock";
			};
		};
		default {};
	};
};
