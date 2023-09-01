/*
 * File: fn_compatabilityLoadFaction.sqf
 * Author: Spoffy
 * Description:
 *    Loads a faction definition file, and transforms it into the old global variable system for sides.
 * Params:
 *    _file - Faction definition file path
 *    _side - Side to load them in as
 * Returns:
 *    Namespace containing faction information
 * Example Usage:
 */
private _fileName = "fn_compatabilityLoadFaction";

params ["_file", "_side"];

[2, format ["Compatibility loading template: '%1' as side %2", _file, _side], _fileName] call A3A_fnc_log;

private _factionDefaultFile = ["EnemyDefaults","EnemyDefaults","RebelDefaults","CivilianDefaults"] #([west, east, independent, civilian] find _side);
_factionDefaultFile = "Templates\NewTemplates\FactionDefaults\" + _factionDefaultFile + ".sqf";

private _faction = [[_factionDefaultFile,_file]] call A3A_fnc_loadFaction;
private _factionPrefix = ["occ", "inv", "reb", "civ"] #([west, east, independent, civilian] find _side);
missionNamespace setVariable ["A3A_faction_" + _factionPrefix, _faction, true];  // ["A3A_faction_occ", "A3A_faction_inv", "A3A_faction_reb", "A3A_faction_civ"]

private _baseUnitClass = switch (_side) do {
	case west: { "B_G_Soldier_F" };
	case east: { "O_G_Soldier_F" };
	case independent: { "I_G_Soldier_F" };
	case civilian: { "C_Man_1" };
};

private _unitClassMap = createHashMapFromArray (_faction getVariable "baseSoldiers");

//Register loadouts globally.
private _loadoutsPrefix = format ["loadouts_%1_", _factionPrefix];
private _allDefinitions = _faction getVariable "loadouts";

{
		private _loadoutName = _x;
		private _definition = _allDefinitions getVariable _loadoutName;
		private _unitClass = _unitClassMap getOrDefault [_loadoutName, _baseUnitClass];
		[_loadoutsPrefix + _loadoutName, _definition + [_unitClass]] call A3A_fnc_registerUnitType;
} forEach allVariables _allDefinitions;

if (_side isEqualTo east) then {
	nameInvaders = _faction getVariable "name";

	//Flag images
	CSATFlag = _faction getVariable "flag";
	CSATFlagTexture = _faction getVariable "flagTexture";
	flagCSATmrk = _faction getVariable "flagMarkerType";
	if (isServer) then {
		"CSAT_carrier" setMarkerText (_faction getVariable "spawnMarkerName");
		"CSAT_carrier" setMarkerType flagCSATmrk;
	};

	//Loot crate
	CSATAmmoBox = _faction getVariable "ammobox";
    CSATSurrenderCrate = _faction getVariable "surrenderCrate";
    CSATEquipmentBox = _faction getVariable "equipmentBox";

	//PVP Loadouts
	CSATPlayerLoadouts = _faction getVariable "pvpLoadouts";
	vehCSATPVP = _faction getVariable "pvpVehicles";

	CSATGrunt = ["loadouts_inv_militia_Rifleman", "loadouts_inv_military_Rifleman", "loadouts_inv_elite_Rifleman"];
	CSATOfficer = "loadouts_inv_other_Official";
	CSATOfficer2 = "loadouts_inv_other_Traitor";
	CSATCrew = "loadouts_inv_other_Crew";
	CSATMarksman = ["loadouts_inv_militia_Marksman", "loadouts_inv_military_Marksman", "loadouts_inv_elite_Marksman"];
	staticCrewInvaders = CSATGrunt;
	CSATPilot = "loadouts_inv_other_Pilot";
	CSATUnarmed = "loadouts_inv_other_Unarmed";

	WAMRifleman = "loadouts_inv_militia_Rifleman";
	WAMMarksman = "loadouts_inv_militia_Marksman";

	groupsCSATSentry = [
		["loadouts_inv_militia_Grenadier", "loadouts_inv_militia_Rifleman"],
		["loadouts_inv_military_Grenadier", "loadouts_inv_military_Rifleman"],
		["loadouts_inv_elite_Grenadier", "loadouts_inv_elite_LAT"]
	];
	//TODO Change Rifleman to spotter.
	groupsCSATSniper = [
		["loadouts_inv_militia_Sniper", "loadouts_inv_militia_Rifleman"],
		["loadouts_inv_military_Sniper", "loadouts_inv_military_Rifleman"],
		["loadouts_inv_elite_Sniper", "loadouts_inv_elite_Rifleman"]
	];
	//TODO Create lighter Recon loadouts, and add a group of them to here.
	groupsCSATSmall = [groupsCSATSentry, groupsCSATSniper];
	//TODO Add ammobearers
	groupsCSATAA = [
		["loadouts_inv_militia_SquadLeader", "loadouts_inv_militia_Rifleman", "loadouts_inv_militia_AA", "loadouts_inv_militia_AA"],
		["loadouts_inv_military_SquadLeader", "loadouts_inv_military_Rifleman", "loadouts_inv_military_AA", "loadouts_inv_military_AA"],
		["loadouts_inv_elite_SquadLeader", "loadouts_inv_elite_Rifleman", "loadouts_inv_elite_AA", "loadouts_inv_elite_AA"]
	];
	groupsCSATAT = [
		["loadouts_inv_militia_SquadLeader", "loadouts_inv_militia_LAT", "loadouts_inv_militia_AT", "loadouts_inv_militia_AT"],
		["loadouts_inv_military_SquadLeader", "loadouts_inv_military_LAT", "loadouts_inv_military_AT", "loadouts_inv_military_AT"],
		["loadouts_inv_elite_SquadLeader", "loadouts_inv_elite_LAT", "loadouts_inv_elite_AT", "loadouts_inv_elite_AT"]
	];
	private _groupsCSATMediumSquad = [
		["loadouts_inv_militia_SquadLeader","loadouts_inv_militia_MachineGunner","loadouts_inv_militia_Grenadier", "loadouts_inv_militia_Radioman", "loadouts_inv_militia_LAT"],
		["loadouts_inv_military_SquadLeader","loadouts_inv_military_MachineGunner","loadouts_inv_military_Grenadier", "loadouts_inv_military_Radioman", "loadouts_inv_military_LAT"],
		["loadouts_inv_elite_SquadLeader","loadouts_inv_elite_MachineGunner","loadouts_inv_elite_Grenadier","loadouts_inv_elite_Radioman", "loadouts_inv_elite_LAT"]
	];
	groupsCSATmid = [_groupsCSATMediumSquad, groupsCSATAA, groupsCSATAT];

	groupsCSATSquadT1 = [];
	for "_i" from 1 to 5 do {
		groupsCSATSquadT1 pushBack [
			"loadouts_inv_militia_SquadLeader",
			selectRandomWeighted ["loadouts_inv_militia_LAT", 2, "loadouts_inv_militia_MachineGunner", 1],
			selectRandomWeighted ["loadouts_inv_militia_Rifleman", 2, "loadouts_inv_militia_Grenadier", 1],
			selectRandomWeighted ["loadouts_inv_militia_MachineGunner", 2, "loadouts_inv_militia_Marksman", 1],
			selectRandomWeighted ["loadouts_inv_militia_AT", 2, "loadouts_inv_militia_LAT", 1],
			selectRandomWeighted ["loadouts_inv_militia_AA", 1, "loadouts_inv_militia_Engineer", 3],
			selectRandomWeighted ["loadouts_inv_militia_Rifleman", 1, "loadouts_inv_militia_Radioman", 1],
			"loadouts_inv_militia_Medic"
		];
	};

	groupsCSATSquadT2 = [];
	for "_i" from 1 to 5 do {
		groupsCSATSquadT2 pushBack [
			"loadouts_inv_military_SquadLeader",
			selectRandomWeighted ["loadouts_inv_military_LAT", 2, "loadouts_inv_military_MachineGunner", 1],
			selectRandomWeighted ["loadouts_inv_military_Rifleman", 2, "loadouts_inv_military_Grenadier", 1],
			selectRandomWeighted ["loadouts_inv_military_MachineGunner", 2, "loadouts_inv_military_Marksman", 1],
			selectRandomWeighted ["loadouts_inv_military_AT", 2, "loadouts_inv_military_LAT", 1],
			selectRandomWeighted ["loadouts_inv_military_AA", 1, "loadouts_inv_military_Engineer", 3],
			selectRandomWeighted ["loadouts_inv_military_Rifleman", 1, "loadouts_inv_military_Radioman", 1],
			"loadouts_inv_military_Medic"
		];
	};

	groupsCSATSquadT3 = [];
	for "_i" from 1 to 5 do {
		groupsCSATSquadT3 pushBack [
			"loadouts_inv_elite_SquadLeader",
			selectRandomWeighted ["loadouts_inv_elite_LAT", 2, "loadouts_inv_elite_MachineGunner", 1],
			selectRandomWeighted ["loadouts_inv_elite_Rifleman", 2, "loadouts_inv_elite_Grenadier", 1],
			selectRandomWeighted ["loadouts_inv_elite_MachineGunner", 2, "loadouts_inv_elite_Marksman", 1],
			"loadouts_inv_elite_AT",
			selectRandomWeighted ["loadouts_inv_elite_AA", 1, "loadouts_inv_elite_Engineer", 3],
			selectRandomWeighted ["loadouts_inv_elite_Rifleman", 1, "loadouts_inv_elite_Radioman", 1],
			"loadouts_inv_elite_Medic"
		];
	};

	CSATSquad = [(groupsCSATSquadT1 select 0), (groupsCSATSquadT2 select 0), (groupsCSATSquadT3 select 0)];
	CSATSpecOp = [
		"loadouts_inv_SF_SquadLeader",
		"loadouts_inv_SF_Rifleman",
		"loadouts_inv_SF_Radioman",
		"loadouts_inv_SF_Marksman",
		"loadouts_inv_SF_MachineGunner",
		"loadouts_inv_SF_ExplosivesExpert",
		"loadouts_inv_SF_AT",
		"loadouts_inv_SF_LAT",
		"loadouts_inv_SF_Medic"
	];

	groupsWAMSmall = [
		["loadouts_inv_militia_Grenadier", "loadouts_inv_militia_LAT"],
		["loadouts_inv_militia_Marksman", "loadouts_inv_militia_Rifleman"],
		["loadouts_inv_militia_Marksman", "loadouts_inv_militia_Grenadier"]
	];
	groupsWAMMid = [];
	for "_i" from 1 to 6 do {
		groupsWAMMid pushBack [
			"loadouts_inv_militia_SquadLeader",
			"loadouts_inv_militia_Grenadier",
			"loadouts_inv_militia_MachineGunner",
			selectRandomWeighted [
				"loadouts_inv_militia_LAT", 1,
				"loadouts_inv_militia_Marksman", 1,
				"loadouts_inv_militia_Engineer", 1,
				"loadouts_inv_militia_Medic", 1
			]
		];
	};

	groupsWAMSquad = [];
	for "_i" from 1 to 5 do {
		groupsWAMSquad pushBack [
			"loadouts_inv_militia_SquadLeader",
			"loadouts_inv_militia_MachineGunner",
			"loadouts_inv_militia_Grenadier",
			selectRandomWeighted ["loadouts_inv_militia_Rifleman", 1, "loadouts_inv_militia_Radioman", 1],
			selectRandomWeighted ["loadouts_inv_militia_Rifleman", 1, "loadouts_inv_militia_Marksman", 1],
			selectRandomWeighted ["loadouts_inv_militia_Rifleman", 2, "loadouts_inv_militia_Marksman", 1],
			selectRandomWeighted ["loadouts_inv_militia_Rifleman", 1, "loadouts_inv_militia_LAT", 1],
			selectRandomWeighted ["loadouts_inv_militia_AT", 1, "loadouts_inv_militia_LAT", 2],
			"loadouts_inv_militia_Medic"
		];
	};

	vehCSATBike = _faction getVariable "vehiclesBasic" select 0;
	vehCSATLightArmed = _faction getVariable "vehiclesLightArmed";
	vehCSATLightUnarmed = _faction getVariable "vehiclesLightUnarmed";
	vehCSATTrucks = _faction getVariable "vehiclesTrucks";
	vehCSATCargoTrucks = _faction getVariable "vehiclesCargoTrucks";
	vehCSATAmmoTruck = _faction getVariable "vehiclesAmmoTrucks" select 0;
	vehCSATFuelTruck = _faction getVariable "vehiclesFuelTrucks" select 0;
	vehCSATRepairTruck = _faction getVariable "vehiclesRepairTrucks" select 0;
	vehCSATMedical = _faction getVariable "vehiclesMedical" select 0;
	vehCSATLight = vehCSATLightArmed + vehCSATLightUnarmed;

	vehCSATLightAPC = _faction getVariable "vehiclesLightAPCs";
	vehCSATAPC = _faction getVariable "vehiclesAPCs";
	vehCSATTanks = _faction getVariable "vehiclesTanks";
	vehCSATAA = _faction getVariable "vehiclesAA";
	vehCSATAttack = vehCSATAPC + vehCSATTanks;

	vehCSATBoat = _faction getVariable "vehiclesGunboats" select 0;
	vehCSATRBoat = _faction getVariable "vehiclesTransportBoats" select 0;
	vehCSATBoats = [vehCSATBoat, vehCSATRBoat] + (_faction getVariable "vehiclesAmphibious");

	vehCSATPlanes = _faction getVariable "vehiclesPlanesCAS";
	vehCSATPlanesAA = _faction getVariable "vehiclesPlanesAA";
	vehCSATTransportPlanes = _faction getVariable "vehiclesPlanesTransport";

	vehCSATPatrolHeli = _faction getVariable "vehiclesHelisLight" select 0;
	vehCSATTransportHelis = (_faction getVariable "vehiclesHelisLight") + (_faction getVariable "vehiclesHelisTransport");
	vehCSATAttackHelis = _faction getVariable "vehiclesHelisAttack";

	vehCSATUAV = _faction getVariable "uavsAttack" select 0;
	vehCSATUAVSmall = _faction getVariable "uavsPortable" select 0;

	vehCSATMRLS = _faction getVariable "vehiclesArtillery" select 0 select 0;
	vehCSATMRLSMags = _faction getVariable "vehiclesArtillery" select 0 select 1 select 0;

	vehCSATNormal =
		  vehCSATLight
		+ vehCSATTrucks
		+ (_faction getVariable "vehiclesAmmoTrucks")
		+ (_faction getVariable "vehiclesRepairTrucks")
		+ (_faction getVariable "vehiclesFuelTrucks")
		+ (_faction getVariable "vehiclesMedical");

	vehCSATUtilityTrucks = (_faction getVariable "vehiclesAmmoTrucks") + (_faction getVariable "vehiclesRepairTrucks") + (_faction getVariable "vehiclesFuelTrucks") + (_faction getVariable "vehiclesMedical");

	vehCSATAir =
		  vehCSATTransportHelis
		+ vehCSATAttackHelis
		+ vehCSATPlanes
		+ vehCSATPlanesAA
		+ vehCSATTransportPlanes;

	if (gameMode == 4) then {
		policeOfficer = "loadouts_inv_police_SquadLeader";
		policeGrunt = "loadouts_inv_police_Standard";

		vehPoliceCars = _faction getVariable "vehiclesPolice";
	};

	vehWAMArmedCars = _faction getVariable "vehiclesMilitiaLightArmed";
	vehWAMTrucks = _faction getVariable "vehiclesMilitiaTrucks";
	vehWAMCars = _faction getVariable "vehiclesMilitiaCars";
	vehWAMAPC = _faction getVariable "vehiclesMilitiaApcs";
	vehWAMTanks = _faction getVariable "vehiclesMilitiaTanks";

	CSATMG = _faction getVariable "staticMGs";
	staticATInvaders = _faction getVariable "staticAT" select 0;
	staticAAInvaders = _faction getVariable "staticAA";
	CSATMortar = _faction getVariable "staticMortars" select 0;
	CSATHowitzer = _faction getVariable "staticHowitzers" select 0;
	CSATmortarMagazineHE = _faction getVariable "mortarMagazineHE";
	CSATHowitzerMagazineHE = _faction getVariable "howitzerMagazineHE";

	CSATAARadar = _faction getVariable "vehiclesSam" select 0;
	CSATAASam = _faction getVariable "vehiclesSam" select 1;
};

if (_side isEqualTo west) then {
	nameOccupants = _faction getVariable "name";

	//Flag images
	NATOFlag = _faction getVariable "flag";
	NATOFlagTexture = _faction getVariable "flagTexture";
	flagNATOmrk = _faction getVariable "flagMarkerType";
	if (isServer) then {
		"NATO_carrier" setMarkerText (_faction getVariable "spawnMarkerName");
		"NATO_carrier" setMarkerType flagNATOmrk;
	};

	//Loot crate
	NATOAmmobox = _faction getVariable "ammobox";
    NATOSurrenderCrate = _faction getVariable "surrenderCrate";
    NATOEquipmentBox = _faction getVariable "equipmentBox";

	//PVP Loadouts
	NATOPlayerLoadouts = _faction getVariable "pvpLoadouts";
	vehNATOPVP = _faction getVariable "pvpVehicles";

	NATOGrunt = ["loadouts_occ_military_Rifleman", "loadouts_occ_elite_Rifleman"];
	NATOOfficer = "loadouts_occ_other_Official";
	NATOOfficer2 = "loadouts_occ_other_Traitor";
	NATOCrew = "loadouts_occ_other_Crew";
	NATOUnarmed = "loadouts_occ_other_Unarmed";
	staticCrewOccupants = NATOGrunt;
	NATOPilot = "loadouts_occ_other_Pilot";
	NATOSniper = ["loadouts_occ_military_Sniper", "loadouts_occ_elite_Sniper"];
	NATOMGMan = ["loadouts_occ_military_MachineGunner", "loadouts_occ_elite_MachineGunner"];

	FIARifleman = "loadouts_occ_military_Rifleman";


	groupsNATOSentry = [
		["loadouts_occ_military_Grenadier", "loadouts_occ_military_Rifleman"],
		["loadouts_occ_elite_Grenadier", "loadouts_occ_elite_LAT"]
	];
	//TODO Change Rifleman to spotter.
	groupsNATOSniper = [
		["loadouts_occ_military_Sniper", "loadouts_occ_military_Rifleman"],
		["loadouts_occ_elite_Sniper", "loadouts_occ_elite_Rifleman"]
	];

	//TODO Add ammobearers
	groupsNATOAA = [
		["loadouts_occ_military_SquadLeader", "loadouts_occ_military_MachineGunner", "loadouts_occ_military_Rifleman", "loadouts_occ_military_Medic"],
		["loadouts_occ_elite_SquadLeader", "loadouts_occ_elite_MachineGunner", "loadouts_occ_elite_Rifleman", "loadouts_occ_elite_Medic"]
	];
	groupsNATOAT = [
		["loadouts_occ_military_SquadLeader", "loadouts_occ_military_LAT", "loadouts_occ_military_AT", "loadouts_occ_military_Medic"],
		["loadouts_occ_elite_SquadLeader", "loadouts_occ_elite_LAT", "loadouts_occ_elite_AT", "loadouts_occ_elite_Medic"]
	];
	private _groupsNATOMediumSquad = [
		["loadouts_occ_military_SquadLeader","loadouts_occ_military_MachineGunner","loadouts_occ_military_Rifleman","loadouts_occ_military_Radioman","loadouts_occ_military_Medic"],
		["loadouts_occ_elite_SquadLeader","loadouts_occ_elite_MachineGunner","loadouts_occ_elite_Rifleman","loadouts_occ_elite_Radioman","loadouts_occ_elite_Medic"]
	];
	groupsNATOmid = [_groupsNATOMediumSquad, groupsNATOAA, groupsNATOAT];

	groupsNATOSquadT1 = [];
	for "_i" from 1 to 5 do {
		groupsNATOSquadT1 pushBack [
			"loadouts_occ_military_SquadLeader",
			selectRandomWeighted ["loadouts_occ_military_LAT", 2, "loadouts_occ_military_MachineGunner", 1],
			selectRandomWeighted ["loadouts_occ_military_Rifleman", 2, "loadouts_occ_military_Grenadier", 1],
			selectRandomWeighted ["loadouts_occ_military_MachineGunner", 2, "loadouts_occ_military_Rifleman", 1],
			selectRandomWeighted ["loadouts_occ_military_AT", 2, "loadouts_occ_military_LAT", 1],
			selectRandomWeighted ["loadouts_occ_military_Rifleman", 1, "loadouts_occ_military_Engineer", 3],
			"loadouts_occ_military_Radioman",
			"loadouts_occ_military_Medic"
		];
	};

	groupsNATOSquadT2 = [];
	for "_i" from 1 to 5 do {
		groupsNATOSquadT2 pushBack [
			"loadouts_occ_elite_SquadLeader",
			selectRandomWeighted ["loadouts_occ_elite_LAT", 2, "loadouts_occ_elite_MachineGunner", 1],
			selectRandomWeighted ["loadouts_occ_elite_Rifleman", 2, "loadouts_occ_elite_Grenadier", 1],
			selectRandomWeighted ["loadouts_occ_elite_MachineGunner", 2, "loadouts_occ_elite_Rifleman", 1],
			selectRandomWeighted ["loadouts_occ_elite_AT", 2, "loadouts_occ_elite_LAT", 1],
			selectRandomWeighted ["loadouts_occ_elite_Rifleman", 1, "loadouts_occ_elite_Engineer", 3],
			"loadouts_occ_elite_Radioman",
			"loadouts_occ_elite_Medic"
		];
	};

	NATOSquad = [(groupsNATOSquadT1 select 0), (groupsNATOSquadT2 select 1)];
	
	NATOSpecOp = [
		"loadouts_occ_SF_SquadLeader",
		"loadouts_occ_SF_Rifleman",
		"loadouts_occ_SF_Rifleman",
		"loadouts_occ_SF_Rifleman",
		"loadouts_occ_SF_Radioman",
		"loadouts_occ_SF_MachineGunner",
		"loadouts_occ_SF_ExplosivesExpert",
		"loadouts_occ_SF_AT",
		"loadouts_occ_SF_LAT",
		"loadouts_occ_SF_Medic"
	];

	NATOParaSquad = [
		"loadouts_occ_para_SquadLeader",
		"loadouts_occ_para_Rifleman",
		"loadouts_occ_para_Rifleman",
		"loadouts_occ_para_Rifleman",
		"loadouts_occ_para_Radioman",
		"loadouts_occ_para_MachineGunner",
		"loadouts_occ_para_ExplosivesExpert",
		"loadouts_occ_para_AT",
		"loadouts_occ_para_LAT",
		"loadouts_occ_para_Medic"
	];

	groupsFIASmall = [
		["loadouts_occ_military_Grenadier", "loadouts_occ_military_Rifleman"],
		["loadouts_occ_military_Rifleman", "loadouts_occ_military_Rifleman"],
		["loadouts_occ_military_Rifleman", "loadouts_occ_military_Grenadier"]
	];
	groupsFIAMid = [];
	for "_i" from 1 to 6 do {
		groupsFIAMid pushBack [
			"loadouts_occ_military_SquadLeader",
			"loadouts_occ_military_Grenadier",
			"loadouts_occ_military_MachineGunner",
			selectRandomWeighted [
				"loadouts_occ_military_LAT", 1,
				"loadouts_occ_military_Rifleman", 1,
				"loadouts_occ_military_Medic", 1,
				"loadouts_occ_military_Engineer", 1
			]
		];
	};

	groupsFIASquad = [];
	for "_i" from 1 to 5 do {
		groupsFIASquad pushBack [
			"loadouts_occ_military_SquadLeader",
			"loadouts_occ_military_MachineGunner",
			"loadouts_occ_military_Grenadier",
			selectRandomWeighted ["loadouts_occ_military_Rifleman", 1, "loadouts_occ_military_Radioman", 1],
			selectRandomWeighted ["loadouts_occ_military_Rifleman", 1, "loadouts_occ_military_Rifleman", 1],
			selectRandomWeighted ["loadouts_occ_military_Rifleman", 2, "loadouts_occ_military_Rifleman", 1],
			selectRandomWeighted ["loadouts_occ_military_Rifleman", 1, "loadouts_occ_military_LAT", 1],
			"loadouts_occ_military_AT",
			"loadouts_occ_military_Medic"
		];
	};

	vehNATOBike = _faction getVariable "vehiclesBasic" select 0;
	vehNATOLightArmed = _faction getVariable "vehiclesLightArmed";
	vehNATOLightUnarmed = _faction getVariable "vehiclesLightUnarmed";
	vehNATOTrucks = _faction getVariable "vehiclesTrucks";
	vehNATOCargoTrucks = _faction getVariable "vehiclesCargoTrucks";
	vehNATOAmmoTruck = _faction getVariable "vehiclesAmmoTrucks" select 0;
	vehNATOFuelTruck = _faction getVariable "vehiclesFuelTrucks" select 0;
	vehNATORepairTruck = _faction getVariable "vehiclesRepairTrucks" select 0;
	vehNATOMedical = _faction getVariable "vehiclesMedical" select 0;
	vehNATOLight = vehNATOLightArmed + vehNATOLightUnarmed;

	vehNATOLightAPC = _faction getVariable "vehiclesLightAPCs";
	vehNATOAPC = _faction getVariable "vehiclesAPCs";
	vehNATOTanks = _faction getVariable "vehiclesTanks";
	vehNATOAA = _faction getVariable "vehiclesAA";
	vehNATOAttack = vehNATOAPC + vehNATOTanks;

	vehNATOBoat = _faction getVariable "vehiclesGunboats" select 0;
	vehNATORBoat = _faction getVariable "vehiclesTransportBoats" select 0;
	vehNATOBoats = [vehNATOBoat, vehNATORBoat] + (_faction getVariable "vehiclesAmphibious");

	vehNATOPlanes = _faction getVariable "vehiclesPlanesCAS";
	vehNATOPlanesAA = _faction getVariable "vehiclesPlanesAA";
	vehNATOTransportPlanes = _faction getVariable "vehiclesPlanesTransport";

	vehNATOPatrolHeli = _faction getVariable "vehiclesHelisLight" select 0;
	vehNATOTransportHelis = _faction getVariable "vehiclesHelisTransport";
	vehNATOAttackHelis = _faction getVariable "vehiclesHelisAttack";

	vehNATOUAV = _faction getVariable "uavsAttack" select 0;
	vehNATOUAVSmall = _faction getVariable "uavsPortable" select 0;

	vehNATOMRLS = _faction getVariable "vehiclesArtillery" select 0 select 0;
	vehNATOMRLSMags = _faction getVariable "vehiclesArtillery" select 0 select 1 select 0;

	vehNATONormal =
		  vehNATOLight
		+ vehNATOTrucks
		+ (_faction getVariable "vehiclesAmmoTrucks")
		+ (_faction getVariable "vehiclesRepairTrucks")
		+ (_faction getVariable "vehiclesFuelTrucks")
		+ (_faction getVariable "vehiclesMedical");

	vehNATOUtilityTrucks = (_faction getVariable "vehiclesAmmoTrucks") + (_faction getVariable "vehiclesRepairTrucks") + (_faction getVariable "vehiclesFuelTrucks") + (_faction getVariable "vehiclesMedical");

	vehNATOAir = vehNATOTransportHelis + vehNATOAttackHelis + vehNATOPlanes + vehNATOPlanesAA + vehNATOTransportPlanes;

	vehFIAArmedCars = _faction getVariable "vehiclesMilitiaLightArmed";
	vehFIATrucks = _faction getVariable "vehiclesMilitiaTrucks";
	vehFIACars = _faction getVariable "vehiclesMilitiaCars";
	vehFIAAPC = _faction getVariable "vehiclesMilitiaApcs";
	vehFIATanks = _faction getVariable "vehiclesMilitiaTanks";

	if (gameMode != 4) then {
		policeOfficer = "loadouts_occ_police_SquadLeader";
		policeGrunt = "loadouts_occ_police_Standard";

		vehPoliceCars = _faction getVariable "vehiclesPolice";
	};

	NATOMG = _faction getVariable "staticMGs";
	staticATOccupants = _faction getVariable "staticAT" select 0;
	staticAAOccupants = _faction getVariable "staticAA";
	NATOMortar = _faction getVariable "staticMortars" select 0;
	NATOHowitzer = _faction getVariable "staticHowitzers" select 0;
	NATOmortarMagazineHE = _faction getVariable "mortarMagazineHE";
	NATOHowitzerMagazineHE = _faction getVariable "howitzerMagazineHE";

	NATOAARadar = _faction getVariable "vehiclesSam" select 0;
	NATOAASam = _faction getVariable "vehiclesSam" select 1;
};

if (_side isEqualTo independent) then {
	nameTeamPlayer = _faction getVariable "name";

	//Flag images
	SDKFlag = _faction getVariable "flag";
	SDKFlag2 = _faction getVariable "flag2";
	SDKFlagTexture = _faction getVariable "flagTexture";
	SDKFlagMarkerType = _faction getVariable "flagMarkerType";

	typePetros = "loadouts_reb_militia_Petros";

	SDKUnarmed = "loadouts_reb_militia_Unarmed";
	SDKMedic = "loadouts_reb_militia_medic";
	SDKMG = "loadouts_reb_militia_MachineGunner";
	SDKMil = "loadouts_reb_militia_Rifleman";
	SDKSL = "loadouts_reb_militia_SquadLeader";
	SDKEng = "loadouts_reb_militia_Engineer";

	UKstaticCrewTeamPlayer = "loadouts_reb_militia_ukstaticCrew";
	UKUnarmed = "loadouts_reb_militia_ukUnarmed";
	UKsniper = "loadouts_reb_militia_uksniper";
	UKMil = "loadouts_reb_militia_ukRifleman";
	UKMedic = "loadouts_reb_militia_ukmedic";
	UKMG = "loadouts_reb_militia_ukMachineGunner";
	UKExp = "loadouts_reb_militia_ukExplosivesExpert";
	UKGL = "loadouts_reb_militia_ukGrenadier";
	UKSL = "loadouts_reb_militia_ukSquadLeader";
	UKEng = "loadouts_reb_militia_ukEngineer";
	UKATman = "loadouts_reb_militia_ukAT";
	UKPilot = "loadouts_reb_militia_ukPilot";
	UKCrew = "loadouts_reb_militia_ukCrew";

	SASsniper = "loadouts_reb_militia_sassniper";
	SASMil = "loadouts_reb_militia_sasRifleman";
	SASMedic = "loadouts_reb_militia_sasmedic";
	SASMG = "loadouts_reb_militia_sasMachineGunner";
	SASExp = "loadouts_reb_militia_sasExplosivesExpert";
	SASSL = "loadouts_reb_militia_sasSquadLeader";
	SASATman = "loadouts_reb_militia_sasAT";

	USstaticCrewTeamPlayer = "loadouts_reb_militia_usstaticCrew";
	USUnarmed = "loadouts_reb_militia_usUnarmed";
	USsniper = "loadouts_reb_militia_ussniper";
	USMil = "loadouts_reb_militia_usRifleman";
	USMedic = "loadouts_reb_militia_usmedic";
	USMG = "loadouts_reb_militia_usMachineGunner";
	USExp = "loadouts_reb_militia_usExplosivesExpert";
	USGL = "loadouts_reb_militia_usGrenadier";
	USSL = "loadouts_reb_militia_usSquadLeader";
	USEng = "loadouts_reb_militia_usEngineer";
	USATman = "loadouts_reb_militia_usAT";
	USPilot = "loadouts_reb_militia_usPilot";
	USCrew = "loadouts_reb_militia_usCrew";
	
	parasniper = "loadouts_reb_militia_parasniper";
	paraMil = "loadouts_reb_militia_paraRifleman";
	paraMedic = "loadouts_reb_militia_paramedic";
	paraMG = "loadouts_reb_militia_paraMachineGunner";
	paraExp = "loadouts_reb_militia_paraExplosivesExpert";
	paraGL = "loadouts_reb_militia_paraGrenadier";
	paraSL = "loadouts_reb_militia_paraSquadLeader";
	paraEng = "loadouts_reb_militia_paraEngineer";
	paraATman = "loadouts_reb_militia_paraAT";

	UKTroops = [UKstaticCrewTeamPlayer,	UKUnarmed, UKsniper, UKMil, UKMedic, UKMG, UKExp, UKGL, UKSL, UKEng, UKATman, UKPilot, UKCrew];
	SASTroops = [SASsniper, SASMil, SASMedic, SASMG, SASExp, SASSL, SASATman];
	USTroops = [USstaticCrewTeamPlayer, USUnarmed, USsniper, USMil, USMedic, USMG, USExp, USGL, USSL, USEng, USATman, USPilot, USCrew];
	paraTroops = [parasniper, paraMil, paraMedic, paraMG, paraExp, paraGL, paraSL, paraEng, paraATman];
	SDKTroops = [SDKUnarmed, SDKMedic, SDKMG, SDKMil, SDKSL, SDKEng];
	
	alliedTroops = (UKTroops + SASTroops + USTroops + paraTroops + SDKTroops);
	
	groupsUKSquad = [UKSL,UKMG,UKGL,UKMil,UKATman,UKMil,UKMil,UKMedic,UKsniper,UKMil];
	groupsUSSquad = [USSL,USMG,USGL,USMil,USATman,USMil,USMil,USMedic,USsniper,USMil];
	groupsparaSquad = [paraSL,paraMG,paraGL,paraMil,paraATman,paraMil,paraMil,paraMedic,parasniper,paraMil];
	groupsSASSquad = [SASSL,SASMG,SASExp,SASMil,SASATman,SASMedic,SASsniper,SASMil];
	groupsSDKSquad = [SDKSL,SDKMG,SDKMG,SDKMil,SDKMil,SDKMil,SDKMedic,SDKMil];
	
	groupsSASRecon = [SASSL,SASMG,SASsniper,SASATman];
	groupsUSAT = [USSL,USATman,USATman,USATman];
	groupSASSniper = [SASsniper,SASsniper];
	groupSDKLeaders = [SDKMil,SDKMG,SDKSL];
	
	vehUKAACrew = [UKSL,UKEng,UKMedic,UKstaticCrewTeamPlayer,UKstaticCrewTeamPlayer,UKstaticCrewTeamPlayer];
	vehUSMGCrew = [USSL,USEng,USstaticCrewTeamPlayer];
	groupUSMortarCrew = [USSL,USMG,USstaticCrewTeamPlayer,USstaticCrewTeamPlayer];
	groupUSMGCrew = [USSL,USMG,USstaticCrewTeamPlayer,USstaticCrewTeamPlayer];
	groupUKMGCrew = [UKSL,UKMG,UKstaticCrewTeamPlayer,UKstaticCrewTeamPlayer];
	
	tankUKcrew = [UKCrew,UKCrew,UKCrew,UKCrew,UKCrew];
	tankUScrew = [USCrew,USCrew,USCrew,USCrew,USCrew];
	tankM5crew = [USCrew,USCrew,USCrew,USCrew];

	//Rebel Unit Tiers (for costs)
	sdkTier1 = [UKMil, UKstaticCrewTeamPlayer, UKMG, UKGL, USMil, USstaticCrewTeamPlayer, USMG, USGL, paraMil, SDKMil, SDKMG];
	sdkTier2 = [UKMedic, UKExp, UKEng, UKATman, USMedic, USExp, USEng, USATman, SDKMedic, SDKEng, paraGL, paraMG];
	sdkTier3 = [UKSL, UKsniper, USSL, USsniper, SDKSL, paraMedic, paraExp, paraEng, paraATman, SASMil];
	sdkTier4 = [paraSL, parasniper, SASMG, UKCrew, USCrew];
	sdkTier5 = [SASExp, SASMedic, SASATman, UKPilot, USPilot];
	sdkTier6 = [SASSL, SASSniper];
	soldiersSDK = sdkTier1 + sdkTier2 + sdkTier3 + sdkTier4 + sdkTier5 + sdkTier6;

	vehSDKBike = _faction getVariable "vehicleBasic";
	vehSDKLightArmed = _faction getVariable "vehicleLightArmed";
	vehSDKHeavyArmed = _faction getVariable "vehicleHeavyArmed";
	vehSDKAT = _faction getVariable "vehicleAT";
	vehSDKAA = _faction getVariable "vehicleAA";
	vehSDKLightUnarmed = _faction getVariable "vehicleLightUnarmed";
	vehSDKTruck = _faction getVariable "vehicleTruck";
	vehSDKTruckClosed = _faction getVariable "vehicleTruckClosed";
	vehSDKPlane = _faction getVariable "vehiclePlane";
	vehUSPayloadPlane = _faction getVariable "vehiclePayloadPlaneUS";
	vehUKPayloadPlane = _faction getVariable "vehiclePayloadPlaneUK";
	vehSDKBoat = _faction getVariable "vehicleBoat";
	vehInfSDKBoat = _faction getVariable "vehicleInfBoat";
	vehSDKAttackBoat = _faction getVariable "vehicleAttackBoat";
	vehSDKRepair = _faction getVariable "vehicleRepair";
	vehSDKFuel = _faction getVariable "vehicleFuel";
	vehSDKAmmo = _faction getVariable "vehicleAmmo";
	vehSDKMedical = _faction getVariable "vehicleMedical";

	vehSDKAPCUK1 = _faction getVariable "vehicleAPCUK1";
	vehSDKAPCUK2 = _faction getVariable "vehicleAPCUK2";
	vehSDKAPCUS = _faction getVariable "vehicleAPCUS";
	vehSDKTankChur = _faction getVariable "vehicleTankUKChur";
	vehSDKTankCroc = _faction getVariable "vehicleTankUKCroc";
	vehSDKTankHow = _faction getVariable "vehicleTankUKHow";
	vehSDKTankUKM4 = _faction getVariable "vehicleTankUKM4";
	vehSDKTankUSM5 = _faction getVariable "vehicleTankUSM5";
	vehSDKTankUSM4 = _faction getVariable "vehicleTankUSM4";

	vehSDKPlaneUK1 = _faction getVariable "vehiclePlaneUK1";
	vehSDKPlaneUK2 = _faction getVariable "vehiclePlaneUK2";
	vehSDKPlaneUK3 = _faction getVariable "vehiclePlaneUK3";
	vehSDKTransPlaneUK = _faction getVariable "vehicleTransportPlaneUK";
	vehSDKPlaneUS1 = _faction getVariable "vehiclePlaneUS1";
	vehSDKPlaneUS2 = _faction getVariable "vehiclePlaneUS2";
	vehSDKPlaneUS3 = _faction getVariable "vehiclePlaneUS3";
	vehSDKTransPlaneUS = _faction getVariable "vehicleTransportPlaneUS";

	UKMGStatic = _faction getVariable "staticMGUK";
	USMGStatic = _faction getVariable "staticMGUS";
	staticATteamPlayer = _faction getVariable "staticAT";
	staticAAteamPlayer = _faction getVariable "staticAA";
	SDKMortar = _faction getVariable "staticMortar";
	SDKArtillery = _faction getVariable "staticArtillery";
	SDKMortarHEMag = _faction getVariable "staticMortarMagHE";
	SDKMortarSmokeMag = _faction getVariable "staticMortarMagSmoke";
	SDKArtilleryHEMag = _faction getVariable "staticArtilleryMagHE";

	civBike = _faction getVariable "vehicleCivBike";
	civCar = _faction getVariable "vehicleCivCar";
	civTruck = _faction getVariable "vehicleCivTruck";
	civHeli = _faction getVariable "vehicleCivHeli";
	civBoat = _faction getVariable "vehicleCivBoat";
	civSupplyVehicle = _faction getVariable "vehicleCivSupply";

	UKMGStaticWeap = _faction getVariable "UKbaggedMGs" select 0 select 0;
	UKMGStaticSupp = _faction getVariable "UKbaggedMGs" select 0 select 1;
	USMGStaticWeap = _faction getVariable "USbaggedMGs" select 0 select 0;
	USMGStaticSupp = _faction getVariable "USbaggedMGs" select 0 select 1;
	MortStaticWeap = _faction getVariable "baggedMortars" select 0 select 0;
	MortStaticSupp = _faction getVariable "baggedMortars" select 0 select 1;
	ATStaticSDKB = _faction getVariable "baggedAT" select 0 select 0;
	AAStaticSDKB = _faction getVariable "baggedAA" select 0 select 0;

	ATMineMags = _faction getVariable "mineAT";
	APERSMineMags = _faction getVariable "mineAPERS";

	breachingExplosivesAPC = _faction getVariable "breachingExplosivesAPC";
	breachingExplosivesTank = _faction getVariable "breachingExplosivesTank";

	initialRebelEquipment = _faction getVariable "initialRebelEquipment";
};

if (_side isEqualTo civilian) then {
	civVehCommonData = _faction getVariable "vehiclesCivCar";
	civVehRepairData = _faction getVariable "vehiclesCivRepair";
	civVehMedicalData = _faction getVariable "vehiclesCivMedical";
	civVehRefuelData = _faction getVariable "vehiclesCivFuel";
	civBoatData = _faction getVariable "vehiclesCivBoat";
	civVehIndustrialData = _faction getVariable "vehiclesCivIndustrial";
};

_faction;
