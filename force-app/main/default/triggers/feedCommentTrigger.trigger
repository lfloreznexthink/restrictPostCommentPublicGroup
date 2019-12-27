trigger feedCommentTrigger on FeedComment (before insert) {


    String feedItemId = Trigger.New[0].FeedItemId;
    String userId = UserInfo.getUserId();
    List<CollaborationGroupFeed> posts = [SELECT Id, ParentId, NetworkScope FROM CollaborationGroupFeed WHERE Id = :feedItemId];
    if(posts.size() == 0)
    {
        return;
    }
    CollaborationGroupFeed post = posts[0];
    // Functionality only for communities
    if(post.NetworkScope == null)
    {
        return;
    }
    String groupId = post.ParentId;
    // Check if the post is from a Group
    if(groupId == null)
    {
        return;
    }
    List<CollaborationGroupMember> groupMembers = [SELECT Id, MemberId, CollaborationGroupId FROM CollaborationGroupMember WHERE MemberId = :userId AND CollaborationGroupId = :groupId];
    if(groupMembers.size() == 0)
    {
        Trigger.New[0].addError('Please join this group to be able to participate');
    }

}