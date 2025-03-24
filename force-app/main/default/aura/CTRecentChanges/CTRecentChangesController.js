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
    }
})