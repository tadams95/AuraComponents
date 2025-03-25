({
    doInit : function(component, event, helper) {
        // Set up the columns for the datatable
        helper.setupDataTable(component);
        // Fetch data from the server
        helper.fetchRecentChanges(component, '');
    },
    
    handleSearchChange : function(component, event, helper) {
        const searchTerm = component.get('v.searchTerm');
        helper.fetchRecentChanges(component, searchTerm);
    },
    
    refreshData : function(component, event, helper) {
        // Reset search term
        component.set('v.searchTerm', '');
        // Fetch fresh data
        helper.fetchRecentChanges(component, '');
    },
    
    // Public method to allow parent components to refresh this component
    refresh: function(component, event, helper) {
        component.set('v.searchTerm', '');
        helper.fetchRecentChanges(component, '');
    },
    
    // Handle row actions from the datatable
    handleRowAction: function(component, event, helper) {
        const action = event.getParam('action');
        const row = event.getParam('row');
        
        console.log('Row action triggered: ', action.name);
        console.log('Row data: ', JSON.stringify(row));
        
        switch (action.name) {
            case 'view_update':
                // Handle the view/update action
                const recordType = component.get('v.recordType');
                console.log('Record type: ', recordType);
                
                if (recordType === 'person') {
                    // Fix for the event - make sure the event is being obtained correctly
                    try {
                        // Fire the CTPersonSelectEvent with person record details
                        const personSelectEvent = $A.get("e.c:CTPersonSelectEvent");
                        if (personSelectEvent) {
                            personSelectEvent.setParams({
                                "recordId": row.id,
                                "healthStatus": row.Status
                            });
                            personSelectEvent.fire();
                            console.log('Event fired for record ID: ' + row.id);
                        } else {
                            console.error('Could not get event e.c:CTPersonSelectEvent');
                        }
                    } catch (error) {
                        console.error('Error firing event: ', error);
                    }
                } else if (recordType === 'location') {
                    // Fire an event for location record view/update
                    try {
                        console.log('Attempting to fire location select event');
                        // Fire the CTLocationSelectEvent with location record details
                        const locationSelectEvent = $A.get("e.c:CTLocationSelectEvent");
                        if (locationSelectEvent) {
                            locationSelectEvent.setParams({
                                "recordId": row.id,
                                "status": row.Status
                            });
                            locationSelectEvent.fire();
                            console.log('Location event fired for record ID: ' + row.id + ' with status: ' + row.Status);
                        } else {
                            console.error('Could not get event e.c:CTLocationSelectEvent');
                        }
                    } catch (error) {
                        console.error('Error firing location event: ', error);
                    }
                }
                break;
        }
    }
})