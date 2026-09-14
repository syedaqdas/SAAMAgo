import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_panel.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/app_state.dart';

class ListItemScreen extends StatefulWidget {
  const ListItemScreen({super.key, this.showAppBar = false});

  final bool showAppBar;

  @override
  State<ListItemScreen> createState() => _ListItemScreenState();
}

class _ListItemScreenState extends State<ListItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Bluetooth Speaker');
  final _descriptionController = TextEditingController(
    text: 'Portable speaker in good condition. Perfect sound quality.',
  );
  final _priceController = TextEditingController(text: '200');
  final _depositController = TextEditingController(text: '1000');
  final _locationController = TextEditingController(
    text: 'Indiranagar, Bengaluru',
  );
  String _category = 'Electronics';
  String _condition = 'Good';
  String _availability = 'Today';
  bool _delivery = true;
  bool _isLoading = false;
  String? _imagePath;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _depositController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _imagePath = image.path;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 750));
    if (!mounted) {
      return;
    }
    AppStateScope.of(context).publishItem(
      name: _nameController.text.trim(),
      category: _category,
      description: _descriptionController.text.trim(),
      price: int.parse(_priceController.text.trim()),
      deposit: int.parse(_depositController.text.trim()),
      condition: _condition,
      availability: _availability,
      delivery: _delivery,
      imagePath: _imagePath,
    );
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item published and added to Explore.')),
    );
    _formKey.currentState!.reset();
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _depositController.clear();
    _locationController.clear();
    setState(() => _imagePath = null);
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStateScope.of(context);
    final content = SafeArea(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            20,
            widget.showAppBar ? 8 : 12,
            20,
            widget.showAppBar ? 24 : 112,
          ),
          children: [
            if (!widget.showAppBar)
              const Text(
                'List Your Item',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
            if (!widget.showAppBar) const SizedBox(height: 18),
            SizedBox(
              height: 92,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _imagePath != null ? 1 : 4,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  if (_imagePath != null) {
                    return Stack(
                      children: [
                        Container(
                          width: 92,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                            image: DecorationImage(
                              image: FileImage(File(_imagePath!)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: -4,
                          top: -4,
                          child: IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.white),
                            onPressed: () => setState(() => _imagePath = null),
                          ),
                        ),
                      ],
                    );
                  }
                  final isAdd = index == 0;
                  return InkWell(
                    onTap: isAdd ? _pickImage : null,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 92,
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Icon(
                        isAdd
                            ? Icons.add_photo_alternate_rounded
                            : Icons.inventory_2_rounded,
                        color: isAdd
                            ? AppColors.lightPurple
                            : AppColors.secondaryText,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            AppPanel(
              child: Column(
                children: [
                  AppTextField(
                    controller: _nameController,
                    label: 'Item name',
                    icon: Icons.inventory_2_rounded,
                    validator: (value) =>
                        Validators.requiredText(value, 'Item name'),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: store.categories
                        .where((category) => category != 'All')
                        .map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        })
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _category = value ?? _category),
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    icon: Icons.notes_rounded,
                    maxLines: 3,
                    validator: (value) =>
                        Validators.requiredText(value, 'Description'),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _priceController,
                          label: 'Price per day',
                          icon: Icons.currency_rupee_rounded,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) =>
                              Validators.amount(value, 'Price'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          controller: _depositController,
                          label: 'Deposit',
                          icon: Icons.lock_rounded,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) =>
                              Validators.amount(value, 'Deposit'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _condition,
                    decoration: const InputDecoration(
                      labelText: 'Item condition',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Like New',
                        child: Text('Like New'),
                      ),
                      DropdownMenuItem(
                        value: 'Excellent',
                        child: Text('Excellent'),
                      ),
                      DropdownMenuItem(value: 'Good', child: Text('Good')),
                    ],
                    onChanged: (value) =>
                        setState(() => _condition = value ?? _condition),
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _locationController,
                    label: 'Pickup location',
                    icon: Icons.place_rounded,
                    validator: (value) =>
                        Validators.requiredText(value, 'Pickup location'),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _availability,
                    decoration: const InputDecoration(
                      labelText: 'Availability',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Today', child: Text('Today')),
                      DropdownMenuItem(
                        value: 'Tomorrow',
                        child: Text('Tomorrow'),
                      ),
                      DropdownMenuItem(
                        value: 'Weekend',
                        child: Text('Weekend'),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _availability = value ?? _availability),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: AppColors.primaryPurple,
                    title: const Text('Offer delivery option'),
                    value: _delivery,
                    onChanged: (value) => setState(() => _delivery = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              label: 'Publish Item',
              icon: Icons.publish_rounded,
              isLoading: _isLoading,
              onPressed: _publish,
            ),
          ],
        ),
      ),
    );

    if (!widget.showAppBar) {
      return content;
    }
    return Scaffold(
      appBar: AppBar(title: const Text('List Your Item')),
      body: content,
    );
  }
}
