
// PharmaTrack SL - Pharmacy Inventory & Sales Management System
// Module     : PROG 202 - Software Engineering
// Assignment : 1 - Problem Analysis and Dart-Based System Prototype
// Type       : Console-based Dart prototype (core logic only)
// Run        : dart run bin/main.dart

import 'dart:io';

// 1. HELPER FUNCTIONS (formatting and validated console input)
String two(int n) => n.toString().padLeft(2, '0');

String fmtDate(DateTime d) => '${d.year}-${two(d.month)}-${two(d.day)}';

String fmtDateTime(DateTime d) => '${fmtDate(d)} ${two(d.hour)}:${two(d.minute)}';

String money(double v) => 'NLe ${v.toStringAsFixed(2)}';

/// Pads or trims [s] so that it occupies exactly [w] characters.
String cell(String s, int w) => s.length > w ? s.substring(0, w) : s.padRight(w);

String line([int n = 78, String ch = '-']) => ch * n;

/// Whole days from today until [d] (negative when [d] is in the past).
int daysUntil(DateTime d) {
  final now = DateTime.now();
  final today = DateTime.utc(now.year, now.month, now.day);
  final target = DateTime.utc(d.year, d.month, d.day);
  return target.difference(today).inDays;
}

/// Reads one line from the keyboard. Exits cleanly if the input stream closes.
String readLine(String prompt) {
  stdout.write(prompt);
  final input = stdin.readLineSync();
  if (input == null) {
    print('\nInput closed. Goodbye.');
    exit(0);
  }
  return input.trim();
}

String readText(String prompt) {
  while (true) {
    final value = readLine(prompt);
    if (value.isNotEmpty) return value;
    print('  ! Input cannot be empty.');
  }
}

int readInt(String prompt, {int min = 0, int? max}) {
  while (true) {
    final n = int.tryParse(readLine(prompt));
    if (n != null && n >= min && (max == null || n <= max)) return n;
    if (max == null) {
      print('  ! Enter a whole number of at least $min.');
    } else {
      print('  ! Enter a whole number between $min and $max.');
    }
  }
}

double readDouble(String prompt, {double min = 0}) {
  while (true) {
    final n = double.tryParse(readLine(prompt));
    if (n != null && n >= min) return n;
    print('  ! Enter a number of at least $min.');
  }
}

DateTime readDate(String prompt) {
  final pattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');
  while (true) {
    final value = readLine(prompt);
    if (pattern.hasMatch(value)) {
      final d = DateTime.tryParse(value);
      if (d != null && fmtDate(d) == value) return d;
    }
    print('  ! Use the format YYYY-MM-DD (for example 2027-12-31).');
  }
}

bool confirm(String prompt) {
  final answer = readLine('$prompt (y/n): ').toLowerCase();
  return answer == 'y' || answer == 'yes';
}

// 2. MODEL CLASSES (entities of the system)
enum Role { admin, pharmacist }

// Prototype only. The final app uses Supabase Auth
class User {
  final String username;
  final String password; 
  final String fullName;
  final Role role;

  User(this.username, this.password, this.fullName, this.role);

  bool get isAdmin => role == Role.admin;
  String get roleLabel => isAdmin ? 'Administrator' : 'Pharmacist';
}

class Medicine {
  final String id;
  String name;
  String category;
  double price;
  int quantity;
  DateTime expiryDate;
  int reorderLevel;

  Medicine({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
    required this.expiryDate,
    this.reorderLevel = 10,
  });

  int get daysLeft => daysUntil(expiryDate);
  bool get isExpired => daysLeft < 0;
  bool get expiresSoon => !isExpired && daysLeft <= 90;
  bool get isLowStock => quantity <= reorderLevel;
  bool get needsAttention => isExpired || expiresSoon || isLowStock;

  String get status {
    final flags = <String>[];
    if (isExpired) {
      flags.add('EXPIRED');
    } else if (expiresSoon) {
      flags.add('EXPIRES SOON');
    }
    if (isLowStock) flags.add('LOW STOCK');
    return flags.isEmpty ? 'OK' : flags.join(', ');
  }
}

// price is frozen at the time of sale
class SaleItem {
  final Medicine medicine;
  final double unitPrice; 
  int quantity;

  SaleItem(this.medicine, this.quantity) : unitPrice = medicine.price;

  double get subtotal => unitPrice * quantity;
}

class Sale {
  final String id;
  final DateTime time;
  final String cashier;
  final List<SaleItem> items;

  Sale({
    required this.id,
    required this.time,
    required this.cashier,
    required this.items,
  });

  double get total => items.fold(0.0, (sum, item) => sum + item.subtotal);
  int get unitsSold => items.fold(0, (sum, item) => sum + item.quantity);
}

// 3. BUSINESS LOGIC (no printing or keyboard input in this class)
class Pharmacy {
  final String name;
  final List<User> _users = [];
  final List<Medicine> _medicines = [];
  final List<Sale> _sales = [];
  int _nextMedicineNo = 1;
  int _nextSaleNo = 1;

  Pharmacy(this.name) {
    _seedData();
  }

  List<Medicine> get medicines => List.unmodifiable(_medicines);
  List<Sale> get sales => List.unmodifiable(_sales);

  DateTime _daysFromNow(int days) {
    final d = DateTime.now().add(Duration(days: days));
    return DateTime(d.year, d.month, d.day);
  }

  void _seedData() {
    _users.add(User('admin', 'admin123', 'Store Manager', Role.admin));
    _users.add(User('pharma', 'pharma123', 'Pharmacist on Duty', Role.pharmacist));

    addMedicine('Paracetamol 500mg', 'Analgesic', 2.50, 120, _daysFromNow(400));
    addMedicine('Amoxicillin 500mg', 'Antibiotic', 8.00, 8, _daysFromNow(300));
    addMedicine('Coartem 20/120mg', 'Antimalarial', 35.00, 60, _daysFromNow(45));
    addMedicine('ORS Sachets', 'Rehydration', 3.00, 200, _daysFromNow(700));
    addMedicine('Ibuprofen 400mg', 'Analgesic', 4.50, 5, _daysFromNow(200));
    addMedicine('Cough Syrup 100ml', 'Respiratory', 18.00, 25, _daysFromNow(-10));
  }

  User? login(String username, String password) {
    for (final user in _users) {
      if (user.username == username && user.password == password) return user;
    }
    return null;
  }

  Medicine? findById(String id) {
    for (final m in _medicines) {
      if (m.id == id.toUpperCase()) return m;
    }
    return null;
  }

  List<Medicine> search(String keyword) {
    final k = keyword.toLowerCase();
    return _medicines
        .where((m) =>
            m.name.toLowerCase().contains(k) ||
            m.category.toLowerCase().contains(k))
        .toList();
  }

  Medicine addMedicine(String name, String category, double price, int quantity,
      DateTime expiryDate,
      {int reorderLevel = 10}) {
    final id = 'M${_nextMedicineNo.toString().padLeft(3, '0')}';
    _nextMedicineNo++;
    final medicine = Medicine(
      id: id,
      name: name,
      category: category,
      price: price,
      quantity: quantity,
      expiryDate: expiryDate,
      reorderLevel: reorderLevel,
    );
    _medicines.add(medicine);
    return medicine;
  }

  void restock(Medicine medicine, int quantity) {
    medicine.quantity += quantity;
  }

  /// Completes a sale: reduces stock for each item and records the sale.
  Sale completeSale(String cashier, List<SaleItem> items) {
    for (final item in items) {
      item.medicine.quantity -= item.quantity;
    }
    final sale = Sale(
      id: 'S${_nextSaleNo.toString().padLeft(4, '0')}',
      time: DateTime.now(),
      cashier: cashier,
      items: List.of(items),
    );
    _nextSaleNo++;
    _sales.add(sale);
    return sale;
  }

  List<Medicine> get expiredMedicines =>
      _medicines.where((m) => m.isExpired).toList();

  List<Medicine> get expiringSoonMedicines =>
      _medicines.where((m) => m.expiresSoon).toList();

  List<Medicine> get lowStockMedicines =>
      _medicines.where((m) => m.isLowStock).toList();

  int get alertCount => _medicines.where((m) => m.needsAttention).length;

  List<Sale> salesToday() {
    final now = DateTime.now();
    return _sales
        .where((s) =>
            s.time.year == now.year &&
            s.time.month == now.month &&
            s.time.day == now.day)
        .toList();
  }
}

// 4. CONSOLE USER INTERFACE
class PharmaTrackApp {
  final Pharmacy pharmacy;
  late User _user;

  PharmaTrackApp(this.pharmacy);

  void run() {
    _banner();
    final user = _login();
    if (user == null) {
      print('\nToo many failed attempts. The program will now close.');
      return;
    }
    _user = user;
    print('\nWelcome, ${user.fullName} (${user.roleLabel}).');
    if (pharmacy.alertCount > 0) {
      print('  ! ${pharmacy.alertCount} medicine(s) need attention. Choose option 4 to view alerts.');
    }

    var running = true;
    while (running) {
      _printMenu();
      running = _handle(readLine('Choose an option: '));
    }
    print('\nLogged out. Thank you for using PharmaTrack SL.');
  }

  void _banner() {
    print(line(60, '='));
    print('  PHARMATRACK SL - Pharmacy Inventory & Sales System');
    print('  ${pharmacy.name}');
    print(line(60, '='));
    print('  Demo accounts -> admin / admin123   |   pharma / pharma123');
  }

  User? _login() {
    for (var attempt = 1; attempt <= 3; attempt++) {
      print('\n--- LOGIN (attempt $attempt of 3) ---');
      final username = readText('Username: ');
      final password = readText('Password: ');
      final user = pharmacy.login(username, password);
      if (user != null) return user;
      print('  ! Incorrect username or password.');
    }
    return null;
  }

  void _printMenu() {
    print('\n${line(20, '=')} MAIN MENU ${line(20, '=')}');
    print('  1. View all medicines');
    print('  2. Search for a medicine');
    print('  3. New sale');
    print('  4. Stock and expiry alerts');
    if (_user.isAdmin) {
      print('  5. Add new medicine        (Admin)');
      print('  6. Restock medicine        (Admin)');
      print('  7. Daily sales report      (Admin)');
    }
    print('  0. Logout');
  }

  bool _handle(String choice) {
    switch (choice) {
      case '1':
        _viewAll();
        break;
      case '2':
        _search();
        break;
      case '3':
        _newSale();
        break;
      case '4':
        _showAlerts();
        break;
      case '5':
        if (_requireAdmin()) _addMedicine();
        break;
      case '6':
        if (_requireAdmin()) _restock();
        break;
      case '7':
        if (_requireAdmin()) _salesReport();
        break;
      case '0':
        return false;
      default:
        print('  ! Invalid option. Please choose from the menu.');
    }
    return true;
  }

  bool _requireAdmin() {
    if (_user.isAdmin) return true;
    print('  ! Access denied. This option is for administrators only.');
    return false;
  }

  //  Stock viewing 
  String _row(String id, String name, String category, String price, String qty,
      String expiry, String status) {
    return '${cell(id, 6)}${cell(name, 22)}${cell(category, 14)}'
        '${cell(price, 11)}${cell(qty, 6)}${cell(expiry, 12)}$status';
  }

  void _printTable(List<Medicine> list) {
    print(_row('ID', 'Medicine', 'Category', 'Price', 'Qty', 'Expiry', 'Status'));
    print(line(90));
    for (final m in list) {
      print(_row(m.id, m.name, m.category, money(m.price), m.quantity.toString(),
          fmtDate(m.expiryDate), m.status));
    }
  }

  void _viewAll() {
    print('\n--- ALL MEDICINES ---');
    final list = [...pharmacy.medicines]
      ..sort((a, b) => a.name.compareTo(b.name));
    _printTable(list);
    print('Total medicines: ${list.length}');
  }

  void _search() {
    print('\n--- SEARCH ---');
    final keyword = readText('Enter name or category: ');
    final results = pharmacy.search(keyword);
    if (results.isEmpty) {
      print('  No medicine found for "$keyword".');
    } else {
      _printTable(results);
    }
  }

  void _showAlerts() {
    print('\n--- STOCK AND EXPIRY ALERTS ---');
    if (pharmacy.alertCount == 0) {
      print('  No alerts. Stock levels and expiry dates are healthy.');
      return;
    }
    final expired = pharmacy.expiredMedicines;
    if (expired.isNotEmpty) {
      print('EXPIRED (remove from shelf):');
      for (final m in expired) {
        print('  ${cell(m.id, 6)}${cell(m.name, 22)}expired ${fmtDate(m.expiryDate)}, qty ${m.quantity}');
      }
    }
    final soon = pharmacy.expiringSoonMedicines;
    if (soon.isNotEmpty) {
      print('EXPIRING WITHIN 90 DAYS:');
      for (final m in soon) {
        print('  ${cell(m.id, 6)}${cell(m.name, 22)}expires ${fmtDate(m.expiryDate)} (${m.daysLeft} days)');
      }
    }
    final low = pharmacy.lowStockMedicines;
    if (low.isNotEmpty) {
      print('LOW STOCK (at or below reorder level):');
      for (final m in low) {
        print('  ${cell(m.id, 6)}${cell(m.name, 22)}qty ${m.quantity}, reorder level ${m.reorderLevel}');
      }
    }
  }

  // Selling 
  int _quantityInCart(List<SaleItem> cart, Medicine medicine) {
    return cart
        .where((i) => i.medicine.id == medicine.id)
        .fold(0, (sum, i) => sum + i.quantity);
  }

  void _newSale() {
    print('\n--- NEW SALE ---');
    final cart = <SaleItem>[];

    while (true) {
      final id = readLine('Medicine ID (press Enter to finish): ');
      if (id.isEmpty) break;

      final medicine = pharmacy.findById(id);
      if (medicine == null) {
        print('  ! No medicine with ID "$id".');
        continue;
      }
      if (medicine.isExpired) {
        print('  ! ${medicine.name} is EXPIRED and cannot be sold.');
        continue;
      }
      final available = medicine.quantity - _quantityInCart(cart, medicine);
      if (available <= 0) {
        print('  ! ${medicine.name} is out of stock.');
        continue;
      }

      print('  ${medicine.name} - ${money(medicine.price)} each, $available available.');
      final qty = readInt('Quantity: ', min: 1, max: available);

      final existing = cart.where((i) => i.medicine.id == medicine.id).toList();
      if (existing.isEmpty) {
        cart.add(SaleItem(medicine, qty));
      } else {
        existing.first.quantity += qty;
      }
      print('  + Added $qty x ${medicine.name}');
    }

    if (cart.isEmpty) {
      print('No items added. Sale cancelled.');
      return;
    }

    final total = cart.fold(0.0, (sum, i) => sum + i.subtotal);
    print('\nItems in cart: ${cart.length}   Amount due: ${money(total)}');
    if (!confirm('Confirm and complete sale?')) {
      print('Sale cancelled. Stock was not changed.');
      return;
    }

    final sale = pharmacy.completeSale(_user.username, cart);
    _printReceipt(sale);
    for (final item in sale.items) {
      if (item.medicine.isLowStock) {
        print('  ! Low stock warning: ${item.medicine.name} now has ${item.medicine.quantity} left.');
      }
    }
  }

  void _printReceipt(Sale sale) {
    print('\n${line(44, '=')}');
    print('  ${pharmacy.name.toUpperCase()}');
    print('  RECEIPT');
    print(line(44, '='));
    print('  Receipt No : ${sale.id}');
    print('  Date/Time  : ${fmtDateTime(sale.time)}');
    print('  Served by  : ${sale.cashier}');
    print(line(44));
    print('  ${cell('Item', 20)}${cell('Qty', 5)}${cell('Price', 8)}Total');
    for (final item in sale.items) {
      final qty = item.quantity.toString();
      final price = item.unitPrice.toStringAsFixed(2);
      final sub = item.subtotal.toStringAsFixed(2);
      print('  ${cell(item.medicine.name, 20)}${cell(qty, 5)}${cell(price, 8)}$sub');
    }
    print(line(44));
    print('  TOTAL: ${money(sale.total)}');
    print(line(44, '='));
  }

  // Administrator functions
  void _addMedicine() {
    print('\n--- ADD NEW MEDICINE ---');
    final name = readText('Medicine name: ');
    final category = readText('Category: ');
    final price = readDouble('Unit price (NLe): ', min: 0.01);
    final quantity = readInt('Opening quantity: ');
    final reorder = readInt('Reorder level: ');
    DateTime expiry = readDate('Expiry date (YYYY-MM-DD): ');
    while (daysUntil(expiry) < 0) {
      print('  ! That date is in the past. Expired stock cannot be added.');
      expiry = readDate('Expiry date (YYYY-MM-DD): ');
    }
    final m = pharmacy.addMedicine(name, category, price, quantity, expiry,
        reorderLevel: reorder);
    print('  + Saved: ${m.id} - ${m.name}');
  }

  void _restock() {
    print('\n--- RESTOCK MEDICINE ---');
    final medicine = pharmacy.findById(readText('Medicine ID: '));
    if (medicine == null) {
      print('  ! Medicine not found.');
      return;
    }
    print('  ${medicine.name}: current quantity ${medicine.quantity}');
    final qty = readInt('Quantity received: ', min: 1);
    pharmacy.restock(medicine, qty);
    print('  + New quantity for ${medicine.name}: ${medicine.quantity}');
  }

  void _salesReport() {
    print('\n--- DAILY SALES REPORT (${fmtDate(DateTime.now())}) ---');
    final today = pharmacy.salesToday();
    if (today.isEmpty) {
      print('  No sales recorded today.');
      return;
    }

    var revenue = 0.0;
    var units = 0;
    final unitsByMedicine = <String, int>{};
    for (final sale in today) {
      revenue += sale.total;
      units += sale.unitsSold;
      print('  ${cell(sale.id, 8)}${cell(fmtDateTime(sale.time), 18)}'
          '${cell(sale.cashier, 10)}${money(sale.total)}');
      for (final item in sale.items) {
        final key = item.medicine.name;
        unitsByMedicine[key] = (unitsByMedicine[key] ?? 0) + item.quantity;
      }
    }
    final ranking = unitsByMedicine.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    print(line(60));
    print('  Transactions : ${today.length}');
    print('  Units sold   : $units');
    print('  Revenue      : ${money(revenue)}');
    print('  Top seller   : ${ranking.first.key} (${ranking.first.value} units)');
  }
}

// 5. ENTRY POINT
void main() {
  final pharmacy = Pharmacy('Salone Community Pharmacy');
  PharmaTrackApp(pharmacy).run();
}
