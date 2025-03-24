({
    // Default renderer implementation
    render: function(component, helper) {
        return this.superRender();
    },
    
    // After render function 
    afterRender: function(component, helper) {
        this.superAfterRender();
        console.log("Component rendered");
    }
})