import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/services/user_repository.dart';
import '../../shared/data/user_model.dart';

class PaymentMethodsScreen extends ConsumerStatefulWidget {
  final UserModel user;

  const PaymentMethodsScreen({super.key, required this.user});

  @override
  ConsumerState<PaymentMethodsScreen> createState() =>
      _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends ConsumerState<PaymentMethodsScreen> {
  // Simple map for now: "Cash": true, "UPI": "upi_id"

  Future<void> _toggleCash(bool value) async {
    final updatedMethods = Map<String, dynamic>.from(
      widget.user.paymentMethods,
    );
    updatedMethods['Cash'] = value;
    await ref
        .read(userRepositoryProvider)
        .updatePaymentMethods(widget.user.id, updatedMethods);
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userStreamProvider(widget.user.id));

    return Scaffold(
      appBar: AppBar(title: const Text('Payment Methods')),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('User not found'));

          final isCashEnabled = user.paymentMethods['Cash'] == true;

          return ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              SwitchListTile(
                title: const Text('Cash on Delivery'),
                subtitle: const Text('Pay cash when ride ends'),
                secondary: const Icon(Icons.money),
                value: isCashEnabled,
                onChanged: _toggleCash,
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Add New Method'),
                subtitle: const Text('Credit Card / UPI (Coming Soon)'),
                onTap: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Coming Soon')));
                },
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
