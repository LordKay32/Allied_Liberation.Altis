
class JN {
	class Common {
		file = "JeroenArsenal\Common";
		class common_addActionSelect {};
		class common_addActionCancel {};
		class common_updateActionCancel {};
		class common_removeActionCancel {};
		class common_getActionCanceled {};
	};
	
	class Common_Vehicle {
		file = "JeroenArsenal\Common\vehicle";
		class common_vehicle_getSeatNames {};
		class common_vehicle_getVehicleType {};
	};

	class Common_Array {
		file = "JeroenArsenal\Common\array";
		class common_array_add {};
		class common_array_remove {};
	};

	class JNA {
		file = "JeroenArsenal\JNA";
		class arsenal {};
		class arsenal_addItem {};
		class arsenal_addToArray {};
		class arsenal_cargoToArray {};
		class arsenal_cargoToArsenal {};
		class arsenal_handleAction {};
		class arsenal_init {};
		class arsenal_inList {};
		class arsenal_itemCount {};
		class arsenal_itemType {};
		class arsenal_loadInventory {};
		class arsenal_removeFromArray {};
		class arsenal_removeItem {};
		class arsenal_requestOpen {};
		class arsenal_requestClose {};
		class vehicleArsenal {};

	};

	class JNL {
		file = "JeroenArsenal\JNL";
		class logistics_init {};
		class logistics_load {};
		class logistics_unLoad {};
		class logistics_addAction {};
		class logistics_removeAction {};
	};

	class JNL_Actions {
		file = "JeroenArsenal\JNL\Actions";
		class logistics_addActionGetInWeapon {};
		class logistics_addActionLoad {};
		class logistics_addActionUnload {};
		class logistics_addEventGetOutWeapon {};
		class logistics_removeActionGetInWeapon {};
		class logistics_removeActionLoad {};
		class logistics_removeActionUnload {};
		class logistics_removeEventGetOutWeapon {};
	};

	class JNL_Functions {
		file = "JeroenArsenal\JNL\Functions";
		class logistics_addOrRemoveObjectMass {};
		class logistics_canLoad {};
		class logistics_classHasCargo {};
		class logistics_getCargo {};
		class logistics_getCargoOffsetAndDir {};
		class logistics_getCargoType {};
		class logistics_getNodes {};
		class logistics_lockSeats {};
	};
};