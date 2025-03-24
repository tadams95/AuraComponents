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
    }
})