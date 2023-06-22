({
    onPageReferenceChange: function(cmp, evt, helper) {
        var myPageRef = null;
        var id = null;
        if(cmp.get("v.pageReference") != null) {
            myPageRef = cmp.get("v.pageReference");
            id = myPageRef.state.c__id;
            cmp.set("v.id", id);
        }
        

        helper.getLocations(cmp, evt, helper);

        console.log("recordId: " + cmp.get("v.recordId"));

        (cmp.get("v.recordId") !== undefined) ? helper.getVolumeData(cmp, evt, helper) : helper.getData(cmp, evt, helper)
    },
    onSave: function(cmp, evt, helper) {
        helper.saveData(cmp, evt, helper);
    },
    handleInputChange: function(cmp,event,helper) {
        var data = cmp.get("v.slWrapperList");
        var isSaveEnabled = true;

        data.forEach(varietyItem => {
            varietyItem.tPercentage = 0;
            varietyItem.sLocalizationList.forEach(locItem => {
                varietyItem.tPercentage = parseInt(varietyItem.tPercentage) + parseInt(locItem.Percentage__c);
            })
            if(varietyItem.tPercentage != 100) {
                isSaveEnabled = false;
            }
        });

        console.log(data);

        cmp.set("v.isSaveEnabled",isSaveEnabled);
        cmp.set("v.slWrapperList",data);
    }
})