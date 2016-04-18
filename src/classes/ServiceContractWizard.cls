public class ServiceContractWizard {
    public Service_Contract__c contract;
    public List<Contract_Cost__c> costs;
    
    // The number of contract cost lines to show on the 2nd step of the wizard
    private final Integer NUM_COST_LINES = 25;
    
    //
    // Constructor
    //
    public ServiceContractWizard(ApexPages.StandardController controller) {
        contract = (Service_Contract__c)controller.getRecord();

        // Initialise the costs array
        costs = new List<Contract_Cost__c>();
        
        costs = [select Cost__c, Year__c, Service_Definition__c, FCR__c, Pays_VAT__c
                 from Contract_Cost__c where Contract__c = :contract.Id
                 order by Year__c, Service_Definition__c];
        
        // Add as many cost lines as specified in variable NUM_COST_LINES
        for (Integer i=costs.size(); i < NUM_COST_LINES; i++)
            costs.add( new Contract_Cost__c() );
    }
    
    //
    // Properties
    //
    public Service_Contract__c getContract() {
        if (contract == null)
            contract = new Service_Contract__c();
        return contract;
    }
    
    public List<Contract_Cost__c> getCosts() {
        return costs;
    }
    
    public void setCosts(List<Contract_Cost__c> c) {
        costs = c;
    }
    
    // Shows default of £0.00 in 'Suggested FCR' field
    public string getDefaultFCR() {
        return '0.00';
    }
    
    // Mandatory setter for 'Suggested FCR' field. Doesn't need to do anything
    public void setDefaultFCR(string fcr) {
        // Do nothing
    }
    
    // 
    // Navigation methods
    //
    // Go to first page of wizard
    public PageReference back() {
        return Page.ServiceContract1;
    }
    
    // Go to second page of wizard
    public PageReference next() {
        return Page.ServiceContract2;
    }
    
    // Return the user to the Service Contract tab
    public PageReference cancel() {
        PageReference contPage = new PageReference('/a0A/o');
        contPage.setRedirect(true);
        return contPage;
    }
    
    // Return to service contract page
    public PageReference cancelCosts() {
        PageReference contPage = new PageReference('/' + contract.Id);
        contPage.setRedirect(true);
        return contPage;
    }
    
    //
    // Save record methods
    //
    public PageReference save() {
        try {
            insert contract;
        }
        catch (DMLException de) {
            System.debug('ERROR: inserting Service Contract. Name: ' + contract.Contract_Name__c);
        }
        
        // Save contract cost records and navigate to service contract record
        return saveCosts();
    }
    
    public PageReference saveCosts() {
        Integer i = 0;
        
        // Remove any contract cost lines without a 'financial year' -- they are blank line
        // Loop backwards because removing forwards causes records to be missed
        for (i = costs.size()-1; i > 0; i--)
            if ((costs[i].Year__c == null) && (costs[i].Service_Definition__c == null))
                costs.remove(i);
        
        try {
            // Link each cost line to the service contract 
            for (i = 0; i < costs.size(); i++)
                if (costs[i].Id == null)
                    costs[i].Contract__c = contract.Id;
        
            // Insert cost lines (as long as list isn't empty)
            if (!costs.isEmpty())
                upsert costs;
        }
        catch (Exception e) {
              System.debug('INSERT CONTRACT COSTS:');
              for (Contract_Cost__c c : costs)
                System.debug('-- Year:' + c.Year__c + '; Contract:' + c.Contract__c); 
        }
        
        // Return to new service contract page
        PageReference contPage = new PageReference('/' + contract.Id);
        contPage.setRedirect(true);
        return contPage;
    }
    
    //
    // TEST ServiceContractWizard
    //
    private static testMethod void testContract () {
        Service_Contract__c contract = new Service_Contract__c(Contract_Name__c = 'test contract');
        insert contract;
        
        List<Contract_Cost__c> costs = new List<Contract_Cost__c>();
        costs.add( new Contract_Cost__c(Contract__c = contract.Id) );
        
        // Create a PageReference to the VF page being tested       
        PageReference pageRef = Page.ServiceContract1;
        test.setCurrentPage(pageRef);
        
        // Now create the standard controller for the contact event
        ApexPages.StandardController stdCon = new ApexPages.StandardController(contract);
        
        // Test constructors
        ServiceContractWizard cnt = new ServiceContractWizard(stdCon);
        
        cnt.getContract();
        cnt.getCosts();
        cnt.setCosts(costs);
        cnt.getDefaultFCR();
        cnt.setDefaultFCR('0.00');
        
        cnt.back();
        cnt.next();
        cnt.cancel();
        cnt.cancelCosts();
        
        cnt.save();
    }
}