({
    doInit : function(component, event, helper) {
        // Initialize component and load initial data
        helper.fetchHealthStatusData(component);
    },
    
    handleTabChange : function(component, event, helper) {
        // Get the selected tab
        var selectedTab = event.getParam("id");
        component.set("v.selectedTabId", selectedTab);
        
        // Refresh health status counts based on selected tab
        helper.fetchHealthStatusData(component);
    },
    
    handleAddNew : function(component, event, helper) {
        // Check which tab is active and open the appropriate modal
        var selectedTab = component.get("v.selectedTabId");
        
        if(selectedTab === "personTab") {
            // Initialize the newPerson object
            component.set("v.newPerson", {});
            component.set("v.personStatus", "");
            component.set("v.isPersonModalOpen", true);
        } else if(selectedTab === "locationTab") {
            // Initialize the newLocation object
            component.set("v.newLocation", {});
            component.set("v.locationStatus", "");
            component.set("v.isLocationModalOpen", true);
        }
    },
    
    closePersonModal : function(component, event, helper) {
        component.set("v.isPersonModalOpen", false);
    },
    
    closeLocationModal : function(component, event, helper) {
        component.set("v.isLocationModalOpen", false);
    },
    
    handlePersonStatusChange : function(component, event, helper) {
        // Update the Health_Status__c field when radio selection changes
        var status = event.getParam("value");  // Get the value from the event
        component.set("v.personStatus", status);
        
        var newPerson = component.get("v.newPerson");
        if(newPerson) {
            newPerson.Health_Status__c = status;
            component.set("v.newPerson", newPerson);
        }
    },
    
    savePersonRecord : function(component, event, helper) {
        // Get the current person record and status
        var newPerson = component.get("v.newPerson");
        var status = component.get("v.personStatus");
        
        // Ensure the status is set on the record
        if (status) {
            newPerson.Health_Status__c = status;
            component.set("v.newPerson", newPerson);
        }
        
        // Validate required fields
        if (!newPerson.Name || !newPerson.Mobile__c || !newPerson.Health_Status__c) {
            // Show error toast
            helper.showToast('Error', 'Please fill all required fields', 'error');
            return;
        }
        
        // For debugging
        console.log('Saving person with status: ' + newPerson.Health_Status__c);
        
        // Call helper method to save the record
        helper.savePersonToServer(component);
    },
    
    saveLocationRecord : function(component, event, helper) {
        // Get the current location record and status
        var newLocation = component.get("v.newLocation");
        var status = component.get("v.locationStatus");
        
        // Ensure the status is set on the record
        if (status) {
            newLocation.Status__c = status;
            component.set("v.newLocation", newLocation);
        }
        
        // Validate required fields
        if (!newLocation.Name || !newLocation.Address__c || !newLocation.Status__c) {
            // Show error toast
            helper.showToast('Error', 'Please fill all required fields', 'error');
            return;
        }
        
        // For debugging
        console.log('Saving location with status: ' + newLocation.Status__c);
        
        // Call helper method to save the record
        helper.saveLocationToServer(component);
    },
    
    handleStatusChange : function(component, event, helper) {
        // Update the Status__c field when radio selection changes
        var status = event.getParam("value");  // Get the value from the event
        component.set("v.locationStatus", status);
        
        var newLocation = component.get("v.newLocation");
        if(newLocation) {
            newLocation.Status__c = status;
            component.set("v.newLocation", newLocation);
        }
    }
})