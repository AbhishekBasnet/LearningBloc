import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// --- 1. EVENTS (The Actions) ---
// The only thing we can do is "Toggle" the colors.
abstract class ColorEvent {}

class ToggleColorsEvent extends ColorEvent {}

// --- 2. STATE (The Data) ---
// We hold two colors.
class ColorState {
  final Color firstColor;
  final Color secondColor;

  ColorState({required this.firstColor, required this.secondColor});
}

// --- 3. BLOC (The Logic) ---
class ColorBloc extends Bloc<ColorEvent, ColorState> {
  // Initial state: Red and Blue
  ColorBloc()
    : super(ColorState(firstColor: Colors.red, secondColor: Colors.blue)) {
    on<ToggleColorsEvent>((event, emit) {
      // Logic: Swap the colors or change them
      if (state.firstColor == Colors.red) {
        emit(ColorState(firstColor: Colors.green, secondColor: Colors.orange));
      } else {
        emit(ColorState(firstColor: Colors.red, secondColor: Colors.blue));
      }
    });
  }
}

// --- 4. THE UI ---
void main() {
  runApp(
    MaterialApp(
      home: BlocProvider(
        create: (_) => ColorBloc(),
        child: const TenBoxScreen(),
      ),
    ),
  );
}

class TenBoxScreen extends StatelessWidget {
  const TenBoxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print("SCAFFOLD REBUILT"); // Proof that the whole screen doesn't rebuild!

    return Scaffold(
      appBar: AppBar(title: const Text("BLoC Selective Rebuild")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // We generate 10 widgets, but only wrap specific ones
            for (int i = 0; i < 10; i++) ...[
              // --- WIDGET #1: USES BLOC BUILDER ---
              // Rebuilds whenever the state changes
              if (i == 0)
                BlocBuilder<ColorBloc, ColorState>(
                  builder: (context, state) {
                    print("Widget 1 Rebuilt");
                    return BoxWidget(index: i, color: state.firstColor);
                  },
                )
              // --- WIDGET #5: USES BLOC SELECTOR ---
              // Only rebuilds if 'secondColor' specifically changes
              else if (i == 4)
                BlocSelector<ColorBloc, ColorState, Color>(
                  selector: (state) => state.secondColor,
                  builder: (context, color) {
                    print("Widget 5 Rebuilt");
                    return BoxWidget(index: i, color: color);
                  },
                )
              // --- OTHER 8 WIDGETS: STATIC ---
              // These have NO listeners. They never rebuild.
              else
                const BoxWidget(index: -1, color: Colors.grey),

              const SizedBox(height: 5), // Spacing
            ],

            const SizedBox(height: 20),

            // Button to trigger the change
            ElevatedButton(
              onPressed: () {
                context.read<ColorBloc>().add(ToggleColorsEvent());
              },
              child: const Text("Change Colors"),
            ),
          ],
        ),
      ),
    );
  }
}

// Just a simple box to display color
class BoxWidget extends StatelessWidget {
  final int index;
  final Color color;

  const BoxWidget({super.key, required this.index, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 30,
      color: color,
      alignment: Alignment.center,
      child: Text(
        index == -1 ? "Static Widget" : "Active Widget #${index + 1}",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
