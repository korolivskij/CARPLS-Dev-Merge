public with sharing class PovertyBean {
 
    public static final String NO_AMI_LEVELS_FOUND = '-4';
	public static final String NO_HOUSEHOLD_NBR = '-3';
	public static final String NO_ANNUALIZED_INCOME = '-2';
	public static final String NOT_PROCESSED = '-1';
	public static final String NOT_ELIGIBLE  = '0';
	public static final String ELIGIBLE = '1';

	public decimal					povertyPct 				{get; set;}
	public String 					povertyLevelDesc 		{get; set;}
	public Poverty_Levels__c		povertyLevel			{get; set;}
	public AMI_Poverty_Level__c     amiPovertyLevel100      {get; set;}
	public AMI_Poverty_Level__c     amiPovertyLevel80       {get; set;}
	public String					containerStyleClass		{get; set;}
	public String 					povertyFormulaType      {get; set;}
	public Integer                  perIncome  				{get; set;}
	public String                   povertyResult           {get; set;}
	
	public PovertyBean() {
		this.povertyPct = 0.00;		
		this.povertyLevelDesc = '';				
		this.containerStyleClass = '';
		this.povertyFormulaType = 'FPL';
		this.perIncome = 0;
        this.povertyResult = PovertyBean.NOT_PROCESSED;
	}
	public boolean isBothAmiPovertyLevelsExist() {
		return amiPovertyLevel80 != null && amiPovertyLevel100 != null;
	}
}