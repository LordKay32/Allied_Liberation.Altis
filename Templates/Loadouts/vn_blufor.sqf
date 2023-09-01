[//Loadout
	[//Primary Weapon
		"vn_xm177_fg",								//Weapon
		"",													//Muzzle
		"",									//Rail
		"vn_o_4x_m16",						    			//Sight
		["vn_m16_40_mag",20],						//Primary Magazine
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
		"vn_mx991_m1911",									//Weapon
		"",									//Muzzle
		"",													//Rail
		"",													//Sight
		["vn_m1911_mag", 7],								//Primary Magazine
		[],													//Secondary Magazine
		""													//Bipod
	],

	[//Uniform
		selectRandom										//Uniform
		["vn_b_uniform_sog_02_02", "vn_b_uniform_sog_02_05", "vn_b_uniform_macv_06_02", "vn_b_uniform_macv_04_02"],
		[] + _basicMedicalSupplies + _basicMiscItems
	],

	[//Vest
		selectRandom										//Vest
		["vn_b_vest_sog_04"],
		[//Inventory
			["vn_m18_white_mag",2,1],
			["vn_m67_grenade_mag",1,1],
			["16Rnd_9x21_Mag",2,17],
			["vn_m16_40_mag",4,20]
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
		["vn_b_boonie_02_02", "vn_b_boonie_02_01", "vn_b_beret_01_01", "vn_b_beret_01_06", "vn_b_bandana_02"],
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
