({
    getTracks: function(component, event, helper) {
        let action = component.get("c.getRelatedSeedTracks");
        action.setParams({
            inventoryStatusId: component.get("v.recordId")
        })
        action.setCallback(this, function(response){
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.tracksList", response.getReturnValue());         

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

        });
        $A.enqueueAction(action);
    },
})