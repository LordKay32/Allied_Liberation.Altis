private ["_flag","_typeX"];

if (!hasInterface) exitWith {};

_flag = _this select 0;
_typeX = _this select 1;

switch _typeX do
{
    case "take":
    {
        removeAllActions _flag;
        _actionX = _flag addAction ["<t>Take the Flag<t> <img image='\A3\ui_f\data\igui\cfg\actions\takeflag_ca.paa' size='1.8' shadow=2 />", A3A_fnc_mrkWIN,nil,6,true,true,"","(isPlayer _this) and (_this == _this getVariable ['owner',objNull])",4];
        _flag setUserActionText [_actionX,"Take the Flag","<t size='2'><img image='\A3\ui_f\data\igui\cfg\actions\takeflag_ca.paa'/></t>"];
    };
    case "unit":
    {
        _flag addAction ["Unit Recruitment", {if ([player,300] call A3A_fnc_enemyNearCheck) then {["Unit Recruitment", "You cannot recruit units while there are enemies near you."] call A3A_fnc_customHint;} else { [] spawn A3A_fnc_unit_recruit; };},nil,0,false,true,"","(isPlayer _this) and (_this == _this getVariable ['owner',objNull])",4]
    };
    case "vehicle":
    {
        _flag addAction ["Deploy Vehicle", {if ([player,300] call A3A_fnc_enemyNearCheck) then {["Deploy Vehicle", "You cannot deploy vehicles while there are enemies near you."] call A3A_fnc_customHint;} else {["MAIN"] call SCRT_fnc_ui_createBuyVehicleMenu}},nil,0,false,true,"","(isPlayer _this) and (_this == _this getVariable ['owner',objNull])",4];
    };
    case "mission":
    {
        petros addAction ["Mission Request (50 intel point required)", {_intel = server getVariable "intelPoints"; if (_intel < 50) then {["Mission Request", "We do not have enough intelligence on enemy operations to task any missions (50 intel points needed)"] call A3A_fnc_customHint;} else {["requested", clientOwner] remoteExec ["A3A_fnc_missionRequest", 2];};},nil,0,false,true,"","(isPlayer _this) and (vehicle _this == _this) and (_this == _this getVariable ['owner',objNull]) and (_this call A3A_fnc_isMember) and (petros == leader group petros)",4];
        petros addAction ["HQ Management", {
            closeDialog 0;
		    closeDialog 0;
            createDialog "commanderMenu";
            isMenuOpen = true;
            [] spawn SCRT_fnc_misc_orbitingCamera;
		    [] call SCRT_fnc_ui_populateHqMenu;
        },nil,0,false,true,"","(isPlayer _this) and (_this == theBoss) and (vehicle _this == _this) and (petros == leader group petros)", 4];
        petros addAction ["Move this asset", A3A_fnc_moveHQObject,nil,0,false,true,"","(_this == theBoss)"];
    };
    case "truckX":
    {
        actionX = _flag addAction ["<t>Transfer Ammobox to Truck<t> <img image='\A3\ui_f\data\igui\cfg\actions\unloadVehicle_ca.paa' size='1.8' shadow=2 />", A3A_fnc_transfer,nil,6,true,true,"","(isPlayer _this) and (_this == _this getVariable ['owner',objNull])"]
    };
    case "heal":
    {
        if (player != _flag) then
        {
    		if ([_flag] call A3A_fnc_fatalWound) then
            {
                _actionX = _flag addAction [format ["<t>Revive %1 </t> <img size='1.8' <img image='\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_reviveMedic_ca.paa' />",name _flag], A3A_fnc_actionRevive,nil,6,true,true,"","!(_this getVariable [""helping"",false]) and (isNull attachedTo _target)",4];
                _flag setUserActionText [_actionX,format ["Revive %1",name _flag],"<t size='2'><img image='\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_reviveMedic_ca.paa'/></t>"];
            }
            else
            {    
    	        _actionX = _flag addAction [format ["<t>Revive %1 </t> <img size='1.8' <img image='\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_revive_ca.paa' />",name _flag], A3A_fnc_actionRevive,nil,6,true,true,"","!(_this getVariable [""helping"",false]) and (isNull attachedTo _target)",4];
    	        _flag setUserActionText [_actionX,format ["Revive %1",name _flag],"<t size='2'><img image='\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_revive_ca.paa'/></t>"];
    	    };
    	     
    	    _actionX = _flag addAction [format ["<t>Order team medic to revive %1 (check medic not stopped)</t> <img size='1.8' <img image='\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_revive_ca.paa' />",name _flag], A3A_fnc_teamMedicRevive,nil,5,true,true,"","((units group _this) - [_this, _target]) findIf {_x getUnitTrait 'Medic'} != -1",25];
	        _flag setUserActionText [_actionX,format ["Order team medic to revive %1 (check medic not stopped)",name _flag],"<t size='2'><img image='\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_revive_ca.paa'/></t>"];
        
        };
    };
    case "heal1":
    {
        if (player != _flag) then
        {
        	            if ([_flag] call A3A_fnc_fatalWound) then
            {
                _actionX = _flag addAction [format ["<t>Revive %1</t> <img size='1.8' <img image='\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_reviveMedic_ca.paa' />",name _flag], A3A_fnc_actionRevive,nil,6,true,false,"","!(_this getVariable [""helping"",false]) and (isNull attachedTo _target)",4];
                _flag setUserActionText [_actionX,format ["Revive %1",name _flag],"<t size='2'><img image='\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_reviveMedic_ca.paa'/></t>"];
            }
            else
            {
        	    _actionX = _flag addAction [format ["<t>Revive %1</t> <img size='1.8' <img image='\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_revive_ca.paa' />",name _flag], A3A_fnc_actionRevive,nil,6,true,false,"","!(_this getVariable [""helping"",false]) and (isNull attachedTo _target)",4];
        	    _flag setUserActionText [_actionX,format ["Revive %1",name _flag],"<t size='2'><img image='\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_revive_ca.paa'/></t>"];
            };
        
	        _actionX = _flag addAction [format ["<t>Order team medic to revive %1 (if not moving ensure medic not stopped)</t> <img size='1.8' <img image='\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_revive_ca.paa' />",name _flag], A3A_fnc_teamMedicRevive,nil,5,true,false,"","((units group _this) - [_this, _target]) findIf {_x getUnitTrait 'Medic'} != -1",25];
			_flag setUserActionText [_actionX,format ["Order team medic to revive %1 (if not moving ensure medic not stopped)",name _flag],"<t size='2'><img image='\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_revive_ca.paa'/></t>"];

            _actionX = _flag addAction [format ["<t>Carry %1</t> <img image='\A3\ui_f\data\igui\cfg\actions\take_ca.paa' size='1.6' shadow=2 />",name _flag], A3A_fnc_carry,nil,4,true,false,"","(isPlayer _this) and (_this == _this getVariable ['owner',objNull]) and (isNull attachedTo _target) and !(_this getVariable [""helping"",false]);",4];
            _flag setUserActionText [_actionX,format ["Carry %1",name _flag],"<t size='2'><img image='\A3\ui_f\data\igui\cfg\actions\take_ca.paa'/></t>"];
            [_flag] call A3A_fnc_logistics_addLoadAction;
        };
    };
    case "moveS":
    {
        _flag addAction ["Move this asset", A3A_fnc_moveHQObject,nil,0,false,true,"","_this == theBoss"]
    };
    case "remove":
    {
        if (player == _flag) then
        {
            if (isNil "actionX") then
            {
                removeAllActions _flag;
                if (player == player getVariable ["owner",player]) then {[] call SA_Add_Player_Tow_Actions};
            }
            else
            {
                _flag removeAction actionX;
            };
        }
        else
        {
            removeAllActions _flag;
        };
    };
    case "refugee":
    {
        _flag addAction ["<t>Liberate</t> <img image='\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa' size='1.6' shadow=2 />", A3A_fnc_liberaterefugee,nil,6,true,true,"","(isPlayer _this) && (_this == _this getVariable ['owner',objNull]) && alive _target",4]
    };
    case "prisonerX":
    {
        _flag addAction ["<t>Liberate POW</t> <img image='\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa' size='1.6' shadow=2 />", A3A_fnc_liberatePOW,nil,6,true,true,"","(isPlayer _this) && (_this == _this getVariable ['owner',objNull]) && alive _target",4]
    };
    case "prisonerFlee":
    {
        _flag addAction ["<t>Liberate POW</t> <img image='\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa' size='1.6' shadow=2 />", A3A_fnc_liberateFlee,nil,6,true,true,"","(isPlayer _this) && (_this == _this getVariable ['owner',objNull]) && alive _target",4]
    };
    case "captureX":
    {
        // Uses the optional param to determine whether the call of captureX is a release or a recruit
        _flag addAction [format ["<t>%1</t> <img image='\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa' size='1.6' shadow=2 />", localize "STR_release_action"], { _this spawn A3A_fnc_captureX; },false,6,true,true,"","(isPlayer _this) and (_this == _this getVariable ['owner',objNull])",4];
        _flag addAction [localize "STR_recruit_action", { _this spawn A3A_fnc_captureX; },true,0,false,true,"","(isPlayer _this) and (_this == _this getVariable ['owner',objNull])",4];
        _flag addAction [format ["<t>%1</t> <img image='\a3\ui_f\data\IGUI\Cfg\Actions\talk_ca.paa' size='1.6' shadow=2 />", localize "STR_reveal_action"],SCRT_fnc_common_reveal,false,6,true,true,"","(isPlayer _this) and (_this == _this getVariable ['owner',objNull])",4];
    };
    case "buildHQ":
    {
        _flag addAction ["Build HQ here", A3A_fnc_buildHQ,nil,0,false,true,"","(isPlayer _this) and (_this == _this getVariable ['owner',objNull])",4]
    };
    case "seaport":
    {
        removeAllActions _flag;
        _flag addAction ["Deploy US Troops", {if ([player,300] call A3A_fnc_enemyNearCheck) then {["Unit Recruitment", "You cannot recruit units while there are enemies near you."] call A3A_fnc_customHint;} else { [] spawn A3A_fnc_US_recruit; };},nil,0,false,true,"","(isPlayer _this) and (_this == _this getVariable ['owner',objNull])",4];
		_flag addAction ["Deploy Vehicle", {if ([player,300] call A3A_fnc_enemyNearCheck) then {["Deploy Vehicle", "You cannot deploy vehicles while there are enemies near you."] call A3A_fnc_customHint;} else {["SEAPORT"] call SCRT_fnc_ui_createBuyVehicleMenu}},nil,0,false,true,"","(isPlayer _this) and (_this == _this getVariable ['owner',objNull])",4];
    	//[_flag] call HR_GRG_fnc_initGarage;
	};
    case "airbase":
    {
        removeAllActions _flag;
        _flag addaction [ 
        	(format ["<img image='%1' size='1' color='#ffffff'/>", "\A3\ui_f\data\GUI\Rsc\RscDisplayArsenal\spaceArsenal_ca.paa"] + format["<t size='1'> %1</t>", (localize "STR_A3_Arsenal")]), 
        	JN_fnc_arsenal_handleAction, 
        	[], 
        	6, 
        	true, 
        	false, 
        	"", 
        	"alive _target && {_target distance _this < 5} && {vehicle player == player}" 
    	];
        _flag addAction ["Deploy US Troops", {if ([player,300] call A3A_fnc_enemyNearCheck) then {["Unit Recruitment", "You cannot recruit units while there are enemies near you."] call A3A_fnc_customHint;} else { createDialog 'USunitRecruit'; }},nil,0,false,true,"","(isPlayer _this) and (_this == _this getVariable ['owner',objNull])",4];
		_flag addAction ["Deploy Vehicle", {if ([player,300] call A3A_fnc_enemyNearCheck) then {["Deploy Vehicle", "You cannot deploy vehicles while there are enemies near you."] call A3A_fnc_customHint;} else {["AIRPORT"] call SCRT_fnc_ui_createBuyVehicleMenu}},nil,0,false,true,"","(isPlayer _this) and (_this == _this getVariable ['owner',objNull])",4];
    	//[_flag] call HR_GRG_fnc_initGarage;
	};
	case "airbase3":
    {
        removeAllActions _flag;
        _flag addaction [ 
        	(format ["<img image='%1' size='1' color='#ffffff'/>", "\A3\ui_f\data\GUI\Rsc\RscDisplayArsenal\spaceArsenal_ca.paa"] + format["<t size='1'> %1</t>", (localize "STR_A3_Arsenal")]), 
        	JN_fnc_arsenal_handleAction, 
        	[], 
        	6, 
        	true, 
        	false, 
        	"", 
        	"alive _target && {_target distance _this < 5} && {vehicle player == player}" 
    	];
        _flag addAction ["Deploy US Troops", {if ([player,300] call A3A_fnc_enemyNearCheck) then {["Unit Recruitment", "You cannot recruit units while there are enemies near you."] call A3A_fnc_customHint;} else { createDialog 'USunitRecruit'; }},nil,0,false,true,"","(isPlayer _this) and (_this == _this getVariable ['owner',objNull])",4];
		_flag addAction ["Deploy Vehicle", {if ([player,300] call A3A_fnc_enemyNearCheck) then {["Deploy Vehicle", "You cannot deploy vehicles while there are enemies near you."] call A3A_fnc_customHint;} else {["AIRPORT3"] call SCRT_fnc_ui_createBuyVehicleMenu}},nil,0,false,true,"","(isPlayer _this) and (_this == _this getVariable ['owner',objNull])",4];
    	//[_flag] call HR_GRG_fnc_initGarage;
	};
    case "outpost":
    {
        removeAllActions _flag;
        _flag addAction ["Deploy US Troops", {if ([player,300] call A3A_fnc_enemyNearCheck) then {["Unit Recruitment", "You cannot recruit units while there are enemies near you."] call A3A_fnc_customHint;} else { [] spawn A3A_fnc_US_recruit; };},nil,0,false,true,"","(isPlayer _this) and (_this == _this getVariable ['owner',objNull])",4];
		_flag addAction ["Deploy Vehicle", {if ([player,300] call A3A_fnc_enemyNearCheck) then {["Deploy Vehicle", "You cannot deploy vehicles while there are enemies near you."] call A3A_fnc_customHint;} else {["OUTPOST"] call SCRT_fnc_ui_createBuyVehicleMenu}},nil,0,false,true,"","(isPlayer _this) and (_this == _this getVariable ['owner',objNull])",4];
    	//[_flag] call HR_GRG_fnc_initGarage;
    };
    case "garage":
    {
        //[_flag] call HR_GRG_fnc_initGarage;
    };
    case "SDKFlag":
    {
        removeAllActions _flag;
        _flag addaction [ 
        	(format ["<img image='%1' size='1' color='#ffffff'/>", "\A3\ui_f\data\GUI\Rsc\RscDisplayArsenal\spaceArsenal_ca.paa"] + format["<t size='1'> %1</t>", (localize "STR_A3_Arsenal")]), 
        	JN_fnc_arsenal_handleAction, 
        	[], 
        	6, 
        	true, 
        	false, 
        	"", 
        	"alive _target && {_target distance _this < 5} && {vehicle player == player}" 
    	];
        _flag addAction ["Deploy US Troops", {if ([player,300] call A3A_fnc_enemyNearCheck) then {["Unit Recruitment", "You cannot recruit units while there are enemies near you."] call A3A_fnc_customHint;} else { createDialog 'USunitRecruit'; }},nil,0,false,true,"","(isPlayer _this) and (_this == _this getVariable ['owner',objNull])",4];
        _flag addAction ["Deploy Vehicle", {if ([player,300] call A3A_fnc_enemyNearCheck) then {["Deploy Vehicle", "You cannot deploy vehicles while there are enemies near you."] call A3A_fnc_customHint;} else {["MAIN"] call SCRT_fnc_ui_createBuyVehicleMenu}},nil,0,false,true,"","(isPlayer _this) and (_this == _this getVariable ['owner',objNull])",4];
        [_flag] call HR_GRG_fnc_initGarage;
    };
    case "SDKFlag2":
    {
        removeAllActions _flag;
        _flag addAction ["Deploy UK Troops", {if ([player,300] call A3A_fnc_enemyNearCheck) then {["Unit Recruitment", "You cannot recruit units while there are enemies near you."] call A3A_fnc_customHint;} else { createDialog 'UKunitRecruit'; }},nil,0,false,true,"","(isPlayer _this) and (_this == _this getVariable ['owner',objNull])",4];
	};
	case "SDKFlag2OP":
    {
        removeAllActions _flag;
        _flag addAction ["Deploy UK Troops", {if ([player,300] call A3A_fnc_enemyNearCheck) then {["Unit Recruitment", "You cannot recruit units while there are enemies near you."] call A3A_fnc_customHint;} else { [] spawn A3A_fnc_UK_recruit; };},nil,0,false,true,"","(isPlayer _this) and (_this == _this getVariable ['owner',objNull])",4];
	};
    case "Intel_Small":
    {
        _flag addAction [
            format ["<t>%1</t> <img image='\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_search_ca.paa' size='1.6' shadow=2 />", localize "STR_search_intel_text"],
            A3A_fnc_searchIntelOnLeader,
            nil,
            4,
            true,
            false,
            "",
            "([_target] call A3A_fnc_canFight == false) && (_target getVariable ['intelSearchDone', false] != true) && isPlayer _this",
            4
        ];
    };
    case "Intel_Medium":
    {
        _flag addAction ["Take Intel", A3A_fnc_searchIntelOnDocument, nil, 4, true, false, "", "isPlayer _this", 4];
    };
    case "Intel_Large":
    {
        _flag addAction ["Download Intel", A3A_fnc_searchIntelOnLaptop, nil, 4, true, false, "", "isPlayer _this", 4];
    };
    case "Intel_Encrypted":
    {
        _flag addAction ["Decifer Intel", A3A_fnc_searchEncryptedIntel, nil, 4, true, false, "", "isPlayer _this", 4];
    };
    case "Move_Outpost_Static":
    {
        _flag addAction ["Move Emplacement Static", SCRT_fnc_common_moveOutpostStatic, nil, 4, true, false, "", "isPlayer _this", 4];
    };
    case "static":
    {
        private _cond = "(_target getVariable ['ownerSide', teamPlayer] == teamPlayer) and (isNull attachedTo _target) and (_this call A3A_fnc_isMember) and ";
        _flag addAction ["Allow AIs to use this weapon", A3A_fnc_unlockStatic, nil, 1, false, false, "", _cond+"!isNil {_target getVariable 'lockedForAI'}", 4];
        _flag addAction ["Prevent AIs using this weapon", A3A_fnc_lockStatic, nil, 1, false, false, "", _cond+"isNil {_target getVariable 'lockedForAI'}", 4];
        _flag addAction ["Kick AI off this weapon", A3A_fnc_lockStatic, nil, 1, true, false, "", _cond+"isNil {_target getVariable 'lockedForAI' and {!(isNull gunner _target) and {!(isPlayer gunner _target)}}}", 4];
        _flag addAction ["Move this asset", A3A_fnc_moveHQObject, nil, 1.5, false, false, "",  _cond+"(count crew _target == 0)", 4];
    };
    case "SDKRecruit":
    {
        private _cond = "!(behaviour _target == 'COMBAT') and !(_target getVariable ['incapacitated',false])";
        _flag addAction ["Recruit Partisans", {if ([player,300] call A3A_fnc_enemyNearCheck) then {["Recruit Partisans", "You cannot recruit units while there are enemies near you."] call A3A_fnc_customHint;} else { [] spawn A3A_fnc_SDK_recruit; }},nil,0,false,true,"","(isPlayer _this) and (_this == _this getVariable ['owner',objNull]) and (side (group _this) == teamPlayer)"];
        _flag addAction ["Recruit Partisan Squad", {if ([player,300] call A3A_fnc_enemyNearCheck) then {["Recruit Partisan Squad", "You cannot recruit a squad while there are enemies near you."] call A3A_fnc_customHint;} else { [groupsSDKSquad] spawn A3A_fnc_addFIAsquadHC; }},nil,0,false,true,"","(isPlayer _this) and (_this == _this getVariable ['owner',objNull]) and (side (group _this) == teamPlayer) and (_this == theBoss)"];
        _flag addAction ["Buy Civilian Vehicle", {if ([player,300] call A3A_fnc_enemyNearCheck) then {["Buy Civilian Vehicle", "You cannot buy vehicles while there are enemies near you."] call A3A_fnc_customHint;} else {["SDK"] call SCRT_fnc_ui_createBuyVehicleMenu}},nil,0,false,true,"","(isPlayer _this) and (_this == _this getVariable ['owner',objNull])",4];
	};
};
