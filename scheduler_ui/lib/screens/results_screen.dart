import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/gantt_chart.dart';

class ResultsScreen extends StatelessWidget {
  final ScheduleOutput output;
  final Algorithm      algorithm;
  final int            quantum;

  const ResultsScreen({
    super.key,
    required this.output,
    required this.algorithm,
    required this.quantum,
  });

  String get _title => algorithm == Algorithm.roundRobin
      ? '${algorithm.displayName}  (Quantum = $quantum)'
      : algorithm.fullName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF1E2540),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFF2A3456), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('Gantt Chart'),
            const SizedBox(height: 12),
            _ganttCard(),
            const SizedBox(height: 28),
            _sectionLabel('Process Results'),
            const SizedBox(height: 12),
            _resultsTable(),
            const SizedBox(height: 20),
            _metricsRow(),
          ],
        ),
      ),
    );
  }

  // ── section label ────────────────────────────────────────────────────

  Widget _sectionLabel(String text) => Row(
        children: [
          Container(
            width: 4, height: 18,
            decoration: BoxDecoration(
              color: const Color(0xFF4F8EF7),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(text,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
        ],
      );

  // ── gantt ────────────────────────────────────────────────────────────

  Widget _ganttCard() {
    final pids = output.gantt.map((e) => e.pid).toSet().toList()..sort();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2335),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A3456)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GanttChart(entries: output.gantt),
          const SizedBox(height: 14),
          Wrap(
            spacing: 14,
            runSpacing: 8,
            children: pids.map((pid) {
              final color = getProcessColor(pid);
              final label = pid == -1 ? 'IDLE' : 'P$pid';
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(
                      color: pid == -1
                          ? color.withOpacity(0.25)
                          : color.withOpacity(0.82),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(label,
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 12)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── results table ────────────────────────────────────────────────────

  Widget _resultsTable() {
    const headers = [
      'Process', 'Arrival', 'Burst', 'Finish', 'Waiting', 'Turnaround'
    ];
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C2335),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A3456)),
      ),
      child: Column(
        children: [
          // header
          Container(
            padding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF1E2540),
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(
                  bottom: BorderSide(color: Color(0xFF2A3456))),
            ),
            child: Row(
              children: headers
                  .map((h) => Expanded(
                        child: Text(h,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ))
                  .toList(),
            ),
          ),
          // rows
          ...output.results.asMap().entries.map((entry) {
            final i = entry.key;
            final r = entry.value;
            final color = getProcessColor(r.pid);
            return Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: i.isEven
                    ? Colors.transparent
                    : Colors.white.withOpacity(0.02),
                border: const Border(
                    bottom:
                        BorderSide(color: Color(0xFF252B3E))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                              color: color.withOpacity(0.35)),
                        ),
                        child: Text('P${r.pid}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: color,
                                fontSize: 13,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  _cell('${r.arrival}'),
                  _cell('${r.burst}'),
                  _cell('${r.finish}'),
                  Expanded(
                    child: Text('${r.waiting}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Color(0xFFFF9F43),
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                  ),
                  Expanded(
                    child: Text('${r.turnaround}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Color(0xFF50C5A0),
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _cell(String v) => Expanded(
        child: Text(v,
            textAlign: TextAlign.center,
            style:
                const TextStyle(color: Colors.white70, fontSize: 13)),
      );

  // ── metrics cards ────────────────────────────────────────────────────

  Widget _metricsRow() => Row(
        children: [
          Expanded(
            child: _MetricCard(
              label: 'Avg Waiting Time',
              value: output.avgWT.toStringAsFixed(2),
              color: const Color(0xFFFF9F43),
              icon:  Icons.hourglass_bottom_rounded,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _MetricCard(
              label: 'Avg Turnaround Time',
              value: output.avgTAT.toStringAsFixed(2),
              color: const Color(0xFF50C5A0),
              icon:  Icons.rotate_right_rounded,
            ),
          ),
        ],
      );
}

class _MetricCard extends StatelessWidget {
  final String  label;
  final String  value;
  final Color   color;
  final IconData icon;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2335),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 4),
              Text(value,
                  style: TextStyle(
                      color: color,
                      fontSize: 26,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
