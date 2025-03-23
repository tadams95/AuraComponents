trigger CaseStatusTrigger on Case (before update) {
    
    List<Case> breakdownCasesChangedToWorking = new List<Case>();
    
    for(Case newCase : Trigger.new) {
        // Get the old version of the record
        Case oldCase = Trigger.oldMap.get(newCase.Id);
        
        // Check if Status changed to 'Working' and Reason is 'Breakdown'
        if(newCase.Status == 'Working' && 
           oldCase.Status != 'Working' && 
           newCase.Reason == 'Breakdown') {
            
            // Add to our list for processing
            breakdownCasesChangedToWorking.add(newCase);
        }
    }
    
    // Update the Description for all qualifying cases
    if(!breakdownCasesChangedToWorking.isEmpty()) {
        for(Case c : breakdownCasesChangedToWorking) {
            c.Description = 'In-Progress';
        }
        
        // No need to do DML as this is a before trigger
        System.debug('Updated Description to In-Progress for ' + 
                    breakdownCasesChangedToWorking.size() + 
                    ' Breakdown cases changed to Working status');
    }
}
