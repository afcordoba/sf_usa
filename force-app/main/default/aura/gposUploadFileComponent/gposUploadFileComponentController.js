({
    handleUploadFinished: function (component, event, helper) {
        component.set("v.uploadedId", event.getParam("files")[0].contentVersionId);
        helper.generateTemps(component, event, helper);
    },
})