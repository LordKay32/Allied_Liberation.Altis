[//Loadout
	[//Primary Weapon
		"vn_type56",								//Weapon
		"",													//Muzzle
		"",									//Rail
		"",						    			//Sight
		["vn_type56_mag",30],						//Primary Magazine
		[],													//Secondary Magazine
		""													//Bipod
	],

	[//Launcher
		"vn_m72",													//Weapon
		"",													//Muzzle
		"",													//Rail
		"",													//Sight
		["vn_m72_mag", 1],									//Primary Magazine
		[],													//Secondary Magazine
		""													//Bipod
	],

	[//Secondary Weapon
		"vn_izh54_p",									//Weapon
		"",									//Muzzle
		"",													//Rail
		"",													//Sight
		["vn_izh54_mag", 2],								//Primary Magazine
		[],													//Secondary Magazine
		""													//Bipod
	],

	[//Uniform
		selectRandom										//Uniform
		["vn_o_uniform_nva_army_01_03", "vn_o_uniform_nva_army_10_03", "vn_o_uniform_nva_army_11_03", "vn_o_uniform_nva_army_12_03", "vn_o_uniform_nva_army_04_03", "vn_o_uniform_nva_army_06_03", "vn_o_uniform_nva_army_09_04"],
		[] + _basicMedicalSupplies + _basicMiscItems
	],

	[//Vest
		selectRandom										//Vest
		["vn_o_vest_01"],
		[//Inventory
			["vn_rdg2_mag",2,1],
			["vn_t67_grenade_mag",1,1],
			["vn_type56_mag",4,30]
		]
		+ _aceFlashlight
		+ _aceM84
	],

    [//Backpack
		"vn_b_pack_04",								//Backpack
		[//Inventory
			["vn_m16_40_mag",1]
		]
	],

		selectRandom										//Headgear
		["vn_o_helmet_nva_01", "vn_o_helmet_nva_04", "vn_o_helmet_nva_03", "vn_o_helmet_nva_02"],
		"",													//Facewear

	[//Binocular
		"Binocular",										//Binocular
		"",
		"",
		"",
		[],
		[],
		""
	],

	[//Item
        "ItemMap",											//Map
        "ItemGPS",											//Terminal
		["TF_ANPRC152"] call _fnc_tfarRadio,				//Radio
        "ItemCompass",										//Compass
        "ItemWatch",										//Watch
        ""													//Goggles
	]
];
