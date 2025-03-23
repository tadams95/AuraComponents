({
    myAction : function(component, event, helper) {

    },
    handleAddNew : function(component, event, helper) {
        // Add functionality to handle the button click
        console.log('Add New button clicked');
        // You can add more functionality here, such as opening a modal or navigating to a record creation page
    },
    handleTabChange : function(component, event, helper) {
        // Get tab ID from the event
        var selectedTabId = event.getParam("id");
        // Update the attribute
        component.set("v.selectedTabId", selectedTabId);
        console.log('Tab changed to: ' + selectedTabId);
    }
})