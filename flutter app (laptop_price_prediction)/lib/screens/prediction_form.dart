import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import 'result_screen.dart';

class PredictionForm extends StatefulWidget {
  const PredictionForm({Key? key}) : super(key: key);

  @override
  State<PredictionForm> createState() => _PredictionFormState();
}

class _PredictionFormState extends State<PredictionForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  // Form controllers
  final _cpuFrequencyController = TextEditingController();
  final _ramController = TextEditingController();
  final _storageController = TextEditingController();
  final _screenSizeController = TextEditingController();
  final _weightController = TextEditingController();
  
  // Dropdown values
  String _selectedManufacturer = 'Dell';
  String _selectedScreen = 'LED';
  
  // Lists for dropdowns with user-friendly labels
  final List<String> _manufacturers = [
    'Apple', 'Acer', 'Dell', 'HP', 'Asus', 'Lenovo', 'Toshiba', 
    'Huawei', 'MSI', 'Samsung', 'Razer', 'Xiaomi'
  ];
  
  final List<String> _screenTypes = ['LED', 'IPS', 'Retina', 'OLED', 'LCD'];

  // Validation constants - matching API constraints
  final double _minCpuFrequency = 1.0;
  final double _maxCpuFrequency = 5.0;
  final double _minScreenSize = 10.0;
  final double _maxScreenSize = 50.0;
  final double _minRam = 2.0;
  final double _maxRam = 128.0;
  final double _minStorage = 128.0;
  final double _maxStorage = 8192.0;
  final double _minWeight = 0.5;
  final double _maxWeight = 5.0;

  @override
  void dispose() {
    _cpuFrequencyController.dispose();
    _ramController.dispose();
    _storageController.dispose();
    _screenSizeController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Create a map that matches the FastAPI LaptopFeatures model
        final laptopData = {
          "Manufacturer": _selectedManufacturer,
          "Screen": _selectedScreen,
          "Screen_Size_cm": double.parse(_screenSizeController.text),
          "CPU_frequency": double.parse(_cpuFrequencyController.text),
          "RAM_GB": double.parse(_ramController.text),
          "Storage_GB_SSD": double.parse(_storageController.text),
          "Weight_kg": double.parse(_weightController.text),
        };

        final apiService = ApiService();
        final predictedPrice = await apiService.predictPrice(laptopData);

        if (!mounted) return;
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              laptopData: laptopData,
              predictedPrice: predictedPrice,
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  String _getHelpText(String field) {
    switch (field) {
      case 'cpuFrequency':
        return 'Enter a value between $_minCpuFrequency and $_maxCpuFrequency GHz';
      case 'screenSize':
        return 'Enter a value between $_minScreenSize and $_maxScreenSize cm';
      case 'ram':
        return 'Enter a value between $_minRam and $_maxRam GB';
      case 'storage':
        return 'Enter a value between $_minStorage and $_maxStorage GB';
      case 'weight':
        return 'Enter a value between $_minWeight and $_maxWeight kg';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laptop Price Predictor'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter Laptop Specifications',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Manufacturer
                    _buildDropdownField(
                      label: 'Manufacturer',
                      value: _selectedManufacturer,
                      items: _manufacturers,
                      onChanged: (value) {
                        setState(() {
                          _selectedManufacturer = value!;
                        });
                      },
                      icon: Icons.laptop,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Screen Type
                    _buildDropdownField(
                      label: 'Screen Type',
                      value: _selectedScreen,
                      items: _screenTypes,
                      onChanged: (value) {
                        setState(() {
                          _selectedScreen = value!;
                        });
                      },
                      icon: Icons.monitor,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Screen Size
                    _buildTextField(
                      controller: _screenSizeController,
                      label: 'Screen Size (cm)',
                      helpText: _getHelpText('screenSize'),
                      prefixIcon: Icons.aspect_ratio,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter screen size';
                        }
                        final size = double.tryParse(value);
                        if (size == null) {
                          return 'Please enter a valid number';
                        }
                        if (size < _minScreenSize || size > _maxScreenSize) {
                          return 'Size must be between $_minScreenSize and $_maxScreenSize cm';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // CPU Frequency
                    _buildTextField(
                      controller: _cpuFrequencyController,
                      label: 'CPU Frequency (GHz)',
                      helpText: _getHelpText('cpuFrequency'),
                      prefixIcon: Icons.speed,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter CPU frequency';
                        }
                        final frequency = double.tryParse(value);
                        if (frequency == null) {
                          return 'Please enter a valid number';
                        }
                        if (frequency < _minCpuFrequency || frequency > _maxCpuFrequency) {
                          return 'Frequency must be between $_minCpuFrequency and $_maxCpuFrequency GHz';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // RAM
                    _buildTextField(
                      controller: _ramController,
                      label: 'RAM (GB)',
                      helpText: _getHelpText('ram'),
                      prefixIcon: Icons.memory_outlined,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter RAM amount';
                        }
                        final ram = double.tryParse(value);
                        if (ram == null) {
                          return 'Please enter a valid number';
                        }
                        if (ram < _minRam || ram > _maxRam) {
                          return 'RAM must be between $_minRam and $_maxRam GB';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Storage
                    _buildTextField(
                      controller: _storageController,
                      label: 'Storage (GB SSD)',
                      helpText: _getHelpText('storage'),
                      prefixIcon: Icons.storage,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter storage amount';
                        }
                        final storage = double.tryParse(value);
                        if (storage == null) {
                          return 'Please enter a valid number';
                        }
                        if (storage < _minStorage || storage > _maxStorage) {
                          return 'Storage must be between $_minStorage and $_maxStorage GB';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Weight
                    _buildTextField(
                      controller: _weightController,
                      label: 'Weight (kg)',
                      helpText: _getHelpText('weight'),
                      prefixIcon: Icons.line_weight,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter laptop weight';
                        }
                        final weight = double.tryParse(value);
                        if (weight == null) {
                          return 'Please enter a valid number';
                        }
                        if (weight < _minWeight || weight > _maxWeight) {
                          return 'Weight must be between $_minWeight and $_maxWeight kg';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Info text
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Enter the specifications to get a price prediction based on our trained machine learning model.',
                              style: TextStyle(color: Colors.blue.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Submit Button
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _submitForm,
                        icon: const Icon(Icons.calculate),
                        label: const Text('Predict Price'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String helpText,
    required IconData prefixIcon,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        helperText: helpText,
        helperMaxLines: 2,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      value: value,
      isExpanded: true,
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}