myBuildings = [["Land_New_WiredFence_5m_F","",0,0],["Land_New_WiredFence_10m_F","",0,0],["Land_New_WiredFence_10m_Dam_F","",0,0],["Land_Shed_Big_F","Land_sm_01_shelter_wide_f",0,0],["Land_Metal_Shed_F","land_gm_euro_gardenshed_01",270,0],["Land_ReservoirTank_V1_F","ReservoirTower_F",0,0],["Land_Net_Fence_Gate_F","",0,0],["Land_TBox_F","Land_WW2_Shed_M01",0,0],["Land_dp_mainFactory_F","land_fow_warehouse1_part1",0,-0.3],["Land_spp_Transformer_F","Land_Shed_W03_EP1",90,0.35],["Land_Stone_Gate_F","",0,0],["Land_i_House_Small_03_V1_F","Land_bthbc_md_NewHouseSmall_1_v1",0,0.3],["Land_FuelStation_Feed_F","",0,0],["Land_fs_roof_F","",0,0],["Land_LandMark_F","",0,0],["Land_ContainerLine_02_F","",0,0],["Land_Factory_Main_F","land_fow_warehouse1_part1",0,0],["Land_u_Shed_Ind_F","Land_Ind_SawMillPen",90,0.15],["Land_dp_bigTank_F","Land_Ind_TankBig",0,0],["Land_Carousel_01_F","",0,0],["Land_Hospital_side2_F","",0,0],["Land_Hospital_side1_F","",0,0],["Land_SlideCastle_F","",0,0],["Land_Shed_Small_F","land_gm_euro_shed_02",90,0.15],["Land_Cargo_Tower_V1_F","",90,0],["Land_Cargo_Tower_V2_F","",90,0],["Land_Cargo_Tower_V3_F","",90,0],["Land_Cargo_House_V2_F","",0,0],["Land_Cargo_House_V3_F","",0,0],["Land_PowerPoleWooden_L_F","Land_PowLines_WoodL",180,0],["Land_Cargo_Patrol_V2_F","Land_Hlaska",180,0],["Land_Cargo_Patrol_V3_F","Land_Hlaska",180,0],["Land_BeachBooth_01_F","",0,0],["Land_u_Barracks_V2_F","Land_Mil_Barracks_no_interior_CUP",0,0],["Land_i_Shed_Ind_F","Land_Mil_Barracks_no_interior_EP1_CUP",180,0.29],["Land_cargo_house_slum_F","Land_Shed_M01_EP1",270,0],["Land_Cargo_House_V1_F","CampEast",0,0],["Land_Airport_center_F","Land_Letistni_hala",0,0],["Land_Airport_right_F","",0,0],["Land_Airport_left_F","",0,0],["Land_Kiosk_papers_F","Land_water_tank",270,1.1],["Land_Kiosk_blueking_F","Land_water_tank",270,1.1],["Land_City_Gate_F","",0,0],["Land_LifeguardTower_01_F","",0,0],["Land_WIP_F","",0,0],["Land_Crane_F","",0,0],["Land_i_Garage_V1_F","Land_Garaz_mala",270,0],["Land_CarService_F","",180],["Land_fs_feed_F","",0],["Land_Dome_Big_F","",0,0],["Land_spp_Mirror_F","",0,0],["Land_Research_HQ_F","Land_Barrack2_EP1",90,0],["Land_Cargo_Patrol_V1_F","Land_Hlaska",180,0],["Land_Dome_Small_F","",0,0],["Land_Research_house_V1_F","Land_Barrack2_EP1",0,0],["Land_Cargo_HQ_V1_F","Land_Budova1",180,0],["Land_Cargo_HQ_V2_F","",180,0],["Land_Cargo_HQ_V3_F","",180,0],["Land_Cargo_Patrol_V3_ruins_F","",0,0],["Land_dp_smallTank_F","Land_vodni_vez",270,1],["Land_Communication_F","",0,0],["Land_TTowerSmall_1_F","",0,0],["Land_TTowerSmall_2_F","",0,0],["Land_i_Barracks_V2_F","Land_Mil_Barracks_no_interior_EP1_CUP",0,0],["Land_MilOffices_V1_F","",0,0],["Land_TentHangar_V1_F","",0,0],["Land_Radar_Small_F","",0,0],["Land_dp_smallFactory_F","Land_Mil_Barracks_L_EP1",180,0.15],["Land_spp_Tower_F","Land_Mil_Guardhouse_no_interior_EP1_CUP",270,0],["Land_Unfinished_Building_02_F","Land_bthbc_md_NewHouseMed_2_v1",0,0.5],["Land_Unfinished_Building_01_F","Land_bthbc_md_NewHouseSmall_1_v1",0,0.3]];                            
                         
for "_i" from 0 to(count myBuildings-1) do {                         
                         
    _CurrentBuilding   = (myBuildings select _i) select 0;                         
    _ReplacementBuilding = (myBuildings select _i) select 1;                          
    _DirectionOffset   = (myBuildings select _i) select 2;                       
    _d   = (myBuildings select _i) select 3;                           
                             
                         
    {                         
        systemchat format["getPosATL: %2 getDir: %4 _CurrentBuilding %5",getpos _x, getPosATL _x, getPosASL _x, getdir _x, _x];                          
        diag_log format["getPosATL: %1 getDir: %2 _CurrentBuilding %3 _ReplacementBuilding %4 _x %5", getPosATL _x, getdir _x, _CurrentBuilding, _ReplacementBuilding, _x];                          
        hideObjectGlobal  _x;                         
                             
        _myReplacement = createVehicle [_ReplacementBuilding, getPosATL _x, [], 0, "CAN_COLLIDE"];                         
        _myReplacement setDir (getdir _x) + _DirectionOffset;                         
        _myReplacement setPosATL [getPosATL _x select 0, getPosATL _x select 1, (getPosATL _x select 2) - _d];                           
                                      
        _myReplacement enableSimulationGlobal false;                        
    } forEach nearestObjects [[worldSize/2, worldSize/2], [_CurrentBuilding], 30000];                         
                         
                         
};                         
hint "Replacement script end";  
OT_common = true;