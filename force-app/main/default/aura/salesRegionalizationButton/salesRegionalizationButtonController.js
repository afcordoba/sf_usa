({
    handleClick : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
        "url": "/lightning/cmp/c__salesRegionalizationComponent?c__id="+component.get("v.recordId")
        });
        urlEvent.fire();
    }
})