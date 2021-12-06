public with sharing class ctrlDebug extends ctrlComponentBase {
    
    public pageReference doClearDebugMessages() {
        if(pageController!= null) {
            pageController.debugMessages = new List<DebugMessage>();
        }
        return null;
    }
}