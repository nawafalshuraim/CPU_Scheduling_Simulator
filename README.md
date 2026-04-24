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

![FCFS](Screenshot%202026-04-24%20at%2016.02.03.png)

---

### SJF — Non-Preemptive
The process with the shortest burst time among arrived processes is scheduled next.

![SJF](Screenshot%202026-04-24%20at%2016.02.37.png)

---

### Round Robin (Quantum = 3)
Each process gets a fixed time slice; remaining burst is re-queued until completion.

![Round Robin](Screenshot%202026-04-24%20at%2016.02.51.png)

---

### Priority — Non-Preemptive
Among arrived processes, the one with the lowest priority number runs to completion first.

![Priority](Screenshot%202026-04-24%20at%2016.03.06.png)

---

### Exit
Choosing option 5 exits the simulator cleanly.

![Exit](Screenshot%202026-04-24%20at%2016.03.23.png)

---

## Project Structure

```
CPU Scheduling Simulator/
├── scheduler.c   # All source code (single file)
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
