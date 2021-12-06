public with sharing virtual class ctrlComponentBase {
        
    public ctrlCarplesGeneric pageController { get; 
    set {
      if (value != null) {
        pageController = value;
        pageController.setComponentController(this);
      }
    }
  }
}