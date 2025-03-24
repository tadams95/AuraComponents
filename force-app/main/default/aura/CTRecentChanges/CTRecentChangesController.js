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
    }
})