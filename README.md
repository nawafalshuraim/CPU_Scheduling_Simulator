# CPU Scheduling Simulator

A terminal-based CPU scheduling simulator written in C. It supports four classic scheduling algorithms, renders ASCII Gantt charts, and reports per-process metrics along with average waiting and turnaround times.

---

## Features

- Supports **1–100 processes**, each with configurable arrival time, burst time, and priority
- Four scheduling algorithms selectable from an interactive menu
- ASCII **Gantt chart** rendered after each run
- Per-process table: Arrival, Burst, Finish, Waiting, Turnaround
- **Average Waiting Time** and **Average Turnaround Time** calculated automatically
- Full **input validation** — invalid values are re-prompted without crashing
- Algorithms can be run back-to-back on the same process set without re-entering data

---

## Algorithms

| # | Algorithm | Type |
|---|-----------|------|
| 1 | FCFS — First-Come-First-Served | Non-preemptive |
| 2 | SJF — Shortest Job First | Non-preemptive |
| 3 | Round Robin | Preemptive (configurable quantum) |
| 4 | Priority Scheduling | Non-preemptive (lower value = higher priority) |

---

## Build & Run

**Requirements:** any C99-compatible compiler (e.g. `gcc`, `clang`)

```bash
# Compile
gcc -o scheduler scheduler.c

# Run
./scheduler
```

---

## Usage

1. Enter the number of processes and their attributes (arrival time, burst time, priority).
2. Select an algorithm from the menu.
3. For Round Robin, enter a time quantum when prompted.
4. View the Gantt chart and metrics table.
5. Run another algorithm on the same processes, or choose **5 — Exit**.

---

## Screenshots

### Process Input + FCFS Scheduling
Enter process details once; the algorithm menu appears after. FCFS executes processes in arrival order.

![FCFS](Screenshots/Screenshot%202026-04-24%20at%2016.02.03.png)

---

### SJF — Non-Preemptive
The process with the shortest burst time among arrived processes is scheduled next.

![SJF](Screenshots/Screenshot%202026-04-24%20at%2016.02.37.png)

---

### Round Robin (Quantum = 3)
Each process gets a fixed time slice; remaining burst is re-queued until completion.

![Round Robin](Screenshots/Screenshot%202026-04-24%20at%2016.02.51.png)

---

### Priority — Non-Preemptive
Among arrived processes, the one with the lowest priority number runs to completion first.

![Priority](Screenshots/Screenshot%202026-04-24%20at%2016.03.06.png)

---

### Exit
Choosing option 5 exits the simulator cleanly.

![Exit](Screenshots/Screenshot%202026-04-24%20at%2016.03.23.png)

---

## Framework Diagram

```
┌─────────────────────────────────────────────────────────┐
│                    CPU Scheduling Simulator             │
├─────────────────────────────────────────────────────────┤
│                                                         │
│   ┌──────────────┐        ┌──────────────────────────┐  │
│   │ Input Module │        │     Scheduling Module    │  │
│   │──────────────│        │──────────────────────────│  │
│   │inputProcesses│──────▶ │ fcfs()                   │  │
│   │resetProcesses│        │ sjfNonPreemptive()        │ │
│   └──────────────┘        │ roundRobin()              │ │
│                           │ priorityNonPreemptive()   │ │
│                           └────────────┬─────────────┘  │
│                                        │                │
│                           ┌────────────▼─────────────┐  │
│                           │  Calculation Module      │  │
│                           │──────────────────────────│  │
│                           │  calculateMetrics()      │  │
│                           └────────────┬─────────────┘  │
│                                        │                │
│                           ┌────────────▼─────────────┐  │
│                           │    Output Module         │  │
│                           │──────────────────────────│  │
│                           │  printGantt()            │  │
│                           │  displayResults()        │  │
│                           └──────────────────────────┘  │
│                                                         │
│   ┌──────────────────────────────────────────────────┐  │
│   │                  main()                          │  │
│   │  Menu loop → dispatches to Scheduling Module     │  │
│   └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

---

## Workflow Diagram

```
          ┌─────────────────────┐
          │        START        │
          └──────────┬──────────┘
                     │
          ┌──────────▼──────────┐
          │  Enter number of    │◀──────┐
          │  processes (1–100)  │       │ Invalid
          └──────────┬──────────┘       │
                     │ Valid            │
          ┌──────────▼──────────┐       │
          │ Input arrival time, │       │
          │ burst time, priority│───────┘
          │ for each process    │ (re-prompt on invalid)
          └──────────┬──────────┘
                     │
          ┌──────────▼──────────┐
          │   Algorithm Menu    │◀─────────────────┐
          │  1. FCFS            │                  │
          │  2. SJF             │                  │
          │  3. Round Robin     │                  │
          │  4. Priority        │                  │
          │  5. Exit            │                  │
          └──────────┬──────────┘                  │
                     │                             │
       ┌─────────────┼─────────────────────────┐   │
       │             │             │           │   │
  ┌────▼───┐   ┌─────▼──┐  ┌──────▼──┐  ┌─────▼──┐ │
  │  FCFS  │   │  SJF   │  │Round    │  │Priority│ │
  │        │   │        │  │Robin    │  │        │ │
  └────┬───┘   └─────┬──┘  └──────┬──┘  └─────┬──┘ │
       └─────────────┴────────────┴────────────┘   │
                     │                             │
          ┌──────────▼──────────┐                  │
          │ calculateMetrics()  │                  │
          │  TAT = Finish−Arrival│                 │
          │  WT  = TAT − Burst  │                  │
          └──────────┬──────────┘                  │
                     │                             │
          ┌──────────▼──────────┐                  │
          │   printGantt()      │                  │
          │   displayResults()  │                  │
          └──────────┬──────────┘                  │
                     │                             │
          ┌──────────▼──────────┐                  │
          │  Run another algo?  │──── Yes ─────────┘
          └──────────┬──────────┘
                  No │
          ┌──────────▼──────────┐
          │         END         │
          └─────────────────────┘
```

---

## Evaluation Metrics and Results

All four algorithms were run on the **same process set** to allow a direct comparison.

### Test Processes

| Process | Arrival Time | Burst Time | Priority |
|---------|-------------|------------|----------|
| P1      | 0           | 6          | 2        |
| P2      | 1           | 4          | 1        |
| P3      | 2           | 2          | 3        |
| P4      | 3           | 5          | 2        |

---

### FCFS — First-Come-First-Served

```
Gantt Chart:
 +-----------------------+---------------+-------+-------------------+
 |          P1           |      P2       |  P3   |        P4         |
 +-----------------------+---------------+-------+-------------------+
 0                       6              10      12                  17
```

| Process | Arrival | Burst | Finish | Waiting | Turnaround |
|---------|---------|-------|--------|---------|------------|
| P1      | 0       | 6     | 6      | 0       | 6          |
| P2      | 1       | 4     | 10     | 5       | 9          |
| P3      | 2       | 2     | 12     | 8       | 10         |
| P4      | 3       | 5     | 17     | 9       | 14         |

> **Avg Waiting Time: 5.50 &nbsp;|&nbsp; Avg Turnaround Time: 9.75**

---

### SJF — Shortest Job First (Non-Preemptive)

```
Gantt Chart:
 +-----------------------+-------+---------------+-------------------+
 |          P1           |  P3   |      P2       |        P4         |
 +-----------------------+-------+---------------+-------------------+
 0                       6       8              12                  17
```

| Process | Arrival | Burst | Finish | Waiting | Turnaround |
|---------|---------|-------|--------|---------|------------|
| P1      | 0       | 6     | 6      | 0       | 6          |
| P2      | 1       | 4     | 12     | 7       | 11         |
| P3      | 2       | 2     | 8      | 4       | 6          |
| P4      | 3       | 5     | 17     | 9       | 14         |

> **Avg Waiting Time: 5.00 &nbsp;|&nbsp; Avg Turnaround Time: 9.25**

---

### Round Robin (Quantum = 2)

```
Gantt Chart:
 +-------+-------+-------+-------+-------+-------+-------+-------+---+
 |  P1   |  P2   |  P3   |  P1   |  P4   |  P2   |  P1   |  P4   |P4 |
 +-------+-------+-------+-------+-------+-------+-------+-------+---+
 0       2       4       6       8      10      12      14      16  17
```

| Process | Arrival | Burst | Finish | Waiting | Turnaround |
|---------|---------|-------|--------|---------|------------|
| P1      | 0       | 6     | 14     | 8       | 14         |
| P2      | 1       | 4     | 12     | 7       | 11         |
| P3      | 2       | 2     | 6      | 2       | 4          |
| P4      | 3       | 5     | 17     | 9       | 14         |

> **Avg Waiting Time: 6.50 &nbsp;|&nbsp; Avg Turnaround Time: 10.75**

---

### Priority Scheduling (Non-Preemptive)

```
Gantt Chart:
 +-----------------------+---------------+-------------------+-------+
 |          P1           |      P2       |        P4         |  P3   |
 +-----------------------+---------------+-------------------+-------+
 0                       6              10                  15      17
```

| Process | Arrival | Burst | Finish | Waiting | Turnaround |
|---------|---------|-------|--------|---------|------------|
| P1      | 0       | 6     | 6      | 0       | 6          |
| P2      | 1       | 4     | 10     | 5       | 9          |
| P3      | 2       | 2     | 17     | 13      | 15         |
| P4      | 3       | 5     | 15     | 7       | 12         |

> **Avg Waiting Time: 6.25 &nbsp;|&nbsp; Avg Turnaround Time: 10.50**

---

### Algorithm Comparison

| Algorithm              | Avg Waiting Time | Avg Turnaround Time | Best For |
|------------------------|-----------------|---------------------|----------|
| FCFS                   | 5.50            | 9.75                | Simple, fair ordering |
| SJF (Non-Preemptive)   | **5.00**        | **9.25**            | Minimizing average wait |
| Round Robin (Q=2)      | 6.50            | 10.75               | Fair time-sharing, interactive systems |
| Priority (Non-Preemptive) | 6.25         | 10.50               | Critical task prioritization |

> SJF achieves the lowest average waiting and turnaround times for this test case, which is consistent with the theoretical optimality of SJF for non-preemptive scheduling. Round Robin has higher averages but ensures no process is starved.

---

## Project Structure

```
CPU Scheduling Simulator/
├── scheduler.c      # All source code (single file)
├── Screenshots/     # Demo screenshots
└── README.md
```

### Code Modules (inside `scheduler.c`)

| Module | Functions | Responsibility |
|--------|-----------|----------------|
| Input | `inputProcesses`, `resetProcesses` | Read and validate process attributes; reset between runs |
| Calculation | `calculateMetrics` | Derive WT and TAT from finish time |
| Output | `printGantt`, `displayResults` | Render Gantt chart and results table |
| Scheduling | `fcfs`, `sjfNonPreemptive`, `roundRobin`, `priorityNonPreemptive` | Algorithm implementations |
| Entry point | `main` | Menu loop and dispatcher |

---

## Metrics Explained

| Metric | Formula |
|--------|---------|
| Turnaround Time (TAT) | `Finish Time − Arrival Time` |
| Waiting Time (WT) | `Turnaround Time − Burst Time` |
| Average WT / TAT | Sum of all processes ÷ number of processes |
