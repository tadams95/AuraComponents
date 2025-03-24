({
    helperMethod : function() {

    },
    
    setupDataTable: function(component) {
        // Get record type
        const recordType = component.get('v.recordType');
        
        // Define columns based on record type
        let columns = [];
        
        if (recordType === 'person') {
            columns = [
                {label: 'Name', fieldName: 'Name', type: 'text'},
                {label: 'Phone', fieldName: 'Mobile', type: 'phone'},
                {label: 'Token', fieldName: 'Token', type: 'text'},
                {label: 'Health Status', fieldName: 'Status', type: 'text'},
                {
                    label: 'Status Update Date', 
                    fieldName: 'StatusUpdateDate', 
                    type: 'date',
                    typeAttributes: {
                        year: 'numeric',
                        month: 'short',
                        day: '2-digit',
                        hour: '2-digit',
                        minute: '2-digit'
                    }
                }
            ];
        } else if (recordType === 'location') {
            columns = [
                {label: 'Name', fieldName: 'Name', type: 'text'},
                {label: 'Status', fieldName: 'Status', type: 'text'},
                {label: 'Pincode', fieldName: 'Pincode', type: 'text'},
                {label: 'Address', fieldName: 'Address', type: 'text'},
                {
                    label: 'Red Score', 
                    fieldName: 'RedScore', 
                    type: 'number',
                    typeAttributes: {
                        minimumFractionDigits: 0,
                        maximumFractionDigits: 2
                    }
                },
                {
                    label: 'Status Update Date', 
                    fieldName: 'StatusUpdateDate', 
                    type: 'date',
                    typeAttributes: {
                        year: 'numeric',
                        month: 'short',
                        day: '2-digit',
                        hour: '2-digit',
                        minute: '2-digit'
                    }
                }
            ];
        }
        
        // Set the columns
        component.set('v.columns', columns);
    },
    
    fetchRecentChanges: function(component, searchTerm) {
        // Show loading spinner
        component.set('v.isLoading', true);
        
        const recordType = component.get('v.recordType');
        
        // Call the Apex controller method
        const action = component.get('c.getRecentChanges');
        action.setParams({
            recordType: recordType,
            searchTerm: searchTerm
        });
        
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === 'SUCCESS') {
                const data = response.getReturnValue();
                component.set('v.data', data);
                
                // Set empty message based on record type
                if (data.length === 0) {
                    const emptyMsg = 'No recent ' + (recordType === 'person' ? 'person' : 'location') + ' changes found';
                    component.set('v.emptyMessage', emptyMsg);
                }
            } else if (state === 'ERROR') {
                const errors = response.getError();
                console.error('Error fetching recent changes:', errors);
                
                // Set error message
                component.set('v.emptyMessage', 'Error fetching data. Please try again later.');
            }
            
            // Hide loading spinner
            component.set('v.isLoading', false);
        });
        
        $A.enqueueAction(action);
    }
})