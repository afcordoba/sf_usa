({
    doInit: function(component, event, helper) {
        console.log(component.get("v.recordId"));
        helper.getData(component, event, helper);
    },
    handleNext: function(component, event, helper) {
        component.set("v.checkFlag", true);
    },
    handleBack: function(component, event, helper) {
        component.set("v.checkFlag", false);
    },
    generate: function (component, event, helper) {
        helper.generateOpps(component, event, helper);
    },
})