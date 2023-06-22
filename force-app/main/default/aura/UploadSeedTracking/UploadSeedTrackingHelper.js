({
    createCSVObject : function(cmp, csv) {
        var action = cmp.get('c.getCSVObject');
        action.setParams({
            csv_str : csv
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
	    if(state == "SUCCESS") {
		cmp.set("v.csvObject", response.getReturnValue());
	    }
        });
        $A.enqueueAction(action);
    },
    
    createSeedTracking : function(cmp, csvObj) {
        var action = cmp.get('c.crearSeedTracking');
        action.setParams({            
            'jsonString': JSON.stringify(csvObj) 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
        if(state == "SUCCESS") {
		alert(response.getReturnValue());
	    }    
	    });        
        $A.enqueueAction(action);
    },
    
})