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
        // Determine which data to fetch based on the active tab
        var selectedTab = component.get("v.selectedTabId");
        
        if(selectedTab === "personTab") {
            this.fetchPersonHealthData(component);
        } else if(selectedTab === "locationTab") {
            this.fetchLocationHealthData(component);
        }
    },
    
    fetchPersonHealthData : function(component) {
        // Call Apex method to get person health status counts
        var action = component.get("c.getPersonHealthStatusCount");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var statusData = response.getReturnValue();
                this.updateHealthMetrics(component, statusData);
            } else {
                console.error("Error fetching person health data: " + state);
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
                var statusData = response.getReturnValue();
                this.updateHealthMetrics(component, statusData);
            } else {
                console.error("Error fetching location health data: " + state);
            }
        });
        
        $A.enqueueAction(action);
    },
    
    updateHealthMetrics : function(component, statusData) {
        // Update the health metrics based on the returned data
        component.set("v.greenCount", statusData["Green"] || 0);
        component.set("v.yellowCount", statusData["Yellow"] || 0);
        component.set("v.orangeCount", statusData["Orange"] || 0);
        component.set("v.redCount", statusData["Red"] || 0);
    }
})