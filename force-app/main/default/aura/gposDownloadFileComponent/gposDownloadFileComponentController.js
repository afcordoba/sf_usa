({
    doInit: function(component, event, helper) {
        helper.getData(component, event, helper);
    },
    handleRefresh: function(component, event, helper) {
        component.set("v.isLoading",true);
        helper.getData(component,event,helper);
    }
})