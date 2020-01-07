trigger feedPostTrigger on FeedItem (before insert) {
    String userId = UserInfo.getUserId();
    String groupId = Trigger.New[0].ParentId;
    if(groupId == null)
    {
        return;
    }

    //Check that the ParentId is a group from Communities
    List<CollaborationGroup> groupTargeted = [SELECT Id FROM CollaborationGroup WHERE Id = :groupId AND NetworkId <> ''];
    if(groupTargeted.size() == 0)
    {
        return;
    }

    List<CollaborationGroupMember> groupMembers = [SELECT Id, MemberId, CollaborationGroupId FROM CollaborationGroupMember WHERE MemberId = :userId AND CollaborationGroupId = :groupId];
    if(groupMembers.size() == 0)
    {
        Trigger.New[0].addError('Please join this group to be able to participate');
    }
}