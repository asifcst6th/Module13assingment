import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const BMICalculatorApp());
}

class BMICalculatorApp extends StatelessWidget {
  const BMICalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const BMICalculatorPage(),
    );
  }
}

class BMICalculatorPage extends StatefulWidget {
  const BMICalculatorPage({super.key});

  @override
  State<BMICalculatorPage> createState() => _BMICalculatorPageState();
}

class _BMICalculatorPageState extends State<BMICalculatorPage> {

  final TextEditingController weightController = TextEditingController();
  String weightUnit = "kg";


  String heightUnit = "cm";
  final TextEditingController heightController = TextEditingController(); // for m or cm

  final TextEditingController feetController = TextEditingController();
  final TextEditingController inchController = TextEditingController();

  double? bmi;
  String resultText = "";
  Color resultColor = Colors.transparent;


  double poundsToKg(double lb) => lb * 0.45359237;

  double cmToMeters(double cm) => cm / 100;

  double feetInchToMeters(double ft, double inch) {
    final totalInches = (ft * 12) + inch;
    return totalInches * 0.0254;
  }


  void checkCategory(double bmiValue) {
    if (bmiValue < 18.5) {
      resultText = "Underweight";
      resultColor = Colors.blue;
    } else if (bmiValue < 25) {
      resultText = "Normal";
      resultColor = Colors.green;
    } else if (bmiValue < 30) {
      resultText = "Overweight";
      resultColor = Colors.orange;
    } else {
      resultText = "Obese";
      resultColor = Colors.red;
    }
  }


  void calculateBMI() {
    try {

      double weight = double.tryParse(weightController.text) ?? 0;
      if (weight == 0) {
        showMessage("Please enter weight");
        return;
      }
      if (weightUnit == "lb") weight = poundsToKg(weight);


      double heightM;
      if (heightUnit == "m") {
        heightM = double.tryParse(heightController.text) ?? 0;
      } else if (heightUnit == "cm") {
        heightM = cmToMeters(double.tryParse(heightController.text) ?? 0);
      } else {
        double ft = double.tryParse(feetController.text) ?? 0;
        double inch = double.tryParse(inchController.text) ?? 0;


        if (inch >= 12) {
          ft += (inch ~/ 12);
          inch = inch % 12;
          feetController.text = ft.toString();
          inchController.text = inch.toString();
        }

        heightM = feetInchToMeters(ft, inch);
      }

      if (heightM <= 0) {
        showMessage("Please enter height");
        return;
      }

      double bmiValue = weight / (heightM * heightM);

      setState(() {
        bmi = bmiValue;
        checkCategory(bmiValue);
      });
    } catch (e) {
      showMessage("Invalid input");
    }
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BMI Calculator"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text("Weight"),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: weightController,
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Enter weight"),
                  ),
                ),
                const SizedBox(width: 10),
                ToggleButtons(
                  isSelected: [weightUnit == "kg", weightUnit == "lb"],
                  onPressed: (index) {
                    setState(() {
                      weightUnit = index == 0 ? "kg" : "lb";
                    });
                  },
                  children: const [
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text("kg")),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text("lb")),
                  ],
                )
              ],
            ),

            const SizedBox(height: 20),

            const Text("Height"),
            const SizedBox(height: 5),
            ToggleButtons(
              isSelected: [
                heightUnit == "m",
                heightUnit == "cm",
                heightUnit == "ft"
              ],
              onPressed: (index) {
                setState(() {
                  heightUnit = ["m", "cm", "ft"][index];
                });
              },
              children: const [
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text("m")),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text("cm")),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text("ft + in")),
              ],
            ),

            const SizedBox(height: 10),

            if (heightUnit == "m" || heightUnit == "cm")
              TextField(
                controller: heightController,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: heightUnit == "m" ? "Enter meters" : "Enter cm"),
              ),

            if (heightUnit == "ft")
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: feetController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Feet",
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: inchController,
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Inches",
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 25),


            Center(
              child: ElevatedButton(
                onPressed: calculateBMI,
                style: ElevatedButton.styleFrom(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                ),
                child: const Text("Calculate BMI"),
              ),
            ),

            const SizedBox(height: 30),


            if (bmi != null)
              Card(
                color: resultColor.withOpacity(0.2),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Text(
                        "BMI: ${bmi!.toStringAsFixed(1)}",
                        style: const TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Chip(
                        label: Text(
                          resultText,
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: resultColor,
                      )
                    ],
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
