# Analyst Visualization Experiment

> One-command Docker lab for comparing and experimenting with BI & data visualization tools — Metabase, Apache Superset, Grafana, and Redash — all connected to a shared PostgreSQL with sample data. Runs on Docker Desktop with WSL2 backend.

---

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Tools Included](#tools-included)
- [Shared Database](#shared-database)
- [WSL / Docker Desktop Notes](#wsl--docker-desktop-notes)
- [Starting Individual Tools](#starting-individual-tools)
- [Access URLs](#access-urls)
- [First-Time Setup Per Tool](#first-time-setup-per-tool)
- [Sample Queries to Try](#sample-queries-to-try)
- [Desktop-Only Tools](#desktop-only-tools-cannot-dockerize)
- [Comparison Matrix](#comparison-matrix)
- [Troubleshooting](#troubleshooting)

---

## Overview

This project lets you spin up 4 popular BI/visualization tools side-by-side to compare features, learn their interfaces, and decide which fits your workflow. All tools share a single PostgreSQL database pre-loaded with 250K rows of sample data (customers, orders, products).

```
┌─────────────────────────────────────────────────────────┐
│  Docker (WSL2 backend)                                   │
│                                                          │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐   │
│  │ Metabase │ │ Superset │ │ Grafana  │ │ Redash   │   │
│  │ :5000    │ │ :8088    │ │ :3000    │ │ :5001    │   │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘   │
│       │            │            │            │          │
│       └────────────┴────────────┴────────────┘          │
│                        │                                 │
│                 ┌──────┴──────┐                          │
│                 │ PostgreSQL  │  ← 250K sample rows      │
│                 │ :5439       │                          │
│                 └─────────────┘                          │
└─────────────────────────────────────────────────────────┘
         │
         ▼
  Windows Browser
  http://localhost:5000  → Metabase
  http://localhost:8088  → Superset
  http://localhost:3000  → Grafana
  http://localhost:5001  → Redash
```

---

## Quick Start

### Prerequisites

- **Docker Desktop** installed on Windows (with WSL2 backend enabled)
- **4 GB+ RAM** free (all tools together use ~2-3 GB)
- **Git Bash** or WSL terminal to run the scripts

### 1. Clone and start

```bash
cd ~/Desktop/Analyst_Visualization_experiment

# Make scripts executable
chmod +x start.sh stop.sh

# Start everything
./start.sh
```

First boot downloads images (2-5 minutes). Subsequent boots are instant.

### 2. Open in browser

| Tool | URL | Login |
|------|-----|-------|
| **Metabase** | http://localhost:5000 | Setup wizard on first visit |
| **Superset** | http://localhost:8088 | `admin` / `admin` |
| **Grafana** | http://localhost:3000 | `admin` / `admin` |
| **Redash** | http://localhost:5001 | Create account on first visit |
| **Shared DB** | `localhost:5439` | `analyst` / `analyst_pass` / `analytics` |

### 3. Stop

```bash
./stop.sh           # Stop all, keep data
./stop.sh clean     # Stop all, remove everything
```

---

## Tools Included

### Metabase
- **Type:** Open-source BI (Java)
- **Best for:** Quick dashboards, non-technical users, simple SQL questions
- **Strengths:** Zero-config setup, beautiful UI, "Ask a question" natural language
- **Weaknesses:** Limited advanced chart types, less flexible than Superset

### Apache Superset
- **Type:** Open-source data exploration (Python)
- **Best for:** Power users, complex dashboards, SQL Lab
- **Strengths:** 40+ chart types, SQL IDE, semantic layer, row-level security
- **Weaknesses:** Heavier setup, steeper learning curve

### Grafana
- **Type:** Open-source observability (Go)
- **Best for:** Time-series monitoring, infrastructure dashboards, alerts
- **Strengths:** Industry standard for monitoring, excellent time-series, plugins
- **Weaknesses:** Not ideal for ad-hoc BI queries, SQL support is secondary

### Redash
- **Type:** Open-source SQL dashboarding (Python)
- **Best for:** SQL-heavy teams, scheduled queries, alerts
- **Strengths:** Pure SQL focus, query snippets, easy sharing
- **Weaknesses:** Fewer chart types, smaller community than Metabase/Superset

---

## Shared Database

All tools connect to the same PostgreSQL instance with pre-loaded data:

| Parameter | Value |
|-----------|-------|
| Host | `bi_postgres` (inside Docker) or `localhost` (from Windows) |
| Port | `5439` |
| Database | `analytics` |
| Username | `analyst` |
| Password | `analyst_pass` |

### Sample Data

| Table | Rows | Description |
|-------|------|-------------|
| `customers` | 100,000 | Customer profiles with location and status |
| `orders` | 100,000 | Orders with amounts, categories, and statuses |
| `products` | 50,000 | Product catalog with pricing and stock status |

### Connecting from each tool

When adding a data source in any tool, use:

```
Host:     bi_postgres
Port:     5432           (internal Docker port, NOT 5439)
Database: analytics
User:     analyst
Password: analyst_pass
```

> ⚠ **Important:** Use port `5432` inside Docker (container-to-container) and `5439` from Windows.

---

## WSL / Docker Desktop Notes

### How it works

Docker Desktop on Windows runs containers inside a WSL2 virtual machine. From Windows:

```
Windows Browser → localhost:PORT → Docker proxy → Container
```

This is automatic — Docker Desktop forwards `localhost` ports to WSL2. **No special IP configuration needed.**

### Accessing from WSL terminal

```bash
# From WSL bash, same URLs work:
curl http://localhost:5000
```

### Accessing from another machine on the network

```bash
# 1. Get your WSL IP
ip addr show eth0 | grep inet

# 2. From another machine, use:
http://<WSL_IP>:5000
```

> For persistent network access, configure Windows Firewall to allow the ports.

### Resource Limits

Docker Desktop → Settings → Resources → WSL Integration:
- Memory: Set to at least 8 GB if running all tools
- CPUs: 4+ recommended
- Enable integration with your WSL distro

### Docker Compose vs Docker Compose (V2)

This project uses the modern `docker compose` (V2) syntax. If you see `'compose' is not a docker command`, use `docker-compose` (with hyphen) instead.

---

## Starting Individual Tools

You don't have to run everything. Use the helper script with a tool name:

```bash
./start.sh metabase    # Only Metabase + shared DB
./start.sh superset    # Only Superset + shared DB
./start.sh grafana     # Only Grafana + shared DB
./start.sh redash      # Only Redash (has its own DB)
```

Or use Docker Compose directly:

```bash
# Start shared DB first (required for Metabase, Superset, Grafana)
docker compose -f docker-compose-shared-db.yml up -d

# Then start your tool of choice
docker compose -f docker-compose-metabase.yml up -d
docker compose -f docker-compose-superset.yml up -d
docker compose -f docker-compose-grafana.yml up -d
docker compose -f docker-compose-redash.yml up -d
```

---

## Access URLs

| Service | URL | Notes |
|---------|-----|-------|
| Metabase | http://localhost:5000 | First visit → follow setup wizard |
| Superset | http://localhost:8088 | Login: `admin` / `admin` |
| Grafana | http://localhost:3000 | Login: `admin` / `admin` |
| Redash | http://localhost:5001 | Create account on first visit |
| PostgreSQL | `localhost:5439` | `analyst` / `analyst_pass` |

---

## First-Time Setup Per Tool

### Metabase

1. Open http://localhost:5000
2. Click "Let's get started"
3. Choose language → fill in your name/email/password
4. Add database: PostgreSQL → host: `bi_postgres`, port: `5432`, db: `analytics`, user: `analyst`, pass: `analyst_pass`
5. Skip sample data (you already have it)
6. Start building questions and dashboards

### Superset

1. Open http://localhost:8088 → login `admin` / `admin`
2. Settings → Database Connections → + Database
3. Choose PostgreSQL
4. URI: `postgresql://analyst:analyst_pass@bi_postgres:5432/analytics`
5. Click "Connect" → "Finish"
6. Go to SQL Lab → start querying
7. Create charts and dashboards

### Grafana

1. Open http://localhost:3000 → login `admin` / `admin`
2. Skip changing password (or change it)
3. Connections → Data Sources → Add data source → PostgreSQL
4. Host: `bi_postgres:5432`, Database: `analytics`, User: `analyst`, Password: `analyst_pass`
5. Save & Test
6. Create dashboard → Add panel → write SQL queries

### Redash

1. Open http://localhost:5001
2. Create admin account (first visit)
3. Settings → Data Sources → New Data Source → PostgreSQL
4. Host: `bi_postgres`, Port: `5432`, Database: `analytics`, User: `analyst`, Password: `analyst_pass`
5. Create → Save
6. Write queries and build visualizations

---

## Sample Queries to Try

Once connected, try these queries across all 4 tools to compare the experience:

### Revenue by country (bar chart)
```sql
SELECT country, ROUND(SUM(amount)::numeric, 2) AS total_revenue
FROM orders o
JOIN customers c ON c.id = o.customer_id
GROUP BY country
ORDER BY total_revenue DESC;
```

### Monthly order trends (line chart)
```sql
SELECT
    DATE_TRUNC('month', order_date) AS month,
    COUNT(*) AS order_count,
    ROUND(AVG(amount)::numeric, 2) AS avg_order_value
FROM orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month;
```

### Category breakdown (pie chart)
```sql
SELECT product_category, COUNT(*) AS orders
FROM orders
GROUP BY product_category
ORDER BY orders DESC;
```

### Top 10 cities by customer count (table)
```sql
SELECT city, country, COUNT(*) AS customers
FROM customers
GROUP BY city, country
ORDER BY customers DESC
LIMIT 10;
```

### High-value pending orders (table)
```sql
SELECT o.id, c.name, o.amount, o.order_date
FROM orders o
JOIN customers c ON c.id = o.customer_id
WHERE o.status = 'pending' AND o.amount > 500
ORDER BY o.amount DESC
LIMIT 20;
```

---

## Desktop-Only Tools (Cannot Dockerize)

These tools are Windows/Mac desktop applications. Install them separately to compare:

| Tool | Type | Install |
|------|------|---------|
| **Tableau Public** | Desktop BI (free) | https://public.tableau.com |
| **Power BI Desktop** | Desktop BI (free) | https://powerbi.microsoft.com/desktop |
| **Google Looker Studio** | Cloud BI (free, web) | https://lookerstudio.google.com |
| **Excel / Google Sheets** | Spreadsheet | Built-in / sheets.google.com |

### Connecting desktop tools to the Docker DB

Desktop apps run on Windows, not inside Docker. Use:

```
Host:     localhost
Port:     5439           ← external mapped port
Database: analytics
User:     analyst
Password: analyst_pass
```

---

## Comparison Matrix

| Feature | Metabase | Superset | Grafana | Redash |
|---------|----------|----------|---------|--------|
| **Setup complexity** | ⭐ Easy | ⭐⭐⭐ Medium | ⭐ Easy | ⭐⭐ Medium |
| **Chart types** | 15+ | 40+ | 20+ (plugin) | 15+ |
| **SQL editor** | ✓ Simple | ✓✓ SQL Lab (full) | ✓ Basic | ✓✓ Good |
| **Natural language** | ✓ "Ask a question" | ✗ | ✗ | ✗ |
| **Dashboards** | ✓✓ Good | ✓✓✓ Best | ✓✓ Good | ✓ Good |
| **Alerts** | ✓ | ✓ | ✓✓✓ Best | ✓ |
| **Semantic layer** | ✓ | ✓✓ | ✗ | ✗ |
| **Multi-tenant** | ✗ | ✓✓✓ Row-level | ✓ Org-based | ✓ Basic |
| **Time-series focus** | ✗ | ✗ | ✓✓✓ Best | ✗ |
| **License** | AGPL (OSS) | Apache 2.0 | AGPL (OSS) | BSD |
| **Best for** | Quick BI | Power users | Monitoring | SQL teams |

---

## Troubleshooting

### Port already in use

```bash
# Check what's on the port
netstat -ano | findstr :5000

# Kill the process (Windows)
taskkill /PID <PID> /F
```

### Container fails to start

```bash
# Check logs
docker logs metabase
docker logs superset
docker logs grafana
docker logs redash_server
```

### Can't connect to shared DB from tool

Make sure you're using host `bi_postgres` port `5432` (not `localhost` or `5439`) inside Docker.

### Full reset

```bash
./stop.sh clean
./start.sh
```

### WSL not running

```powershell
# In PowerShell (as admin):
wsl --install
wsl --shutdown
wsl
```

### Docker Desktop not connected to WSL

Docker Desktop → Settings → Resources → WSL Integration → Enable your distro → Apply & Restart.

---

## License

MIT — free to use and modify for learning and comparison purposes.
