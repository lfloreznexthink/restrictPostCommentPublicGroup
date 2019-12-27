({
    doInit : function(component, event, helper) {
        var action = component.get("c.isPartOfGroup");
        action.setParams({groupId: component.get("v.recordId")});
        action.setCallback(this, function(response){
            if(response.getState() !== "SUCCESS")
                return;
            var isPartOfGroup = response.getReturnValue();
            component.set("v.isPartOfGroup", isPartOfGroup);
        });
        $A.enqueueAction(action);
    }
})