#include "scheduler_lib.h"
#include <string.h>

/* Internal Process struct — identical to scheduler.c */
typedef struct {
    int pid;
    int arrival;
    int burst;
    int priority;
    int remaining;
    int waiting;
    int turnaround;
    int finish;
    int completed;
} Process;

/* ── helpers ─────────────────────────────────────────────────────────── */

static void initProcesses(ProcessInput* in_, int n, Process* p) {
    for (int i = 0; i < n; i++) {
        p[i].pid        = in_[i].pid;
        p[i].arrival    = in_[i].arrival;
        p[i].burst      = in_[i].burst;
        p[i].priority   = in_[i].priority;
        p[i].remaining  = in_[i].burst;
        p[i].waiting    = 0;
        p[i].turnaround = 0;
        p[i].finish     = 0;
        p[i].completed  = 0;
    }
}

static void resetProcesses(Process p[], int n) {
    for (int i = 0; i < n; i++) {
        p[i].waiting    = 0;
        p[i].turnaround = 0;
        p[i].finish     = 0;
        p[i].completed  = 0;
        p[i].remaining  = p[i].burst;
    }
}

static void calculateMetrics(Process p[], int n) {
    for (int i = 0; i < n; i++) {
        p[i].turnaround = p[i].finish - p[i].arrival;
        p[i].waiting    = p[i].turnaround - p[i].burst;
    }
}

static void fillOutput(Process p[], int n, GanttEntry g[], int gLen, ScheduleOutput* out) {
    out->ganttLen     = gLen;
    out->processCount = n;
    for (int i = 0; i < gLen; i++) out->gantt[i] = g[i];

    float totalWT = 0, totalTAT = 0;
    for (int i = 0; i < n; i++) {
        out->results[i].pid        = p[i].pid;
        out->results[i].arrival    = p[i].arrival;
        out->results[i].burst      = p[i].burst;
        out->results[i].finish     = p[i].finish;
        out->results[i].waiting    = p[i].waiting;
        out->results[i].turnaround = p[i].turnaround;
        totalWT  += p[i].waiting;
        totalTAT += p[i].turnaround;
    }
    out->avgWT  = totalWT  / n;
    out->avgTAT = totalTAT / n;
}

/* ── FCFS ──────────────────────────────────────────────────────────────
   Same logic as scheduler.c → fcfs()                                    */
void run_fcfs(ProcessInput* inputs, int n, ScheduleOutput* output) {
    Process p[MAX_PROCESSES];
    initProcesses(inputs, n, p);
    GanttEntry g[MAX_GANTT];
    int gLen = 0, time = 0;

    for (int i = 0; i < n - 1; i++)
        for (int j = i + 1; j < n; j++)
            if (p[j].arrival < p[i].arrival) {
                Process tmp = p[i]; p[i] = p[j]; p[j] = tmp;
            }

    for (int i = 0; i < n; i++) {
        if (time < p[i].arrival) {
            g[gLen].pid   = -1;
            g[gLen].start = time;
            g[gLen].end   = p[i].arrival;
            gLen++;
            time = p[i].arrival;
        }
        g[gLen].pid   = p[i].pid;
        g[gLen].start = time;
        time         += p[i].burst;
        g[gLen].end   = time;
        gLen++;
        p[i].finish   = time;
    }

    calculateMetrics(p, n);
    fillOutput(p, n, g, gLen, output);
}

/* ── SJF Non-Preemptive ────────────────────────────────────────────────
   Same logic as scheduler.c → sjfNonPreemptive()                        */
void run_sjf(ProcessInput* inputs, int n, ScheduleOutput* output) {
    Process p[MAX_PROCESSES];
    initProcesses(inputs, n, p);
    GanttEntry g[MAX_GANTT];
    int gLen = 0, time = 0, completed = 0;

    while (completed < n) {
        int shortest = -1;
        for (int i = 0; i < n; i++) {
            if (!p[i].completed && p[i].arrival <= time) {
                if (shortest == -1 ||
                    p[i].burst < p[shortest].burst ||
                    (p[i].burst == p[shortest].burst && p[i].arrival < p[shortest].arrival))
                    shortest = i;
            }
        }
        if (shortest == -1) {
            int nxt = -1;
            for (int i = 0; i < n; i++)
                if (!p[i].completed && (nxt == -1 || p[i].arrival < nxt)) nxt = p[i].arrival;
            g[gLen].pid   = -1;
            g[gLen].start = time;
            g[gLen].end   = nxt;
            gLen++;
            time = nxt;
            continue;
        }
        g[gLen].pid   = p[shortest].pid;
        g[gLen].start = time;
        time         += p[shortest].burst;
        g[gLen].end   = time;
        gLen++;
        p[shortest].finish    = time;
        p[shortest].completed = 1;
        completed++;
    }

    calculateMetrics(p, n);
    fillOutput(p, n, g, gLen, output);
}

/* ── Round Robin ───────────────────────────────────────────────────────
   Same logic as scheduler.c → roundRobin()                              */
void run_round_robin(ProcessInput* inputs, int n, int quantum, ScheduleOutput* output) {
    Process p[MAX_PROCESSES];
    initProcesses(inputs, n, p);
    GanttEntry g[MAX_GANTT];
    int gLen = 0, time = 0, completed = 0;

    int queue[MAX_PROCESSES * MAX_GANTT];
    int head = 0, tail = 0;
    int inQueue[MAX_PROCESSES];
    memset(inQueue, 0, sizeof(inQueue));

    for (int i = 0; i < n; i++)
        if (p[i].arrival == 0) { queue[tail++ % (MAX_PROCESSES * MAX_GANTT)] = i; inQueue[i] = 1; }

    while (completed < n) {
        if (head == tail) {
            int nxt = -1;
            for (int i = 0; i < n; i++)
                if (!p[i].completed && !inQueue[i] && (nxt == -1 || p[i].arrival < nxt)) nxt = p[i].arrival;
            g[gLen].pid   = -1;
            g[gLen].start = time;
            g[gLen].end   = nxt;
            gLen++;
            time = nxt;
            for (int i = 0; i < n; i++)
                if (!p[i].completed && !inQueue[i] && p[i].arrival <= time) {
                    queue[tail++ % (MAX_PROCESSES * MAX_GANTT)] = i; inQueue[i] = 1;
                }
            continue;
        }

        int idx = queue[head++ % (MAX_PROCESSES * MAX_GANTT)];
        inQueue[idx] = 0;
        int execTime = (p[idx].remaining < quantum) ? p[idx].remaining : quantum;

        g[gLen].pid   = p[idx].pid;
        g[gLen].start = time;
        time         += execTime;
        g[gLen].end   = time;
        gLen++;
        p[idx].remaining -= execTime;

        for (int i = 0; i < n; i++)
            if (!p[i].completed && !inQueue[i] &&
                p[i].arrival > g[gLen-1].start && p[i].arrival <= time) {
                queue[tail++ % (MAX_PROCESSES * MAX_GANTT)] = i; inQueue[i] = 1;
            }

        if (p[idx].remaining == 0) {
            p[idx].finish = time; p[idx].completed = 1; completed++;
        } else {
            queue[tail++ % (MAX_PROCESSES * MAX_GANTT)] = idx; inQueue[idx] = 1;
        }
    }

    calculateMetrics(p, n);
    fillOutput(p, n, g, gLen, output);
}

/* ── Priority Non-Preemptive ───────────────────────────────────────────
   Same logic as scheduler.c → priorityNonPreemptive()                   */
void run_priority(ProcessInput* inputs, int n, ScheduleOutput* output) {
    Process p[MAX_PROCESSES];
    initProcesses(inputs, n, p);
    GanttEntry g[MAX_GANTT];
    int gLen = 0, time = 0, completed = 0;

    while (completed < n) {
        int best = -1;
        for (int i = 0; i < n; i++) {
            if (!p[i].completed && p[i].arrival <= time) {
                if (best == -1 ||
                    p[i].priority < p[best].priority ||
                    (p[i].priority == p[best].priority && p[i].arrival < p[best].arrival))
                    best = i;
            }
        }
        if (best == -1) {
            int nxt = -1;
            for (int i = 0; i < n; i++)
                if (!p[i].completed && (nxt == -1 || p[i].arrival < nxt)) nxt = p[i].arrival;
            g[gLen].pid   = -1;
            g[gLen].start = time;
            g[gLen].end   = nxt;
            gLen++;
            time = nxt;
            continue;
        }
        g[gLen].pid   = p[best].pid;
        g[gLen].start = time;
        time         += p[best].burst;
        g[gLen].end   = time;
        gLen++;
        p[best].finish    = time;
        p[best].completed = 1;
        completed++;
    }

    calculateMetrics(p, n);
    fillOutput(p, n, g, gLen, output);
}
