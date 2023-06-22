({
    generateTemps : function(component, event, helper) {
        let action = component.get("c.generateTemps");
        action.setParams({
            contentId: component.get("v.uploadedId"),
            accountId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.showFileCompletion(component, event, helper);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                    helper.showFileError(component,event,helper, errors[0].message);
                } else {
                    console.log("Unknown error");
                }
            }
            component.set("v.isLoading",false);
        });
        $A.enqueueAction(action);
    },
    showFileError : function(component, event, helper, error) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "mode": "sticky",
            "title": "Error!",
            "type": "error",
            "message": error
        });
        toastEvent.fire();
    },
    showFileCompletion : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "mode": "sticky",
            "title": "Success!",
            "type": "success",
            "message": "File succesfully processed"
        });
        toastEvent.fire();
    }
})