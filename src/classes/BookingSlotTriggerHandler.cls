public with sharing class BookingSlotTriggerHandler {

    
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;

    public BookingSlotTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    BookingSlotUtilities utilities = new BookingSlotUtilities();

    
    public void OnBeforeInsert(Booking_Slot__c[] newBookingSlots, Map<Id, Booking_Slot__c> newBookingSlotMap) {

    	utilities.bookingSlotOwnerAssignment(newBookingSlots);
        //utilities.populateDriverAvailability(newBookingSlots);        
    }
    
    public void OnAfterInsert(Booking_Slot__c[] newBookingSlots, Map<Id, Booking_Slot__c> newBookingSlotMap) {
        utilities.rollUpDurationToDriverAvailabilityRecord(newBookingSlots);

        
    }

    public void OnBeforeUpdate(Booking_Slot__c[] newBookingSlots, Booking_Slot__c[] oldBookingSlots, Map<Id, Booking_Slot__c> newBookingSlotMap, Map<Id, Booking_Slot__c> oldBookingSlotMap) { 
     	
     	utilities.bookingSlotOwnerAssignment(newBookingSlots);
        //utilities.populateDriverAvailability(oldBookingSlotMap, newBookingSlots);


    }
    
    public void OnAfterUpdate(Booking_Slot__c[] newBookingSlots, Booking_Slot__c[] oldBookingSlots, Map<Id, Booking_Slot__c> newBookingSlotMap, Map<Id, Booking_Slot__c> oldBookingSlotMap) {     
        utilities.rollUpDurationToDriverAvailabilityRecord(oldBookingSlotMap, newBookingSlots);

    } 
}