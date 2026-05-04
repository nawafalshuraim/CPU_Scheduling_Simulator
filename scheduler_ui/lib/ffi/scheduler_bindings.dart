import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../models/models.dart';

// ── C struct mirrors ────────────────────────────────────────────────────

final class ProcessInputC extends Struct {
  @Int32() external int pid;
  @Int32() external int arrival;
  @Int32() external int burst;
  @Int32() external int priority;
}

final class GanttEntryC extends Struct {
  @Int32() external int pid;
  @Int32() external int start;
  @Int32() external int end;
}

final class ProcessResultC extends Struct {
  @Int32() external int pid;
  @Int32() external int arrival;
  @Int32() external int burst;
  @Int32() external int finish;
  @Int32() external int waiting;
  @Int32() external int turnaround;
}

final class ScheduleOutputC extends Struct {
  @Array(1000) external Array<GanttEntryC>    gantt;
  @Int32()     external int                   ganttLen;
  @Array(100)  external Array<ProcessResultC> results;
  @Int32()     external int                   processCount;
  @Float()     external double                avgWT;
  @Float()     external double                avgTAT;
}

// ── Native function typedefs ────────────────────────────────────────────

typedef _FcfsC    = Void Function(Pointer<ProcessInputC>, Int32, Pointer<ScheduleOutputC>);
typedef _FcfsDart = void Function(Pointer<ProcessInputC>, int,  Pointer<ScheduleOutputC>);

typedef _SjfC    = Void Function(Pointer<ProcessInputC>, Int32, Pointer<ScheduleOutputC>);
typedef _SjfDart = void Function(Pointer<ProcessInputC>, int,  Pointer<ScheduleOutputC>);

typedef _RRC    = Void Function(Pointer<ProcessInputC>, Int32, Int32, Pointer<ScheduleOutputC>);
typedef _RRDart = void Function(Pointer<ProcessInputC>, int,  int,   Pointer<ScheduleOutputC>);

typedef _PriorityC    = Void Function(Pointer<ProcessInputC>, Int32, Pointer<ScheduleOutputC>);
typedef _PriorityDart = void Function(Pointer<ProcessInputC>, int,  Pointer<ScheduleOutputC>);

// ── Bindings ────────────────────────────────────────────────────────────

class SchedulerBindings {
  static final _lib = DynamicLibrary.process();

  static final _runFcfs       = _lib.lookupFunction<_FcfsC,     _FcfsDart>    ('run_fcfs');
  static final _runSjf        = _lib.lookupFunction<_SjfC,      _SjfDart>     ('run_sjf');
  static final _runRoundRobin = _lib.lookupFunction<_RRC,       _RRDart>      ('run_round_robin');
  static final _runPriority   = _lib.lookupFunction<_PriorityC, _PriorityDart>('run_priority');

  static ScheduleOutput run(
    Algorithm algorithm,
    List<ProcessInput> processes, {
    int quantum = 1,
  }) {
    final n         = processes.length;
    final inputsPtr = calloc<ProcessInputC>(n);
    final outputPtr = calloc<ScheduleOutputC>();

    try {
      for (int i = 0; i < n; i++) {
        inputsPtr[i].pid      = processes[i].pid;
        inputsPtr[i].arrival  = processes[i].arrival;
        inputsPtr[i].burst    = processes[i].burst;
        inputsPtr[i].priority = processes[i].priority;
      }

      switch (algorithm) {
        case Algorithm.fcfs:
          _runFcfs(inputsPtr, n, outputPtr);
        case Algorithm.sjf:
          _runSjf(inputsPtr, n, outputPtr);
        case Algorithm.roundRobin:
          _runRoundRobin(inputsPtr, n, quantum, outputPtr);
        case Algorithm.priority:
          _runPriority(inputsPtr, n, outputPtr);
      }

      return _parse(outputPtr.ref);
    } finally {
      calloc.free(inputsPtr);
      calloc.free(outputPtr);
    }
  }

  static ScheduleOutput _parse(ScheduleOutputC out) {
    final gantt = <GanttEntry>[];
    for (int i = 0; i < out.ganttLen; i++) {
      final e = out.gantt[i];
      gantt.add(GanttEntry(pid: e.pid, start: e.start, end: e.end));
    }

    final results = <ProcessResult>[];
    for (int i = 0; i < out.processCount; i++) {
      final r = out.results[i];
      results.add(ProcessResult(
        pid:        r.pid,
        arrival:    r.arrival,
        burst:      r.burst,
        finish:     r.finish,
        waiting:    r.waiting,
        turnaround: r.turnaround,
      ));
    }

    return ScheduleOutput(
      gantt:   gantt,
      results: results,
      avgWT:   out.avgWT.toDouble(),
      avgTAT:  out.avgTAT.toDouble(),
    );
  }
}
