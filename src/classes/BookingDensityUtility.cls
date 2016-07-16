public class BookingDensityUtility {

	public static Map<Date, Integer> getBookingDensity(Date startDate, Date endDate, Set<Id> trackIds) {


		List<AggregateResult> results = [SELECT Count(Id), Date__c 
										 FROM Booking_Slot__c 
										 WHERE 
										 Track_Availability__r.Track__c IN :trackIds
										 AND
										 (Date__c >= :startDate AND Date__c <= :endDate) 
										 AND
										 (Status__c = 'Booked' OR Status__c = 'Locked') 
										 GROUP BY Date__c];


		Map<Date, Track_Availability__c> trackAvailabilityToDate = getTrackAvailabilityPerDate(startDate, endDate, trackIds);


		Map<Date, Integer> dateWithBookedSlots = new Map<Date, Integer>();

		// put the aggregate results into a more friendly map
		for(AggregateResult result : results) {
		    dateWithBookedSlots.put((Date)result.get('Date__c'), (Integer)result.get('expr0'));
		}


		Map<Date, Integer> bookingDensityMap = new Map<Date, Integer>();

		Integer daysBetween = startDate.daysBetween(endDate);


		Date loopDate = startDate;


		for(Integer i = 0; i <= daysBetween; i++) {

			if(dateWithBookedSlots.containsKey(loopDate)) {
				// there are some booking slots
				bookingDensityMap.put(loopDate, 2); // 2 = 'some' booking slots
			} else {
				// there are no booking slots
				bookingDensityMap.put(loopDate, 3); // 3 = no booking slots
			}

			// if this date is not in the trackAvailabilityToDate map, then no trackavailability record exists, 
			// and the track is closed.
			if(!trackAvailabilityToDate.containsKey(loopDate)) {
				bookingDensityMap.put(loopDate, 1); // this will supersede any previous entry to the map
			}

			loopDate = loopDate.addDays(1);
		}

		return bookingDensityMap;

	}


	public static Map<Date, Track_Availability__c> getTrackAvailabilityPerDate(Date startDate, Date endDate, Set<Id> trackIds) {
		
		Map<Date, Track_Availability__c> trackAvailabilityToDate = new Map<Date, Track_Availability__c>();
		
		List<Track_Availability__c> trackAvailabilitys = [SELECT Id, Date__c 
															 FROM Track_Availability__c 
															 WHERE 
															 Track__c IN :trackIds 
															 AND
															 Date__c >= :startDate AND Date__c <= :endDate];

		for(Track_Availability__c trackAvailability : trackAvailabilitys) {
			trackAvailabilityToDate.put(trackAvailability.Date__c, trackAvailability);
		}

		return trackAvailabilityToDate;
	}

}