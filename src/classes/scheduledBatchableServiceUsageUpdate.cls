global class scheduledBatchableServiceUsageUpdate implements Schedulable{
   global void execute(SchedulableContext sc) {
      // Implement any logic to be scheduled
 
         // We now call the batch class to be scheduled
      ServiceChangeUpdateServiceUsage1 b = new ServiceChangeUpdateServiceUsage1(); 
       
      //Parameters of ExecuteBatch(context,BatchSize)
      database.executebatch(b,10);
   }
}