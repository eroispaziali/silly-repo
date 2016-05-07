public with sharing class BookingSlotUtilities {

	private Map<Id, Id> mapOfDriverIdToUserId;

	public void bookingSlotOwnerAssignment(List<Booking_Slot__c> bookingSlotList) {

		List<Booking_Slot__c> bookingSlotsToUpdate = new List<Booking_Slot__c>();

		for(Booking_Slot__c bookingSlot : bookingSlotList) {

			if(ownerIsNotCurrentlyDriver(bookingSlot)) {
				bookingSlotsToUpdate.add(bookingSlot);
			}
		}

		assignDriverAsOwner(bookingSlotsToUpdate);
	}


	public void populateDriverAvailability(Map<Id, Booking_Slot__c> oldBookingSlotMap, List<Booking_Slot__c> newBookingSlotList) {

		List<Booking_Slot__c> bookingSlotsToUpdate = filterBookingSlotsWithChangedDriver(oldBookingSlotMap, newBookingSlotList);

		Set<Id> driverIdSet = getDriverIds(bookingSlotsToUpdate);

		Map<Id, Driver__c> driverMap = new Map<Id, Driver__c>(	[SELECT Id, 
																		(SELECT Id, Start_Date__c 
																		 FROM Driver_Availability__r) 
																FROM Driver__c 
																WHERE Id IN :driverIdSet]);

		System.debug('driverMap: ' + driverMap);


		for(Booking_Slot__c bookingSlot : bookingSlotsToUpdate) {
			// get relevant driver
			Driver__c driver = driverMap.get(bookingSlot.Driver__c);

			for(Driver_Availability__c availabilityRecord : driver.Driver_Availability__r) {
				System.debug('availabilityRecord: ' + availabilityRecord);
				if(availabilityRecord.Start_Date__c.date() == bookingSlot.Start__c.date()) {
					// this is the correct availabiliy record
					bookingSlot.Driver_Availability__c = availabilityRecord.Id;
				}
			}
		}

	}


	public void populateDriverAvailability(List<Booking_Slot__c> newBookingSlotList) {
		populateDriverAvailability(null, newBookingSlotList);
	}

	public void rollUpDurationToDriverAvailabilityRecord(List<Booking_Slot__c> newBookingSlotList) {
		rollUpDurationToDriverAvailabilityRecord(null, newBookingSlotList);
	}


	public void rollUpDurationToDriverAvailabilityRecord(Map<Id, Booking_Slot__c> oldBookingSlotMap, List<Booking_Slot__c> newBookingSlotList) {

		Set<Id> driverAvailabilityToRecalculate = filterBookingSlotsWithChangedDriverAvailability(oldBookingSlotMap, newBookingSlotList);

		List<AggregateResult> rollupOfDurationResults = [SELECT Driver_Availability__c, SUM(Slot_Duration__c)
														 FROM Booking_Slot__c
														 WHERE Booking_Slot__c.Driver_Availability__r.Id IN :driverAvailabilityToRecalculate
														 GROUP BY Driver_Availability__c];


		// parse aggregate results into something more useful..
		Map<Id, Integer> driverAvailabilityToDurationMap = new Map<Id, Integer>();
		for(AggregateResult result : rollupOfDurationResults) {
			driverAvailabilityToDurationMap.put((Id)result.get('Driver_Availability__c'), Integer.valueOf(result.get('expr0')));
		}

		// apply to records;
		List<Driver_Availability__c> driverAvailabilityToUpdate = new List<Driver_Availability__c>();

		for(Id driverAvailabilityId : driverAvailabilityToRecalculate) {

			Driver_Availability__c driverAvailability = new Driver_Availability__c();
			driverAvailability.Id = driverAvailabilityId;

			if(driverAvailabilityToDurationMap.containsKey(driverAvailabilityId)) {
				driverAvailability.Total_Duration__c = driverAvailabilityToDurationMap.get(driverAvailabilityId);
			} else {
				driverAvailability.Total_Duration__c = null;
			}

			driverAvailabilityToUpdate.add(driverAvailability);
		}

		update driverAvailabilityToUpdate;

	}




	private Boolean driverAndDateNotNull(Booking_Slot__c bookingSlot) {
		Boolean result = bookingSlot.Driver__c != null && bookingSlot.Date__c != null;
		return bookingSlot.Driver__c != null && bookingSlot.Date__c != null;


	}

	private Boolean driverOrDateHasChanged(Booking_Slot__c oldBookingSlot, Booking_Slot__c newBookingSlot) {

		Boolean result = oldBookingSlot.Driver__c != newBookingSlot.Driver__c || 
			   			 oldBookingSlot.Date__c != newBookingSlot.Date__c;

		return oldBookingSlot.Driver__c != newBookingSlot.Driver__c || 
			   oldBookingSlot.Date__c != newBookingSlot.Date__c;

	}


	private Set<Id> filterBookingSlotsWithChangedDriverAvailability(Map<Id, Booking_Slot__c> oldBookingSlotMap, List<Booking_Slot__c> newBookingSlotList) {

		Set<Id> driverAvailabilityToRecalculate = new Set<Id>();

		if(oldBookingSlotMap != null) {
			for(Booking_Slot__c bookingSlot : newBookingSlotList) {
				Booking_Slot__c oldBookingSlot = oldBookingSlotMap.get(bookingSlot.Id);
				if(bookingSlot.Driver_Availability__c != oldBookingSlot.Driver_Availability__c) {
					if(bookingSlot.Driver_Availability__c != null) {
						driverAvailabilityToRecalculate.add(bookingSlot.Driver_Availability__c);
					}
					if(oldBookingSlot.Driver_Availability__c != null) {
						driverAvailabilityToRecalculate.add(oldBookingSlot.Driver_Availability__c);
					}
				} 
			}
		} else {
			for(Booking_Slot__c bookingSlot : newBookingSlotList) {
				if(bookingSlot.Driver_Availability__c != null) {
					driverAvailabilityToRecalculate.add(bookingSlot.Driver_Availability__c);
				}
			}
		}

		return driverAvailabilityToRecalculate;


	}

	private List<Booking_Slot__c> filterBookingSlotsWithChangedDriver (Map<Id, Booking_Slot__c> oldBookingSlotMap, List<Booking_Slot__c> newBookingSlotList) {

		List<Booking_Slot__c> bookingSlotsToUpdate = new List<Booking_Slot__c>();

		if(oldBookingSlotMap != null) {
			for(Booking_Slot__c bookingSlot : newBookingSlotList) {
				Booking_Slot__c oldBookingSlot = oldBookingSlotMap.get(bookingSlot.Id);
				if(driverAndDateNotNull(bookingSlot) && driverOrDateHasChanged(oldBookingSlot, bookingSlot)) {
					bookingSlotsToUpdate.add(bookingSlot);
				}
			}
		} else {
			for(Booking_Slot__c bookingSlot : newBookingSlotList) {
				if(driverAndDateNotNull(bookingSlot)) {
					bookingSlotsToUpdate.add(bookingSlot);
				}
			}
		}

		return bookingSlotsToUpdate;


	}


	private Set<Id> getDriverIds (List<Booking_Slot__c> bookingSlotList) {

		Set<Id> driverIdSet = new Set<Id>();

		for(Booking_Slot__c bookingSlot : bookingSlotList) {
			driverIdSet.add(bookingSlot.Driver__c);
		}

		return driverIdSet;
	}




	private void assignDriverAsOwner(List<Booking_Slot__c> bookingSlotList) {

		mapOfDriverIdToUserId = getUserLinkedToDriver(bookingSlotList);

		for(Booking_Slot__c bookingSlot : bookingSlotList) {
			if(driverIsLinkedToAUser(bookingSlot)) {
				bookingSlot.OwnerId = mapOfDriverIdToUserId.get(bookingSlot.Driver__c);
			}
		}

	}



	private Map<Id, Id> getUserLinkedToDriver(List<Booking_Slot__c> bookingSlots) {

		Set<Id> driverIds = new Set<Id>();
		Map<Id, Id> mapOfDriverIdToUserId = new Map<Id, Id>();

		for(Booking_Slot__c bookingSlot : bookingSlots) {
			driverIds.add(bookingSlot.Driver__c);
		}

		List<Driver__c> drivers = [SELECT Id, User__c FROM Driver__c WHERE Id IN :driverIds];

		for(Driver__c driver : drivers) {
			mapOfDriverIdToUserId.put(driver.Id, driver.User__c);
		}


		return mapOfDriverIdToUserId;
	}

	private Boolean ownerIsNotCurrentlyDriver(Booking_Slot__c bookingSlot) {
		return bookingSlot.Driver__c != null && bookingSlot.Driver__c != bookingSlot.OwnerId;

	}

	private Boolean driverIsLinkedToAUser(Booking_Slot__c bookingSlot) {

		return  mapOfDriverIdToUserId != null &&
				mapOfDriverIdToUserId.containsKey(bookingSlot.Driver__c) &&
				mapOfDriverIdToUserId.get(bookingSlot.Driver__c) != null;

	}


}