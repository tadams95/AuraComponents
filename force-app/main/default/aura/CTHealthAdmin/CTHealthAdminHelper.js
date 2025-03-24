({
    helperMethod : function() {

    },
    showToast : function(title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        if (toastEvent) {
            toastEvent.setParams({
                title: title,
                message: message,
                type: type
            });
            toastEvent.fire();
        } else {
            // Fallback for cases where force:showToast is not available
            alert(title + ': ' + message);
        }
    },
    fetchHealthStatusData : function(component) {
        // Determine which data to fetch based on the selected tab
        var selectedTab = component.get("v.selectedTabId");
        
        if (selectedTab === "personTab") {
            this.fetchPersonHealthData(component);
        } else if (selectedTab === "locationTab") {
            this.fetchLocationHealthData(component);
        }
    },
    
    savePersonToServer : function(component) {
        // Show a spinner or loading state
        this.toggleSpinner(component, true);
        
        // Get the person record
        var newPerson = component.get("v.newPerson");
        
        // Create action
        var action = component.get("c.createPerson");
        
        // Set parameters
        action.setParams({
            "personRecord": newPerson
        });
        
        // Set callback
        action.setCallback(this, function(response) {
            // Hide spinner
            this.toggleSpinner(component, false);
            
            var state = response.getState();
            if (state === "SUCCESS") {
                // Show success message
                this.showToast('Success', 'Person record created successfully', 'success');
                
                // Close the modal
                component.set("v.isPersonModalOpen", false);
                
                // Refresh the counts - use a small timeout to ensure server data is updated
                window.setTimeout(
                    $A.getCallback(() => {
                        this.fetchHealthStatusData(component);
                    }), 500
                );
            } else {
                // Show error message
                var errors = response.getError();
                var errorMessage = 'Unknown error';
                
                if (errors && errors[0] && errors[0].message) {
                    errorMessage = errors[0].message;
                }
                
                this.showToast('Error', 'Failed to create person record: ' + errorMessage, 'error');
                console.error('Error details:', errors);
            }
        });
        
        // Send action to server
        $A.enqueueAction(action);
    },
    
    saveLocationToServer : function(component) {
        // Show a spinner or loading state
        this.toggleSpinner(component, true);
        
        // Get the location record
        var newLocation = component.get("v.newLocation");
        
        // Create action
        var action = component.get("c.createLocation");
        
        // Set parameters
        action.setParams({
            "locationRecord": newLocation
        });
        
        // Set callback
        action.setCallback(this, function(response) {
            // Hide spinner
            this.toggleSpinner(component, false);
            
            var state = response.getState();
            if (state === "SUCCESS") {
                // Show success message
                this.showToast('Success', 'Location record created successfully', 'success');
                
                // Close the modal
                component.set("v.isLocationModalOpen", false);
                
                // Refresh the counts - use a small timeout to ensure server data is updated
                window.setTimeout(
                    $A.getCallback(() => {
                        this.fetchHealthStatusData(component);
                    }), 500
                );
            } else {
                // Show error message
                var errors = response.getError();
                var errorMessage = 'Unknown error';
                
                if (errors && errors[0] && errors[0].message) {
                    errorMessage = errors[0].message;
                }
                
                this.showToast('Error', 'Failed to create location record: ' + errorMessage, 'error');
                console.error('Error details:', errors);
            }
        });
        
        // Send action to server
        $A.enqueueAction(action);
    },
    
    fetchPersonHealthData : function(component) {
        // Call Apex method to get person health status counts
        var action = component.get("c.getHealthStatusCount");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.greenCount", result.Green || 0);
                component.set("v.yellowCount", result.Yellow || 0);
                component.set("v.orangeCount", result.Orange || 0);
                component.set("v.redCount", result.Red || 0);
            } else {
                console.error("Error fetching health status counts: " + response.getError());
            }
        });
        
        $A.enqueueAction(action);
    },
    
    fetchLocationHealthData : function(component) {
        // Call Apex method to get location health status counts
        var action = component.get("c.getLocationHealthStatusCount");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.greenCount", result.Green || 0);
                component.set("v.yellowCount", result.Yellow || 0);
                component.set("v.orangeCount", result.Orange || 0);
                component.set("v.redCount", result.Red || 0);
            } else {
                console.error("Error fetching location health status counts: " + response.getError());
            }
        });
        
        $A.enqueueAction(action);
    },
    
    toggleSpinner : function(component, show) {
        // This method would toggle a spinner component if you have one
        // For now, we'll use console to show loading state
        if (show) {
            console.log('Loading...');
        }
    },
    
    updateHealthMetrics : function(component, statusData) {
        // Update the health metrics based on the returned data
        component.set("v.greenCount", statusData["Green"] || 0);
        component.set("v.yellowCount", statusData["Yellow"] || 0);
        component.set("v.orangeCount", statusData["Orange"] || 0);
        component.set("v.redCount", statusData["Red"] || 0);
    }
})