@isTest
public class feedCommentTrigger_Test {

    @isTest
    static void testData()
    {
        String communityId = Network.getNetworkId();
        //Create an account
        Account a = new Account(Name='Test account', BillingCountry='France');
        insert a;

        //Create contact
        Contact c = new Contact(AccountId=a.Id, FirstName='Test', LastName='Testing', email='test0@test.com.invalid');
		insert c;

        //Create some users
        Profile p = [SELECT Id FROM Profile WHERE Name='High Volume Customer Portal User'];
        User u = new User(Username='test0@test.com.invalid', LastName='test', Email='test0@test.com.invalid', Alias='test', 
								TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', ProfileId=p.Id, LanguageLocaleKey='en_US', 
                                IsActive=true, ContactId=c.Id);
        insert u;

        // Create group
        String groupOwnerId = UserInfo.getUserId();
        User groupOwner = [SELECT Id FROM User WHERE Id = :groupOwnerId];
        System.runAs(groupOwner){
            ConnectApi.ChatterGroupDetail groupTest = new ConnectApi.ChatterGroupDetail();
            ConnectApi.ChatterGroupInput groupInput = new ConnectApi.ChatterGroupInput();
            groupInput.Name = 'Test0';
            groupInput.visibility = ConnectApi.GroupVisibilityType.PublicAccess;
            groupTest = ConnectApi.ChatterGroups.createGroup(communityId, groupInput);


            // Add post to group created
            ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(communityId, groupTest.Id, ConnectApi.FeedElementType.FeedItem, 'Test post group ');
        }

        // End of test data
    }
    

    @isTest(SeeAllData=true)
    static void testPostNotPartOfGroup()
    {
        feedCommentTrigger_Test.testData();
        
        String communityId = Network.getNetworkId();
        User u = [SELECT Id FROM User WHERE Username='test0@test.com.invalid' LIMIT 1];
        CollaborationGroup g = [SELECT Id FROM CollaborationGroup WHERE Name = 'Test0' LIMIT 1];
        String errorMessage = '';
        System.runAs(u){
            Test.startTest();
            try{
                ConnectApi.ChatterFeeds.postFeedElement(communityId, g.Id, ConnectApi.FeedElementType.FeedItem, 'Test post group');
            }
            catch(Exception e)
            {
                errorMessage = e.getMessage();
            }
            Test.stopTest();
        }
        System.assertEquals('Please join this group to be able to participate', errorMessage);
    }

    @isTest(SeeAllData=true)
    static void testPostPartOfGroup()
    {
        feedCommentTrigger_Test.testData();

        String communityId = Network.getNetworkId();
        User u = [SELECT Id FROM User WHERE Username='test0@test.com.invalid' LIMIT 1];
        CollaborationGroup g = [SELECT Id FROM CollaborationGroup WHERE Name = 'Test0' LIMIT 1];
        
        // Add member to group
        CollaborationGroupMember groupMember = new CollaborationGroupMember(CollaborationGroupId=g.Id, CollaborationRole='Standard', MemberId=u.id, NotificationFrequency='N');
        insert groupMember;

        String errorMessage = '';
        System.runAs(u){
            Test.startTest();
            try{
                ConnectApi.ChatterFeeds.postFeedElement(communityId, g.Id, ConnectApi.FeedElementType.FeedItem, 'Test post group');
            }
            catch(Exception e)
            {
                errorMessage = e.getMessage();
            }
            Test.stopTest();
        }
        System.assertEquals('', errorMessage);
    }

    @isTest(SeeAllData=true)
    static void testCommentNotPartOfGroup()
    {
        feedCommentTrigger_Test.testData();

        String communityId = Network.getNetworkId();
        User u = [SELECT Id FROM User WHERE Username='test0@test.com.invalid' LIMIT 1];
        CollaborationGroup g = [SELECT Id FROM CollaborationGroup WHERE Name = 'Test0' LIMIT 1];
        CollaborationGroupFeed postGroup = [SELECT Id FROM CollaborationGroupFeed WHERE ParentId = :g.Id LIMIT 1];
        String errorMessage = '';
        System.runAs(u){
            Test.startTest();
            try{
                ConnectApi.ChatterFeeds.postCommentToFeedElement(communityId, postGroup.Id, 'Test comment');
            }
            catch(Exception e)
            {
                errorMessage = e.getMessage();
            }
            Test.stopTest();
        }
        System.assertEquals('Please join this group to be able to participate', errorMessage);
        ConnectApi.CommentPage comment = ConnectApi.ChatterFeeds.getCommentsForFeedElement(communityId, postGroup.Id);
        System.assertEquals(0, comment.total);
    }

    @isTest(SeeAllData=true)
    static void testCommentPartOfGroup()
    {
        feedCommentTrigger_Test.testData();

        Id communityId = Network.getNetworkId();
        User u = [SELECT Id FROM User WHERE Username='test0@test.com.invalid' LIMIT 1];
        CollaborationGroup g = [SELECT Id FROM CollaborationGroup WHERE Name = 'Test0' LIMIT 1];
        CollaborationGroupFeed postGroup = [SELECT Id FROM CollaborationGroupFeed WHERE ParentId = :g.Id LIMIT 1];
        
        // Add member to group
        CollaborationGroupMember groupMember = new CollaborationGroupMember(CollaborationGroupId=g.Id, CollaborationRole='Standard', MemberId=u.id, NotificationFrequency='N');
        insert groupMember;

        String errorMessage = '';
        System.runAs(u){
            Test.startTest();
            try{
                ConnectApi.ChatterFeeds.postCommentToFeedElement(communityId, postGroup.Id, 'Test comment');
            }
            catch(Exception e)
            {
                errorMessage = e.getMessage();
            }
            Test.stopTest();
        }
        System.assertEquals('', errorMessage);
        ConnectApi.CommentPage comment = ConnectApi.ChatterFeeds.getCommentsForFeedElement(communityId, postGroup.Id);
        System.assertEquals(1, comment.total);
    }

}
