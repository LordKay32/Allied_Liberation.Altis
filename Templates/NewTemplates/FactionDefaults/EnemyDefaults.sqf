//////////////////////////
//  Mission/HQ Objects  //
//////////////////////////

// All of bellow are optional overrides.
["firstAidKits", ["fow_i_fak_ger"]] call _fnc_saveToTemplate;  // However, item is tested for for help and reviving.
["mediKits", ["Medikit"]] call _fnc_saveToTemplate;  // However, item is tested for for help and reviving.

// The bellow are optional overrides
["placeIntel_desk", ["Land_CampingTable_F",0]] call _fnc_saveToTemplate;  // [classname,azimuth].
["placeIntel_itemMedium", ["Intel_File1_F",-155,false]] call _fnc_saveToTemplate;  // [classname,azimuth,isComputer].
["placeIntel_itemLarge", ["fow_p_radio",-25,true]] call _fnc_saveToTemplate;  // [classname,azimuth,isComputer].
