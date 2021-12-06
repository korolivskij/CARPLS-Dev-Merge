public with sharing class DebugMessage {
    
    public string Message {get; private set;}
    public string StackTrace {get; private set;}
    public string Other {get; private set;}
    
        
    public DebugMessage() {
    }
    public DebugMessage(String strMessage) {
        this.Message = strMessage;
    }    
    public DebugMessage(string strMessage, string strStackTrace) {
        this.Message = strMessage;
        this.StackTrace = strStackTrace;
    }     
    public DebugMessage(string strMessage, string strStackTrace, string strOther){
        Message = strMessage;
        Stacktrace = strStackTrace;
        Other = strOther;
    }
 
}