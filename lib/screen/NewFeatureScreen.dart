import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

class NewFeatureScreen extends StatefulWidget {
  const NewFeatureScreen({super.key});

  @override
  State<NewFeatureScreen> createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<NewFeatureScreen> {
  // Comprehensive list of world currencies with codes, names and symbols
  final List<Map<String, String>> currencies = [
    {'code': 'USD', 'name': 'US Dollar', 'symbol': '\$'},
    {'code': 'EUR', 'name': 'Euro', 'symbol': '€'},
    {'code': 'JPY', 'name': 'Japanese Yen', 'symbol': '¥'},
   

    {'code': 'PEN', 'name': 'Peruvian Sol', 'symbol': 'S/.'},
    {'code': 'TWD', 'name': 'New Taiwan Dollar', 'symbol': 'NT\$'},
    {'code': 'KWD', 'name': 'Kuwaiti Dinar', 'symbol': 'د.ك'},
    {'code': 'QAR', 'name': 'Qatari Riyal', 'symbol': 'ر.ق'},
    {'code': 'OMR', 'name': 'Omani Rial', 'symbol': 'ر.ع.'},
    {'code': 'BHD', 'name': 'Bahraini Dinar', 'symbol': '.د.ب'},
    {'code': 'JOD', 'name': 'Jordanian Dinar', 'symbol': 'د.ا'},
    {'code': 'LKR', 'name': 'Sri Lankan Rupee', 'symbol': 'රු'},
    {'code': 'NPR', 'name': 'Nepalese Rupee', 'symbol': 'रू'},
    {'code': 'UAH', 'name': 'Ukrainian Hryvnia', 'symbol': '₴'},
    {'code': 'KZT', 'name': 'Kazakhstani Tenge', 'symbol': '₸'},
    
    {'code': 'ETB', 'name': 'Ethiopian Birr', 'symbol': 'Br'},
    {'code': 'KES', 'name': 'Kenyan Shilling', 'symbol': 'KSh'},
    {'code': 'TZS', 'name': 'Tanzanian Shilling', 'symbol': 'TSh'},
    {'code': 'UGX', 'name': 'Ugandan Shilling', 'symbol': 'USh'},
    
    {'code': 'MKD', 'name': 'Macedonian Denar', 'symbol': 'ден'},
    {'code': 'BAM', 'name': 'Bosnia-Herzegovina Convertible Mark', 'symbol': 'KM'},
    {'code': 'GTQ', 'name': 'Guatemalan Quetzal', 'symbol': 'Q'},
    {'code': 'HNL', 'name': 'Honduran Lempira', 'symbol': 'L'},
    {'code': 'NIO', 'name': 'Nicaraguan Córdoba', 'symbol': 'C\$'},
    {'code': 'PYG', 'name': 'Paraguayan Guarani', 'symbol': '₲'},
    {'code': 'BOB', 'name': 'Bolivian Boliviano', 'symbol': 'Bs.'},
    {'code': 'SVC', 'name': 'Salvadoran Colón', 'symbol': '₡'},
    {'code': 'BZD', 'name': 'Belize Dollar', 'symbol': 'BZ\$'},
    {'code': 'TTD', 'name': 'Trinidad & Tobago Dollar', 'symbol': 'TT\$'},
    {'code': 'BBD', 'name': 'Barbadian Dollar', 'symbol': 'Bds\$'},
    {'code': 'XCD', 'name': 'East Caribbean Dollar', 'symbol': '\$'},
    {'code': 'AWG', 'name': 'Aruban Florin', 'symbol': 'ƒ'},
    {'code': 'BSD', 'name': 'Bahamian Dollar', 'symbol': 'B\$'},
    {'code': 'KYD', 'name': 'Cayman Islands Dollar', 'symbol': 'CI\$'},
    {'code': 'GYD', 'name': 'Guyanese Dollar', 'symbol': 'G\$'},
 
    {'code': 'GNF', 'name': 'Guinean Franc', 'symbol': 'FG'},
    {'code': 'SSP', 'name': 'South Sudanese Pound', 'symbol': '£'},
    {'code': 'SDG', 'name': 'Sudanese Pound', 'symbol': 'ج.س.'},
    {'code': 'LYD', 'name': 'Libyan Dinar', 'symbol': 'ل.د'},
    {'code': 'TND', 'name': 'Tunisian Dinar', 'symbol': 'د.ت'},
    {'code': 'DZD', 'name': 'Algerian Dinar', 'symbol': 'د.ج'},
    {'code': 'MRO', 'name': 'Mauritanian Ouguiya', 'symbol': 'UM'},
    {'code': 'BIF', 'name': 'Burundian Franc', 'symbol': 'FBu'},
    {'code': 'CVE', 'name': 'Cape Verdean Escudo', 'symbol': '\$'},
    {'code': 'GIP', 'name': 'Gibraltar Pound', 'symbol': '£'},
    {'code': 'FKP', 'name': 'Falkland Islands Pound', 'symbol': '£'},
    {'code': 'SHP', 'name': 'St. Helena Pound', 'symbol': '£'},
    {'code': 'IMP', 'name': 'Isle of Man Pound', 'symbol': '£'},
    {'code': 'JEP', 'name': 'Jersey Pound', 'symbol': '£'},
    {'code': 'TMT', 'name': 'Turkmenistani Manat', 'symbol': 'm'},
    {'code': 'TJS', 'name': 'Tajikistani Somoni', 'symbol': 'ЅМ'},
    {'code': 'UZS', 'name': 'Uzbekistani Som', 'symbol': 'soʻm'},
   
  ];

  // Selected currencies
  String fromCurrency = 'USD';
  String toCurrency = 'EUR';

  // Controllers for text fields
  final TextEditingController amountController = TextEditingController();
  final TextEditingController resultController = TextEditingController();

  // Sample conversion rates (in a real app, fetch from API)
  final Map<String, Map<String, double>> rates = {
    'USD': {
      'EUR': 0.85,
      'GBP': 0.73,
      'JPY': 110.25,
      'AUD': 1.30,
      'CAD': 1.25,
      'INR': 74.85,
      'SGD': 1.35,
      'MYR': 4.20,
      'THB': 33.50,
      'IDR': 14350.00,
      'KRW': 1180.00,
      'VND': 23000.00,
      'PHP': 50.50,
      'BRL': 5.25,
      'MXN': 20.15,
      'RUB': 75.50,
      'ZAR': 15.25,
      'AED': 3.67,
      'SAR': 3.75,
      'TRY': 8.50,
      'SEK': 8.65,
      'NOK': 8.85,
      'DKK': 6.35,
      'HKD': 7.78,
      'NZD': 1.45,
      'EGP': 15.70,
      'PLN': 3.85,
      'HUF': 300.00,
      'CZK': 22.00,
      'ILS': 3.25,
    
      'UZS': 10500.00,
      'KPW': 900.00,
      'IRR': 42000.00,
      'IQD': 1450.00,
      'SYP': 2500.00,
      'YER': 250.00,
      'AFN': 85.00,
      'BTN': 74.85,
      'MOP': 8.00,
      'PGK': 3.50,
      'VES': 2500000.00,
    },
    // Add more base currencies as needed
  };


  @override
  void initState() {
    super.initState();
    // Initialize with default conversion
    _convertCurrency();
  }

  @override
  void dispose() {
    amountController.dispose();
    resultController.dispose();
    super.dispose();
  }

  void _convertCurrency() {
    if (amountController.text.isEmpty) {
      resultController.text = '';
      return;
    }

    try {
      final amount = double.parse(amountController.text);
      double rate = 1.0;

      if (fromCurrency == toCurrency) {
        rate = 1.0;
      } else if (rates.containsKey(fromCurrency) &&
          rates[fromCurrency]!.containsKey(toCurrency)) {
        rate = rates[fromCurrency]![toCurrency]!;
      } else if (rates.containsKey(toCurrency) &&
          rates[toCurrency]!.containsKey(fromCurrency)) {
        rate = 1 / rates[toCurrency]![fromCurrency]!;
      } else {
        // Default rate if not found (in real app, show error)
        rate = 0.85;
      }

      final result = amount * rate;
      resultController.text = result.toStringAsFixed(2);
    } catch (e) {
      resultController.text = 'Invalid input';
    }
  }

  void _swapCurrencies() {
    setState(() {
      final temp = fromCurrency;
      fromCurrency = toCurrency;
      toCurrency = temp;
      _convertCurrency();
    });
  }

  String _getCurrencySymbol(String code) {
    return currencies.firstWhere((c) => c['code'] == code)['symbol'] ?? code;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter',
        style: TextStyle(color: Colors.white,),
        ),
        backgroundColor: Colors.deepPurpleAccent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Header with icon
            const Icon(Icons.currency_exchange, size: 80, color: Colors.amber),
            const SizedBox(height: 20),
            const Text(
              'Currency Converter',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // Amount input card
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text(
                      'Amount to Convert',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      decoration: InputDecoration(
                        prefixText: _getCurrencySymbol(fromCurrency),
                        prefixStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintText: 'Enter amount',
                      ),
                      style: const TextStyle(fontSize: 20),
                      onChanged: (value) => _convertCurrency(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Currency selection row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // From currency dropdown
                Expanded(
                  child: _buildCurrencyDropdown(
                    value: fromCurrency,
                    onChanged: (newValue) {
                      setState(() {
                        fromCurrency = newValue!;
                        _convertCurrency();
                      });
                    },
                    label: 'From',
                  ),
                ),

                // Swap button
                IconButton(
                  onPressed: _swapCurrencies,
                  icon: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.deepPurpleAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.swap_horiz, color: Colors.white),
                  ),
                ),

                // To currency dropdown
                Expanded(
                  child: _buildCurrencyDropdown(
                    value: toCurrency,
                    onChanged: (newValue) {
                      setState(() {
                        toCurrency = newValue!;
                        _convertCurrency();
                      });
                    },
                    label: 'To',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Result card
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text(
                      'Converted Amount',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: resultController,
                      readOnly: true,
                      decoration: InputDecoration(
                        prefixText: _getCurrencySymbol(toCurrency),
                        prefixStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintText: 'Result will appear here',
                      ),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Conversion rate info
            Text(
              '1 ${fromCurrency} = ${_getConversionRate()} ${toCurrency}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // Disclaimer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Note: Conversion rates are for demonstration only. For real-time rates, connect to a currency API.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyDropdown({
    required String value,
    required ValueChanged<String?> onChanged,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 4),
          child: Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            items: currencies.map((currency) {
              return DropdownMenuItem<String>(
                value: currency['code'],
                child: Text(
                  '${currency['code']} - ${currency['name']}',
                  style: const TextStyle(fontSize: 16),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  String _getConversionRate() {
    if (fromCurrency == toCurrency) return '1';

    try {
      if (rates.containsKey(fromCurrency) &&
          rates[fromCurrency]!.containsKey(toCurrency)) {
        return rates[fromCurrency]![toCurrency]!.toStringAsFixed(4);
      } else if (rates.containsKey(toCurrency) &&
          rates[toCurrency]!.containsKey(fromCurrency)) {
        return (1 / rates[toCurrency]![fromCurrency]!).toStringAsFixed(4);
      }
    } catch (e) {
      return '?';
    }

    return '?';
  }
}

