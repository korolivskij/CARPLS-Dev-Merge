public class ctrlLocalExpert {

    public Id   caseId                      {get;set;}
    public Case cse                         {get;set;}
    public Contact client                   {get;set;}
    public Network network                  {get;set;}
    public Boolean allowLENotifications     {get;set;} //passed from parent page via attribute.
    public Boolean allowLEMultipleSendTos   {get;set;}
    public Boolean showTopicAssignments     {get;set;}
    public Boolean showLikeOption           {get;set;}
    public Boolean showAllTab               {get;set;}
    public String notificationChannel       {get;set;}
    public String arChannel     {get;set;}

    public ctrlLocalExpert() {
        this.showTopicAssignments = false;
        this.showLikeOption = false;
        this.notificationChannel = '';
        this.arChannel = '';
        this.network = LeHelper.retrieveRunningCommunityNetwork();
        this.allowLENotifications = false;
        this.allowLEMultipleSendTos = false;
        this.showAllTab = false;
    }
}