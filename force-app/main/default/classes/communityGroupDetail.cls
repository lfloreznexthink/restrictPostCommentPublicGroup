public with sharing class communityGroupDetail {
    
    @AuraEnabled(cacheable=true)
    public static Boolean isPartOfGroup(String groupId) {
        Id userId = UserInfo.getUserId();
        Integer inGroup = [SELECT Count() FROM CollaborationGroupMember WHERE CollaborationGroupId = :groupId AND MemberId = :userId];
        return inGroup > 0;
    }
}