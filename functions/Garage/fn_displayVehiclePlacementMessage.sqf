#include "defineGarage.inc"

//THIS SHOULDN'T BE CALLED OUTSIDE OF THE VEHICLE PLACEMENT SCRIPTS
//CALL AT YOUR OWN RISK

params ["_vehType", ["_title", ""]];

if (_title == "") then {
	if (_vehType in ["fow_p_defenceposition_03", "fow_p_defenceposition_05", "Land_BagBunker_Large_F"]) then {
		switch (true) do {
	    	case(_vehType == "fow_p_defenceposition_05"): {
	    		_title = "Trench";
	    	};
		};
	} else {
   _title = (getText (configFile >> "CfgVehicles" >> _vehType >> "displayName"));
	};
};

private _turboKeyName = if (count (actionKeysNames ["turbo", 1]) > 0) then {actionKeysNames ["turbo", 1];} else {"""No key bound""";};
[format ["<t size='0.7'>%1</t><br/><t size='0.5'>%2</t><br/><t size='0.5'>SPACE to place vehicle<br/>Arrow Left-Right to rotate<br/>%3 for Precision (Less Safe) Placement<br/>ENTER to Exit</t>", _title, vehPlace_extraMessage, _turboKeyName],0,0,5,0,0,4] spawn bis_fnc_dynamicText;