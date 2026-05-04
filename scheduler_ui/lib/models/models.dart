enum Algorithm { fcfs, sjf, roundRobin, priority }

extension AlgorithmExt on Algorithm {
  String get displayName => switch (this) {
        Algorithm.fcfs        => 'FCFS',
        Algorithm.sjf         => 'SJF',
        Algorithm.roundRobin  => 'Round Robin',
        Algorithm.priority    => 'Priority',
      };

  String get fullName => switch (this) {
        Algorithm.fcfs        => 'First-Come-First-Served',
        Algorithm.sjf         => 'Shortest Job First',
        Algorithm.roundRobin  => 'Round Robin',
        Algorithm.priority    => 'Priority Scheduling',
      };
}

class ProcessInput {
  final int pid;
  final int arrival;
  final int burst;
  final int priority;

  const ProcessInput({
    required this.pid,
    required this.arrival,
    required this.burst,
    required this.priority,
  });
}

class GanttEntry {
  final int pid;
  final int start;
  final int end;

  const GanttEntry({required this.pid, required this.start, required this.end});
}

class ProcessResult {
  final int pid;
  final int arrival;
  final int burst;
  final int finish;
  final int waiting;
  final int turnaround;

  const ProcessResult({
    required this.pid,
    required this.arrival,
    required this.burst,
    required this.finish,
    required this.waiting,
    required this.turnaround,
  });
}

class ScheduleOutput {
  final List<GanttEntry> gantt;
  final List<ProcessResult> results;
  final double avgWT;
  final double avgTAT;

  const ScheduleOutput({
    required this.gantt,
    required this.results,
    required this.avgWT,
    required this.avgTAT,
  });
}
