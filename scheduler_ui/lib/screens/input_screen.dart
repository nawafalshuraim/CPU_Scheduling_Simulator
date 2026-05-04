import 'package:flutter/material.dart';
import '../models/models.dart';
import '../ffi/scheduler_bindings.dart';
import 'results_screen.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  int       _numProcesses     = 3;
  Algorithm _algorithm        = Algorithm.fcfs;
  final     _quantumCtrl      = TextEditingController(text: '2');

  // _ctrl[i] = [arrival, burst, priority]
  late List<List<TextEditingController>> _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = _buildControllers(3);
  }

  List<List<TextEditingController>> _buildControllers(int count) =>
      List.generate(count, (i) => [
            TextEditingController(text: '${i == 0 ? 0 : i}'),
            TextEditingController(text: '${(i + 1) * 2}'),
            TextEditingController(text: '${i + 1}'),
          ]);

  void _setCount(int n) {
    if (n < 1 || n > 20) return;
    final old = _ctrl;
    _ctrl = List.generate(n, (i) => i < old.length ? old[i] : [
          TextEditingController(text: '${i == 0 ? 0 : i}'),
          TextEditingController(text: '${(i + 1) * 2}'),
          TextEditingController(text: '${i + 1}'),
        ]);
    if (n < old.length) {
      for (int i = n; i < old.length; i++) {
        for (final c in old[i]) c.dispose();
      }
    }
    setState(() => _numProcesses = n);
  }

  @override
  void dispose() {
    for (final row in _ctrl) {
      for (final c in row) c.dispose();
    }
    _quantumCtrl.dispose();
    super.dispose();
  }

  // ── validation & run ──────────────────────────────────────────────────

  void _run() {
    final processes = <ProcessInput>[];

    for (int i = 0; i < _numProcesses; i++) {
      final arrival  = int.tryParse(_ctrl[i][0].text.trim());
      final burst    = int.tryParse(_ctrl[i][1].text.trim());
      final priority = int.tryParse(_ctrl[i][2].text.trim()) ?? 0;

      if (arrival == null || arrival < 0) {
        _err('P${i + 1}: Arrival time must be ≥ 0'); return;
      }
      if (burst == null || burst <= 0) {
        _err('P${i + 1}: Burst time must be > 0'); return;
      }

      processes.add(ProcessInput(
        pid:      i + 1,
        arrival:  arrival,
        burst:    burst,
        priority: priority,
      ));
    }

    int quantum = 1;
    if (_algorithm == Algorithm.roundRobin) {
      quantum = int.tryParse(_quantumCtrl.text.trim()) ?? 0;
      if (quantum <= 0) { _err('Quantum must be > 0'); return; }
    }

    final output = SchedulerBindings.run(_algorithm, processes, quantum: quantum);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultsScreen(
          output:    output,
          algorithm: _algorithm,
          quantum:   quantum,
        ),
      ),
    );
  }

  void _err(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: const Color(0xFFFF6B6B)),
    );
  }

  // ── build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _Sidebar(
            selected:   _algorithm,
            onSelected: (a) => setState(() => _algorithm = a),
          ),
          Expanded(
            child: Column(
              children: [
                _Header(algorithm: _algorithm, numProcesses: _numProcesses),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProcessCountRow(
                          count: _numProcesses,
                          onDecrement: () => _setCount(_numProcesses - 1),
                          onIncrement: () => _setCount(_numProcesses + 1),
                        ),
                        const SizedBox(height: 20),
                        _ProcessTable(
                          count: _numProcesses,
                          controllers: _ctrl,
                        ),
                        const SizedBox(height: 28),
                        _AlgorithmPicker(
                          selected:   _algorithm,
                          onSelected: (a) => setState(() => _algorithm = a),
                        ),
                        if (_algorithm == Algorithm.roundRobin) ...[
                          const SizedBox(height: 20),
                          _QuantumRow(controller: _quantumCtrl),
                        ],
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _run,
                            icon:  const Icon(Icons.play_arrow_rounded),
                            label: const Text(
                              'Run Simulation',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4F8EF7),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── sub-widgets ─────────────────────────────────────────────────────────

class _Sidebar extends StatelessWidget {
  final Algorithm selected;
  final ValueChanged<Algorithm> onSelected;

  const _Sidebar({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      color: const Color(0xFF141927),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Image.asset('assets/logo.png', width: 52, height: 52),
          const SizedBox(height: 12),
          const Text(
            'CPU\nScheduler',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Simulator',
            style: TextStyle(color: Color(0xFF50C5A0), fontSize: 13),
          ),
          const SizedBox(height: 28),
          _item(Icons.view_timeline_rounded, 'FCFS',        Algorithm.fcfs),
          _item(Icons.sort_rounded,          'SJF',         Algorithm.sjf),
          _item(Icons.loop_rounded,          'Round Robin', Algorithm.roundRobin),
          _item(Icons.star_rounded,          'Priority',    Algorithm.priority),
          const Spacer(),
          const Divider(color: Color(0xFF2A3456)),
          Text(
            'Logic in C  ·  UI in Flutter',
            style: TextStyle(
              color: Colors.white.withOpacity(0.25),
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(IconData icon, String label, Algorithm algo) {
    final active = selected == algo;
    return GestureDetector(
      onTap: () => onSelected(algo),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin:  const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF4F8EF7).withOpacity(0.14) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: active
              ? Border.all(color: const Color(0xFF4F8EF7).withOpacity(0.35))
              : null,
        ),
        child: Row(
          children: [
            Icon(icon,
                color: active ? const Color(0xFF4F8EF7) : Colors.white30,
                size: 16),
            const SizedBox(width: 10),
            Text(label,
                style: TextStyle(
                  color: active ? const Color(0xFF4F8EF7) : Colors.white38,
                  fontSize: 13,
                  fontWeight:
                      active ? FontWeight.w600 : FontWeight.normal,
                )),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Algorithm algorithm;
  final int numProcesses;

  const _Header({required this.algorithm, required this.numProcesses});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFF1E2540),
        border: Border(bottom: BorderSide(color: Color(0xFF2A3456))),
      ),
      child: Row(
        children: [
          Text(
            algorithm.fullName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          _pill('$numProcesses Processes', const Color(0xFF4F8EF7)),
        ],
      ),
    );
  }

  Widget _pill(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.13),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(label,
            style: TextStyle(color: color, fontSize: 12)),
      );
}

class _ProcessCountRow extends StatelessWidget {
  final int count;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _ProcessCountRow({
    required this.count,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Number of Processes',
            style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        const SizedBox(width: 16),
        _StepBtn(Icons.remove, onDecrement),
        SizedBox(
          width: 44,
          child: Text('$count',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ),
        _StepBtn(Icons.add, onIncrement),
        const SizedBox(width: 10),
        Text('max 20',
            style: TextStyle(
                color: Colors.white.withOpacity(0.28), fontSize: 11)),
      ],
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepBtn(this.icon, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: const Color(0xFF252B3E),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF3A4A6B)),
        ),
        child: Icon(icon, color: Colors.white70, size: 15),
      ),
    );
  }
}

class _ProcessTable extends StatelessWidget {
  final int count;
  final List<List<TextEditingController>> controllers;

  const _ProcessTable({required this.count, required this.controllers});

  static const _colors = [
    Color(0xFF4F8EF7), Color(0xFF50C5A0), Color(0xFFFF9F43),
    Color(0xFFFF6B6B), Color(0xFFA29BFE), Color(0xFFFD79A8),
    Color(0xFF6C5CE7), Color(0xFF00CEC9), Color(0xFFE17055),
    Color(0xFF74B9FF),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // header row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            color: Color(0xFF1E2540),
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            border: Border(
              top:   BorderSide(color: Color(0xFF2A3456)),
              left:  BorderSide(color: Color(0xFF2A3456)),
              right: BorderSide(color: Color(0xFF2A3456)),
            ),
          ),
          child: const Row(
            children: [
              SizedBox(width: 44),
              SizedBox(width: 14),
              Expanded(child: _ColHeader('Arrival Time')),
              SizedBox(width: 12),
              Expanded(child: _ColHeader('Burst Time')),
              SizedBox(width: 12),
              Expanded(child: _ColHeader('Priority')),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C2335),
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(10)),
            border: Border.all(color: const Color(0xFF2A3456)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: count,
            separatorBuilder: (_, __) =>
                const Divider(color: Color(0xFF2A3456), height: 1),
            itemBuilder: (_, i) => Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _PidChip(i + 1, _colors[i % _colors.length]),
                  const SizedBox(width: 14),
                  Expanded(child: _Field(controllers[i][0], 'e.g. 0')),
                  const SizedBox(width: 12),
                  Expanded(child: _Field(controllers[i][1], 'e.g. 5')),
                  const SizedBox(width: 12),
                  Expanded(child: _Field(controllers[i][2], 'e.g. 1')),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ColHeader extends StatelessWidget {
  final String text;
  const _ColHeader(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600));
}

class _PidChip extends StatelessWidget {
  final int pid;
  final Color color;
  const _PidChip(this.pid, this.color);

  @override
  Widget build(BuildContext context) => Container(
        width: 44,
        height: 30,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        alignment: Alignment.center,
        child: Text('P$pid',
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.bold)),
      );
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  const _Field(this.ctrl, this.hint);

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 36,
        child: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
          ),
        ),
      );
}

class _AlgorithmPicker extends StatelessWidget {
  final Algorithm selected;
  final ValueChanged<Algorithm> onSelected;

  const _AlgorithmPicker(
      {required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Algorithm',
            style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: Algorithm.values
              .map((a) => _AlgoChip(
                    algo:       a,
                    isSelected: selected == a,
                    onTap:      () => onSelected(a),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _AlgoChip extends StatelessWidget {
  final Algorithm algo;
  final bool isSelected;
  final VoidCallback onTap;

  const _AlgoChip(
      {required this.algo, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color:  isSelected ? const Color(0xFF4F8EF7) : const Color(0xFF252B3E),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4F8EF7)
                : const Color(0xFF3A4A6B),
          ),
        ),
        child: Text(
          algo.displayName,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white54,
            fontSize: 13,
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _QuantumRow extends StatelessWidget {
  final TextEditingController controller;
  const _QuantumRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Time Quantum',
            style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        const SizedBox(width: 16),
        SizedBox(
          width: 100,
          height: 38,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(hintText: 'e.g. 2'),
          ),
        ),
      ],
    );
  }
}
