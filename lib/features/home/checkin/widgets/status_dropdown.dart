import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatusDropdown extends StatelessWidget {
  const StatusDropdown({super.key,
    required this.options,
    required this.defaultValue,
    required this.onChanged});

  final List<Widget> options;
  final int? defaultValue;
  final Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    var selectedIndex = defaultValue ?? 0;
    return BlocProvider(
      create: (context) =>
      DropdownStatusCubit()
        ..initData(selectedIndex),
      child: BlocBuilder<DropdownStatusCubit, int>(
        builder: (c, s) {
          var cubit = BlocProvider.of<DropdownStatusCubit>(c);
          return DropdownButton<int>(
            value: cubit.selectedIndex,
            underline: const SizedBox(),
            isExpanded: true,
              dropdownColor: Colors.white,
            icon: const Icon(Icons.arrow_drop_down),
            items: List.generate(
              options.length,
                  (index) =>
                  DropdownMenuItem<int>(
                    value: index,
                    child: Container(
                        color: cubit.selectedIndex == index
                            ? Colors.transparent
                            : Colors.transparent
                        ,child: Center(child: options[index])),
                  ),
            ),
            onChanged: (value) {
              cubit.onChanged(value!);
              onChanged(value);
            },
          );
        },
      ),
    );
  }
}

class DropdownStatusCubit extends Cubit<int> {
  DropdownStatusCubit() : super(0);

  int selectedIndex = 0;

  initData(int defaultIndex) {
    selectedIndex = defaultIndex;
  }

  onChanged(int newIndex) {
    selectedIndex = newIndex;
    emit(state + 1);
  }
}
