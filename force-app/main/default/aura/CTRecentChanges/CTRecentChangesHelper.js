({
    helperMethod : function() {

    },
    
    setupDataTable : function(component) {
        // Define the columns for the datatable
        const columns = [
            {label: 'Name', fieldName: 'Name', type: 'text'},
            {label: 'Mobile', fieldName: 'Mobile', type: 'text'},
            {label: 'Token', fieldName: 'Token', type: 'text'},
            {label: 'Status', fieldName: 'Status', type: 'text'},
            {label: 'Status Update Date', fieldName: 'StatusUpdateDate', type: 'date', 
             typeAttributes: {
                 year: 'numeric',
                 month: 'short',
                 day: 'numeric',
                 hour: '2-digit',
                 minute: '2-digit'
             }
            }
        ];
        component.set('v.columns', columns);
    },
    
    fetchRecentChanges : function(component, searchTerm) {
        // Create action to fetch data
        const action = component.get('c.getRecentPersonHealthChanges');
        
        // Set parameters if needed
        if (searchTerm) {
            action.setParams({
                searchTerm: searchTerm
            });
        }
        
        // Set callback
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === 'SUCCESS') {
                const records = response.getReturnValue();
                component.set('v.data', records);
            } else {
                console.error('Error fetching data:', response.getError());
            }
        });
        
        // Enqueue the action
        $A.enqueueAction(action);
    }
})