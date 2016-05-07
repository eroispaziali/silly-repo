global class BatchSlotDeleterScheduler implements Schedulable{
   
    global void execute(SchedulableContext SC) {   
        BatchSlotDeleter batch = new BatchSlotDeleter();
        Database.executeBatch(batch);
    }
}