import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';

/// Shown after the user taps "Upgrade Now" on the Subscription screen.
/// Accepts a plan title and price from route extras.
class CheckoutScreen extends StatefulWidget {
  final String planTitle;
  final String planPrice;

  const CheckoutScreen({
    super.key,
    required this.planTitle,
    required this.planPrice,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedMethod = 0; // 0=UPI, 1=Card, 2=Netbanking
  bool _isProcessing = false;

  final _methods = [
    {'label': 'UPI / QR', 'icon': LucideIcons.qrCode},
    {'label': 'Credit / Debit Card', 'icon': LucideIcons.creditCard},
    {'label': 'Net Banking', 'icon': LucideIcons.landmark},
  ];

  final _cardNumberController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _upiController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardNameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    setState(() => _isProcessing = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppTheme.logoSage,
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.checkCircle, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const Text('Payment Successful!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.primaryDark)),
              const SizedBox(height: 12),
              Text(
                'Welcome to ${widget.planTitle}. You now have access to all premium features.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/main');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.logoSage,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                ),
                child: const Text('Start Using Parrot Pro',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundClean,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: const Text('Checkout',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order summary card
            _buildOrderSummary(),
            const SizedBox(height: 28),

            const Text('PAYMENT METHOD',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
            const SizedBox(height: 16),

            // Method selector
            Row(
              children: List.generate(_methods.length, (i) {
                final selected = _selectedMethod == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedMethod = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(right: i < _methods.length - 1 ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                      decoration: BoxDecoration(
                        color: selected ? AppTheme.logoSage.withOpacity(0.1) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected ? AppTheme.logoSage : Colors.grey.shade200,
                          width: selected ? 1.5 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _methods[i]['icon'] as IconData,
                            color: selected ? AppTheme.logoSage : Colors.grey.shade400,
                            size: 22,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            (_methods[i]['label'] as String).split(' ').first,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: selected ? AppTheme.logoSage : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // Payment form
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _selectedMethod == 0
                  ? _buildUpiForm()
                  : _selectedMethod == 1
                      ? _buildCardForm()
                      : _buildNetBankingForm(),
            ),

            const SizedBox(height: 32),

            // Security note
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.lock, size: 14, color: Colors.grey.shade400),
                const SizedBox(width: 6),
                Text('256-bit SSL Encrypted Payment',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
              ],
            ),
            const SizedBox(height: 24),

            // Pay button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _pay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryDark,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  shadowColor: AppTheme.logoSage.withOpacity(0.3),
                ),
                child: _isProcessing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Processing...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      )
                    : Text(
                        'Pay ${widget.planPrice}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.logoSage.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(LucideIcons.crown, color: AppTheme.logoSage, size: 22),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.planTitle,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.primaryDark)),
                  Text('Monthly Subscription',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                ],
              ),
              const Spacer(),
              Text(widget.planPrice,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.primaryDark)),
            ],
          ),
          const Divider(height: 32),
          _summaryRow('Subtotal', widget.planPrice),
          const SizedBox(height: 8),
          _summaryRow('GST (18%)', '₹89'),
          const SizedBox(height: 8),
          _summaryRow('Total', '₹588', bold: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
              fontSize: 14,
              color: bold ? AppTheme.primaryDark : Colors.grey.shade600,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            )),
        Text(value,
            style: TextStyle(
              fontSize: 14,
              color: bold ? AppTheme.primaryDark : Colors.grey.shade600,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            )),
      ],
    );
  }

  Widget _buildUpiForm() {
    return Container(
      key: const ValueKey('upi'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('UPI ID',
              style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primaryDark, fontSize: 14)),
          const SizedBox(height: 10),
          _field(_upiController, 'yourname@upi', LucideIcons.atSign),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Text('— or scan QR code —',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundClean,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Icon(LucideIcons.qrCode, size: 80, color: AppTheme.primaryDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardForm() {
    return Container(
      key: const ValueKey('card'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _field(_cardNumberController, 'Card Number', LucideIcons.creditCard,
              keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          _field(_cardNameController, 'Cardholder Name', LucideIcons.user),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _field(_expiryController, 'MM / YY', LucideIcons.calendar,
                    keyboardType: TextInputType.number),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _field(_cvvController, 'CVV', LucideIcons.lock,
                    keyboardType: TextInputType.number, obscure: true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNetBankingForm() {
    final banks = ['State Bank of India', 'HDFC Bank', 'ICICI Bank', 'Axis Bank', 'Kotak Bank'];
    return Container(
      key: const ValueKey('netbanking'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select your bank', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primaryDark)),
          const SizedBox(height: 12),
          ...banks.map(
            (bank) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.backgroundClean,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.landmark, size: 18, color: AppTheme.logoSage),
                  const SizedBox(width: 12),
                  Text(bank,
                      style: const TextStyle(fontWeight: FontWeight.w500, color: AppTheme.primaryDark)),
                  const Spacer(),
                  Icon(LucideIcons.chevronRight, size: 16, color: Colors.grey.shade400),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundClean,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          prefixIcon: Icon(icon, color: AppTheme.logoSage.withOpacity(0.5), size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primaryDark, fontSize: 14),
      ),
    );
  }
}
