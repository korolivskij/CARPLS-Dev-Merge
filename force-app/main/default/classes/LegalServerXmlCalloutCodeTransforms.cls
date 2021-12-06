/**
 * Created by thom on 6/29/18.
 */

global class LegalServerXmlCalloutCodeTransforms {

    public static String setBirthdate(Date birthdate) {

        if (birthdate == null) return null;
        Datetime birthdatetime = Datetime.newInstance(birthdate, Time.newInstance(0, 0, 0, 0));
        return birthdatetime.format('yyyy-MM-dd');
    }

    public static String setVeteranStatus(String veteranStatus) {

        if (veteranStatus == null) return null;
        if (veteranStatus == 'Current'
                || veteranStatus.contains('Former')) {
            return 'true';
        }
        return 'false';
    }

    public static String setDisabled(String disabled) {

        if (disabled == null) return null;
        if (disabled == 'None') return 'false';
        return 'true';
    }

    public static String setHomeless(String housing) {
        if (housing == null) return null;
        if (housing == 'Homeless/Pays No Rent') return 'true';
        return 'false';
    }

    public static String setIncomeAmount(Decimal input) {

        if(input == null) return null;
        return input.toPlainString();
    }

    public static String setStateCode(String inputState) {

        if (stateCodes.values().contains(inputState)) {
            return inputState;
        }

        return stateCodes.get(inputState);
    }

    public static String setCountyCode(String inputCounty) {

        // input will be picklist value, so no need to sanitize
        return illinoisCountyCodes.get(inputCounty);
    }

    public static String setLanguage(String inputLanguage) {

        return languages.get(inputLanguage);
    }

    public static String setCitizenshipStatus(String citizenship) {

        return citizenshipStatuses.get(citizenship);
    }

    public static String setMaritalStatus(String marital) {

        return maritalStatuses.get(marital);
    }

    public static String setRace(String ethnicity) {

        return races.get(ethnicity);
    }

    public static String setGender(String gender) {

        return genders.get(gender);
    }

    public static String setIncomeType(String incomeType) {

        return incomeTypes.get(incomeType);
    }

    public static String setIncomeFrequency(String incomeFrequency) {

        return incomeFrequencies.get(incomeFrequency);
    }

    public static String setLegalProblemCode(String legalProblemCode) {

        return legalProblemCodes.get(legalProblemCode);
    }


    public static String setETransferOrganization(String eTransferOrganization) {

        return eTransferOrganizations.get(eTransferOrganization);
    }


    public static final Map<String, String> stateCodes = new Map<String, String>{
            'Alabama' => 'AL',
            'Alaska' => 'AK',
            'Arizona' => 'AZ',
            'Arkansas' => 'AR',
            'Armed Forces America' => 'AA',
            'Armed Forces Europe' => 'AE',
            'Armed Forces Pacific' => 'AP',
            'California' => 'CA',
            'Colorado' => 'CO',
            'Connecticut' => 'CT',
            'Delaware' => 'DE',
            'District of Columbia' => 'DC',
            'Florida' => 'FL',
            'Georgia' => 'GA',
            'Hawaii' => 'HI',
            'Idaho' => 'ID',
            'Illinois' => 'IL',
            'Indiana' => 'IN',
            'Iowa' => 'IA',
            'Kansas' => 'KS',
            'Kentucky' => 'KY',
            'Louisiana' => 'LA',
            'Maine' => 'ME',
            'Maryland' => 'MD',
            'Massachusetts' => 'MA',
            'Michigan' => 'MI',
            'Minnesota' => 'MN',
            'Mississippi' => 'MS',
            'Missouri' => 'MO',
            'Montana' => 'MT',
            'Nebraska' => 'NE',
            'Nevada' => 'NV',
            'New Hampshire' => 'NH',
            'New Jersey' => 'NJ',
            'New Mexico' => 'NM',
            'New York' => 'NY',
            'North Carolina' => 'NC',
            'North Dakota' => 'ND',
            'Ohio' => 'OH',
            'Oklahoma' => 'OK',
            'Oregon' => 'OR',
            'Pennsylvania' => 'PA',
            'Rhode Island' => 'RI',
            'South Carolina' => 'SC',
            'South Dakota' => 'SD',
            'Tennessee' => 'TN',
            'Texas' => 'TX',
            'Utah' => 'UT',
            'Vermont' => 'VT',
            'Virginia' => 'VA',
            'Washington' => 'WA',
            'West Virginia' => 'WV',
            'Wisconsin' => 'WI',
            'Wyoming' => 'WY'
    };

    public static final Map<String, String> illinoisCountyCodes = new Map<String, String>{
            'Adams' => '17001',
            'Alexander' => '17003',
            'Bond' => '17005',
            'Boone' => '17007',
            'Brown' => '17009',
            'Bureau' => '17011',
            'Calhoun' => '17013',
            'Carroll' => '17015',
            'Cass' => '17017',
            'Champaign' => '17019',
            'Christian' => '17021',
            'Clark' => '17023',
            'Clay' => '17025',
            'Clinton' => '17027',
            'Coles' => '17029',
            'Cook' => '17031',
            'Crawford' => '17033',
            'Cumberland' => '17035',
            'DeKalb' => '17037',
            'DeWitt' => '17039',
            'Douglas' => '17041',
            'DuPage' => '17043',
            'Edgar' => '17045',
            'Edwards' => '17047',
            'Effingham' => '17049',
            'Fayette' => '17051',
            'Ford' => '17053',
            'Franklin' => '17055',
            'Fulton' => '17057',
            'Gallatin' => '17059',
            'Greene' => '17061',
            'Grundy' => '17063',
            'Hamilton' => '17065',
            'Hancock' => '17067',
            'Hardin' => '17069',
            'Henderson' => '17071',
            'Henry' => '17073',
            'Iroquois' => '17075',
            'Jackson' => '17077',
            'Jasper' => '17079',
            'Jefferson' => '17081',
            'Jersey' => '17083',
            'Jo Daviess' => '17085',
            'Johnson' => '17087',
            'Kane' => '17089',
            'Kankakee' => '17091',
            'Kendall' => '17093',
            'Knox' => '17095',
            'Lake' => '17097',
            'LaSalle' => '17099',
            'Lawrence' => '17101',
            'Lee' => '17103',
            'Livingston' => '17105',
            'Logan' => '17107'
    };

    public static final Map<String, String> languages = new Map<String, String>{
            'English' => 'English',
            'Spanish' => 'Spanish',
            'Japanese' => 'Japanese',
            'Korean' => 'Korean',
            'Mandarin' => 'Mandarin',
            'Polish' => 'Polish',
            'Russian' => 'Russian',
            'Sign' => 'Sign Language',
            'Vietnamese' => 'Vietnamese'
    };

    public static final Map<String, String> citizenshipStatuses = new Map<String, String>{
            'Citizen' => 'Citizen',
            'Documented' => 'Eligible Alien',
            'Undocumented' => 'Ineligible Alien'
    };

    public static final Map<String, String> maritalStatuses = new Map<String, String>{
            'Civil Union' => 'Common Law',
            'Divorced' => 'Divorced',
            'Married' => 'Married',
            'Separated' => 'Separated',
            'Single' => 'Single',
            'Unknown' => 'Unknown',
            'Widowed' => 'Widowed'
    };

    public static final Map<String, String> races = new Map<String, String>{
            'African/American' => 'Black',
            'Asian/Pacific Islander' => 'Asian',
            'Latino' => 'Hispanic or Latino',
            'Native American' => 'American Indian or Alaska Native',
            'White' => 'White',
            'Other/Unknown' => 'Other'
    };

    public static final Map<String, String> genders = new Map<String, String>{
            'Female' => 'Female',
            'Male' => 'Male',
            'Transgender' => 'Transgender',
            'Other' => 'Other'
    };

    public static final Map<String, String> incomeTypes = new Map<String, String>{
            'Income - Veteran Related Benefits' => 'Veterans\' Benefits',
            'Income - Other Benefits' => 'Other',
            'Income - Earned Income' => 'Employment',
            'Income - Other Income' => 'Other'
    };

    public static final Map<String, String> incomeFrequencies = new Map<String, String>{
            'Bi-Weekly' => '26',
            'Weekly' => '52',
            'Monthly' => '12',
            'Yearly' => '1'
    };
    
    public static final Map<String, String> legalProblemCodes = new Map<String, String>{
            'General Consumer Debt - Bankruptcy' => '0100 Bankruptcy/ Debtor Relief',
            'General Consumer Debt - Debtor' => '0110 Debtor\'s Relief',
            'Citations/Garnishments/Assignments' => '0220 Garnishment',
            'Medical/Legal/Other Prof Services' => '0300 Contracts/ Warranties',
            'Memberships/Subscripts/Other Contracts' => '3000 Contracts/ Warranties',
            'Auto' => '0310 Automobile Financing/ Warranties',
            'Insurance' => '0320 Insurance',
            'Credit Cards/Reporting' => '04 Collection Practices/ Creditor Harassment',
            'Student/Payday/Other Loans' => '0600 Loans/ Installment Purch.',
            'Checking/Savings Accounts' => '0900 Other Consumer/ Finance.',
            'Education' => '1100 Education',
            'Wage Payment and Collection Claims' => '2200 Wage Claims',
            'Audit' => '2400 Taxes (Not EITC)',
            'Preparation/Filing' => '2400 Taxes (Not EITC)',
            'Other' => '2400 Taxes (Not EITC)',
            'Employment Terminated' => '2500 Employee Rights',
            'Employment Terms & Conditions' => '2500 Employee Rights',
            'Migrant Workers' => '2600 Agricultural Worker Issues not FLSA',
            'Employment Application Denied' => '2900 Other Employment',
            'Employment Benefits' => '2900 Other Employment',
            'Worker\'s Compensation' => '2920 Worker\'s Compensation',
            'Adoption' => '3000 Adoption',
            'Parenting Time' => '3100 Custody/ Visitation',
            'Parental Decisionmaking' => '3110 Parenting Plan',
            'Divorce - Pre-Decre, Divorce - Post Decree' => '3200 Divorce/ Sep./ Annul.',
            'Adult Guardianships' => '3300 Adult Guardianship',
            'Name Change' => '3400 Name Change',
            'Parentage' => '3600 Paternity',
            'Orders of Protection' => '3700 Domestic Abuse',
            'Child Support' => '3810 Child Support',
            'Division of Property/Maintenance' => '3820 Spousal Maintenance',
            'Relocation/Concealment/Abduction' => '3900 Other Family',
            'Educational Expense' => '3910 Domestic Partners',
            'Marriage/Civil Unions' => '3910 Domestic Partners',
            'Juvenile Delinquency' => '4100 Delinquent',
            'Child Abuse/Neglect' => '4200 Neglected/ Abused/ Depend.',
            'Emancipation/Runaways' => '4300 Emancipation',
            'Minor Guardianships' => '4400 Minor Guardianship',
            'Medicaid' => '5100 Medicaid',
            'Medicare' => '5200 Medicare',
            'KidCare/Family Care ' => '5300 Gov\'t Children\'s Health Insurance',
            'Private Health Care' => '5500 Private Health Insurance',
            'Nursing Homes ' => '5600 Long Term Health Care Facilities',
            'Public/Subsidized Housing' => '6100 Fed. Subsidized Housing',
            'Homeowenership/Real Property' => '6200 Homeownership/ Real Prop.',
            'Home Repair/Furnishing' => '6200 Homeownership/ Real Prop.',
            'Real Estate' => '6200 Homeownership/ Real Prop.',
            'Landlord/Tenant' => '6300 Landlord/ Tenant not Pub.H',
            'Utilities' => '6340 Utilities',
            'TANF/Other Welfare' => '7100 TANF',
            'SSI' => '7200 Social Security (not SSDI)',
            'Food Stamps' => '7300 Food Stamps',
            'SSDI' => '7400 SSDI',
            'Unemployment Compensation' => '7600 Unemployment Compensation',
            'Veteran\'s Benefits' => '7700 Veterans Benefits',
            'Immigration' => '8100 Immigration/ Naturalization',
            'Jail/Prison/Release' => '8300 Prisoner\'s Rights',
            'Probation/Parole' => '8300 Prisoner\'s Rights',
            'Disability Rights' => '8400 Disability Rights',
            'Civil Rights' => '8500 Civil Rights',
            'Criminal Records' => '87 Criminal Record Expungement',
            'Victim/Witness Rights' => '8900 Other Individual Rights',
            'Military Rights' => '8900 Other Individual Rights',
            'Police Misconduct' => '8900 Other Individual Rights',
            'Business Licensing' => '9300 Licenses (Auto and Other)',
            'Guns & Other Licenses' => '9300 Licenses (Auto and Other)',
            'Professional Licenses & Regulation' => '9300 Licenses (Auto and Other)',
            'Battery/Emotional Distress/Defamation' => '9400 Torts',
            'General Acts of Negligence' => '9400 Torts',
            'Products Liability' => '9400 Torts',
            'Premise Liability' => '9400 Torts',
            'Vehicle Accidents' => '9400 Torts',
            'Professional Malpractice/Misconduct' => '9400 Torts',
            'Trespass/Conversion/Nuisance' => '9400 Torts',
            'Estates' => '9500 Wills and Estates',
            'Criminal Defense' => '9900 Other Miscellaneous',
            'Criminal/Civil Seizures' => '9900 Other Miscellaneous',
            'Traffic/Parking/Auto License' => '9900 Other Miscellaneous',
            'Small Business Employer' => '9900 Other Miscellaneous',
            'Non-Profit' => '9900 Other Miscellaneous',
            'Intellectual Property' => '9900 Other Miscellaneous',
            'Incorporation/Dissolution/Operation' => '9900 Other Miscellaneous'
    };

    public static final Map<String, String> eTransferOrganizations = new Map<String, String> {
            'Chicago Volunteer Legal Services Veterans Project IL-AFLAN' => 'Chicago Volunteer Legal Services',
            'Prairie State Legal Services IL-AFLAN' => 'Prairie State Legal Services',
            'Land of Lincoln Legal Assistance Foundation IL-AFLAN' => 'Land Of Lincoln Legal Assistance Foundation',
            'LAF Veteran\'s Rights Project IL-AFLAN' => 'Legal Assistance Foundation of Metropolitan Chicago'
    };


}