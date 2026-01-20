import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceWhite,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppTheme.surfaceWhite,
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.logoSage.withOpacity(0.1),
                      AppTheme.surfaceWhite,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.logoSage.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.crown, size: 48, color: AppTheme.logoSage),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Parrot Pro",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Text(
                    "Unlock your full potential",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 32),
                  _buildPlanCard(
                    context,
                    title: "Free Plan",
                    price: "₹0",
                    period: "/ month",
                    features: ["Basic Sign Translation", "Standard Voice Output", "Limited History"],
                    isPopular: false,
                    isCurrent: true,
                  ),
                  const SizedBox(height: 24),
                  _buildPlanCard(
                    context,
                    title: "Pro Plan",
                    price: "₹499",
                    period: "/ month",
                    features: [
                      "Unlimited Real-time Translation",
                      "AI Voice Consumer Cloning",
                      "Emotion Detection",
                      "Priority Support",
                      "Offline Mode"
                    ],
                    isPopular: true,
                    isCurrent: false,
                  ),
                  const SizedBox(height: 48),
                  const Text(
                    "Trusted by thousands of users worldwide for accessibility.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String price,
    required String period,
    required List<String> features,
    required bool isPopular,
    required bool isCurrent,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isPopular ? Border.all(color: AppTheme.logoSage, width: 2) : Border.all(color: Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryDark)),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(price, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: AppTheme.primaryDark)),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(period, style: TextStyle(fontSize: 16, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                ...features.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(LucideIcons.check, size: 20, color: isPopular ? AppTheme.logoSage : Colors.grey),
                          const SizedBox(width: 12),
                          Expanded(child: Text(f, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                        ],
                      ),
                    )),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isCurrent ? null : () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mock Payment Gateway Initiated")));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPopular ? AppTheme.logoSage : Colors.grey.shade100,
                      foregroundColor: isPopular ? Colors.white : AppTheme.primaryDark,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: isPopular ? 4 : 0,
                    ),
                    child: Text(
                      isCurrent ? "Current Plan" : "Upgrade Now",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isPopular)
            Positioned(
              top: -12,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.logoSage,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text("MOST POPULAR", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }
}
