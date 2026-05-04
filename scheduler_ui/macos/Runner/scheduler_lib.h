#ifndef SCHEDULER_LIB_H
#define SCHEDULER_LIB_H

#define MAX_PROCESSES 100
#define MAX_GANTT     1000

#if defined(__APPLE__)
  #define EXPORT __attribute__((visibility("default"))) __attribute__((used))
#else
  #define EXPORT
#endif

typedef struct {
    int pid;
    int arrival;
    int burst;
    int priority;
} ProcessInput;

typedef struct {
    int pid;
    int start;
    int end;
} GanttEntry;

typedef struct {
    int pid;
    int arrival;
    int burst;
    int finish;
    int waiting;
    int turnaround;
} ProcessResult;

typedef struct {
    GanttEntry    gantt[MAX_GANTT];
    int           ganttLen;
    ProcessResult results[MAX_PROCESSES];
    int           processCount;
    float         avgWT;
    float         avgTAT;
} ScheduleOutput;

#ifdef __cplusplus
extern "C" {
#endif

EXPORT void run_fcfs(ProcessInput* inputs, int n, ScheduleOutput* output);
EXPORT void run_sjf(ProcessInput* inputs, int n, ScheduleOutput* output);
EXPORT void run_round_robin(ProcessInput* inputs, int n, int quantum, ScheduleOutput* output);
EXPORT void run_priority(ProcessInput* inputs, int n, ScheduleOutput* output);

#ifdef __cplusplus
}
#endif

#endif /* SCHEDULER_LIB_H */
