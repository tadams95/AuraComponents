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
    },
    
    // Handle the CTPersonSelectEvent
    handlePersonSelect: function(component, event, helper) {
        // Get the record id and health status from the event
        const recordId = event.getParam('recordId');
        const healthStatus = event.getParam('healthStatus');
        
        // Save the record id for later use
        component.set('v.editPersonId', recordId);
        
        // Set initial health status value
        component.set('v.editPersonStatus', healthStatus);
        
        // Show spinner while loading the record
        component.set('v.showSpinner', true);
        
        // Call helper to fetch the person record
        helper.fetchPersonRecord(component, recordId);
    },
    
    closePersonEditModal: function(component, event, helper) {
        component.set('v.isPersonEditModalOpen', false);
        // Reset edit person status
        component.set('v.editPersonStatus', '');
    },
    
    handleEditPersonStatusChange: function(component, event, helper) {
        const status = component.get('v.editPersonStatus');
        const person = component.get('v.editPersonRecord');
        person.Health_Status__c = status;
        component.set('v.editPersonRecord', person);
    },
    
    updatePersonRecord: function(component, event, helper) {
        helper.updatePersonRecord(component);
    },
    
    // Handle the CTLocationSelectEvent
    handleLocationSelect: function(component, event, helper) {
        console.log('Location select event received');
        // Get the record id and status from the event
        const recordId = event.getParam('recordId');
        const status = event.getParam('status');
        
        console.log('Location record ID: ' + recordId);
        console.log('Location status: ' + status);
        
        // Save the record id for later use
        component.set('v.editLocationId', recordId);
        
        // Set initial status value
        component.set('v.editLocationStatus', status);
        
        // Show spinner while loading the record
        component.set('v.showSpinner', true);
        
        // Call helper to fetch the location record
        helper.fetchLocationRecord(component, recordId);
    },
    
    closeLocationEditModal: function(component, event, helper) {
        component.set('v.isLocationEditModalOpen', false);
        // Reset edit location status
        component.set('v.editLocationStatus', '');
    },
    
    handleEditLocationStatusChange: function(component, event, helper) {
        const status = component.get('v.editLocationStatus');
        const location = component.get('v.editLocationRecord');
        location.Status__c = status;
        component.set('v.editLocationRecord', location);
    },
    
    updateLocationRecord: function(component, event, helper) {
        helper.updateLocationRecord(component);
    }
})