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
    
    savePersonRecord : function(component, event, helper) {
        // Implement save logic for person
        component.set("v.isPersonModalOpen", false);
        // After save, refresh data
        helper.fetchHealthStatusData(component);
    },
    
    saveLocationRecord : function(component, event, helper) {
        // Set the Status__c field from locationStatus attribute
        var newLocation = component.get("v.newLocation");
        newLocation.Status__c = component.get("v.locationStatus");
        component.set("v.newLocation", newLocation);
        
        // Implement save logic for location
        component.set("v.isLocationModalOpen", false);
        // After save, refresh data
        helper.fetchHealthStatusData(component);
    },
    
    handleStatusChange : function(component, event, helper) {
        // Update the Status__c field when radio selection changes
        var status = component.get("v.locationStatus");
        var newLocation = component.get("v.newLocation");
        if(newLocation) {
            newLocation.Status__c = status;
            component.set("v.newLocation", newLocation);
        }
    }
})