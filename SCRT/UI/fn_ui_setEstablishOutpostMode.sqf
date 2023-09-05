private _moneyCost = outpostCost select 0;
private _hrCost = outpostCost select 1;
private _veh = outpostCost select 2;
private _garrison = outpostCost select 3;
private _hrFIA = 0;
private _hrUS = 0;
private _hrUK = 0;
private _transVeh = "";

private _resourcesFIA = server getVariable "resourcesFIA";

private _exit = false;

switch (true) do {
	
	case (outpostType in ["AA", "AT", "HMG"]) : {
	_hrFIA = server getVariable "UKhr";
	_transVeh = (if (server getVariable (vehSDKTruck + "_count") >= (server getVariable (vehSDKTruckClosed + "_count"))) then {vehSDKTruck} else {vehSDKTruckClosed});
	if (server getVariable (_veh + "_count") < 2) exitWith {
    	[
    	    "FAIL",
       		"Establish Outpost",  
       		parseText "There are not enough static weapons of this type available.", 
       		15
    	] spawn SCRT_fnc_ui_showMessage;
    	_exit = true;
    };
	};

	case (outpostType in ["WATCHPOST"]) : {
	_hrFIA = server getVariable "SAShr";
	_transVeh = vehSDKLightUnarmed;
	};

	case (outpostType in ["MORTAR"]) : {
	_hrFIA = server getVariable "UShr";
	_transVeh = (if (server getVariable (vehSDKTruck + "_count") >= (server getVariable (vehSDKTruckClosed + "_count"))) then {vehSDKTruck} else {vehSDKTruckClosed});
	if (server getVariable (_veh + "_count") < 2) exitWith {
	   	[
	   	    "FAIL",
	   		"Establish Outpost",  
	   		parseText "There are no artillery pieces available.", 
	   		15
	   	] spawn SCRT_fnc_ui_showMessage;
	   	_exit = true;
    };
	};
	
	case (outpostType in ["LIGHTROADBLOCK"]) : {
	_hrFIA = server getVariable "UShr";
	_transVeh = vehSDKLightUnarmed;
	if (server getVariable (_veh + "_count") < 1) exitWith {
    	[
    	    "FAIL",
    		"Establish Outpost",  
    		parseText "There are no MG jeeps available.", 
    		15
    	] spawn SCRT_fnc_ui_showMessage;
    	_exit = true;
    };
	};
	
	case (outpostType in ["ROADBLOCK"]) : {
	_hrFIA = server getVariable "UKhr";
	_transVeh = (if (server getVariable (vehSDKTruck + "_count") >= (server getVariable (vehSDKTruckClosed + "_count"))) then {vehSDKTruck} else {vehSDKTruckClosed});
	if ((server getVariable ((_veh select 0) + "_count") < 1) || (server getVariable ((_veh select 1) + "_count") < 1)) exitWith {
		[
			"FAIL",
		    "Establish Outpost",  
		    parseText "One or more of the static weapons needed to create this outpost are not available.", 
		    15
		] spawn SCRT_fnc_ui_showMessage;
		_exit = true;
	};
	};
	
	case (outpostType in ["SUPPORTPOST"]) : {
	_hrFIA = server getVariable "UShr";
	_transVeh = vehSDKLightUnarmed;
	if ((server getVariable ((_veh select 0) + "_count") < 1) || (server getVariable ((_veh select 1) + "_count") < 1) || (server getVariable ((_veh select 2) + "_count") < 1) || (server getVariable ((_veh select 3) + "_count") < 1) || (server getVariable ((_veh select 4) + "_count") < 1)) exitWith {
   		[
   			"FAIL",
   		    "Establish Outpost",  
   		    parseText "One or more of the support vehicles needed to create this outpost are not available.", 
   		    15
   		] spawn SCRT_fnc_ui_showMessage;
   		_exit = true;
   	};
	};
};

if (outpostType in ["SUPPORTPOST"]) then {
	if (count supportpostsFIA > 1) exitWith {
		[
        	"FAIL",
        	"Establish Outpost",  
        	parseText "We can only support a maximum of 2 support outposts at a time.",
        	15
    	] spawn SCRT_fnc_ui_showMessage;
	};
};

if (_exit) exitWith {};

if ((_resourcesFIA < _moneyCost) or (_hrFIA < _hrCost)) exitWith {
	[
       	"FAIL",
       	"Establish Outpost",  
       	parseText format ["You do not have enough resources to establish this outpost.<br/> %1 HR and %2%3 needed.", _hrCost, _moneyCost, currencySymbol], 
       	15
   	] spawn SCRT_fnc_ui_showMessage;
};

if ("outpostTask" in A3A_activeTasks) exitWith {
    [
        "FAIL",
        "Establish Outpost",  
        parseText "We can only deploy / delete one outpost at a time.", 
        15
    ] spawn SCRT_fnc_ui_showMessage;
};

if (!([player] call A3A_fnc_hasRadio)) exitWith {
    [
        "FAIL",
        "Establish Outpost",  
        parseText "You need a radio in your inventory to be able to give orders to other squads while establishing outpost.", 
        15
    ] spawn SCRT_fnc_ui_showMessage;
};

if (server getVariable (_transVeh + "_count") < 1) exitWith {
    [
        "FAIL",
        "Establish Outpost",  
        parseText "There are no transport vehicles available to move your squad to the outpost location.", 
        15
    ] spawn SCRT_fnc_ui_showMessage;
};

private _squadloadout = [];
{
private _loadout = rebelLoadouts get _x;
_squadloadout pushback _loadout;
} forEach _garrison;

private _fullSquadGear = _squadloadout call A3A_fnc_reorgLoadoutSquad;

private _emptyList = [];
{
private "_number";
_number = [jna_dataList select (_x select 0 call jn_fnc_arsenal_itemType), _x select 0]call jn_fnc_arsenal_itemCount; 
if ((_number <= (_x select 1)) && !(_number == -1)) then { _emptyList pushBack (_x select 0) }
} forEach _fullSquadGear;

if (count _emptyList > 0) exitWith {
		
		private _weaps = [];
		private _mags = [];
		private _strings = [];
		
		{
			_weaps = getText (configFile >> "CfgWeapons" >> _x >> "displayName");
			_strings pushBack _weaps;
			_mags = getText (configFile >> "CfgMagazines" >> _x >> "displayName");
			_strings pushBack _mags;
		} forEach _emptyList;
		
		_strings = _strings - [""];
		
	["Establish Outpost", format ["The following gear has run too low for you to recruit the squad for this outpost: <t color='#ffff00'>%1", _strings], "FAIL"] call SCRT_fnc_ui_showDynamicTextMessage;
	};

{ [_x select 0 call jn_fnc_arsenal_itemType, _x select 0, _x select 1]call jn_fnc_arsenal_removeItem } forEach _fullSquadGear;

["disbandGarrison", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
["establishOutpost", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
["minefieldMap", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
["recruitGarrison", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
["ADD"] spawn SCRT_fnc_ui_establishOutpostEventHandler;
