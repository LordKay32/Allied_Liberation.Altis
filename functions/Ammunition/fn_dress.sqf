private _unit = _this select 0;
private _loadoutOverride = param [1];
private _team = side group _unit;
private _unitLoadoutNumber = if (!isNil "_loadoutOverride") then {_loadoutOverride} else {_unit getVariable ["pvpPlayerUnitNumber", 0]};

_loadout = switch _team do {
	case Occupants: {
		if (count NATOPlayerLoadouts > _unitLoadoutNumber) then {NATOPlayerLoadouts select _unitLoadoutNumber} else { [] };
	};

	case Invaders: {
		if (count CSATPlayerLoadouts > _unitLoadoutNumber) then {CSATPlayerLoadouts select _unitLoadoutNumber} else { [] };
	};

	case teamPlayer: {
		private _uniform = if (roleDescription player in ["Commander","UK Officer (Medic)","UK Officer (Engineer)"]) then {"U_LIB_UK_P37"} else {"U_LIB_US_Off"};
		if (toLower worldName isEqualTo "enoch") then {
			[[],[],[],[selectRandom (A3A_faction_reb getVariable "uniforms"), []],[],[],"","",[],
			[(selectRandom unlockedmaps),"","",(selectRandom unlockedCompasses),(selectRandom unlockedwatches),""]];
		} else {
			[[],[],[],[_uniform, []],[],[],"","",[],
			["ItemMap","","ItemRadio","ItemCompass","ItemWatch",""]];
		};
	};

	default {
		[];
	};
};

_unit setUnitLoadout _loadout;

_unit selectWeapon (primaryWeapon _unit);
