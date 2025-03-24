({
    doInit: function(component, event, helper) {
        // Initialize default values for person and location
        component.set('v.newPerson', {
            'Name': '',
            'Mobile__c': '',
            'Health_Status__c': '',
            'Email__c': ''
        });
        
        component.set('v.newLocation', {
            'Name': '',
            'Address__c': '',
            'Pincode__c': '',
            'Status__c': ''
        });
        
        // Fetch health status counts
        helper.fetchHealthStatusCounts(component);
    },
    
    handleTabChange: function(component, event, helper) {
        // Get the selected tab
        const selectedTab = event.getParam('id');
        component.set('v.selectedTabId', selectedTab);
        
        // Update health status counts based on selected tab
        helper.fetchHealthStatusCounts(component);
    },
    
    handleAddNew: function(component, event, helper) {
        // Open appropriate modal based on selected tab
        const selectedTab = component.get('v.selectedTabId');
        
        if (selectedTab === 'personTab') {
            component.set('v.isPersonModalOpen', true);
        } else if (selectedTab === 'locationTab') {
            component.set('v.isLocationModalOpen', true);
        }
    },
    
    closePersonModal: function(component, event, helper) {
        component.set('v.isPersonModalOpen', false);
        // Reset person status
        component.set('v.personStatus', '');
    },
    
    closeLocationModal: function(component, event, helper) {
        component.set('v.isLocationModalOpen', false);
        // Reset location status
        component.set('v.locationStatus', '');
    },
    
    handlePersonStatusChange: function(component, event, helper) {
        const status = component.get('v.personStatus');
        const person = component.get('v.newPerson');
        person.Health_Status__c = status;
        component.set('v.newPerson', person);
    },
    
    handleStatusChange: function(component, event, helper) {
        const status = component.get('v.locationStatus');
        const location = component.get('v.newLocation');
        location.Status__c = status;
        component.set('v.newLocation', location);
    },
    
    savePersonRecord: function(component, event, helper) {
        helper.savePersonRecord(component);
    },
    
    saveLocationRecord: function(component, event, helper) {
        helper.saveLocationRecord(component);
    }
})