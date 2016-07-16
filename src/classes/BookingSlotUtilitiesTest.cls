@isTest
public class BookingSlotUtilitiesTest {


    public static testMethod void testPopulateDriverAvailability() {
        
    	// we need a driver
		Driver__c driver = TestData.buildDriver();
		insert driver;

		// We need a location
		Location__c location = TestData.buildLocation('Brooklands');
		insert location;

		// we need a driver availability record
		Driver_Availability__c driverAvailability1 = TestData.setDriverAvailability(driver, location);
		Driver_Availability__c driverAvailability2 = TestData.setDriverAvailability(driver, location, Date.today().addDays(10));
		insert driverAvailability1;
		insert driverAvailability2;


		Test.startTest();

			Booking_Slot__c bookingSlot = new Booking_Slot__c();
			bookingSlot.Slot_Duration__c = 60;
			bookingSlot.Driver_Availability__c = driverAvailability1.Id;
			insert bookingSlot;	
        
        	BookingSlotUtilities bs = new BookingSlotUtilities();
	        bs.populateDriverAvailability(new list<Booking_Slot__c>{bookingSlot});
    	Test.stopTest();
    }
    
	@isTest public static void testRollupOfDurationSingleBookingSlot() {


		// we need a driver
		Driver__c driver = TestData.buildDriver();
		insert driver;

		// We need a location
		Location__c location = TestData.buildLocation('Brooklands');
		insert location;

		// we need a driver availability record
		Driver_Availability__c driverAvailability = TestData.setDriverAvailability(driver, location);
		insert driverAvailability;


		Test.startTest();

			driverAvailability = [SELECT Id, Total_Duration__c FROM Driver_Availability__c WHERE Id = :driverAvailability.Id];
			System.assertEquals(null, driverAvailability.Total_Duration__c);

			Booking_Slot__c bookingSlot = new Booking_Slot__c();
			bookingSlot.Slot_Duration__c = 60;
			bookingSlot.Driver_Availability__c = driverAvailability.Id;
			insert bookingSlot;

			//requery driverAvailability
			driverAvailability = [SELECT Id, Total_Duration__c FROM Driver_Availability__c WHERE Id = :driverAvailability.Id];
			System.assertEquals(60, driverAvailability.Total_Duration__c);

		Test.stopTest();

	}

	

	@isTest public static void testRollupOfDurationMultiplwBookingSlot() {


		// we need a driver
		Driver__c driver = TestData.buildDriver();
		insert driver;

		// We need a location
		Location__c location = TestData.buildLocation('Brooklands');
		insert location;

		// we need a driver availability record
		Driver_Availability__c driverAvailability = TestData.setDriverAvailability(driver, location);
		insert driverAvailability;


		Test.startTest();

			driverAvailability = [SELECT Id, Total_Duration__c FROM Driver_Availability__c WHERE Id = :driverAvailability.Id];
			System.assertEquals(null, driverAvailability.Total_Duration__c);

			List<Booking_Slot__c> bookingSlotsToInsert = new List<Booking_Slot__c>();

			Booking_Slot__c bookingSlot = new Booking_Slot__c();
			bookingSlot.Slot_Duration__c = 60;
			bookingSlot.Driver_Availability__c = driverAvailability.Id;
			bookingSlotsToInsert.add(bookingSlot);
			
			Booking_Slot__c bookingSlot1 = new Booking_Slot__c();
			bookingSlot1.Slot_Duration__c = 60;
			bookingSlot1.Driver_Availability__c = driverAvailability.Id;
			bookingSlotsToInsert.add(bookingSlot1);
			
			insert bookingSlotsToInsert;

			//requery driverAvailability
			driverAvailability = [SELECT Id, Total_Duration__c FROM Driver_Availability__c WHERE Id = :driverAvailability.Id];
			System.assertEquals(120, driverAvailability.Total_Duration__c);

		Test.stopTest();

	}


	@isTest public static void testRollupOfDurationReparentBookingSlot() {


		// we need a driver
		Driver__c driver = TestData.buildDriver();
		insert driver;

		// We need a location
		Location__c location = TestData.buildLocation('Brooklands');
		insert location;

		// we need a driver availability record
		Driver_Availability__c driverAvailability1 = TestData.setDriverAvailability(driver, location);
		Driver_Availability__c driverAvailability2 = TestData.setDriverAvailability(driver, location, Date.today().addDays(10));
		insert driverAvailability1;
		insert driverAvailability2;


		Test.startTest();

			Booking_Slot__c bookingSlot = new Booking_Slot__c();
			bookingSlot.Slot_Duration__c = 60;
			bookingSlot.Driver_Availability__c = driverAvailability1.Id;
			insert bookingSlot;			

			//requery driverAvailability
			Map<Id, Driver_Availability__c> driverAvailabilityMap = new Map<Id, Driver_Availability__c>([SELECT Id, Name, Total_Duration__c FROM Driver_Availability__c WHERE Id = :driverAvailability1.Id OR Id = :driverAvailability2.Id]);

			System.assertEquals(60, driverAvailabilityMap.get(driverAvailability1.Id).Total_Duration__c);
			System.assertEquals(null, driverAvailabilityMap.get(driverAvailability2.Id).Total_Duration__c);

			// swtich booking slot to other driver availabiltiy
			bookingSlot.Driver_Availability__c = driverAvailability2.Id;
			update bookingSlot;

			//requery and check values changed
			Map<Id, Driver_Availability__c> updatedDriverAvailabilityMap = new Map<Id, Driver_Availability__c>([SELECT Id, Name, Total_Duration__c FROM Driver_Availability__c WHERE Id = :driverAvailability1.Id OR Id = :driverAvailability2.Id]);

			System.assertEquals(null, updatedDriverAvailabilityMap.get(driverAvailability1.Id).Total_Duration__c);
			System.assertEquals(60, updatedDriverAvailabilityMap.get(driverAvailability2.Id).Total_Duration__c);



		Test.stopTest();

	}



	@isTest public static void insertWithNoDriverSpecified() {


		TestData.initialiseDataModel();

		Track__c track 					= [SELECT Id FROM Track__c LIMIT 1];
		Driver__c driver 				= [SELECT Id FROM Driver__c LIMIT 1];
		Experience__c experience 		= [SELECT Id FROM Experience__c LIMIT 1];
		Vehicle_Availability__c vehicleAvail = [SELECT Id FROM Vehicle_Availability__c LIMIT 1];
		Date trackDate 					= Date.today();
		Track_Availability__c trackAvail= [SELECT Id FROM Track_Availability__c LIMIT 1];


		User user1 = TestData.buildUser();
		insert user1;

		Booking_Slot__c bookingSlot = TestData.buildBookingSlot(trackAvail, 
																driver, 
																experience, 
																vehicleAvail,
																trackDate
																);

		bookingSlot.Driver__c = null;


		System.runAs(user1) {
			insert bookingSlot;
		}

		//requery to get ownerId
		bookingSlot = [SELECT Id, OwnerId FROM Booking_Slot__c LIMIT 1];

		System.assertEquals(bookingSlot.OwnerId, user1.Id);


	}


@isTest public static void checkDriverAssignedAsOwnerOnInsert() {


		TestData.initialiseDataModel();

		Track__c track 					= [SELECT Id FROM Track__c LIMIT 1];
		Experience__c experience 		= [SELECT Id FROM Experience__c LIMIT 1];
		Vehicle_Availability__c vehicleAvail = [SELECT Id FROM Vehicle_Availability__c LIMIT 1];
		Date trackDate 					= Date.today();
		Track_Availability__c trackAvail= [SELECT Id FROM Track_Availability__c LIMIT 1];


		User user1 = TestData.buildUser();
		insert user1;

		User user2 = TestData.buildUser();
		insert user2;

		Driver__c driver1 = TestData.buildDriver('Driver 1');
		driver1.User__c = user2.Id; // link driver to user2
		insert driver1;


		Booking_Slot__c bookingSlot = TestData.buildBookingSlot(trackAvail, 
																driver1, 
																experience, 
																vehicleAvail,
																trackDate
																);


		System.runAs(user1) {
			insert bookingSlot;
		}

		//requery to get values
		bookingSlot = [SELECT Id, OwnerId, Driver__r.User__c FROM Booking_Slot__c LIMIT 1];

		System.assertEquals(bookingSlot.OwnerId, bookingSlot.Driver__r.User__c);


	}



}