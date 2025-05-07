# encoding: UTF-8
CATEGORIES = ['Advertising',
              'Truck Expenses',
              'Contractors',
              'Education and Training',
              'Employee Benefits',
              'Meals and Entertainment',
              'Office Expenses',
              'Professional Services',
              'Rent or Lease',
              'Supplies',
              'Travel',
              'Utilities',
              'Other Expenses']
COUNTRY_LIST = ['Afghanistan',
                'Albania',
                'Algeria',
                'Andorra',
                'Angola',
                'Antigua and Barbuda',
                'Argentina',
                'Armenia',
                'Australia',
                'Austria',
                'Azerbaijan',
                'Bahamas',
                'Bahrain',
                'Bangladesh',
                'Barbados',
                'Belarus',
                'Belgium',
                'Belize',
                'Benin',
                'Bhutan',
                'Bolivia',
                'Bosnia and Herzegovina',
                'Botswana',
                'Brazil',
                'Brunei',
                'Bulgaria',
                'Burkina Faso',
                'Burundi',
                'Cambodia',
                'Cameroon',
                'Canada',
                'Cape Verde',
                'Central African Republic',
                'Chad',
                'Chile',
                'China',
                'Colombi',
                'Comoros',
                'Congo (Brazzaville)',
                'Congo',
                'Costa Rica',
                'Cote d\'Ivoire',
                'Croatia',
                'Cuba',
                'Cyprus',
                'Czech Republic',
                'Denmark',
                'Djibouti',
                'Dominica',
                'Dominican Republic',
                'East Timor (Timor Timur)',
                'Ecuador',
                'Egypt',
                'El Salvador',
                'Equatorial Guinea',
                'Eritrea',
                'Estonia',
                'Ethiopia',
                'Fiji',
                'Finland',
                'France',
                'Gabon',
                'Gambia, The',
                'Georgia',
                'Germany',
                'Ghana',
                'Greece',
                'Grenada',
                'Guatemala',
                'Guinea',
                'Guinea-Bissau',
                'Guyana',
                'Haiti',
                'Honduras',
                'Hungary',
                'Iceland',
                'India',
                'Indonesia',
                'Iran',
                'Iraq',
                'Ireland',
                'Israel',
                'Italy',
                'Jamaica',
                'Japan',
                'Jordan',
                'Kazakhstan',
                'Kenya',
                'Kiribati',
                'Korea, North',
                'Korea, South',
                'Kuwait',
                'Kyrgyzstan',
                'Laos',
                'Latvia',
                'Lebanon',
                'Lesotho',
                'Liberia',
                'Libya',
                'Liechtenstein',
                'Lithuania',
                'Luxembourg',
                'Macedonia',
                'Madagascar',
                'Malawi',
                'Malaysia',
                'Maldives',
                'Mali',
                'Malta',
                'Marshall Islands',
                'Mauritania',
                'Mauritius',
                'Mexico',
                'Micronesia',
                'Moldova',
                'Monaco',
                'Mongolia',
                'Morocco',
                'Mozambique',
                'Myanmar',
                'Namibia',
                'Nauru',
                'Nepal',
                'Netherlands',
                'New Zealand',
                'Nicaragua',
                'Niger',
                'Nigeria',
                'Norway',
                'Oman',
                'Pakistan',
                'Palau',
                'Panama',
                'Papua New Guinea',
                'Paraguay',
                'Peru',
                'Philippines',
                'Poland',
                'Portugal',
                'Qatar',
                'Romania',
                'Russia',
                'Rwanda',
                'Saint Kitts and Nevis',
                'Saint Lucia',
                'Saint Vincent',
                'Samoa',
                'San Marino',
                'Sao Tome and Principe',
                'Saudi Arabia',
                'Senegal',
                'Serbia and Montenegro',
                'Seychelles',
                'Sierra Leone',
                'Singapore',
                'Slovakia',
                'Slovenia',
                'Solomon Islands',
                'Somalia',
                'South Africa',
                'Spain',
                'Sri Lanka',
                'Sudan',
                'Suriname',
                'Swaziland',
                'Sweden',
                'Switzerland',
                'Syria',
                'Taiwan',
                'Tajikistan',
                'Tanzania',
                'Thailand',
                'Togo',
                'Tonga',
                'Trinidad and Tobago',
                'Tunisia',
                'Turkey',
                'Turkmenistan',
                'Tuvalu',
                'Uganda',
                'Ukraine',
                'United Arab Emirates',
                'United Kingdom',
                'United States',
                'Uruguay',
                'Uzbekistan',
                'Vanuatu',
                'Vatican City',
                'Venezuela',
                'Vietnam',
                'Yemen',
                'Zambia',
                'Zimbabwe']

INDUSTRY_LIST = ['Accommodation & Hospitality',
                 'Accounting',
                 'Administrative Services',
                 'Advertising',
                 'Agriculture',
                 'Architecture',
                 'Arts',
                 'Automotive',
                 'Construction',
                 'Consulting',
                 'Design',
                 'Education',
                 'Engineering',
                 'Film',
                 'Finance',
                 'Fishing & Hunting',
                 'Food Services',
                 'Forestry',
                 'Government',
                 'Health Care',
                 'Individual',
                 'Information Technology',
                 'Insurance',
                 'Internet',
                 'Legal',
                 'Manufacturing',
                 'Marketing',
                 'Media & Entertainment',
                 'Mining',
                 'Non-Profit',
                 'Public Relations',
                 'Real Estate',
                 'Recreation',
                 'Retail',
                 'Scientific Services',
                 'Social Assistance',
                 'Software',
                 'Support Services',
                 'Technical Services',
                 'Telecommunications',
                 'Transportation',
                 'Travel & Tourism',
                 'Utilities',
                 'Warehousing',
                 'Waste Management Services',
                 'Wholesale Trade',
                 'Other'
]

DISCOUNT_TYPE = %w(% USD)

DATE_FORMATS = [
    ['dd-mon-yyyy' + ' ' + '(31-Jan-98)'  , '%d-%b-%Y'],
    ['mm/dd/yyyy'  + ' ' + '(01/31/1998)' , '%m/%d/%Y'],
    ['dd/mm/yyyy'  + ' ' + '(31/01/1998)' , '%d/%m/%Y'],
    ['yyyy-mm-dd'  + ' ' + '(1998-01-31)' , '%Y-%m-%d']
]

LINES_PER_PAGE = %w(9 21 51 99)

LANGUAGES = [
    ['English', 'en'],
    ['German', 'de'],
    ['France', 'fr'],
    ['English Canada', 'en-CA'],
    ['English US', 'en-US'],
    ['Japanese', 'ja'],
    ['Vietnamese', 'vi'],
    ['Nepali', 'nep'],
    ['Persian', 'fa'],
    ['Korean', 'ko'],
    ['Polish', 'pl'],
    ['Swedish', 'sv'],
    ['Spanish', 'es'],
    ['Russian', 'ru'],
    ['Dutch', 'nl'],
    ['Slovak', 'sk'],
    ['Italian', 'it'],
    ['Arabic', 'ar'],
    ['Urdu', 'ur'],
    ['Brazilian Portuguese', 'pt-BR']
]

RECURRING_FREQUENCY = [['weekly', '1.week'], ['2 weeks', '2.weeks'], ['4 weeks', '4.weeks'], ['monthly', '1.month'], ['2 months', '2.months'], ['4 months','4.months'], ['6 months', '6.months'], ['yearly', '1.year'], ['2 years', '2.years'], ['3 years', '3.years']]

Invoice_FREQUENCY = [['Weekly', '1.week'], ['Monthly', '1.month'], ['Yearly', '1.year']]

QUARTER_MONTHS = [['Jan - Mar', '1-3'], ['Apr - Jun', '4-6'], ['Jul - Sep', '7-9'], ['Oct - Dec', '10-12']]

INVOICE_STATUS = [['Draft', 'draft'], ['Sent', 'sent'], ['Viewed', 'viewed'], ['Paid', 'paid'], ['Partial', 'partial'], ['Draft partial', 'draft_partial'], ['Disputed', 'disputed']]

INVOICE_DATE_TO_USE = [['Invoice Date', 'invoice_date'], ['Paid Date', 'paid_date']]

CREDIT_CARD_TYPE = ['Visa', 'Master Card', 'Discover', 'American Express']

COMPANY_SIZE = ['1-10 employees',
                '11-100 employees',
                '101-500 employees',
                'Over 500 employees']

PAYMENT_METHODS = ['Cheque', 'Bank Transfer', 'Credit', 'Cash', 'Debit', 'Paypal']

CURRENCY_CODE = [
    ['PKR Pakistan Rupee', 'PKR'],
    ['USD United States Dollar', 'USD'],
    ['CNY China Yuan Renminbi', 'CNY'],
    ['GBP United Kingdom Pound', 'GBP'],
    ['EUR Euro Member Countries', 'EUR'],
    ['SAR Saudi Arabia Riyal', 'SAR']
]
CURRENCY_SYMBOL = {'PKR' => 'Rs', 'USD' => '$', 'CNY' => '¥', 'GBP' => '£', 'EUR' => '€', 'SAR' => '﷼'}
# this is to prepare the list of files to autoload from lib folder in development environment
# we'll use this list in application controller to reload on every request to avoid restarting the server and/or console
RELOAD_LIBS = Dir[Rails.root + 'lib/**/*.rb'] if Rails.env.development?

SHORT_DATE = '%Y'

CUSTOM_FIELDS = {
    'New Invoice' =>
        [
            {label: 'Company Name', token: '{{company_name}}'},
            {label: 'Client Company', token: '{{client_company}}'},
            {label: 'Client Name', token: '{{client_contact}}'},
            {label: 'Currency Symbol', token: '{{currency_symbol}}'},
            {label: 'Invoice Total', token: '{{invoice_total}}'},
            {label: 'Invoice Number', token: '{{invoice_number}}'},
            {label: 'Company Contact', token: '{{company_contact}}'},
            {label: 'Company Phone', token: '{{company_phone}}'},
            {label: 'Company Signature', token: '{{company_signature}}'},
            {label: 'Invoice URL', token: '{{invoice_url}}'}
        ],

    'Payment Received' =>
        [
            {label: 'Client Name', token: '{{client_name}}'},
            {label: 'Company Name', token: '{{company_name}}'},
            {label: 'Currency Symbol', token: '{{currency_symbol}}'},
            {label: 'Invoice Total', token: '{{invoice_total}}'},
            {label: 'Payment Amount', token: '{{payment_amount}}'},
            {label: 'Invoice Number', token: '{{invoice_number}}'},
            {label: 'Company Signature', token: '{{company_signature}}'},
            {label: 'Invoice URL', token: '{{invoice_url}}'}
        ],
    'Late Payment Reminder' =>
        [
            {label: 'Company Name', token: '{{company_name}}'},
            {label: 'Currency Symbol', token: '{{currency_symbol}}'},
            {label: 'Client Company', token: '{{client_company}}'},
            {label: 'Client Name', token: '{{client_contact}}'},
            {label: 'Due Payment Amount', token: '{{payment_amount_due}}'},
            {label: 'Invoice Number', token: '{{invoice_number}}'},
            {label: 'Company Signature', token: '{{company_signature}}'},
            {label: 'Invoice URL', token: '{{invoice_url}}'}

        ],
    'Dispute Invoice' =>
        [
            {label: 'Company Name', token: '{{company_name}}'},
            {label: 'Client Company', token: '{{client_company}}'},
            {label: 'Invoice Number', token: '{{invoice_number}}'},
            {label: 'Company Contact', token: '{{company_contact}}'},
            {label: 'Dispute Reason', token: '{{reason}}'}
        ],
    'Dispute Reply' =>
        [
            {label: 'Company Name', token: '{{company_name}}'},
            {label: 'Invoice Number', token: '{{invoice_number}}'},
            {label: 'Application URL', token: '{{app_url}}'},
            {label: 'Company Signature', token: '{{company_signature}}'},
            {label: 'Encrypted Invoice Id', token: '{{encrypted_id}}'},
            {label: ' Response to Client', token: '{{dispute_response}}'}
        ],
    'New User' =>
        [
            {label: 'Company Name', token: '{{company_name}}'},
            {label: 'Company Contact', token: '{{company_contact}}'},
            {label: 'Company Phone', token: '{{company_phone}}'},
            {label: 'User Name', token: '{{user_email}}'},
            {label: 'User Password', token: '{{user_password}}'},
        ],
    'New Estimate' =>
        [
            {label: 'Company Name', token: '{{company_name}}'},
            {label: 'Client Company', token: '{{client_company}}'},
            {label: 'Client Name', token: '{{client_contact}}'},
            {label: 'Currency Symbol', token: '{{currency_symbol}}'},
            {label: 'Invoice Total', token: '{{invoice_total}}'},
            {label: 'Invoice Number', token: '{{invoice_number}}'},
            {label: 'Company Contact', token: '{{company_contact}}'},
            {label: 'Company Phone', token: '{{company_phone}}'},
            {label: 'Company Signature', token: '{{company_signature}}'},
            {label: 'Invoice URL', token: '{{invoice_url}}'}
        ],
    'Soft Payment Reminder' =>
        [
            {label: 'Company Name', token: '{{company_name}}'},
            {label: 'Company Contact', token: '{{company_contact}}'},
            {label: 'Company Phone', token: '{{company_phone}}'},
            {label: 'Currency Symbol', token: '{{currency_symbol}}'},
            {label: 'Client Company', token: '{{client_company}}'},
            {label: 'Client Name', token: '{{client_contact}}'},
            {label: 'Due Payment Amount', token: '{{payment_amount_due}}'},
            {label: 'Invoice Number', token: '{{invoice_number}}'},
            {label: 'Company Signature', token: '{{company_signature}}'},
            {label: 'Invoice URL', token: '{{invoice_url}}'}
        ]
}

ROLES = ['admin', 'manager', 'staff']

ENTITIES = ['Account','Category', 'Client', 'Company', 'CompanyEmailTemplate', 'CompanyEntity', 'Currency', 'EmailTemplate', 'Estimate', 'ExpenseCategory', 'Expense', 'InvoiceLineItem', 'InvoiceTask', 'Invoice', 'Item', 'LineItemTax', 'Log', 'PaymentTerm', 'Payment', 'ProjectTask', 'Project', 'RecurringProfileLineItem', 'RecurringProfile', 'Role', 'SentEmail', 'Staff', 'Task', 'TeamMember']


FREEPLAN = ['5 Clients', 'Unlimited Invoices', 'Unlimited sub users' , 'Free Reporting']
SILVER = ['10 Clients', 'Unlimited Invoices', 'Unlimited sub users' , 'Free Reporting']
GOLD = ['25 Clients', 'Unlimited Invoices', 'Unlimited sub users' , 'Free Reporting']
PLATINUM = ['Unlimited Clients', 'Unlimited Invoices', 'Unlimited sub users' , 'Free Reporting']
OSB_MARKETING_SITE = 'https://opensourcebilling.org/'
PRESSTIGERS_SITE = 'https://www.presstigers.com/'

COUNTRIES_WITH_CODES = {"AF"=>"Afghanistan", "AL"=>"Albania", "DZ"=>"Algeria", "AS"=>"American Samoa", "AD"=>"Andorra", "AO"=>"Angola", "AI"=>"Anguilla", "AQ"=>"Antarctica", "AG"=>"Antigua and Barbuda", "AR"=>"Argentina", "AM"=>"Armenia", "AW"=>"Aruba", "AU"=>"Australia", "AT"=>"Austria", "AZ"=>"Azerbaijan", "BS"=>"Bahamas", "BH"=>"Bahrain", "BD"=>"Bangladesh", "BB"=>"Barbados", "BY"=>"Belarus", "BE"=>"Belgium", "BZ"=>"Belize", "BJ"=>"Benin", "BM"=>"Bermuda", "BT"=>"Bhutan", "BO"=>"Bolivia", "BQ"=>"Bonaire, Sint Eustatius and Saba", "BA"=>"Bosnia and Herzegovina", "BW"=>"Botswana", "BV"=>"Bouvet Island", "BR"=>"Brazil", "IO"=>"British Indian Ocean Territory", "BN"=>"Brunei Darussalam", "BG"=>"Bulgaria", "BF"=>"Burkina Faso", "BI"=>"Burundi", "CV"=>"Cabo Verde", "KH"=>"Cambodia", "CM"=>"Cameroon", "CA"=>"Canada", "KY"=>"Cayman Islands", "CF"=>"Central African Republic", "TD"=>"Chad", "CL"=>"Chile", "CN"=>"China", "CX"=>"Christmas Island", "CC"=>"Cocos (Keeling) Islands", "CO"=>"Colombia", "KM"=>"Comoros", "CG"=>"Congo", "CD"=>"Congo, The Democratic Republic of the", "CK"=>"Cook Islands", "CR"=>"Costa Rica", "HR"=>"Croatia", "CU"=>"Cuba", "CW"=>"Curaçao", "CY"=>"Cyprus", "CZ"=>"Czechia", "CI"=>"Côte d'Ivoire", "DK"=>"Denmark", "DJ"=>"Djibouti", "DM"=>"Dominica", "DO"=>"Dominican Republic", "EC"=>"Ecuador", "EG"=>"Egypt", "SV"=>"El Salvador", "GQ"=>"Equatorial Guinea", "ER"=>"Eritrea", "EE"=>"Estonia", "SZ"=>"Eswatini", "ET"=>"Ethiopia", "FK"=>"Falkland Islands (Malvinas)", "FO"=>"Faroe Islands", "FJ"=>"Fiji", "FI"=>"Finland", "FR"=>"France", "GF"=>"French Guiana", "PF"=>"French Polynesia", "TF"=>"French Southern Territories", "GA"=>"Gabon", "GM"=>"Gambia", "GE"=>"Georgia", "DE"=>"Germany", "GH"=>"Ghana", "GI"=>"Gibraltar", "GR"=>"Greece", "GL"=>"Greenland", "GD"=>"Grenada", "GP"=>"Guadeloupe", "GU"=>"Guam", "GT"=>"Guatemala", "GG"=>"Guernsey", "GN"=>"Guinea", "GW"=>"Guinea-Bissau", "GY"=>"Guyana", "HT"=>"Haiti", "HM"=>"Heard Island and McDonald Islands", "VA"=>"Holy See (Vatican City State)", "HN"=>"Honduras", "HK"=>"Hong Kong", "HU"=>"Hungary", "IS"=>"Iceland", "IN"=>"India", "ID"=>"Indonesia", "IR"=>"Iran, Islamic Republic of", "IQ"=>"Iraq", "IE"=>"Ireland", "IM"=>"Isle of Man", "IL"=>"Israel", "IT"=>"Italy", "JM"=>"Jamaica", "JP"=>"Japan", "JE"=>"Jersey", "JO"=>"Jordan", "KZ"=>"Kazakhstan", "KE"=>"Kenya", "KI"=>"Kiribati", "KW"=>"Kuwait", "KG"=>"Kyrgyzstan", "LA"=>"Lao People's Democratic Republic", "LV"=>"Latvia", "LB"=>"Lebanon", "LS"=>"Lesotho", "LR"=>"Liberia", "LY"=>"Libya", "LI"=>"Liechtenstein", "LT"=>"Lithuania", "LU"=>"Luxembourg", "MO"=>"Macao", "MG"=>"Madagascar", "MW"=>"Malawi", "MY"=>"Malaysia", "MV"=>"Maldives", "ML"=>"Mali", "MT"=>"Malta", "MH"=>"Marshall Islands", "MQ"=>"Martinique", "MR"=>"Mauritania", "MU"=>"Mauritius", "YT"=>"Mayotte", "MX"=>"Mexico", "FM"=>"Micronesia, Federated States of", "MD"=>"Moldova", "MC"=>"Monaco", "MN"=>"Mongolia", "ME"=>"Montenegro", "MS"=>"Montserrat", "MA"=>"Morocco", "MZ"=>"Mozambique", "MM"=>"Myanmar", "NA"=>"Namibia", "NR"=>"Nauru", "NP"=>"Nepal", "NL"=>"Netherlands", "NC"=>"New Caledonia", "NZ"=>"New Zealand", "NI"=>"Nicaragua", "NE"=>"Niger", "NG"=>"Nigeria", "NU"=>"Niue", "NF"=>"Norfolk Island", "KP"=>"North Korea", "MK"=>"North Macedonia", "MP"=>"Northern Mariana Islands", "NO"=>"Norway", "OM"=>"Oman", "PK"=>"Pakistan", "PW"=>"Palau", "PS"=>"Palestine, State of", "PA"=>"Panama", "PG"=>"Papua New Guinea", "PY"=>"Paraguay", "PE"=>"Peru", "PH"=>"Philippines", "PN"=>"Pitcairn", "PL"=>"Poland", "PT"=>"Portugal", "PR"=>"Puerto Rico", "QA"=>"Qatar", "RO"=>"Romania", "RU"=>"Russian Federation", "RW"=>"Rwanda", "RE"=>"Réunion", "BL"=>"Saint Barthélemy", "SH"=>"Saint Helena, Ascension and Tristan da Cunha", "KN"=>"Saint Kitts and Nevis", "LC"=>"Saint Lucia", "MF"=>"Saint Martin (French part)", "PM"=>"Saint Pierre and Miquelon", "VC"=>"Saint Vincent and the Grenadines", "WS"=>"Samoa", "SM"=>"San Marino", "ST"=>"Sao Tome and Principe", "SA"=>"Saudi Arabia", "SN"=>"Senegal", "RS"=>"Serbia", "SC"=>"Seychelles", "SL"=>"Sierra Leone", "SG"=>"Singapore", "SX"=>"Sint Maarten (Dutch part)", "SK"=>"Slovakia", "SI"=>"Slovenia", "SB"=>"Solomon Islands", "SO"=>"Somalia", "ZA"=>"South Africa", "GS"=>"South Georgia and the South Sandwich Islands", "KR"=>"South Korea", "SS"=>"South Sudan", "ES"=>"Spain", "LK"=>"Sri Lanka", "SD"=>"Sudan", "SR"=>"Suriname", "SJ"=>"Svalbard and Jan Mayen", "SE"=>"Sweden", "CH"=>"Switzerland", "SY"=>"Syrian Arab Republic", "TW"=>"Taiwan", "TJ"=>"Tajikistan", "TZ"=>"Tanzania", "TH"=>"Thailand", "TL"=>"Timor-Leste", "TG"=>"Togo", "TK"=>"Tokelau", "TO"=>"Tonga", "TT"=>"Trinidad and Tobago", "TN"=>"Tunisia", "TR"=>"Turkey", "TM"=>"Turkmenistan", "TC"=>"Turks and Caicos Islands", "TV"=>"Tuvalu", "UG"=>"Uganda", "UA"=>"Ukraine", "AE"=>"United Arab Emirates", "GB"=>"United Kingdom", "US"=>"United States", "UM"=>"United States Minor Outlying Islands", "UY"=>"Uruguay", "UZ"=>"Uzbekistan", "VU"=>"Vanuatu", "VE"=>"Venezuela", "VN"=>"Vietnam", "VG"=>"Virgin Islands, British", "VI"=>"Virgin Islands, U.S.", "WF"=>"Wallis and Futuna", "EH"=>"Western Sahara", "YE"=>"Yemen", "ZM"=>"Zambia", "ZW"=>"Zimbabwe", "AX"=>"Åland Islands"} 
