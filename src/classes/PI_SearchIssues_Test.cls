@isTest
private class PI_SearchIssues_Test
{
	 /* Run a search for Participants */
    static TestMethod void testSearchParticipants()
    {
               
        PI_IssueSearchController e = new PI_IssueSearchController();
                      
        e.clicked();
        
        String sDebug = e.debugSoql;
               
        List<SelectOption> lis = e.getStatusOptions(); 
        List<String> lisSelection = new List<String>();    
        lisSelection.add(lis[0].getValue());
        e.status_selection = lisSelection;
      
		lis = e.getPriorityOptions(); 
        lisSelection = new List<String>();    
        lisSelection.add(lis[0].getValue());
        e.priority_selection = lisSelection;

		lis = e.getCategoryOptions(); 
        lisSelection = new List<String>();    
        lisSelection.add(lis[0].getValue());
        e.category_selection = lisSelection;

        lis = e.getStatusOptions(); 
        lisSelection = new List<String>();    
        lisSelection.add(lis[0].getValue());
        e.status_selection = lisSelection;

		lis = e.getProjectOptions(); 
        lis = e.getOwnerOptions(); 

        e.project = 'a0P18000000BeNW';
        e.owner = 'a0P18000000BeNW';
       
        e.runSearch();
        
        e.toggleSort();
              
    }
}