 #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>
 
 #define MAX_PROCESSES 100
 #define MAX_GANTT     1000
 
 //Data Structures
 typedef struct {
     int pid;
     int arrival;
     int burst;
     int priority;       // Lower value = higher priority          */
     int remaining;      // To be used by the Round Robin                    */
     int waiting;
     int turnaround;
     int finish;
     int completed;
 } Process;
 
 // Gantt chart entry
 typedef struct {
     int pid;
     int start;
     int end;
 } GanttEntry;

 // Input Module
 
 // InputProcesses: reads and validates all process attributes.
 // Keeps prompting until a valid value is entered.
 void inputProcesses(Process p[], int *n) {
     do {
         printf("Enter number of processes (1-%d): ", MAX_PROCESSES);
         if (scanf("%d", n) != 1) { while (getchar() != '\n'); *n = -1; }
         if (*n <= 0 || *n > MAX_PROCESSES)
             printf("  [Error] Invalid number :( Please try again.\n");
     } while (*n <= 0 || *n > MAX_PROCESSES);
 
     for (int i = 0; i < *n; i++) {
         p[i].pid = i + 1;
 
         do {
             printf("  Arrival time  for P%d: ", p[i].pid);
             if (scanf("%d", &p[i].arrival) != 1) {
                 while (getchar() != '\n'); p[i].arrival = -1;
             }
             if (p[i].arrival < 0)
                 printf("  [Error] Arrival time must be >= 0.\n");
         } while (p[i].arrival < 0);
 
         do {
             printf("  Burst time    for P%d: ", p[i].pid);
             if (scanf("%d", &p[i].burst) != 1) {
                 while (getchar() != '\n'); p[i].burst = 0;
             }
             if (p[i].burst <= 0)
                 printf("  [Error] Burst time must be > 0.\n");
         } while (p[i].burst <= 0);
 
         printf("  Priority      for P%d (lower = higher priority): ", p[i].pid);
         if (scanf("%d", &p[i].priority) != 1) {
             while (getchar() != '\n'); p[i].priority = 0;
         }
 
         //initialise computed fields 
         p[i].waiting   = 0;
         p[i].turnaround = 0;
         p[i].finish    = 0;
         p[i].completed = 0;
         p[i].remaining = p[i].burst;
     }
 }
 
 // esetProcesses clears computed fields before each algorithm run
 void resetProcesses(Process p[], int n) {
     for (int i = 0; i < n; i++) {
         p[i].waiting    = 0;
         p[i].turnaround = 0;
         p[i].finish     = 0;
         p[i].completed  = 0;
         p[i].remaining  = p[i].burst;
     }
 }
 
 // Calculation Module
 
 // calculateMetrics derives WT and TAT from finish time
 //turnaround = finish - arrival
 //waiting = turnaround - burst

 void calculateMetrics(Process p[], int n) {
     for (int i = 0; i < n; i++) {
         p[i].turnaround = p[i].finish - p[i].arrival;
         p[i].waiting    = p[i].turnaround - p[i].burst;
     }
 }
 
    //Output Module
 
 // printGantt renders a text-based Gantt chart. 
 // It takes the array of GanttEntry items and draws the chart
 void printGantt(GanttEntry g[], int len) {
     // Top bar 
     printf("\nGantt Chart:\n +");
     for (int i = 0; i < len; i++) {
         int width = g[i].end - g[i].start;
         for (int w = 0; w < width * 4 - 1; w++) printf("-");
         printf("+");
     }
     // Process labels 
     printf("\n |");
     for (int i = 0; i < len; i++) {
         int width = g[i].end - g[i].start;
         int total = width * 4 - 1;
         char label[8];
         if (g[i].pid == -1) snprintf(label, sizeof(label), "IDLE");
         else                snprintf(label, sizeof(label), "P%d", g[i].pid);
         int llen = (int)strlen(label);
         int lpad = (total - llen) / 2;
         int rpad = total - llen - lpad;
         for (int k = 0; k < lpad; k++) printf(" ");
         printf("%s", label);
         for (int k = 0; k < rpad; k++) printf(" ");
         printf("|");
     }
     // Bottom bar 
     printf("\n +");
     for (int i = 0; i < len; i++) {
         int width = g[i].end - g[i].start;
         for (int w = 0; w < width * 4 - 1; w++) printf("-");
         printf("+");
     }
     // Time markers
     printf("\n %d", g[0].start);
     for (int i = 0; i < len; i++) {
         int width = g[i].end - g[i].start;
         printf("%*d", width * 4, g[i].end);
     }
     printf("\n");
 }
 
 // DisplayResults prints per-process table and averages
 void displayResults(Process p[], int n) {
     float totalWT = 0, totalTAT = 0;
 
     printf("\n%-10s %-10s %-10s %-10s %-10s %-12s\n",
            "Process", "Arrival", "Burst", "Finish", "Waiting", "Turnaround");
     printf("%-10s %-10s %-10s %-10s %-10s %-12s\n",
            "-------", "-------", "-----", "------", "-------", "----------");
 
     for (int i = 0; i < n; i++) {
         printf("P%-9d %-10d %-10d %-10d %-10d %-12d\n",
                p[i].pid, p[i].arrival, p[i].burst,
                p[i].finish, p[i].waiting, p[i].turnaround);
         totalWT  += p[i].waiting;
         totalTAT += p[i].turnaround;
     }
 
     printf("\n  Average Waiting Time   : %.2f\n", totalWT  / n);
     printf("  Average Turnaround Time: %.2f\n",  totalTAT / n);
 }
 
    // Scheduling Module
    // each algorithm follows the same pattern: 
    // call resetProcesses, simulate time moving forward, fill in GanttEntry slots, 
    // call printGantt, then calculateMetrics, then displayResults.
   
 
 // FCFS  
 void fcfs(Process p[], int n) {
     resetProcesses(p, n);
     GanttEntry g[MAX_GANTT];
     int gLen = 0, time = 0;
 
     // Sort by arrival time (selection sort) 
     for (int i = 0; i < n - 1; i++)
         for (int j = i + 1; j < n; j++)
             if (p[j].arrival < p[i].arrival) {
                 Process tmp = p[i]; p[i] = p[j]; p[j] = tmp;
             }
 
     for (int i = 0; i < n; i++) {
         if (time < p[i].arrival) {
             // CPU idle gap 
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
 
     printGantt(g, gLen);
     calculateMetrics(p, n);
     displayResults(p, n);
 }
 
 // SJF Non-Preemptive
 void sjfNonPreemptive(Process p[], int n) {
     resetProcesses(p, n);
     GanttEntry g[MAX_GANTT];
     int gLen = 0, time = 0, completed = 0;
 
     while (completed < n) {
         int shortest = -1;
 
         for (int i = 0; i < n; i++) {
             if (!p[i].completed && p[i].arrival <= time) {
                 if (shortest == -1 ||
                     p[i].burst < p[shortest].burst ||
                     (p[i].burst == p[shortest].burst &&
                      p[i].arrival < p[shortest].arrival)) {
                     shortest = i;
                 }
             }
         }
 
         if (shortest == -1) {
             // find next arrival and mark idle 
             int nextArrival = -1;
             for (int i = 0; i < n; i++)
                 if (!p[i].completed && (nextArrival == -1 || p[i].arrival < nextArrival))
                     nextArrival = p[i].arrival;
             g[gLen].pid   = -1;
             g[gLen].start = time;
             g[gLen].end   = nextArrival;
             gLen++;
             time = nextArrival;
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
 
     printGantt(g, gLen);
     calculateMetrics(p, n);
     displayResults(p, n);
 }
 
 // Round Robin 
 void roundRobin(Process p[], int n, int quantum) {
     resetProcesses(p, n);
     GanttEntry g[MAX_GANTT];
     int gLen = 0, time = 0, completed = 0;
 
     // Ready queue (circular) 
     int queue[MAX_PROCESSES * MAX_GANTT];
     int head = 0, tail = 0;
     int inQueue[MAX_PROCESSES];
     memset(inQueue, 0, sizeof(inQueue));
 
     // Enqueue processes that arrive at time 0 
     for (int i = 0; i < n; i++)
         if (p[i].arrival == 0) {
             queue[tail++ % (MAX_PROCESSES * MAX_GANTT)] = i;
             inQueue[i] = 1;
         }
 
     while (completed < n) {
         // If queue empty, advance time 
         if (head == tail) {
             int nextArrival = -1;
             for (int i = 0; i < n; i++)
                 if (!p[i].completed && !inQueue[i] &&
                     (nextArrival == -1 || p[i].arrival < nextArrival))
                     nextArrival = p[i].arrival;
             g[gLen].pid   = -1;
             g[gLen].start = time;
             g[gLen].end   = nextArrival;
             gLen++;
             time = nextArrival;
             for (int i = 0; i < n; i++)
                 if (!p[i].completed && !inQueue[i] && p[i].arrival <= time) {
                     queue[tail++ % (MAX_PROCESSES * MAX_GANTT)] = i;
                     inQueue[i] = 1;
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
 
         // Enqueue newly arrived processes during this slice 
         for (int i = 0; i < n; i++)
             if (!p[i].completed && !inQueue[i] &&
                 p[i].arrival > g[gLen-1].start && p[i].arrival <= time) {
                 queue[tail++ % (MAX_PROCESSES * MAX_GANTT)] = i;
                 inQueue[i] = 1;
             }
 
         if (p[idx].remaining == 0) {
             p[idx].finish    = time;
             p[idx].completed = 1;
             completed++;
         } else {
             // Re-enqueue 
             queue[tail++ % (MAX_PROCESSES * MAX_GANTT)] = idx;
             inQueue[idx] = 1;
         }
     }
 
     printGantt(g, gLen);
     calculateMetrics(p, n);
     displayResults(p, n);
 }
 
 // Non-Preemptive Priority 
 void priorityNonPreemptive(Process p[], int n) {
     resetProcesses(p, n);
     GanttEntry g[MAX_GANTT];
     int gLen = 0, time = 0, completed = 0;
 
     while (completed < n) {
         int best = -1;
 
         for (int i = 0; i < n; i++) {
             if (!p[i].completed && p[i].arrival <= time) {
                 if (best == -1 ||
                     p[i].priority < p[best].priority ||
                     (p[i].priority == p[best].priority &&
                      p[i].arrival  < p[best].arrival)) {
                     best = i;
                 }
             }
         }
 
         if (best == -1) {
             int nextArrival = -1;
             for (int i = 0; i < n; i++)
                 if (!p[i].completed && (nextArrival == -1 || p[i].arrival < nextArrival))
                     nextArrival = p[i].arrival;
             g[gLen].pid   = -1;
             g[gLen].start = time;
             g[gLen].end   = nextArrival;
             gLen++;
             time = nextArrival;
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
 
     printGantt(g, gLen);
     calculateMetrics(p, n);
     displayResults(p, n);
 }
 
    // Main
 int main(void) {
     Process processes[MAX_PROCESSES];
     int n, choice, quantum;
 
     printf("========================================\n");
     printf("   CPU Scheduling Simulator\n");
     printf("========================================\n\n");
 
     inputProcesses(processes, &n);
 
     do {
         printf("\n--- Algorithm Menu ---\n");
         printf("  1. FCFS (First-Come-First-Served)\n");
         printf("  2. SJF  (Non-Preemptive)\n");
         printf("  3. Round Robin\n");
         printf("  4. Priority (Non-Preemptive)\n");
         printf("  5. Exit\n");
         printf("Choose: ");
         if (scanf("%d", &choice) != 1) { while (getchar() != '\n'); choice = -1; }
 
         switch (choice) {
             case 1:
                 printf("\n[FCFS Scheduling]\n");
                 fcfs(processes, n);
                 break;
             case 2:
                 printf("\n[SJF Non-Preemptive Scheduling]\n");
                 sjfNonPreemptive(processes, n);
                 break;
             case 3:
                 do {
                     printf("Enter time quantum (> 0): ");
                     if (scanf("%d", &quantum) != 1) {
                         while (getchar() != '\n'); quantum = 0;
                     }
                     if (quantum <= 0) printf("  [Error] Quantum must be > 0.\n");
                 } while (quantum <= 0);
                 printf("\n[Round Robin Scheduling | Quantum = %d]\n", quantum);
                 roundRobin(processes, n, quantum);
                 break;
             case 4:
                 printf("\n[Priority (Non-Preemptive) Scheduling]\n");
                 priorityNonPreemptive(processes, n);
                 break;
             case 5:
                 printf("Done!\n");
                 break;
             default:
                 printf("  [Error] Invalid choice. Try again.\n");
         }
 
     } while (choice != 5);
 
     return 0;
 }