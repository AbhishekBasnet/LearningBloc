import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// --- 1. EVENTS (The Remote Control Buttons) ---
// We only have one action: Increment
abstract class CounterEvent {}

class IncrementPressed extends CounterEvent {}

class DecrementPressed extends CounterEvent {}

// --- 2. STATE (The Screen Display) ---
// The only data we care about is the number (int)
class CounterState {
  final int counterValue;
  CounterState({required this.counterValue});
}

// --- 3. BLOC (The Logic/Brain) ---
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  // Start with 0
  CounterBloc() : super(CounterState(counterValue: 0)) {
    // When "Increment" happens -> Add 1 -> Emit new number
    on<IncrementPressed>((event, emit) {
      emit(CounterState(counterValue: state.counterValue + 1));
    });

    // When "Decrement" happens -> Subtract 1 -> Emit new number
    on<DecrementPressed>((event, emit) {
      emit(CounterState(counterValue: state.counterValue - 1));
    });
  }
}

// --- 4. THE UI (The View) ---
void main() {
  runApp(const MaterialApp(home: CounterPage()));
}

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    // We wrap the screen in BlocProvider so the buttons and text can access the Bloc
    return BlocProvider(
      create: (context) => CounterBloc(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Simple Bloc Counter")),
        body: Center(
          // BlocBuilder listens for changes.
          // Whenever a new State is emitted, this 'builder' runs again.
          child: BlocBuilder<CounterBloc, CounterState>(
            builder: (context, state) {
              return Text(
                'Count: ${state.counterValue}',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // BUTTON 1: Add
            FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                // Send the "Increment" event to the Bloc
                context.read<CounterBloc>().add(IncrementPressed());
              },
            ),
            const SizedBox(height: 10),
            // BUTTON 2: Subtract
            FloatingActionButton(
              child: const Icon(Icons.remove),
              onPressed: () {
                // Send the "Decrement" event to the Bloc
                context.read<CounterBloc>().add(DecrementPressed());
              },
            ),
          ],
        ),
      ),
    );
  }
}
