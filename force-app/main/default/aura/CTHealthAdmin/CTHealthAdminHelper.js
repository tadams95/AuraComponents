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
    },
    
    fetchHealthStatusCounts: function(component) {
        // Show spinner
        component.set('v.showSpinner', true);
        
        // Get the selected tab to determine which type of counts to fetch
        const selectedTab = component.get('v.selectedTabId');
        
        // Determine which controller method to call based on tab
        const methodName = selectedTab === 'personTab' ? 'c.getPersonHealthStatusCount' : 'c.getLocationHealthStatusCount';
        
        // Call the appropriate Apex method
        const action = component.get(methodName);
        
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === 'SUCCESS') {
                const counts = response.getReturnValue();
                
                // Set the counts in the component attributes
                component.set('v.greenCount', counts['Green'] || 0);
                component.set('v.yellowCount', counts['Yellow'] || 0);
                component.set('v.orangeCount', counts['Orange'] || 0);
                component.set('v.redCount', counts['Red'] || 0);
            } else if (state === 'ERROR') {
                const errors = response.getError();
                console.error('Error fetching health status counts:', errors);
                // Optionally show error toast
            }
            
            // Hide spinner
            component.set('v.showSpinner', false);
        });
        
        $A.enqueueAction(action);
    },
    
    savePersonRecord: function(component) {
        // Show spinner while saving
        component.set('v.showSpinner', true);
        
        // Get the person record from component
        const person = component.get('v.newPerson');
        
        // Simple validation - check that required fields are filled
        if (!person.Name || !person.Mobile__c || !person.Health_Status__c) {
            // Show error message for required fields
            this.showToast('Error', 'Please fill in all required fields', 'error');
            component.set('v.showSpinner', false);
            return;
        }
        
        // Call apex to save the record
        const action = component.get('c.addPerson');
        action.setParams({
            personRecord: person
        });
        
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === 'SUCCESS') {
                // Close the modal
                component.set('v.isPersonModalOpen', false);
                
                // Show success message
                this.showToast('Success', 'Person record created successfully', 'success');
                
                // Reset the form
                component.set('v.newPerson', {
                    'Name': '',
                    'Mobile__c': '',
                    'Health_Status__c': '',
                    'Email__c': ''
                });
                component.set('v.personStatus', '');
                
                // Refresh the health status counts
                this.fetchHealthStatusCounts(component);
                
                // Refresh recent changes if on person tab
                if (component.get('v.selectedTabId') === 'personTab') {
                    // Find and refresh the CTRecentChanges component
                    const recentChangesComponent = component.find('personRecentChanges');
                    if (recentChangesComponent) {
                        recentChangesComponent.refresh();
                    }
                }
            } else if (state === 'ERROR') {
                const errors = response.getError();
                console.error('Error saving person record:', errors);
                
                // Show error message
                let errorMsg = 'An error occurred while saving the record.';
                if (errors && errors[0] && errors[0].message) {
                    errorMsg = errors[0].message;
                }
                this.showToast('Error', errorMsg, 'error');
            }
            
            // Hide spinner
            component.set('v.showSpinner', false);
        });
        
        $A.enqueueAction(action);
    },
    
    saveLocationRecord: function(component) {
        // Show spinner while saving
        component.set('v.showSpinner', true);
        
        // Get the location record from component
        const location = component.get('v.newLocation');
        
        // Simple validation - check that required fields are filled
        if (!location.Name || !location.Address__c || !location.Status__c) {
            // Show error message for required fields
            this.showToast('Error', 'Please fill in all required fields', 'error');
            component.set('v.showSpinner', false);
            return;
        }
        
        // Call apex to save the record
        const action = component.get('c.addLocation');
        action.setParams({
            locationRecord: location
        });
        
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === 'SUCCESS') {
                // Close the modal
                component.set('v.isLocationModalOpen', false);
                
                // Show success message
                this.showToast('Success', 'Location record created successfully', 'success');
                
                // Reset the form
                component.set('v.newLocation', {
                    'Name': '',
                    'Address__c': '',
                    'Pincode__c': '',
                    'Status__c': ''
                });
                component.set('v.locationStatus', '');
                
                // Refresh the health status counts
                this.fetchHealthStatusCounts(component);
                
                // Refresh recent changes if on location tab
                if (component.get('v.selectedTabId') === 'locationTab') {
                    // Find and refresh the CTRecentChanges component
                    const recentChangesComponent = component.find('locationRecentChanges');
                    if (recentChangesComponent) {
                        recentChangesComponent.refresh();
                    }
                }
            } else if (state === 'ERROR') {
                const errors = response.getError();
                console.error('Error saving location record:', errors);
                
                // Show error message
                let errorMsg = 'An error occurred while saving the record.';
                if (errors && errors[0] && errors[0].message) {
                    errorMsg = errors[0].message;
                }
                this.showToast('Error', errorMsg, 'error');
            }
            
            // Hide spinner
            component.set('v.showSpinner', false);
        });
        
        $A.enqueueAction(action);
    },
    
    fetchPersonRecord: function(component, recordId) {
        // Call apex to get the person record
        const action = component.get('c.getPersonById');
        action.setParams({
            personId: recordId
        });
        
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === 'SUCCESS') {
                const personRecord = response.getReturnValue();
                
                // Set the person record in the component
                component.set('v.editPersonRecord', personRecord);
                
                // Open the edit modal
                component.set('v.isPersonEditModalOpen', true);
            } else if (state === 'ERROR') {
                const errors = response.getError();
                console.error('Error fetching person record:', errors);
                
                // Show error message
                let errorMsg = 'An error occurred while fetching the record.';
                if (errors && errors[0] && errors[0].message) {
                    errorMsg = errors[0].message;
                }
                this.showToast('Error', errorMsg, 'error');
            }
            
            // Hide spinner
            component.set('v.showSpinner', false);
        });
        
        $A.enqueueAction(action);
    },
    
    updatePersonRecord: function(component) {
        // Show spinner while saving
        component.set('v.showSpinner', true);
        
        // Get the person record from component
        const person = component.get('v.editPersonRecord');
        
        // Simple validation - check that required fields are filled
        if (!person.Name || !person.Mobile__c || !person.Health_Status__c) {
            // Show error message for required fields
            this.showToast('Error', 'Please fill in all required fields', 'error');
            component.set('v.showSpinner', false);
            return;
        }
        
        // Call apex to update the record
        const action = component.get('c.updatePerson');
        action.setParams({
            personRecord: person
        });
        
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === 'SUCCESS') {
                // Close the modal
                component.set('v.isPersonEditModalOpen', false);
                
                // Show success message
                this.showToast('Success', 'Person record updated successfully', 'success');
                
                // Reset the form
                component.set('v.editPersonRecord', {});
                component.set('v.editPersonStatus', '');
                
                // Refresh the health status counts
                this.fetchHealthStatusCounts(component);
                
                // Refresh recent changes if on person tab
                if (component.get('v.selectedTabId') === 'personTab') {
                    // Find and refresh the CTRecentChanges component
                    const recentChangesComponent = component.find('personRecentChanges');
                    if (recentChangesComponent) {
                        recentChangesComponent.refresh();
                    }
                }
            } else if (state === 'ERROR') {
                const errors = response.getError();
                console.error('Error updating person record:', errors);
                
                // Show error message
                let errorMsg = 'An error occurred while updating the record.';
                if (errors && errors[0] && errors[0].message) {
                    errorMsg = errors[0].message;
                }
                this.showToast('Error', errorMsg, 'error');
            }
            
            // Hide spinner
            component.set('v.showSpinner', false);
        });
        
        $A.enqueueAction(action);
    },
    
    fetchLocationRecord: function(component, recordId) {
        console.log('Fetching location record with ID: ' + recordId);
        
        // Call apex to get the location record
        const action = component.get('c.getLocationById');
        action.setParams({
            locationId: recordId
        });
        
        action.setCallback(this, function(response) {
            const state = response.getState();
            console.log('Location fetch response state: ' + state);
            
            if (state === 'SUCCESS') {
                const locationRecord = response.getReturnValue();
                console.log('Location record retrieved: ', JSON.stringify(locationRecord));
                
                // Set the location record in the component
                component.set('v.editLocationRecord', locationRecord);
                
                // Set the status in the edit field
                component.set('v.editLocationStatus', locationRecord.Status__c);
                
                // Open the edit modal
                component.set('v.isLocationEditModalOpen', true);
                
                console.log('Location edit modal should be open now');
            } else if (state === 'ERROR') {
                const errors = response.getError();
                console.error('Error fetching location record:', errors);
                
                // Show error message
                let errorMsg = 'An error occurred while fetching the record.';
                if (errors && errors[0] && errors[0].message) {
                    errorMsg = errors[0].message;
                }
                this.showToast('Error', errorMsg, 'error');
            }
            
            // Hide spinner
            component.set('v.showSpinner', false);
        });
        
        console.log('Sending request to server to fetch location record');
        $A.enqueueAction(action);
    },
    
    updateLocationRecord: function(component) {
        // Show spinner while saving
        component.set('v.showSpinner', true);
        
        // Get the location record from component
        const location = component.get('v.editLocationRecord');
        
        // Simple validation - check that required fields are filled
        if (!location.Name || !location.Address__c || !location.Status__c) {
            // Show error message for required fields
            this.showToast('Error', 'Please fill in all required fields', 'error');
            component.set('v.showSpinner', false);
            return;
        }
        
        // Call apex to update the record
        const action = component.get('c.updateLocation');
        action.setParams({
            locationRecord: location
        });
        
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === 'SUCCESS') {
                // Close the modal
                component.set('v.isLocationEditModalOpen', false);
                
                // Show success message
                this.showToast('Success', 'Location record updated successfully', 'success');
                
                // Reset the form
                component.set('v.editLocationRecord', {});
                component.set('v.editLocationStatus', '');
                
                // Refresh the health status counts
                this.fetchHealthStatusCounts(component);
                
                // Refresh recent changes if on location tab
                if (component.get('v.selectedTabId') === 'locationTab') {
                    // Find and refresh the CTRecentChanges component
                    const recentChangesComponent = component.find('locationRecentChanges');
                    if (recentChangesComponent) {
                        recentChangesComponent.refresh();
                    }
                }
            } else if (state === 'ERROR') {
                const errors = response.getError();
                console.error('Error updating location record:', errors);
                
                // Show error message
                let errorMsg = 'An error occurred while updating the record.';
                if (errors && errors[0] && errors[0].message) {
                    errorMsg = errors[0].message;
                }
                this.showToast('Error', errorMsg, 'error');
            }
            
            // Hide spinner
            component.set('v.showSpinner', false);
        });
        
        $A.enqueueAction(action);
    }
})