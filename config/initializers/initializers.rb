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
            {label: 'Invoice URL', token: '{{invoice_url}}'},
            {label: 'Password URL', token: '{{new_password_url}}'},
        ],

    'Payment Received' =>
        [
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
        ],
    'Invoice Number Format' =>
        [
            {label: 'Invoice Number', token: '{{invoice_number}}'},
            {label: 'Client Name', token: '{{client_contact}}'},
            {label: 'Company Name', token: '{{company_name}}'},
            {label: 'Company Contact', token: '{{company_contact}}'},
            {label: 'Invoice Year', token: '{{invoice_year}}'},
            {label: 'Invoice Month', token: '{{invoice_month}}'},
            {label: 'Invoice Day', token: '{{invoice_day}}'},
            {label: 'Company Abbreviation', token: '{{company_abbreviation}}'}
        ]
}

ROLE = 'Super Admin'

ENTITIES = ['Account','Category', 'Client', 'Company', 'CompanyEmailTemplate', 'CompanyEntity', 'Currency', 'EmailTemplate', 'Estimate', 'ExpenseCategory', 'Expense', 'InvoiceLineItem', 'InvoiceTask', 'Invoice', 'Item', 'LineItemTax', 'Log', 'PaymentTerm', 'Payment', 'ProjectTask', 'Project', 'RecurringProfileLineItem', 'RecurringProfile', 'Role', 'SentEmail', 'Staff', 'Task', 'TeamMember']

ENTITY_TYPES = %w(Invoice Estimate Time\ Tracking Payment Client Item Taxes Report Settings)


FREEPLAN = ['5 Clients', 'Unlimited Invoices', 'Unlimited sub users' , 'Free Reporting']
SILVER = ['10 Clients', 'Unlimited Invoices', 'Unlimited sub users' , 'Free Reporting']
GOLD = ['25 Clients', 'Unlimited Invoices', 'Unlimited sub users' , 'Free Reporting']
PLATINUM = ['Unlimited Clients', 'Unlimited Invoices', 'Unlimited sub users' , 'Free Reporting']
