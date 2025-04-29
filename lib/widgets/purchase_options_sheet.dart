import 'package:flutter/material.dart';
import 'package:nft_once/pages/shop_detail.dart';

class PurchaseOptionsSheet extends StatefulWidget {
  final String imageUrl;
  final String price;
  final String name;
  // Add other necessary parameters like specs, etc.

  const PurchaseOptionsSheet({
    Key? key,
    required this.imageUrl,
    required this.price,
    required this.name,
  }) : super(key: key);

  @override
  _PurchaseOptionsSheetState createState() => _PurchaseOptionsSheetState();
}

class _PurchaseOptionsSheetState extends State<PurchaseOptionsSheet> {
  String? selectedSpec; // Example state for selected spec
  int quantity = 1; // Example state for quantity

  // Example specs data (replace with actual data)
  final List<String> specs = [];

  @override
  Widget build(BuildContext context) {
    // Build the UI based on the provided image
    // This is a placeholder implementation
    return Container(
      padding: const EdgeInsets.all(8.0),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7, // 限制最大高度为屏幕高度的70%
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Top section with image, price, stock, close button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(widget.imageUrl,
                  width: 80, height: 80, fit: BoxFit.cover),
              const SizedBox(width: 30),
              Expanded(
                  child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${widget.name}',
                        style: TextStyle(
                            fontSize: 16,
                            color: const Color.fromRGBO(0, 0, 0, 0.7),
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('¥ ${widget.price}',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red)),
                    const SizedBox(height: 4),
                  ],
                ),
              )),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          // Spec selection
          // Text('规格',
          //     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          // const SizedBox(height: 8),
          // Wrap(
          //   spacing: 8.0,
          //   runSpacing: 8.0,
          //   children: specs.map((spec) {
          //     bool isSelected = selectedSpec == spec;
          //     return ChoiceChip(
          //       label: Text(spec),
          //       selected: isSelected,
          //       onSelected: (selected) {
          //         setState(() {
          //           selectedSpec = selected ? spec : null;
          //         });
          //       },
          //       selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
          //       labelStyle: TextStyle(
          //           color: isSelected
          //               ? Theme.of(context).primaryColor
          //               : Colors.black),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(4),
          //         side: BorderSide(
          //             color: isSelected
          //                 ? Theme.of(context).primaryColor
          //                 : Colors.grey.shade300),
          //       ),
          //       backgroundColor: Colors.white,
          //       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          //     );
          //   }).toList(),
          // ),
          const SizedBox(height: 8),
          // Text('* 餐具配置: 1磅/5人份, 1.5磅/10人份, 2磅/10人份, 3磅/15人份, 5磅/20人份',
          //     style: TextStyle(fontSize: 12, color: Colors.grey)),
          // const Divider(),
          // Quantity selection
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('购买数量',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline,
                        color: quantity > 1 ? Colors.black : Colors.grey),
                    onPressed:
                        quantity > 1 ? () => setState(() => quantity--) : null,
                  ),
                  Text('$quantity',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline),
                    onPressed: () => setState(() => quantity++),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          // Confirm button
          SafeArea(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size.fromHeight(52),
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  print('Selected Spec: $selectedSpec, Quantity: $quantity');
                  Navigator.pop(context);
                },
                child: const Text('确认',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
