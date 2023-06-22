({
    getLocations : function(component, event, helper) {
        let action = component.get("c.getLocations");
        action.setCallback(this, function(response){
            let state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                component.set("v.locationList",response.getReturnValue());
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
    getData : function(component, event, helper) {
        let action = component.get("c.getSalesVolumeDetailData");
        action.setParams({
            oppId: component.get("v.id"),
        })
        action.setCallback(this, function(response){
            let state = response.getState();
            if (state === "SUCCESS") {
                console.log(response);
                console.log(response.getReturnValue());
                component.set("v.slWrapperList", response.getReturnValue());
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
    },getVolumeData : function(component, event, helper) {
        let action = component.get("c.getRecordSalesVolumeDetailData");
        action.setParams({
            sveId: component.get("v.recordId"),
        })
        action.setCallback(this, function(response){
            let state = response.getState();
            if (state === "SUCCESS") {
                console.log(response);
                console.log(response.getReturnValue());
                component.set("v.slWrapperList", response.getReturnValue());
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
    saveData : function(component, event, helper) {
        let action = component.get("c.saveSalesRegionalizationData");
        var data = component.get("v.slWrapperList");
        action.setParams({
            salesLocalizationList: data,
        })
        action.setCallback(this, function(response){
            let state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": component.get("v.id")
                });
                navEvt.fire();
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