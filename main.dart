import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

// FinTrust Digital Bank — runnable Flutter UI demo (no banking backend).
// Every name, account and transaction is fictional. No banking backend is used.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white, systemNavigationBarIconBrightness: Brightness.dark,
  ));
  runApp(const FinTrustApp());
}

class FinTrustApp extends StatelessWidget {
  const FinTrustApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinTrust Digital Bank • UI Prototype',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: FinTrustColors.surface,
        colorScheme: ColorScheme.fromSeed(seedColor: FinTrustColors.blue),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: FinTrustColors.ink,
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF6F8FD),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFE9EEF7))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: FinTrustColors.blue, width: 1.6)),
        ),
        dialogTheme: DialogThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      home: const BankingShell(),
    );
  }
}


class FinTrustColors {
  static const navy = Color(0xFF0A2451);
  static const blue = Color(0xFF2367E8);
  static const bright = Color(0xFF3F86FF);
  static const cyan = Color(0xFF47D8D8);
  static const pale = Color(0xFFEAF2FF);
  static const ink = Color(0xFF1A2C4A);
  static const muted = Color(0xFF7C8DA8);
  static const green = Color(0xFF0EAB83);
  static const surface = Color(0xFFF5F7FC);
  static const orange = Color(0xFFF4AA57);
}


enum BankingScreen {
  login, dashboard, accounts, history, transfer, beneficiaries, qr,
  bills, savings, spending, notifications, assistant, profile, settings,
}

class BankingShell extends StatefulWidget {
  const BankingShell({super.key});

  @override
  State<BankingShell> createState() => _BankingShellState();
}

class _BankingShellState extends State<BankingShell> {
  BankingScreen screen = BankingScreen.login;
  BankingScreen previousScreen = BankingScreen.dashboard;
  bool darkMode = false;
  bool balanceVisible = true;
  bool passwordVisible = false;
  bool biometricsBusy = false;
  final LocalAuthentication localAuth = LocalAuthentication();
  final loginUserController = TextEditingController(text: 'kavitha.rajan');
  final loginPassController = TextEditingController(text: '');
  int transactionFilter = 0;
  String chosenBeneficiary = 'Amal Perera';
  String billCategory = 'Electricity';
  final amountController = TextEditingController();
  final toAccountController = TextEditingController();
  final billAmountController = TextEditingController(text: '8500');
  final searchController = TextEditingController();

  @override
  void dispose() {
    loginUserController.dispose();
    loginPassController.dispose();
    amountController.dispose();
    toAccountController.dispose();
    billAmountController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void open(BankingScreen destination) {
    setState(() {
      if (screen != destination) previousScreen = screen;
      screen = destination;
    });
  }

  void back() => open(BankingScreen.dashboard);

  @override
  Widget build(BuildContext context) {
    final dark = darkMode;
    final appTheme = Theme.of(context);
    return Theme(
      data: appTheme.copyWith(
        scaffoldBackgroundColor: dark ? const Color(0xFF0A1830) : FinTrustColors.surface,
        colorScheme: ColorScheme.fromSeed(
          seedColor: FinTrustColors.blue,
          brightness: dark ? Brightness.dark : Brightness.light,
        ),
      ),
      child: Scaffold(
        appBar: screen == BankingScreen.login || screen == BankingScreen.dashboard ? null : _topBar(),
        body: SafeArea(top: screen != BankingScreen.login, child: _content()),
        bottomNavigationBar: screen == BankingScreen.login ? null : _bottomBar(),
      ),
    );
  }

  PreferredSizeWidget _topBar() {
    const titles = {
      BankingScreen.accounts: 'My Accounts',
      BankingScreen.history: 'Transaction History',
      BankingScreen.transfer: 'Money Transfer',
      BankingScreen.beneficiaries: 'Beneficiaries',
      BankingScreen.qr: 'Scan & Pay',
      BankingScreen.bills: 'Bill Payment',
      BankingScreen.savings: 'Savings Goals',
      BankingScreen.spending: 'Spending Analysis',
      BankingScreen.notifications: 'Notifications',
      BankingScreen.assistant: 'FinTrust AI Assistant',
      BankingScreen.profile: 'Profile & Security',
      BankingScreen.settings: 'Settings',
    };
    return AppBar(
      toolbarHeight: 66,
      titleSpacing: 4,
      backgroundColor: darkMode ? const Color(0xFF0B1D39) : Colors.white,
      title: Text(titles[screen] ?? 'FinTrust', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
        tooltip: 'Back to dashboard',
        onPressed: back,
      ),
      actions: [
        IconButton(
          onPressed: () => open(BankingScreen.notifications),
          icon: const Icon(Icons.notifications_none_rounded),
          tooltip: 'Notifications',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _bottomBar() {
    final selection = switch (screen) {
      BankingScreen.dashboard => 0,
      BankingScreen.accounts || BankingScreen.history => 1,
      BankingScreen.bills || BankingScreen.qr || BankingScreen.transfer || BankingScreen.beneficiaries => 2,
      BankingScreen.savings || BankingScreen.spending => 3,
      _ => 4,
    };
    const destinations = [
      NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
      NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet_rounded), label: 'Accounts'),
      NavigationDestination(icon: Icon(Icons.compare_arrows_outlined), selectedIcon: Icon(Icons.compare_arrows_rounded), label: 'Pay'),
      NavigationDestination(icon: Icon(Icons.track_changes_outlined), selectedIcon: Icon(Icons.track_changes_rounded), label: 'Goals'),
      NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view_rounded), label: 'More'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: darkMode ? const Color(0xFF132944) : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 22, offset: const Offset(0, -5))],
      ),
      child: NavigationBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        indicatorColor: darkMode ? FinTrustColors.navy : FinTrustColors.pale,
        height: 70,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: selection,
        destinations: destinations,
        onDestinationSelected: (index) => open([
          BankingScreen.dashboard, BankingScreen.accounts, BankingScreen.bills,
          BankingScreen.savings, BankingScreen.settings,
        ][index]),
      ),
    );
  }

  Widget _content() => switch (screen) {
        BankingScreen.login => _login(),
        BankingScreen.dashboard => _dashboard(),
        BankingScreen.accounts => _accounts(),
        BankingScreen.history => _history(),
        BankingScreen.transfer => _transfer(),
        BankingScreen.beneficiaries => _beneficiaries(),
        BankingScreen.qr => _qr(),
        BankingScreen.bills => _bills(),
        BankingScreen.savings => _savings(),
        BankingScreen.spending => _spending(),
        BankingScreen.notifications => _notifications(),
        BankingScreen.assistant => _assistant(),
        BankingScreen.profile => _profile(),
        BankingScreen.settings => _settings(),
      };

  Widget _scroll(List<Widget> children) => ListView(
        padding: const EdgeInsets.fromLTRB(19, 22, 19, 28),
        children: children,
      );

  Widget _card({required Widget child, EdgeInsets padding = const EdgeInsets.all(18)}) =>
      Container(
        margin: const EdgeInsets.only(bottom: 13),
        padding: padding,
        decoration: BoxDecoration(
          color: darkMode ? const Color(0xFF162944) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: darkMode ? Colors.white10 : const Color(0xFFEAF0F8)),
          boxShadow: [BoxShadow(color: FinTrustColors.navy.withOpacity(darkMode ? .05 : .045), blurRadius: 20, offset: const Offset(0, 7))],
        ),
        child: child,
      );

  Widget _headline(String text) => Padding(
        padding: const EdgeInsets.only(top: 9, bottom: 13),
        child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -.5)),
      );

  Widget _actionButton(String label, IconData icon, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          constraints: const BoxConstraints(minHeight: 91),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          decoration: BoxDecoration(
            color: darkMode ? const Color(0xFF172B48) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: darkMode ? Colors.white10 : const Color(0xFFEAF0FA)),
            boxShadow: [BoxShadow(color: FinTrustColors.navy.withOpacity(.035), blurRadius: 14, offset: const Offset(0, 5))],
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(color: darkMode ? const Color(0xFF243E66) : FinTrustColors.pale, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: darkMode ? Colors.white : FinTrustColors.blue, size: 22),
            ),
            const SizedBox(height: 9),
            Text(label, style: TextStyle(color: darkMode ? Colors.white : FinTrustColors.ink, fontSize: 11, fontWeight: FontWeight.w800), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
          ]),
        ),
      );

  Widget _mainButton(String label, VoidCallback action) => SizedBox(
        width: double.infinity,
        height: 54,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: FinTrustColors.blue,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: action,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
        ),
      );

  Widget _dataRow(String title, String detail, {IconData icon = Icons.receipt_long_rounded, String? trailing, VoidCallback? onTap}) =>
      ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 1, vertical: 5),
        leading: Container(
          width: 46, height: 46,
          decoration: BoxDecoration(color: darkMode ? const Color(0xFF253E63) : FinTrustColors.pale, borderRadius: BorderRadius.circular(15)),
          child: Icon(icon, color: darkMode ? Colors.white : FinTrustColors.blue, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
        subtitle: Text(detail, style: const TextStyle(fontSize: 11, color: FinTrustColors.muted)),
        trailing: trailing == null ? const Icon(Icons.chevron_right_rounded, size: 18) :
          Text(trailing, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: trailing.trim().startsWith('+') ? FinTrustColors.green : null)),
        onTap: onTap ?? () => _notice('This item uses demonstration data.'),
      );

  void _notice(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _brand({bool light = false}) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 43, height: 43,
        decoration: BoxDecoration(color: light ? Colors.white.withOpacity(.15) : FinTrustColors.pale, borderRadius: BorderRadius.circular(13)),
        child: Icon(Icons.account_balance_rounded, color: light ? Colors.white : FinTrustColors.blue, size: 24),
      ),
      const SizedBox(width: 11),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('FinTrust', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: light ? Colors.white : FinTrustColors.ink, height: 1)),
        const SizedBox(height: 4),
        Text('DIGITAL BANK', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 2, color: light ? Colors.white70 : FinTrustColors.muted)),
      ]),
    ],
  );

  Future<bool> _verifyBiometric(String reason) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      _notice('Device fingerprint / face authentication is available in the Android app, not Chrome.');
      return false;
    }
    if (biometricsBusy) return false;
    setState(() => biometricsBusy = true);
    try {
      final supported = await localAuth.isDeviceSupported();
      final capable = await localAuth.canCheckBiometrics;
      if (!supported || !capable) {
        _notice('This Android device does not support app biometric authentication.');
        return false;
      }
      // Android chooses the eligible enrolled fingerprint or face method.
      final verified = await localAuth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
      if (!verified) _notice('Authentication was cancelled or unsuccessful.');
      return verified;
    } on PlatformException catch (error) {
      _notice('Could not authenticate: ${error.message ?? error.code}. Check Android biometric settings.');
      return false;
    } on LocalAuthException catch (error) {
      _notice('Biometric confirmation unavailable (${error.code}). Enrol fingerprint or face unlock in Android Settings.');
      return false;
    } catch (_) {
      _notice('Authentication unavailable. Please enrol a biometric in Android Settings.');
      return false;
    } finally {
      if (mounted) setState(() => biometricsBusy = false);
    }
  }

  Future<void> _biometricLogin() async {
    final verified = await _verifyBiometric('Verify your identity to open the FinTrust demonstration');
    if (verified && mounted) open(BankingScreen.dashboard);
  }

  Future<void> _confirmPayment(String title, double amount) async {
    // Confirmation panel is explicit: users see the amount before the Android OS prompt.
    if (!mounted) return;
    final shouldVerify = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SafeArea(child: Container(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Center(child: Container(width: 42, height: 5, decoration: BoxDecoration(color: const Color(0xFFD7E0EF), borderRadius: BorderRadius.circular(6)))),
          const SizedBox(height: 23),
          Container(width: 64, height: 64, alignment: Alignment.center,
            decoration: const BoxDecoration(color: FinTrustColors.pale, shape: BoxShape.circle),
            child: const Icon(Icons.verified_user_rounded, color: FinTrustColors.blue, size: 34)),
          const SizedBox(height: 16),
          const Text('Security confirmation', textAlign: TextAlign.center,
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900, color: FinTrustColors.ink)),
          const SizedBox(height: 8),
          Text('Review and confirm your $title', textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: FinTrustColors.muted)),
          const SizedBox(height: 20),
          Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: FinTrustColors.surface, borderRadius: BorderRadius.circular(17)),
            child: Row(children: [
              const Text('Amount', style: TextStyle(color: FinTrustColors.muted)),
              const Spacer(),
              Text('LKR ${amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: FinTrustColors.ink)),
            ])),
          const SizedBox(height: 16),
          const Text('Your Android device will ask for an enrolled fingerprint or supported face authentication.',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: FinTrustColors.muted)),
          const SizedBox(height: 20),
          SizedBox(height: 52, child: FilledButton.icon(
            onPressed: () => Navigator.pop(sheetContext, true),
            icon: const Icon(Icons.fingerprint_rounded),
            label: Text(kIsWeb ? 'Continue to web demo' : 'Verify with device biometrics'),
          )),
          const SizedBox(height: 10),
          TextButton(onPressed: () => Navigator.pop(sheetContext, false), child: const Text('Cancel')),
          const SizedBox(height: 5),
          const Text('STUDENT UI PROTOTYPE • NO MONEY MOVES', textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: .8, color: FinTrustColors.muted)),
        ]),
      )),
    );
    if (shouldVerify != true || !mounted) return;
    if (kIsWeb) {
      // Explicit browser UI simulation; do not misrepresent as biometric success.
      _showDemoReceipt('$title (web UI only — no biometric check)', amount);
      return;
    }
    final verified = await _verifyBiometric('Confirm the FinTrust demo $title of LKR ${amount.toStringAsFixed(2)}');
    if (verified && mounted) _showDemoReceipt(title, amount);
  }

  Widget _login() => SingleChildScrollView(
    child: Column(children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(25, 56, 25, 73),
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF061D47), Color(0xFF154EAC), Color(0xFF267EE4)]),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
        ),
        child: Stack(children: [
          Positioned(right: -70, top: -85, child: Container(width: 230, height: 230,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white12, width: 35)))),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _brand(light: true),
            const SizedBox(height: 45),
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(color: Colors.white.withOpacity(.13), borderRadius: BorderRadius.circular(20)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.lock_outline_rounded, color: FinTrustColors.cyan, size: 15), SizedBox(width: 7),
                Text('SAFE. SIMPLE. YOURS.', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
              ])),
            const SizedBox(height: 15),
            const Text('Banking that fits\nyour life.', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900, height: 1.12, letterSpacing: -1.2)),
            const SizedBox(height: 10),
            const Text('Your money. Your goals. One simple place.', style: TextStyle(color: Color(0xFFD5E8FF), fontSize: 13)),
          ]),
        ]),
      ),
      Transform.translate(offset: const Offset(0, -30), child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _card(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('Welcome back', style: TextStyle(fontSize: 24, color: FinTrustColors.ink, fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          const Text('Sign in to your FinTrust experience', style: TextStyle(fontSize: 12, color: FinTrustColors.muted)),
          const SizedBox(height: 22),
          const Text('Username', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: FinTrustColors.ink)),
          const SizedBox(height: 8),
          TextField(controller: loginUserController, decoration: const InputDecoration(prefixIcon: Icon(Icons.person_outline_rounded), hintText: 'Enter username')),
          const SizedBox(height: 15),
          const Text('Password', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: FinTrustColors.ink)),
          const SizedBox(height: 8),
          TextField(controller: loginPassController, obscureText: !passwordVisible,
            decoration: InputDecoration(prefixIcon: const Icon(Icons.lock_outline_rounded), hintText: 'Enter password',
              suffixIcon: IconButton(onPressed: () => setState(() => passwordVisible = !passwordVisible),
                icon: Icon(passwordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined)))),
          const SizedBox(height: 18),
          _mainButton('Sign in • Demo account', () => open(BankingScreen.dashboard)),
          const SizedBox(height: 19),
          const Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('or verify your identity', style: TextStyle(fontSize: 11, color: FinTrustColors.muted))), Expanded(child: Divider())]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: biometricsBusy ? null : _biometricLogin,
              icon: const Icon(Icons.fingerprint_rounded, size: 23),
              label: const Text('Fingerprint', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: const BorderSide(color: Color(0xFFDCE7F6))),
            )),
            const SizedBox(width: 10),
            Expanded(child: OutlinedButton.icon(
              onPressed: biometricsBusy ? null : _biometricLogin,
              icon: const Icon(Icons.face_unlock_outlined, size: 23),
              label: const Text('Face unlock', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: const BorderSide(color: Color(0xFFDCE7F6))),
            )),
          ]),
          const SizedBox(height: 13),
          const Text('Android opens the system biometric prompt. The device chooses the eligible enrolled method.',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: FinTrustColors.muted)),
        ])),
      )),
      const Padding(padding: EdgeInsets.fromLTRB(24, 0, 24, 18), child: Text(
        'ACADEMIC DEMO • FICTIONAL ACCOUNTS • NO REAL TRANSACTIONS',
        textAlign: TextAlign.center, style: TextStyle(color: FinTrustColors.muted, fontSize: 10, fontWeight: FontWeight.w700))),
    ]),
  );

  Widget _dashboard() => _scroll([
    Row(children: [
      Container(width: 46, height: 46, alignment: Alignment.center,
        decoration: BoxDecoration(color: FinTrustColors.pale, borderRadius: BorderRadius.circular(15)),
        child: const Text('KR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: FinTrustColors.blue))),
      const SizedBox(width: 12),
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('GOOD TO SEE YOU AGAIN', style: TextStyle(color: FinTrustColors.muted, fontSize: 9, letterSpacing: 1.2, fontWeight: FontWeight.w800)),
        SizedBox(height: 3),
        Text('Hello, Kavitha 👋', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
      ])),
      Stack(children: [
        IconButton(onPressed: () => open(BankingScreen.notifications), icon: const Icon(Icons.notifications_none_rounded, size: 26), tooltip: 'Notifications'),
        const Positioned(top: 12, right: 12, child: CircleAvatar(radius: 4, backgroundColor: Color(0xFFFB746B))),
      ]),
    ]),
    const SizedBox(height: 20),
    Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF0C2A65), Color(0xFF1C5ECB), Color(0xFF347FF1)]),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: FinTrustColors.blue.withOpacity(.2), blurRadius: 24, offset: const Offset(0, 13))],
      ),
      child: Stack(children: [
        Positioned(top: -76, right: -65, child: Container(width: 190, height: 190,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white12, width: 32)))),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.account_balance_wallet_outlined, size: 17, color: Color(0xFFB4DBFF)),
            const SizedBox(width: 8),
            const Text('TOTAL AVAILABLE BALANCE', style: TextStyle(fontSize: 10, color: Color(0xFFDEECFF), fontWeight: FontWeight.w800, letterSpacing: 1)),
            const Spacer(),
            IconButton(onPressed: () => setState(() => balanceVisible = !balanceVisible),
              icon: Icon(balanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white), tooltip: 'Show or hide balance'),
          ]),
          const SizedBox(height: 14),
          Text(balanceVisible ? 'LKR 528,750.00' : 'LKR •••,•••',
            style: const TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: -.7)),
          const SizedBox(height: 11),
          const Row(children: [Icon(Icons.trending_up_rounded, color: FinTrustColors.cyan, size: 18), SizedBox(width: 5),
            Text('+ 4.2% this month', style: TextStyle(color: Color(0xFFBFECE4), fontWeight: FontWeight.w700, fontSize: 12))]),
          const SizedBox(height: 24),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: Colors.white.withOpacity(.13), borderRadius: BorderRadius.circular(12)),
            child: const Row(children: [Icon(Icons.verified_user_outlined, color: Colors.white, size: 18), SizedBox(width: 8),
              Text('Your finances, beautifully organised', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600))])),
        ]),
      ]),
    ),
    const SizedBox(height: 22),
    _headline('Quick actions'),
    Row(children: [
      Expanded(child: _actionButton('Transfer', Icons.send_rounded, () => open(BankingScreen.transfer))),
      const SizedBox(width: 10),
      Expanded(child: _actionButton('Pay Bills', Icons.receipt_long_rounded, () => open(BankingScreen.bills))),
      const SizedBox(width: 10),
      Expanded(child: _actionButton('Scan & Pay', Icons.qr_code_scanner_rounded, () => open(BankingScreen.qr))),
      const SizedBox(width: 10),
      Expanded(child: _actionButton('Accounts', Icons.account_balance_wallet_outlined, () => open(BankingScreen.accounts))),
    ]),
    const SizedBox(height: 16),
    Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(color: const Color(0xFFE8F8F6), borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: const Icon(Icons.auto_graph_rounded, color: FinTrustColors.green)),
        const SizedBox(width: 12),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('You are on track!', style: TextStyle(color: FinTrustColors.ink, fontWeight: FontWeight.w900, fontSize: 13)),
          SizedBox(height: 3),
          Text('Your savings goals are moving forward.', style: TextStyle(color: FinTrustColors.muted, fontSize: 11)),
        ])),
        IconButton(onPressed: () => open(BankingScreen.savings), icon: const Icon(Icons.arrow_forward_ios_rounded, size: 15)),
      ]),
    ),
    const SizedBox(height: 15),
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      _headline('Recent activity'),
      TextButton(onPressed: () => open(BankingScreen.history), child: const Text('View all')),
    ]),
    _card(child: Column(children: [
      _dataRow('Fund Transfer', 'Today · 09:42', icon: Icons.north_east_rounded, trailing: '- LKR 25,000'),
      const Divider(height: 1),
      _dataRow('Salary Credit', 'Yesterday · 16:20', icon: Icons.south_west_rounded, trailing: '+ LKR 120,000'),
      const Divider(height: 1),
      _dataRow('Electricity Bill', 'Earlier this month', icon: Icons.bolt_outlined, trailing: '- LKR 8,500'),
    ])),
    const Center(child: Padding(padding: EdgeInsets.only(top: 8), child: Text('STUDENT UI DEMO • SAMPLE TRANSACTIONS',
      style: TextStyle(color: FinTrustColors.muted, fontSize: 10, fontWeight: FontWeight.w700)))),
  ]);

  Widget _accounts() => _scroll([
        _accountCard('Savings Account', '•••• 4830', 'LKR 320,450.00', highlighted: true),
        _accountCard('Current Account', '•••• 2710', 'LKR 150,230.00'),
        _accountCard('Fixed Deposit', '•••• 6421', 'LKR 90,000.00'),
        _accountCard('Credit Card', '•••• 9875', 'LKR 125,000.00'),
      ]);

  Widget _accountCard(String name, String number, String amount, {bool highlighted = false}) =>
      InkWell(onTap: () => open(BankingScreen.history), child: Container(
        margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(color: highlighted ? FinTrustColors.blue :
          (darkMode ? const Color(0xFF12304F) : Colors.white), borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          CircleAvatar(backgroundColor: highlighted ? Colors.white24 : FinTrustColors.pale,
            child: Icon(Icons.account_balance, color: highlighted ? Colors.white : FinTrustColors.blue)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13,
              color: highlighted ? Colors.white : null)),
            Text(number, style: TextStyle(fontSize: 11, color: highlighted ? Colors.white70 : FinTrustColors.muted)),
            const SizedBox(height: 6),
            Text(amount, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
              color: highlighted ? Colors.white : null)),
          ])),
          Icon(Icons.chevron_right, color: highlighted ? Colors.white : FinTrustColors.muted),
        ]),
      ));

  Widget _history() {
    const transactions = [
      ('Fund Transfer', 'Today, 09:42', '- LKR 25,000', 0),
      ('Mobile Reload', 'Today, 08:15', '- LKR 1,000', 0),
      ('Salary Credit', 'Sample record', '+ LKR 120,000', 1),
      ('Utility Bill', 'Sample record', '- LKR 8,500', 0),
      ('Grocery Store', 'Sample record', '- LKR 4,250', 0),
      ('Restaurant', 'Sample record', '- LKR 2,800', 0),
    ];
    final filtered = transactions.where((t) => transactionFilter == 0 || (transactionFilter == 1 ? t.$4 == 1 : t.$4 == 0)).toList();
    return _scroll([
      SegmentedButton<int>(
        segments: const [ButtonSegment(value: 0, label: Text('All')), ButtonSegment(value: 1, label: Text('Income')), ButtonSegment(value: 2, label: Text('Expense'))],
        selected: {transactionFilter},
        onSelectionChanged: (value) => setState(() => transactionFilter = value.first),
      ),
      const SizedBox(height: 15),
      _card(child: Column(children: [
        for (final item in filtered) ...[
          _dataRow(item.$1, item.$2, trailing: item.$3,
            icon: item.$4 == 1 ? Icons.add_circle_outline : Icons.arrow_upward_rounded),
          const Divider(height: 1),
        ],
      ])),
    ]);
  }
  Widget _transfer() => _scroll([
        _headline('Transfer Type'),
        Row(children: [
          Expanded(child: _actionButton('To Account', Icons.swap_horiz, () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter sample account details below.'))))),
          const SizedBox(width: 10),
          Expanded(child: _actionButton('To Beneficiary', Icons.person_outline, () => open(BankingScreen.beneficiaries))),
          const SizedBox(width: 10),
          Expanded(child: _actionButton('To Mobile', Icons.phone_android, () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mobile transfers are a demonstration only.'))))),
        ]),
        const SizedBox(height: 16),
        _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('From Account', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          const SizedBox(height: 10),
          const Text('Savings Account – 4830    LKR 528,750.00', style: TextStyle(fontSize: 13)),
          const Divider(height: 26),
          const Text('To Beneficiary', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          const SizedBox(height: 10),
          OutlinedButton.icon(onPressed: () => open(BankingScreen.beneficiaries),
            icon: const Icon(Icons.person_outline), label: Text(chosenBeneficiary)),
          const SizedBox(height: 12),
          TextField(controller: toAccountController, keyboardType: TextInputType.number,
            decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'To Account (sample)', hintText: 'Enter account number')),
          const SizedBox(height: 12),
          TextField(controller: amountController, keyboardType: TextInputType.number,
            decoration: const InputDecoration(prefixText: 'LKR ', border: OutlineInputBorder(), labelText: 'Amount')),
          const SizedBox(height: 12),
          const TextField(decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'Add Note (Optional)')),
        ])),
        const SizedBox(height: 12),
        _mainButton('Review Transfer', _showTransferReview),
        const SizedBox(height: 10),
        const Text('This student prototype never sends money.', style: TextStyle(fontSize: 11, color: FinTrustColors.muted)),
      ]);

  void _showTransferReview() {
    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      _notice('Please enter a valid sample transfer amount.');
      return;
    }
    showDialog<void>(context: context, builder: (dialogContext) => AlertDialog(
      title: const Row(children: [Icon(Icons.fact_check_outlined, color: FinTrustColors.blue), SizedBox(width: 10), Text('Review transfer')]),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        _reviewLine('From', 'Savings •••• 4830'),
        _reviewLine('To', chosenBeneficiary),
        _reviewLine('Account', toAccountController.text.isEmpty ? '•••• 1234 (sample)' : toAccountController.text),
        const Divider(height: 22),
        _reviewLine('Total amount', 'LKR ${amount.toStringAsFixed(2)}', prominent: true),
        const SizedBox(height: 15),
        const Text('Next: biometric security confirmation. This is a sample transfer only.',
          style: TextStyle(color: FinTrustColors.muted, fontSize: 12)),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Edit')),
        FilledButton.icon(onPressed: () {
          Navigator.pop(dialogContext);
          _confirmPayment('transfer', amount);
        }, icon: const Icon(Icons.lock_outline_rounded, size: 17), label: const Text('Confirm securely')),
      ],
    ));
  }

  Widget _reviewLine(String label, String value, {bool prominent = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      Text(label, style: TextStyle(fontSize: 12, color: prominent ? FinTrustColors.ink : FinTrustColors.muted, fontWeight: prominent ? FontWeight.w800 : FontWeight.w400)),
      const Spacer(),
      Flexible(child: Text(value, textAlign: TextAlign.right, style: TextStyle(fontSize: prominent ? 17 : 12, fontWeight: FontWeight.w800))),
    ]),
  );

  void _showDemoReceipt(String title, double amount) {
    showDialog<void>(context: context, builder: (dialogContext) => AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(23, 29, 23, 12),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 80, height: 80, decoration: const BoxDecoration(color: Color(0xFFE1F8EF), shape: BoxShape.circle),
          child: const Icon(Icons.check_circle_rounded, color: FinTrustColors.green, size: 53)),
        const SizedBox(height: 16),
        const Text('Confirmation', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        const Text('Your sample activity is complete', style: TextStyle(color: FinTrustColors.muted, fontSize: 12)),
        const SizedBox(height: 18),
        Text('LKR ${amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900, color: FinTrustColors.ink)),
        const SizedBox(height: 9),
        Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 15),
        Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: FinTrustColors.pale, borderRadius: BorderRadius.circular(12)),
          child: const Text('DEMO RECEIPT — No real money was sent or paid.',
            textAlign: TextAlign.center, style: TextStyle(color: FinTrustColors.blue, fontSize: 11, fontWeight: FontWeight.w800))),
      ]),
      actions: [TextButton(onPressed: () {
        Navigator.pop(dialogContext);
        open(BankingScreen.dashboard);
      }, child: const Text('Back to dashboard'))],
    ));
  }

  Widget _beneficiaries() => _scroll([
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('My Beneficiaries', style: TextStyle(color: FinTrustColors.blue, fontWeight: FontWeight.bold)),
          TextButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Adding beneficiaries needs a secure backend.'))), child: const Text('New Beneficiary')),
        ]),
        for (final person in const [
          ('Amal Perera', 'Bank of Ceylon · ••••1234'),
          ('Nimal Silva', "People's Bank · ••••5678"),
          ('Family Account', 'Commercial Bank · ••••9876'),
          ('Rashmi Fernando', 'HNB Bank · ••••4321'),
        ])
          _card(child: _dataRow(person.$1, person.$2, icon: Icons.person,
            onTap: () { chosenBeneficiary = person.$1; open(BankingScreen.transfer); })),
        _mainButton('Add Beneficiary (Demo)', () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demonstration only — no beneficiary was added.')))),
      ]);

  Widget _qr() => _scroll([
        const SizedBox(height: 25),
        Center(child: Container(
          width: 230, height: 230,
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: FinTrustColors.pale, width: 5), borderRadius: BorderRadius.circular(18)),
          child: const Icon(Icons.qr_code_2_rounded, size: 190, color: Colors.black),
        )),
        const SizedBox(height: 20),
        const Text('Scan QR code to pay', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
        const Text('UI preview only — camera and payment processing are not connected.',
          textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: FinTrustColors.muted)),
        const SizedBox(height: 30),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _actionButton('Gallery', Icons.image_outlined, () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gallery access is not connected in this student demo.')))),
          _actionButton('Light', Icons.lightbulb_outline, () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Flashlight requires a device camera integration.')))),
        ]),
        const SizedBox(height: 26),
        _mainButton('Enter Manually', () => open(BankingScreen.transfer)),
      ]);

  Widget _bills() => _scroll([
        _headline('Choose a service'),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: .86,
          children: [
            _billIcon('Electricity', Icons.bolt), _billIcon('Water', Icons.water_drop_outlined),
            _billIcon('Telecom', Icons.call_outlined), _billIcon('TV & Internet', Icons.desktop_windows_outlined),
            _billIcon('Loan', Icons.account_balance_wallet_outlined), _billIcon('Insurance', Icons.shield_outlined),
            _billIcon('Education', Icons.school_outlined), _billIcon('Others', Icons.more_horiz),
          ],
        ),
        const SizedBox(height: 10),
        _headline('Recent Bills'),
        _card(child: Column(children: [
          _dataRow('CEB Electricity', 'Sample bill • Nov 2026', trailing: 'LKR 8,500', icon: Icons.bolt,
            onTap: () { setState(() => billCategory = 'Electricity'); _showBillDialog(); }),
          _dataRow('Dialog Mobile', 'Sample bill • Nov 2026', trailing: 'LKR 1,200', icon: Icons.phone_android,
            onTap: () { setState(() => billCategory = 'Telecom'); _showBillDialog(); }),
          _dataRow('SLT Broadband', 'Sample bill • Nov 2026', trailing: 'LKR 3,200', icon: Icons.wifi,
            onTap: () { setState(() => billCategory = 'TV & Internet'); _showBillDialog(); }),
        ])),
        const SizedBox(height: 10),
        _mainButton('Scan & Pay (UI)', () => open(BankingScreen.qr)),
      ]);

  Widget _billIcon(String label, IconData icon) => _actionButton(label, icon, () {
        setState(() => billCategory = label);
        _showBillDialog();
      });

  void _showBillDialog() => showDialog<void>(context: context, builder: (dialogContext) => AlertDialog(
    title: Text('Pay $billCategory'),
    content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Sample biller reference •••• 5678', style: TextStyle(color: FinTrustColors.muted, fontSize: 12)),
      const SizedBox(height: 14),
      TextField(controller: billAmountController, keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(labelText: 'Amount (LKR)', prefixIcon: Icon(Icons.payments_outlined))),
      const SizedBox(height: 13),
      const Text('After reviewing, you will be asked to confirm using the Android biometric prompt.',
        style: TextStyle(color: FinTrustColors.muted, fontSize: 11)),
    ]),
    actions: [
      TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
      FilledButton(onPressed: () {
        final value = double.tryParse(billAmountController.text);
        if (value == null || value <= 0) {
          _notice('Enter a valid sample bill amount.');
          return;
        }
        Navigator.pop(dialogContext);
        _showBillReview(value);
      }, child: const Text('Review details')),
    ],
  ));

  void _showBillReview(double amount) => showDialog<void>(context: context, builder: (dialogContext) => AlertDialog(
    title: const Text('Review bill payment'),
    content: Column(mainAxisSize: MainAxisSize.min, children: [
      _reviewLine('Biller', billCategory),
      _reviewLine('Reference', '•••• 5678'),
      _reviewLine('From', 'Savings •••• 4830'),
      const Divider(height: 22),
      _reviewLine('Amount', 'LKR ${amount.toStringAsFixed(2)}', prominent: true),
      const SizedBox(height: 12),
      const Text('This payment is simulated. You will now confirm your identity.',
        style: TextStyle(color: FinTrustColors.muted, fontSize: 12)),
    ]),
    actions: [
      TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Edit')),
      FilledButton.icon(onPressed: () {
        Navigator.pop(dialogContext);
        _confirmPayment('$billCategory bill payment', amount);
      }, icon: const Icon(Icons.lock_outline_rounded, size: 17), label: const Text('Confirm securely')),
    ],
  ));

  Widget _savings() => _scroll([
        _goalCard('Travel to Japan', 'LKR 250,000 / 500,000', .5, Icons.flight_outlined),
        Center(child: OutlinedButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demo goals cannot be saved.'))),
          icon: const Icon(Icons.add), label: const Text('Add New Goal (Demo)'))),
        const SizedBox(height: 12),
        _headline('Other Goals'),
        _goalCard('New Laptop', 'LKR 120,000 / 200,000', .6, Icons.computer_outlined),
        _goalCard('Emergency Fund', 'LKR 60,000 / 100,000', .6, Icons.savings_outlined),
      ]);

  Widget _goalCard(String title, String detail, double fraction, IconData icon) => _card(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _dataRow(title, detail, icon: icon, trailing: '${(fraction * 100).round()}%'),
          const SizedBox(height: 7),
          LinearProgressIndicator(value: fraction, minHeight: 9, borderRadius: BorderRadius.circular(10),
            color: FinTrustColors.blue, backgroundColor: FinTrustColors.pale),
          const SizedBox(height: 8),
        ]),
      );

  Widget _spending() => _scroll([
        Row(children: [
          Expanded(child: _actionButton('This Month', Icons.calendar_month, () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Showing sample monthly spending.'))))),
          const SizedBox(width: 12),
          Expanded(child: _actionButton('Last 3 Months', Icons.date_range, () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Historical spending data is not connected in this demo.'))))),
        ]),
        const SizedBox(height: 24),
        Center(child: SizedBox(
          width: 225, height: 225,
          child: Stack(alignment: Alignment.center, children: [
            CustomPaint(size: const Size(225, 225), painter: SpendingDonutPainter()),
            const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Total Spending', style: TextStyle(fontSize: 12)),
              Text('LKR 145,230', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            ]),
          ]),
        )),
        const SizedBox(height: 28),
        _card(child: Column(children: [
          _legend('Food & Dining', '32%', Colors.blue),
          _legend('Transport', '18%', Colors.teal),
          _legend('Shopping', '15%', Colors.orange),
          _legend('Bills & Utilities', '12%', Colors.purple),
          _legend('Others', '23%', Colors.grey),
        ])),
        _headline('Budget Progress'),
        const LinearProgressIndicator(value: .66, minHeight: 10, backgroundColor: FinTrustColors.pale, color: FinTrustColors.green),
        const SizedBox(height: 5),
        const Text('You are on track! (sample)', style: TextStyle(color: FinTrustColors.green, fontSize: 12)),
      ]);

  Widget _legend(String name, String value, Color color) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [
      CircleAvatar(radius: 5, backgroundColor: color),
      const SizedBox(width: 10),
      Expanded(child: Text(name, style: const TextStyle(fontSize: 13))),
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
    ]),
  );

  Widget _notifications() => _scroll([
        Wrap(spacing: 8, children: const [Chip(label: Text('All')), Chip(label: Text('Transactions')), Chip(label: Text('Security'))]),
        const SizedBox(height: 10),
        _card(child: Column(children: [
          _dataRow('Money Received', '+ LKR 25,000 from Amal Perera · 09:42', icon: Icons.account_balance_wallet_outlined),
          _dataRow('Bill Payment', 'Electricity bill paid · LKR 8,500 · 08:15', icon: Icons.receipt_long_outlined),
          _dataRow('Security Alert', 'New login from Colombo, Sri Lanka · Yesterday', icon: Icons.shield_outlined),
          _dataRow('Promotional Offer', 'Get 5% cashback on QR payments', icon: Icons.star_outline),
          _dataRow('Loan Update', 'Loan application is approved (sample)', icon: Icons.account_balance_outlined),
        ])),
      ]);

  Widget _assistant() => _scroll([
        const Text('Online · Simulated assistant', style: TextStyle(color: FinTrustColors.green, fontSize: 12)),
        const SizedBox(height: 18),
        _card(child: const Row(children: [
          Icon(Icons.smart_toy_outlined, color: FinTrustColors.blue),
          SizedBox(width: 12),
          Expanded(child: Text('Hello! I am your FinTrust demo assistant. How can I help you today?', style: TextStyle(fontSize: 13))),
        ])),
        const SizedBox(height: 15),
        for (final question in const ['Check my balance', 'Transfer money', 'Find nearest branch', 'Report lost card', 'General enquiry'])
          Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: OutlinedButton(
            onPressed: () {
              if (question == 'Check my balance') {
                open(BankingScreen.accounts);
              } else if (question == 'Transfer money') {
                open(BankingScreen.transfer);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$question: a real service is not connected.')));
              }
            },
            child: Text(question),
          )),
        const SizedBox(height: 22),
        const Text('This is preset navigation, not a real AI service.', textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: FinTrustColors.muted)),
      ]);

  Widget _profile() => _scroll([
    _card(child: Row(children: [
      Container(width: 59, height: 59, alignment: Alignment.center,
        decoration: BoxDecoration(color: FinTrustColors.pale, borderRadius: BorderRadius.circular(19)),
        child: const Text('KR', style: TextStyle(color: FinTrustColors.blue, fontSize: 20, fontWeight: FontWeight.w900))),
      const SizedBox(width: 14),
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Kavitha Rajan', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
        SizedBox(height: 3),
        Text('kavitha.demo@example.com', style: TextStyle(fontSize: 11, color: FinTrustColors.muted)),
        SizedBox(height: 7),
        Text('VERIFIED DEMO PROFILE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: FinTrustColors.green)),
      ])),
    ])),
    _headline('Security centre'),
    _card(child: Column(children: [
      _dataRow('Biometric authentication', 'Use your enrolled Android fingerprint / face',
        icon: Icons.fingerprint_rounded, onTap: () async {
          if (await _verifyBiometric('Test your FinTrust device biometric authentication')) {
            _notice('Android device authentication passed.');
          }
        }),
      const Divider(height: 1),
      _dataRow('Personal information', 'Fictional profile details', icon: Icons.person_outline_rounded),
      const Divider(height: 1),
      _dataRow('Security settings', 'Manage the demonstration', icon: Icons.shield_outlined,
        onTap: () => open(BankingScreen.settings)),
      const Divider(height: 1),
      _dataRow('Help & support', 'Contact the demo assistant', icon: Icons.support_agent_outlined,
        onTap: () => open(BankingScreen.assistant)),
    ])),
    const SizedBox(height: 8),
    _mainButton('Sign out', () => open(BankingScreen.login)),
  ]);

  Widget _settings() => _scroll([
    _headline('Appearance'),
    _card(child: SwitchListTile.adaptive(
      value: darkMode,
      onChanged: (value) => setState(() => darkMode = value),
      title: const Text('Dark appearance', style: TextStyle(fontWeight: FontWeight.w800)),
      subtitle: const Text('Switch the app between light and dark', style: TextStyle(fontSize: 12)),
      secondary: const Icon(Icons.dark_mode_outlined, color: FinTrustColors.blue),
    )),
    _headline('Security and privacy'),
    _card(child: Column(children: [
      _dataRow('Test fingerprint / face unlock', 'Opens the Android system prompt', icon: Icons.fingerprint_rounded, onTap: () async {
        if (await _verifyBiometric('Test your biometric security for FinTrust')) {
          _notice('Device verification succeeded.');
        }
      }),
      const Divider(height: 1),
      _dataRow('Login and authentication', 'No account credentials are stored in this demo', icon: Icons.lock_outline_rounded),
      const Divider(height: 1),
      _dataRow('Notifications', 'View sample alerts', icon: Icons.notifications_none_rounded,
        onTap: () => open(BankingScreen.notifications)),
    ])),
    _headline('Explore FinTrust'),
    _card(child: Column(children: [
      _dataRow('Spending analysis', 'Understand sample budgets', icon: Icons.donut_large_outlined,
        onTap: () => open(BankingScreen.spending)),
      const Divider(height: 1),
      _dataRow('AI Banking Assistant', 'Try preset demo help', icon: Icons.smart_toy_outlined,
        onTap: () => open(BankingScreen.assistant)),
      const Divider(height: 1),
      _dataRow('Profile & security', 'View sample profile', icon: Icons.person_outline_rounded,
        onTap: () => open(BankingScreen.profile)),
    ])),
    const SizedBox(height: 10),
    _mainButton('Log out', () => open(BankingScreen.login)),
  ]);
}


class SpendingDonutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(15, 15, size.width - 30, size.height - 30);
    const colors = [Colors.blue, Colors.teal, Colors.orange, Colors.purple, Colors.grey];
    const fractions = [.32, .18, .15, .12, .23];
    double start = -math.pi / 2;
    for (int i = 0; i < fractions.length; i++) {
      final sweep = math.pi * 2 * fractions[i];
      canvas.drawArc(rect, start, sweep, false,
        Paint()..color = colors[i]..style = PaintingStyle.stroke..strokeWidth = 28);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant SpendingDonutPainter oldDelegate) => false;
}
