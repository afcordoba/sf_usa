({
    getData : function(component, event, helper) {
        let action = component.get("c.getFiles");
        console.log(component.get("v.recordId"));
        action.setParams({
            AccountId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                component.set("v.fileList", response.getReturnValue());
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
})