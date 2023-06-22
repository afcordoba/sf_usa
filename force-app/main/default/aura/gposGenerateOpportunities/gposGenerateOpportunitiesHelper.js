({
    getData : function(component, event, helper) {
        let action = component.get("c.getSummaryText");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                let result = response.getReturnValue();
                component.set("v.summaryText", result.message);
                component.set("v.hasRecords", result.hasRecords);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            component.set("v.isLoading",false);
        });
        $A.enqueueAction(action);
    },

    generateOpps : function(component, event, helper) {
        let action = component.get("c.generateOpps");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                let result = response.getReturnValue();
                helper.showSuccessMessage(component, event, helper);
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
            component.set("v.checkFlag", false);
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
    showSuccessMessage : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "mode": "sticky",
            "title": "Success!",
            "type": "success",
            "message": "Opportunities succesfully created"
        });
        toastEvent.fire();
    }
})