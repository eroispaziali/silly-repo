public class BookingHandler2 {

	public static final Integer DEFAULT_LOCKING_PERIOD = General_Setting__c.getInstance('RegBookingLockingPeriodMins') != null
		? Integer.valueOf(General_Setting__c.getInstance('RegBookingLockingPeriodMins').Value__c)
		: 20;

	private final String BOOKING_STATUS_LOCKED = 'Locked';
	private final String EXPERIENCE_STATUS_LOCKED = 'Locked';
	private final String EMAIL = 'Email';
	private final String IN_PROGRESS = 'In Progress';
	private final String EXTRA = 'Extra';
	private final String GIFT_VOUCHER = 'Gift Voucher';
	private final String EXTRA_VOUCHER = 'Extra Voucher';
	private final String EXPERIENCE_CATEGORY = 'Experience';
	private final String ONE_TIME = 'One Time';
	private final Integer DEFAULT_EXTENDABLE_DURATION = 180;

	public Integer overridenLockingPeriod;

	public List<Slot> slotList;
	public Id invitProductRatePlanChargeId;
	public Id invitProductId {
		get {
			if (invitProductId == null) {
				if (slotList != null) {
					invitProductId = slotList[0].productId;
				}
				else {
					invitProductId = [	SELECT
											Invoiceit_s__Product_Rate_Plan__r.Invoiceit_s__Product__c
										FROM
											Invoiceit_s__Product_Rate_Plan_Charge__c
										WHERE
											Id = :invitProductRatePlanChargeId].Invoiceit_s__Product_Rate_Plan__r.Invoiceit_s__Product__c;
				}
				
			}
			return invitProductId;
		}
		set;
	}
	
	public Date purchaseDate;
	public Date usageDate;
	public SlotHandlerDriverAssignment slotDriverAssignment;

	public Id customerAccountId;
	public Id customerContactId;
	public Id participantContactId;
	public Id deliverToContactId;
	public Id parentOrderLineItem;
	public Id oldOrderProductId;
	
	public Boolean isRemovable = true;
	public Boolean isVoucher;
	public String personalisedMessage;
	
	public Experience__c experience;
	public List<Booking_Slot__c> bookingSlotList;
	public Invoiceit_s__Job__c invitOrder;
	public Id invitOrderId;
	public Invoiceit_s__Job_Product__c invitOrderLineItem;
	public Invoiceit_s__Job_Rate_Plan__c invitOrderRatePlan;
	public Invoiceit_s__Product_Rate_Plan_Charge__c invitProductRatePlanCharge {
		get {
			if(invitProductRatePlanCharge == null) {
				invitProductRatePlanCharge = [SELECT Id,
										Invoiceit_s__Unit_Price__c,Invoiceit_s__Product_Rate_Plan__c,
										Invoiceit_s__Product_Rate_Plan__r.Invoiceit_s__Product__r.Name,
										Invoiceit_s__Product_Rate_Plan__r.Invoiceit_s__Product__c,
										Invoiceit_s__Product_Rate_Plan__r.Invoiceit_s__Product__r.Id,
										Invoiceit_s__Product_Rate_Plan__r.Validity_Duration__c
								 	   FROM Invoiceit_s__Product_Rate_Plan_Charge__c 
								 	   WHERE Id = :invitProductRatePlanChargeId];
			}
			return invitProductRatePlanCharge;
		}
		set;
	}
	public Invoiceit_s__Job_Rate_Plan_Charge__c invitOrderRatePlanCharge;
	public List<Product_Component__c> productComponents;
	public static Invoiceit_s__Currency__c invitCurrency;
	//For bulkified insert of Extras list ===============================
	//===================================================================
	public List<Id> invitProductRatePlanChargeIds;
	private List<Invoiceit_s__Job_Product__c> invitOrderLineItems;
	private List<Invoiceit_s__Job_Rate_Plan__c> invitOrderRatePlans;
	private List<Invoiceit_s__Job_Rate_Plan_Charge__c> invitOrderRatePlanCharges;
	private Map<Invoiceit_s__Job_Product__c, Invoiceit_s__Product_Rate_Plan_Charge__c> invitOrderLineItemToProductRatePlanCharge = new Map<Invoiceit_s__Job_Product__c, Invoiceit_s__Product_Rate_Plan_Charge__c>();
	private Map<Invoiceit_s__Job_Rate_Plan__c, Invoiceit_s__Product_Rate_Plan_Charge__c> invitOrderRatePlanToProductRatePlanCharge = new Map<Invoiceit_s__Job_Rate_Plan__c, Invoiceit_s__Product_Rate_Plan_Charge__c>();
	private List<Invoiceit_s__Product_Rate_Plan_Charge__c> invitProductRatePlanCharges {
		get {
			if (invitProductRatePlanCharges == NULL) {
				invitProductRatePlanCharges = [
					SELECT 	Id,
							Invoiceit_s__Unit_Price__c,
							Invoiceit_s__Product_Rate_Plan__c,
							Invoiceit_s__Product_Rate_Plan__r.Invoiceit_s__Product__r.Name,
							Invoiceit_s__Product_Rate_Plan__r.Invoiceit_s__Product__c,
							Invoiceit_s__Product_Rate_Plan__r.Invoiceit_s__Product__r.Id
					FROM Invoiceit_s__Product_Rate_Plan_Charge__c 
					WHERE Id IN :invitProductRatePlanChargeIds
				];

				if (invitProductRatePlanCharges.size() < invitProductRatePlanChargeIds.size()) {
					addDuplicatesInRecordList(invitProductRatePlanCharges);
				}
			}
			return invitProductRatePlanCharges;
		}
		set;
	}

	private void addDuplicatesInRecordList(List<Invoiceit_s__Product_Rate_Plan_Charge__c> productRatePlaneChargesList) {
		Map<Id, Invoiceit_s__Product_Rate_Plan_Charge__c> prpcMap = new Map<Id, Invoiceit_s__Product_Rate_Plan_Charge__c>(productRatePlaneChargesList);
		Map<Id, Integer> amountOfEveryPRPC = new Map<Id, Integer>();
		for (Id eachPRPCId : invitProductRatePlanChargeIds) {
			if (amountOfEveryPRPC.get(eachPRPCId) == NULL) {
				amountOfEveryPRPC.put(eachPRPCId, 1);
			} else {
				amountOfEveryPRPC.put(eachPRPCId, amountOfEveryPRPC.get(eachPRPCId) + 1);
			}
		}

		for (Id eachPRPCId : amountOfEveryPRPC.keySet()) {
			if (amountOfEveryPRPC.get(eachPRPCId) > 1) {
				for (Integer i = 1; i < amountOfEveryPRPC.get(eachPRPCId); i++) {
					Invoiceit_s__Product_Rate_Plan_Charge__c newPRPC = prpcMap.get(eachPRPCId);
					productRatePlaneChargesList.add(newPRPC);
				}
			}
		}
	}
	//===================================================================

	public static Id getCurrency() {

		if (BookingHandler2.invitCurrency == null) {
			BookingHandler2.invitCurrency = [SELECT Id 
							 FROM Invoiceit_s__Currency__c 
							 WHERE Name = 'GBP'];
		}
		
		return BookingHandler2.invitCurrency.Id;
	}

	public void createBooking() {

		initialiseBookingDetails();
		
		Savepoint sp = Database.setSavePoint();

		try {

			if (experience == null) {
				experience 				= createExperience();
			}

			if(invitOrder == null) {
				if(invitOrderId == null) {
					invitOrder 	= createOrder();
				} else {
					invitOrder = [SELECT Id,
										Invoiceit_s__Account__c,
										Invoiceit_s__Billing_Contact__c,
										Invoiceit_s__Start_Date__c,
										Invoiceit_s__Service_Activation_Date__c,
										Invoiceit_s__Status__c,
										Invoiceit_s__CurrencyL__c
								  FROM Invoiceit_s__Job__c 
								  WHERE Id = :invitOrderId];
				}
			} 

			invitOrderLineItem 		= createOrderLineItem();
			invitOrderRatePlan 		= createOrderRatePlan();
			invitOrderRatePlanCharge= createOrderRatePlanCharge();
			bookingSlotList 		= createBookingSlots();

			// If this is an amendment then clone the original extras
			if (oldOrderProductId != null) { 
				Boolean isRedeemVoucher = (!isVoucher &&  BookingUtilities.isVoucher(oldOrderProductId));
				BookingUtilities.cloneExtrasFromOriginalProduct(OldOrderProductId,
					invitOrderLineItem.Id,
					invitOrder.Id,isRedeemVoucher);
			}

		} catch (Exception e) {
			Database.rollback(sp);
			LogUtility logger = new LogUtility();
			logger.addLog('BookingHandler2, createBooking', e);
			logger.writeLogs();
			throw e;
		}


	}

	public void createExtra() {

		initialiseBookingDetails();

		Savepoint sp = Database.setSavePoint();

		try {

			if(invitOrder == null) {
				if(invitOrderId == null) {
					invitOrder = createOrder();
				} else {
					invitOrder = [SELECT Id,
										Invoiceit_s__Account__c,
										Invoiceit_s__Billing_Contact__c,
										Invoiceit_s__Start_Date__c,
										Invoiceit_s__Service_Activation_Date__c,
										Invoiceit_s__Status__c,
										Invoiceit_s__CurrencyL__c
								  FROM Invoiceit_s__Job__c 
								  WHERE Id = :invitOrderId];
				}
			}

			invitOrderLineItem		= createOrderLineItem();
			invitOrderRatePlan 		= createOrderRatePlan();
			invitOrderRatePlanCharge= createOrderRatePlanCharge();
		}
		catch (Exception e) {
			Database.rollback(sp);
			LogUtility logger = new LogUtility();
			logger.addLog('BookingHandler2, createExtra', e);
			logger.writeLogs();
			throw e;
		}
	}


	public void createMultipleExtras() {
		initialiseBookingDetails();
		Savepoint sp = Database.setSavePoint();

		try {

			if (invitOrder == NULL) {
				if (invitOrderId == NULL) {
					invitOrder = createOrder();
				} else {
					invitOrder = [SELECT Id,
										Invoiceit_s__Account__c,
										Invoiceit_s__Billing_Contact__c,
										Invoiceit_s__Start_Date__c,
										Invoiceit_s__Service_Activation_Date__c,
										Invoiceit_s__Status__c,
										Invoiceit_s__CurrencyL__c
								  FROM Invoiceit_s__Job__c 
								  WHERE Id = :invitOrderId];
				}
			}

			invitOrderLineItems = createOrderLineItems();
			invitOrderRatePlans = createOrderRatePlans();
			invitOrderRatePlanCharges = createOrderRatePlanCharges();
		}
		catch (Exception e) {
			Database.rollback(sp);
			LogUtility logger = new LogUtility();
			logger.addLog('BookingHandler2, createMultipleExtras', e);
			logger.writeLogs();
			throw e;
		}
	}


	public void createVoucher() {

		isVoucher = true;
		initialiseBookingDetails();

		Savepoint sp = Database.setSavePoint();

		try {

			if(invitOrder == null) {
				if(invitOrderId == null) {
					throw new BookingEngineException('When creating a voucher the invitOrder or invitOrderId parameters for BookingHandler2 are mandatory.');
				} else {
					invitOrder = [SELECT Id,
										Invoiceit_s__Account__c,
										Invoiceit_s__Billing_Contact__c,
										Invoiceit_s__Start_Date__c,
										Invoiceit_s__Service_Activation_Date__c,
										Invoiceit_s__Status__c,
										Invoiceit_s__CurrencyL__c
								  FROM Invoiceit_s__Job__c 
								  WHERE Id = :invitOrderId];
				}
			}

			invitOrderLineItem		= createOrderLineItem();
			invitOrderRatePlan 		= createOrderRatePlan();
			invitOrderRatePlanCharge= createOrderRatePlanCharge();
		}
		catch (Exception e) {
			Database.rollback(sp);
			LogUtility logger = new LogUtility();
			logger.addLog('BookingHandler2, createVoucher', e);
			logger.writeLogs();
			throw e;
		}

	}

	private Experience__c createExperience() {
		experience = new Experience__c();
		experience.Experience_Start__c 	= slotList[0].startDateTime;
		experience.Experience_End__c 	= slotList.get(slotList.size()-1).endDateTime;
		experience.Product__c 			= invitProductRatePlanCharge.Invoiceit_s__Product_Rate_Plan__r.Invoiceit_s__Product__c;
		experience.Reserve_Experience_Minutes__c = overridenLockingPeriod == NULL ? DEFAULT_LOCKING_PERIOD : overridenLockingPeriod;
		experience.RecordTypeId 		= SObjectUtilities.getObjectRecordTypeId(Experience__c.sObjectType, 'Single Booking');

		// if this is an upgrade / ammend, link back to original Experience and increment Sub Number

		if (oldOrderProductId != NULL) {
			Invoiceit_s__Job_Product__c originalOrderProduct = [SELECT Id, Experience__c, Experience__r.Experience_Sub_Number__c FROM Invoiceit_s__Job_Product__c WHERE Id = :oldOrderProductId];

			experience.Original_Experience__c = originalOrderProduct.Experience__c;
			if (originalOrderProduct.Experience__c != NULL) {
				if (originalOrderProduct.Experience__r.Experience_Sub_Number__c != NULL) {
					experience.Experience_Sub_Number__c = originalOrderProduct.Experience__r.Experience_Sub_Number__c + 1;
				} else {
					experience.Experience_Sub_Number__c = 1;
				}
			}

			//extra validation for 'Experience_External_ID__c duplicates value' issue ===================================================
			if (experience.Original_Experience__c != NULL && experience.Experience_Sub_Number__c != NULL) {//it means that currently we are in an amendment process
				List<Experience__c> existingExp = [
					SELECT Id 
					FROM Experience__c
					WHERE Original_Experience__c = :experience.Original_Experience__c
					AND Experience_Sub_Number__c = :experience.Experience_Sub_Number__c
					AND Status__c = 'Cancelled'
					LIMIT 1
				];

				if (!existingExp.isEmpty()) {
					experience.Id = existingExp[0].Id;
					experience.Status__c = 'Locked';
				}
			}
			//===========================================================================================================================
		}
		System.debug('>>>>>>>>>>>>>>>experience: ' + experience);
		upsert experience;
		//insert experience;
		return experience;
	}

	public Invoiceit_s__Job__c createOrder() {

		invitOrder = new Invoiceit_s__Job__c();
		invitOrder.Invoiceit_s__Account__c = customerAccountId;
		invitOrder.Invoiceit_s__Billing_Contact__c = customerContactId;
		invitOrder.Invoiceit_s__Start_Date__c = purchaseDate;
		invitOrder.Invoiceit_s__Service_Activation_Date__c = purchaseDate;
		invitOrder.Invoiceit_s__Status__c = 'In Progress';
		invitOrder.Invoiceit_s__CurrencyL__c = BookingHandler2.getCurrency();

		insert invitOrder;
		return invitOrder;

	}

	//create new Order Products
	//for each of ProductRatePlanCharges
	private List<Invoiceit_s__Job_Product__c> createOrderLineItems() {
		List<Invoiceit_s__Job_Product__c> result = new List<Invoiceit_s__Job_Product__c>();
		Invoiceit_s__Job_Product__c parentOLI;
		if (parentOrderLineItem != NULL) {
			parentOLI = [SELECT Experience__c, Experience_Status__c FROM Invoiceit_s__Job_Product__c WHERE Id = :parentOrderLineItem];
		}
		Id recordTypeId = SObjectUtilities.getObjectRecordTypeId(Invoiceit_s__Job_Product__c.sObjectType, EXTRA);
		Integer sequenceNumber = 0;

		for (Invoiceit_s__Product_Rate_Plan_Charge__c eachPRPC : invitProductRatePlanCharges) {
			Invoiceit_s__Job_Product__c tempInvitOrderLineItem = new Invoiceit_s__Job_Product__c();

			tempInvitOrderLineItem.Invoiceit_s__Job__c = invitOrder.Id;
			tempInvitOrderLineItem.Invoiceit_s__Product__c = eachPRPC.Invoiceit_s__Product_Rate_Plan__r.Invoiceit_s__Product__c;
			tempInvitOrderLineItem.Participant__c = participantContactId;
			tempInvitOrderLineItem.Deliver_to__c = deliverToContactId;
			tempInvitOrderLineItem.Parent_Order_Product__c = parentOrderLineItem;
			tempInvitOrderLineItem.Delivery_Method__c = EMAIL;
			tempInvitOrderLineItem.Status__c = IN_PROGRESS;
			
			if (oldOrderProductId != null && !isVoucher && BookingUtilities.isVoucher(oldOrderProductId)) {
				BookingUtilities.setOrderProductUpdateStatus(oldOrderProductId, OrderUtilities.ORDER_PRODUCT_STATUS_REDEEMED);
				tempInvitOrderLineItem.Exclude_from_Report__c=true;
			}
			
			if (parentOLI != NULL) {
				if (parentOLI.Experience__c != NULL) {tempInvitOrderLineItem.Experience__c = parentOLI.Experience__c;}
				if (parentOLI.Experience_Status__c != NULL) {tempInvitOrderLineItem.Experience_Status__c = parentOLI.Experience_Status__c;}
			}

			tempInvitOrderLineItem.RecordTypeId = recordTypeId;
			tempInvitOrderLineItem.Invoiceit_s__SequenceNumber__c = ++sequenceNumber;
			result.add(tempInvitOrderLineItem);
		}

		insert result;

		Map<Integer, Invoiceit_s__Job_Product__c> lineMap = new Map<Integer, Invoiceit_s__Job_Product__c>();
		Map<Integer, Invoiceit_s__Product_Rate_Plan_Charge__c> prpcMap = new Map<Integer, Invoiceit_s__Product_Rate_Plan_Charge__c>();
		Integer lineCount = 1;
		Integer prpcCount = 1;
		for (Invoiceit_s__Job_Product__c eachInsertedOrderLineItem : result) {
			lineMap.put(lineCount, eachInsertedOrderLineItem);
			lineCount++;
		}
		for (Invoiceit_s__Product_Rate_Plan_Charge__c eachPRPC : invitProductRatePlanCharges) {
			prpcMap.put(prpcCount, eachPRPC);
			prpcCount++;
		}
		for (Integer key : lineMap.keySet()) {
			invitOrderLineItemToProductRatePlanCharge.put(lineMap.get(key), prpcMap.get(key));
		}

		return result;
	}


	private Invoiceit_s__Job_Product__c createOrderLineItem() {

		invitOrderLineItem = new Invoiceit_s__Job_Product__c();

		invitOrderLineItem.Invoiceit_s__Job__c = invitOrder.Id;
		invitOrderLineItem.Invoiceit_s__Product__c = invitProductId;
		invitOrderLineItem.Participant__c = participantContactId;
		invitOrderLineItem.Deliver_to__c = deliverToContactId;
		invitOrderLineItem.Parent_Order_Product__c = parentOrderLineItem;
		invitOrderLineItem.Delivery_Method__c = EMAIL;
		invitOrderLineItem.Status__c = IN_PROGRESS;
		invitOrderLineItem.Personalised_Message__c = personalisedMessage;

		if (oldOrderProductId != null && !isVoucher && BookingUtilities.isVoucher(oldOrderProductId)) {
			BookingUtilities.setOrderProductUpdateStatus(oldOrderProductId, OrderUtilities.ORDER_PRODUCT_STATUS_REDEEMED);
			invitOrderLineItem.Exclude_from_Report__c=true;
			invitOrderLineItem.Non_discountable__c = true;
		}

		if (experience != null) {
			invitOrderLineItem.Experience__c = experience.Id;
			// TC - MBWSI-1005
			invitOrderLineItem.Experience_Status__c = EXPERIENCE_STATUS_LOCKED; 
		}
		if (parentOrderLineItem != null) {
			Invoiceit_s__Job_Product__c parentOLI = [SELECT Experience__c, Experience_Status__c FROM Invoiceit_s__Job_Product__c WHERE Id = :parentOrderLineItem];
			if (parentOLI.Experience__c!=null) {invitOrderLineItem.Experience__c = parentOLI.Experience__c;}
			if (parentOLI.Experience_Status__c!=null) {invitOrderLineItem.Experience_Status__c = parentOLI.Experience_Status__c;}
		}
		if (isVoucher) {


			invitOrderLineItem.Voucher__c = true;

			invitOrderLineItem.Expiry_Date__c = BookingUtilities.generateExpiryDate(invitProductRatePlanCharge.Invoiceit_s__Product_Rate_Plan__c);
			// Calculate the termination date
			decimal extendableDuration;
			extendableDuration = [SELECT Extendable_Duration__c FROM Invoiceit_s__Product_Rate_Plan__c
				WHERE Id = :invitProductRatePlanCharge.Invoiceit_s__Product_Rate_Plan__c].Extendable_Duration__c;
			if (extendableDuration==null) {
				extendableDuration = DEFAULT_EXTENDABLE_DURATION;
			}
			invitOrderLineItem.Termination_Date__c = invitOrderLineItem.Expiry_Date__c.addDays(extendableDuration.intValue());

			if (oldOrderProductId != null && BookingUtilities.isVoucher(oldOrderProductId)) {
				BookingUtilities.setOrderProductUpdateStatus(oldOrderProductId, OrderUtilities.ORDER_PRODUCT_STATUS_EXTENDED);
				invitOrderLineItem.Exclude_from_Report__c=true;

				// Dates from the old voucher
				Invoiceit_s__Job_Product__c originalVoucherRP = [SELECT CreatedDate, Expiry_Date__c, Termination_Date__c
					FROM Invoiceit_s__Job_Product__c WHERE Id = :oldOrderProductId LIMIT 1];
				Integer validityDuration = invitProductRatePlanCharge.Invoiceit_s__Product_Rate_Plan__r.Validity_Duration__c.intValue();

				// The original voucher purchase date is used instead if it's a further back date
				if (originalVoucherRP.CreatedDate.addDays(validityDuration)<invitOrderLineItem.Expiry_Date__c) {
					invitOrderLineItem.Expiry_Date__c = Date.newInstance(
							originalVoucherRP.CreatedDate.year(),
							originalVoucherRP.CreatedDate.month(),
							originalVoucherRP.CreatedDate.day()
						).addDays(validityDuration);
					invitOrderLineItem.Termination_Date__c = invitOrderLineItem.Expiry_Date__c.addDays(extendableDuration.intValue());
				}
			}


			if (invitOrderLineItem.Parent_Order_Product__c == null) {
				invitOrderLineItem.RecordTypeId = SObjectUtilities.getObjectRecordTypeId(Invoiceit_s__Job_Product__c.sObjectType, GIFT_VOUCHER);
			}
			else {
				invitOrderLineItem.RecordTypeId = SObjectUtilities.getObjectRecordTypeId(Invoiceit_s__Job_Product__c.sObjectType, EXTRA_VOUCHER);
			}
			invitOrderLineItem.Date_of_Issue__c = Date.today();
			invitOrderLineItem.Authorised_By__c = UserInfo.getUserId();
		}
		else {
			if (invitOrderLineItem.Parent_Order_Product__c == null) {
				invitOrderLineItem.RecordTypeId = SObjectUtilities.getObjectRecordTypeId(Invoiceit_s__Job_Product__c.sObjectType, EXPERIENCE_CATEGORY);
			}
			else {
				invitOrderLineItem.RecordTypeId = SObjectUtilities.getObjectRecordTypeId(Invoiceit_s__Job_Product__c.sObjectType, EXTRA);
			}
		}
		if (oldOrderProductId != null || !isRemovable) {
			invitOrderLineItem.Original_Order_Product__c = oldOrderProductId;
			invitOrderLineItem.Non_removable__c = true;
		}

		invitOrderLineItem.Invoiceit_s__SequenceNumber__c = 1;

		if (isVoucher) {
			invitOrderLineItem.Security_Code__c = BookingUtilities.generateVoucherCode();
		}
		
		insert invitOrderLineItem;
		return invitOrderLineItem;
	}

	//create Order Rate Plans for each of new OrderProducts
	private List<Invoiceit_s__Job_Rate_Plan__c> createOrderRatePlans() {
		List<Invoiceit_s__Job_Rate_Plan__c> result = new List<Invoiceit_s__Job_Rate_Plan__c>();
		List<Invoiceit_s__Product_Rate_Plan_Charge__c> pRPChList = new List<Invoiceit_s__Product_Rate_Plan_Charge__c>();
		for (Invoiceit_s__Job_Product__c eachInvitOrderLineItem : invitOrderLineItems) {
			Invoiceit_s__Job_Rate_Plan__c tempInvitOrderRatePlan = new Invoiceit_s__Job_Rate_Plan__c();
			tempInvitOrderRatePlan.Invoiceit_s__Job_Product__c = eachInvitOrderLineItem.Id;
			tempInvitOrderRatePlan.Invoiceit_s__Product_Rate_Plan__c = invitOrderLineItemToProductRatePlanCharge.get(eachInvitOrderLineItem).Invoiceit_s__Product_Rate_Plan__c;
			//fill map for the next step - creation of order rate plan charges
			pRPChList.add(invitOrderLineItemToProductRatePlanCharge.get(eachInvitOrderLineItem));
			result.add(tempInvitOrderRatePlan);
		}

		insert result;

		Map<Integer, Invoiceit_s__Job_Rate_Plan__c> orderPlanMap = new Map<Integer, Invoiceit_s__Job_Rate_Plan__c>();
		Map<Integer, Invoiceit_s__Product_Rate_Plan_Charge__c> prpcMap = new Map<Integer, Invoiceit_s__Product_Rate_Plan_Charge__c>();
		Integer orderPlanCount = 1;
		Integer prpcCount = 1;
		for (Invoiceit_s__Job_Rate_Plan__c eachInsertedOrderPlan : result) {
			orderPlanMap.put(orderPlanCount, eachInsertedOrderPlan);
			orderPlanCount++;
		}
		for (Invoiceit_s__Product_Rate_Plan_Charge__c eachPRPC : pRPChList) {
			prpcMap.put(prpcCount, eachPRPC);
			prpcCount++;
		}
		for (Integer key : orderPlanMap.keySet()) {
			invitOrderRatePlanToProductRatePlanCharge.put(orderPlanMap.get(key), prpcMap.get(key));
		}

		return result;
	}


	private Invoiceit_s__Job_Rate_Plan__c createOrderRatePlan() {
		invitOrderRatePlan = new Invoiceit_s__Job_Rate_Plan__c();
		invitOrderRatePlan.Invoiceit_s__Product_Rate_Plan__c = invitProductRatePlanCharge.Invoiceit_s__Product_Rate_Plan__c;
		invitOrderRatePlan.Invoiceit_s__Job_Product__c = invitOrderLineItem.Id;
		insert invitOrderRatePlan;
		return invitOrderRatePlan;
	}


	private List<Invoiceit_s__Job_Rate_Plan_Charge__c> createOrderRatePlanCharges() {
		List<Invoiceit_s__Job_Rate_Plan_Charge__c> result = new List<Invoiceit_s__Job_Rate_Plan_Charge__c>();
		Id currencyId = BookingHandler2.getCurrency();
		Date currentDate = Date.today();
		Integer sequenceNumber = 0;

		for (Invoiceit_s__Job_Rate_Plan__c eachOrderRatePlan : invitOrderRatePlans) {
	 		Invoiceit_s__Job_Rate_Plan_Charge__c tempInvitOrderRatePlanCharge = new Invoiceit_s__Job_Rate_Plan_Charge__c();
			tempInvitOrderRatePlanCharge.Invoiceit_s__Job_Rate_Plan__c = eachOrderRatePlan.Id;
			tempInvitOrderRatePlanCharge.Invoiceit_s__Product_Rate_Plan_Charge__c = invitOrderRatePlanToProductRatePlanCharge.get(eachOrderRatePlan).Id;//Product Rate Plan Charge Id
			tempInvitOrderRatePlanCharge.Invoiceit_s__Unit_Price__c = invitOrderRatePlanToProductRatePlanCharge.get(eachOrderRatePlan).Invoiceit_s__Unit_Price__c;//Product Rate Plan Charge Price
			tempInvitOrderRatePlanCharge.Invoiceit_s__Price__c = invitOrderRatePlanToProductRatePlanCharge.get(eachOrderRatePlan).Invoiceit_s__Unit_Price__c;//Product Rate Plan Charge Price
			tempInvitOrderRatePlanCharge.Invoiceit_s__CurrencyL__c = currencyId;
			tempInvitOrderRatePlanCharge.Invoiceit_s__Quantity__c = 1;
			tempInvitOrderRatePlanCharge.Invoiceit_s__Sequence_No__c = sequenceNumber++;
			tempInvitOrderRatePlanCharge.Invoiceit_s__Service_Activation_Date__c = currentDate;
			tempInvitOrderRatePlanCharge.Invoiceit_s__Price_Type__c = ONE_TIME;
			tempInvitOrderRatePlanCharge.Full_Price__c = invitOrderRatePlanToProductRatePlanCharge.get(eachOrderRatePlan).Invoiceit_s__Unit_Price__c;//Product Rate Plan Charge Price

			result.add(tempInvitOrderRatePlanCharge);
		}

		insert result;
		return result;
	}


	private Invoiceit_s__Job_Rate_Plan_Charge__c createOrderRatePlanCharge() {
	 	
	 	invitOrderRatePlanCharge = new Invoiceit_s__Job_Rate_Plan_Charge__c();
		invitOrderRatePlanCharge.Invoiceit_s__Job_Rate_Plan__c = invitOrderRatePlan.Id;
		invitOrderRatePlanCharge.Invoiceit_s__Product_Rate_Plan_Charge__c = invitProductRatePlanCharge.Id;
		invitOrderRatePlanCharge.Invoiceit_s__Unit_Price__c = invitProductRatePlanCharge.Invoiceit_s__Unit_Price__c;
		invitOrderRatePlanCharge.Invoiceit_s__Price__c = invitProductRatePlanCharge.Invoiceit_s__Unit_Price__c;
		invitOrderRatePlanCharge.Invoiceit_s__CurrencyL__c = BookingHandler2.getCurrency();
		invitOrderRatePlanCharge.Invoiceit_s__Quantity__c = 1;
		invitOrderRatePlanCharge.Invoiceit_s__Sequence_No__c = 1;
		invitOrderRatePlanCharge.Invoiceit_s__Service_Activation_Date__c = Date.today();
		invitOrderRatePlanCharge.Invoiceit_s__Price_Type__c = 'One Time';
		invitOrderRatePlanCharge.Full_Price__c = invitProductRatePlanCharge.Invoiceit_s__Unit_Price__c;

		insert invitOrderRatePlanCharge;
		
		//While redeeming the voucher apply the discounted price
		if(oldOrderProductId != null && !isVoucher && BookingUtilities.isVoucher(oldOrderProductId)){
			
			Invoiceit_s__Job_Rate_Plan_Charge__c originalRatePlanCharge = 	[SELECT Id, Full_Price__c , invoiceit_s__Discount_Value__c,invoiceit_s__Unit_Price__c
																			FROM Invoiceit_s__Job_Rate_Plan_Charge__c 
																			WHERE Invoiceit_s__Job_Rate_Plan__r.Invoiceit_s__Job_Product__c = :oldOrderProductId
																			LIMIT 1];
																			
			Decimal discountAmount = originalRatePlanCharge.Invoiceit_s__Discount_Value__c;
			if (discountAmount==null) {discountAmount=0;}
			
			invitOrderRatePlanCharge.Invoiceit_s__Unit_Price__c = originalRatePlanCharge.Invoiceit_s__Unit_Price__c-discountAmount;
			invitOrderRatePlanCharge.Invoiceit_s__Price__c = originalRatePlanCharge.Invoiceit_s__Unit_Price__c-discountAmount;
			update invitOrderRatePlanCharge;
		
		}
		
		/*if (oldOrderProductId != null) {

			Decimal newPrice = BookingUtilities.calculateUpgradePrice(oldOrderProductId,invitOrderLineItem.Id);

			invitOrderRatePlanCharge.Invoiceit_s__Unit_Price__c = newPrice;
			invitOrderRatePlanCharge.Invoiceit_s__Price__c = newPrice;

			//new full price
			// get previous full amount
			Invoiceit_s__Job_Rate_Plan_Charge__c originalRatePlanCharge = 	[SELECT Id, Full_Price__c 
																			FROM Invoiceit_s__Job_Rate_Plan_Charge__c 
																			WHERE Invoiceit_s__Job_Rate_Plan__r.Invoiceit_s__Job_Product__c = :oldOrderProductId
																			LIMIT 1];

		 	if(originalRatePlanCharge.Full_Price__c != null) {
		 		invitOrderRatePlanCharge.Full_Price__c = originalRatePlanCharge.Full_Price__c + newPrice;
		 	}


			update invitOrderRatePlanCharge;
		}*/

		return invitOrderRatePlanCharge;

	}

	private void getProductComponents() {

		if(invitProductRatePlanCharge != null) {

			productComponents = [SELECT Id, Product__r.Id, Product__r.Name, Track__c, Track__r.Name, Product__c, Duration__c, Sequence__c
												FROM Product_Component__c
												WHERE Product__r.Id = :invitProductRatePlanCharge.Invoiceit_s__Product_Rate_Plan__r.Invoiceit_s__Product__r.Id
												ORDER By Sequence__c ASC];

		}

	}



	private List<Booking_Slot__c> createBookingSlots() {

		try {
		getProductComponents();

		// merge slots into total time period

		Set<Id> trackIds = new Set<Id>();
		for (Product_Component__c productComponent : productComponents) {
			trackIds.add(productComponent.Track__c);
		}
		Map<Id, Track_Availability__c> trackIdToTrackAvailability = new Map<Id, Track_Availability__c>();

		for (Track_Availability__c trackAvailability : [SELECT Id, Track__c FROM Track_Availability__c WHERE Track__c IN :trackIds AND Date__c = :usageDate]) {
			trackIdToTrackAvailability.put(trackAvailability.Track__c, trackAvailability);
		}

		bookingSlotList = new List<Booking_Slot__c>();

		for(Integer i = 0; i < slotList.size(); i++) {

			// create a Booking_Slot__c
			Booking_Slot__c booking = new Booking_Slot__c();
			booking.Experience__c 	= experience.Id;
			booking.Start__c 		= slotList[i].startDateTime;
			booking.End__c 			= slotList[i].endDateTime;
			//booking.Driver__c 		= slotList[i].driverId;
			//booking.Driver_Availability__c = slotList[i].driverAvailabilities[0].Id;
			if(slotList[i].driverAvailabilityId == null) {
				booking.Driver_Availability__c = slotList[i].driverAvailabilities[0].Id;
			} else {
				booking.Driver_Availability__c = slotList[i].driverAvailabilityId;
			}
			booking.Vehicle_Availability__c = slotList[i].vehicleAvailability.Id;
			booking.Status__c 		= BOOKING_STATUS_LOCKED;
			booking.Date__c			= usageDate;
			booking.Product_Component__c = productComponents[i].Id;
			booking.Slot_Duration__c 	 = productComponents[i].Duration__c;

			if (productComponents[i].Track__c != null && trackIdToTrackAvailability.containsKey(productComponents[i].Track__c)) {
				booking.Track_Availability__c = trackIdToTrackAvailability.get(productComponents[i].Track__c).Id;
			}

			bookingSlotList.add(booking);
			
		}

		if (bookingSlotList.size() > 0) {
			experience.Driver_Availability__c = bookingSlotList[0].Driver_Availability__c;
			update experience;
		}

		insert bookingSlotList;

		}
		catch (Exception e) {
			throw new BookingHandlerSlotException(Label.BookingHandlerSlotException);
		}	
		return bookingSlotList;

	}


	public void initialiseBookingDetails() {
		System.debug('>>>>>>>>>>>>>>>>>> initialiseBookingDetails: customerAccountId='+ customerAccountId+ ' and customerContactId='+customerContactId);

		if(customerAccountId == null) {
			try {
				customerAccountId = (Id) General_Setting__c.getAll().get('API_BUCKET_ACCOUNT').Value__c;
			}
			catch (Exception e) {
				LogUtility logger = new LogUtility();
				logger.addLog('BookingHandler2, API Account ID', e);
				logger.writeLogs();
				throw new BookingEngineException('The API_BUCKET_ACCOUNT custom setting (general setting) should be set to a person account.');
			}
		}

		if(customerContactId == null && customerAccountId != null) {
			// KK: this is a horrible hack but when running BookingUtilitiesTest the query has no results even though
			// API_BUCKET_ACCOUNT is set correctly!??! I have no idea what's going on :(
			try {
				customerContactId = Test.isRunningTest() ? ((String) customerAccountId).replace('001','003') :
				[select PersonContactId from Account where id = :customerAccountId].PersonContactId;
			}
			catch (Exception e) {
				LogUtility logger = new LogUtility();
				logger.addLog('BookingHandler2, API Contact ID', e);
				logger.writeLogs();
				throw new BookingEngineException('The API_BUCKET_ACCOUNT custom setting (general setting) should be set to a person account.' + e.getStackTraceString());
			}
		}

		if (purchaseDate == null) {
			purchaseDate = Date.today();
		}

		if (isVoucher == null) {
			isVoucher = false;
		}
	}

	public class BookingHandlerSlotException extends Exception {}
}