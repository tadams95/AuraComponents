({
    doInit : function(component, event, helper) {
        // Properly initialize the newLocation object
        component.set("v.newLocation", {
            sobjectType: 'Location__c',
            Name: '',
            Status__c: '',
            Address__c: '',
            Pincode__c: ''
        });
        console.log("Initialized newLocation:", JSON.stringify(component.get("v.newLocation")));
    },
    
    myAction : function(component, event, helper) {

    },
    handleAddNew : function(component, event, helper) {
        var selectedTab = component.get("v.selectedTabId");
        
        if (selectedTab === "personTab") {
            // Open modal for Person creation
            component.set("v.isPersonModalOpen", true);
        } else if (selectedTab === "locationTab") {
            // Open modal for Location creation
            component.set("v.isLocationModalOpen", true);
        }
    },
    handleTabChange : function(component, event, helper) {
        // Get tab ID from the event
        var selectedTabId = event.getParam("id");
        // Update the attribute
        component.set("v.selectedTabId", selectedTabId);
        console.log('Tab changed to: ' + selectedTabId);
    },
    
    // Simplified status change handler
    handleStatusChange : function(component, event, helper) {
        // Get the selected value directly from the radio group
        var selectedStatus = component.get("v.locationStatus");
        console.log("Status selected: " + selectedStatus);
        
        // Get the newLocation object and ensure it's an object
        var newLocation = component.get("v.newLocation");
        if (typeof newLocation === 'string') {
            // If it's a string, parse it or create a new object
            try {
                newLocation = JSON.parse(newLocation);
            } catch(e) {
                newLocation = {
                    sobjectType: 'Location__c',
                    Name: '',
                    Status__c: '',
                    Address__c: '',
                    Pincode__c: ''
                };
            }
        }
        
        // Set the Status__c property and update the component
        newLocation.Status__c = selectedStatus;
        component.set("v.newLocation", newLocation);
        
        // Log for debugging
        console.log("Updated newLocation:", JSON.stringify(component.get("v.newLocation")));
    },
    
    // Person Modal Methods
    closePersonModal : function(component, event, helper) {
        component.set("v.isPersonModalOpen", false);
    },
    savePersonRecord : function(component, event, helper) {
        // Here you would implement the logic to save the Person__c record
        console.log('Saving person record...');
        
        // For demonstration purposes, we'll just close the modal
        // In a real implementation, you would call a server-side action to create the record
        helper.showToast('Success', 'Person record created successfully', 'success');
        component.set("v.isPersonModalOpen", false);
    },
    // Location Modal Methods
    closeLocationModal : function(component, event, helper) {
        // Reset both the form and the temporary status
        component.set("v.locationStatus", "");
        component.set("v.newLocation", {
            sobjectType: 'Location__c',
            Name: '',
            Status__c: '',
            Address__c: '',
            Pincode__c: ''
        });
        component.set("v.isLocationModalOpen", false);
    },
    
    saveLocationRecord : function(component, event, helper) {
        try {
            // Get the Location record details
            var newLocation = component.get("v.newLocation");
            
            // Ensure newLocation is an object
            if (typeof newLocation === 'string') {
                try {
                    newLocation = JSON.parse(newLocation);
                } catch(e) {
                    helper.showToast('Error', 'Invalid location data format', 'error');
                    return;
                }
            }
            
            // Sync with the radio group value
            var selectedStatus = component.get("v.locationStatus");
            if (selectedStatus) {
                newLocation.Status__c = selectedStatus;
                component.set("v.newLocation", newLocation);
            }
            
            // Debug logging
            console.log('Attempting to save location: ', JSON.stringify(newLocation));
            
            // Validate required fields
            if (!newLocation.Name) {
                helper.showToast('Error', 'Please enter a location name', 'error');
                return;
            }
            
            if (!newLocation.Address__c) {
                helper.showToast('Error', 'Please enter an address', 'error');
                return;
            }
            
            if (!newLocation.Status__c) {
                helper.showToast('Error', 'Please select a status', 'error');
                return;
            }
            
            // Call the Apex controller method to create the Location record
            var action = component.get("c.createLocation");
            action.setParams({
                "locationObj": newLocation
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log("Apex response state: " + state);
                
                if (state === "SUCCESS") {
                    var locationId = response.getReturnValue();
                    console.log("Created location with ID: " + locationId);
                    helper.showToast('Success', 'Location record created successfully', 'success');
                    component.set("v.isLocationModalOpen", false);
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    var errorMessage = "Unknown error";
                    
                    if (errors && errors.length > 0) {
                        if (errors[0].message) {
                            errorMessage = errors[0].message;
                        } else if (errors[0].pageErrors && errors[0].pageErrors.length > 0) {
                            errorMessage = errors[0].pageErrors[0].message;
                        }
                    }
                    
                    console.error("Error saving location: ", errorMessage, errors);
                    helper.showToast('Error', 'Failed to create location: ' + errorMessage, 'error');
                }
            });
            
            $A.enqueueAction(action);
            
        } catch (e) {
            console.error("Exception in saveLocationRecord: ", e);
            helper.showToast('Error', 'An unexpected error occurred: ' + e.message, 'error');
        }
    }
})