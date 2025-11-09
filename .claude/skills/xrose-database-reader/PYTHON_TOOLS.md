# XRose Database Python Tools

Python utilities for reading, analyzing, and exporting data from XRose database files.

## Installation

No installation required! The script uses only Python standard library modules:
- `sqlite3`
- `json`
- `csv`
- `pathlib`
- `dataclasses`

## Quick Start

```bash
# Make script executable
chmod +x xrose_reader.py

# Show database summary
./xrose_reader.py "Unit Tests/rtest1.XRose"

# Or use python directly
python3 xrose_reader.py "Unit Tests/rtest1.XRose"
```

## Command Reference

### Show Database Summary
```bash
./xrose_reader.py database.XRose summary
```

Displays:
- Window dimensions
- Geometry configuration (sector size, count, angles)
- Layer count by type
- Dataset definitions
- Data table inventory
- Orphaned tables (imported but not used)

**Example Output:**
```
============================================================
XRose Database Summary: rtest1.XRose
============================================================

Window Size: 620.0 x 396.0

Geometry Configuration:
  Equal Area: True
  Sector Size: 10.0°
  Sector Count: 36
  Starting Angle: 0.0°

Layers: 5 total
  data: 2
  grid: 1
  core: 1
  text: 1

Datasets: 2
  [1] Test Data
      Table: rtest, Column: azimuth
  [2] Filtered Data
      Table: rtest, Column: azimuth
      Predicate: azimuth > 180

Data Tables: 1
  rtest: 150 rows

============================================================
```

### List All Tables
```bash
./xrose_reader.py database.XRose tables
```

Shows:
- Configuration tables (`_geometryController`, `_layers`, etc.)
- Data tables with row counts

### Show Table Schema
```bash
./xrose_reader.py database.XRose schema <table_name>
```

**Example:**
```bash
./xrose_reader.py "Unit Tests/rtest1.XRose" schema rtest
```

Output:
```sql
CREATE TABLE rtest (
    _id INTEGER PRIMARY KEY,
    azimuth NUMERIC,
    dip NUMERIC,
    location TEXT
)
```

### Read Table Data
```bash
./xrose_reader.py database.XRose read <table_name> [limit]
```

**Examples:**
```bash
# Read first 20 rows (default)
./xrose_reader.py "Unit Tests/rtest1.XRose" read rtest

# Read first 50 rows
./xrose_reader.py "Unit Tests/rtest1.XRose" read rtest 50

# Read all rows
./xrose_reader.py "Unit Tests/rtest1.XRose" read rtest 999999
```

**Example Output:**
```
Table: rtest (150 total rows)

_id | azimuth | dip  | location
----|---------|------|----------
1   | 45.2    | 30.1 | Site A
2   | 120.5   | 25.3 | Site A
3   | 200.1   | 45.7 | Site B
...

... (130 more rows)
```

### List Datasets
```bash
./xrose_reader.py database.XRose datasets
```

Shows all dataset definitions with:
- Dataset ID and name
- Source table and column
- Filter predicates

**Example Output:**
```
Datasets: 2

[1] Primary Measurements
    Table: measurements
    Column: azimuth

[2] Site A Only
    Table: measurements
    Column: azimuth
    Predicate: location='Site A'
```

### Find Orphaned Tables
```bash
./xrose_reader.py database.XRose orphaned
```

Identifies data tables that exist in the file but aren't referenced by any dataset.

**Example Output:**
```
Orphaned Tables: 2

  old_import (200 rows)
  test_data (50 rows)
```

**Why This Matters:**
- Orphaned tables waste space
- Indicate deleted layers/datasets
- May contain forgotten data

### Export to CSV
```bash
./xrose_reader.py database.XRose export-csv <table_name> <output_file>
```

**Example:**
```bash
./xrose_reader.py "Unit Tests/rtest1.XRose" export-csv rtest output.csv
```

Creates a CSV file with headers and all rows from the table.

### Export to JSON
```bash
./xrose_reader.py database.XRose export-json <table_name> <output_file>
```

**Example:**
```bash
./xrose_reader.py "Unit Tests/rtest1.XRose" export-json rtest output.json
```

Creates a JSON array of objects, one per row.

## Python API Usage

You can also use the `XRoseReader` class in your own Python scripts:

```python
from xrose_reader import XRoseReader

# Open database
with XRoseReader("database.XRose") as reader:
    # Get summary
    summary = reader.get_summary()
    print(f"Found {summary['dataset_count']} datasets")

    # List data tables
    tables = reader.list_data_tables()
    for table in tables:
        count = reader.get_table_row_count(table)
        print(f"{table}: {count} rows")

    # Read data
    data = reader.read_table("rtest", limit=100)
    for row in data:
        print(row['azimuth'], row['dip'])

    # Get datasets
    datasets = reader.get_datasets()
    for ds in datasets:
        print(f"{ds.name}: {ds.tablename}.{ds.columnname}")

    # Find orphaned tables
    orphaned = reader.find_orphaned_tables()
    print(f"Orphaned: {orphaned}")

    # Get geometry config
    geo = reader.get_geometry_config()
    if geo:
        print(f"Sectors: {geo.SECTORCOUNT} x {geo.SECTORSIZE}°")

    # Export
    reader.export_table_csv("rtest", "output.csv")
```

## Common Workflows

### Inspecting a New File

```bash
# Get overview
./xrose_reader.py file.XRose summary

# Check what data tables exist
./xrose_reader.py file.XRose tables

# Look at actual data
./xrose_reader.py file.XRose read measurements 10
```

### Finding Unused Data

```bash
# Find tables not being used
./xrose_reader.py file.XRose orphaned

# Check their contents
./xrose_reader.py file.XRose read old_import 5

# Export for backup before cleanup
./xrose_reader.py file.XRose export-csv old_import backup.csv
```

### Analyzing Dataset Configuration

```bash
# See how datasets are configured
./xrose_reader.py file.XRose datasets

# Check the actual data being used
./xrose_reader.py file.XRose read measurements

# Verify filtered datasets
# (manually apply the predicate to see what data is included)
```

### Exporting for External Analysis

```bash
# Export all data tables
for table in $(./xrose_reader.py file.XRose tables | grep -v "^Configuration" | grep -v "^Data" | awk '{print $1}'); do
    ./xrose_reader.py file.XRose export-csv "$table" "${table}.csv"
done

# Or export to JSON for web visualization
./xrose_reader.py file.XRose export-json measurements data.json
```

## Advanced Usage

### Custom Statistics

```python
from xrose_reader import XRoseReader
import statistics

with XRoseReader("database.XRose") as reader:
    # Get raw data
    data = reader.read_table("measurements")
    azimuths = [row['azimuth'] for row in data]

    # Calculate statistics
    mean = statistics.mean(azimuths)
    stdev = statistics.stdev(azimuths)
    median = statistics.median(azimuths)

    print(f"Mean: {mean}°")
    print(f"StDev: {stdev}°")
    print(f"Median: {median}°")
```

### Filtered Data Analysis

```python
from xrose_reader import XRoseReader

with XRoseReader("database.XRose") as reader:
    # Read with predicate
    site_a = reader.read_table_with_predicate(
        "measurements",
        "location='Site A' AND azimuth > 180"
    )

    print(f"Found {len(site_a)} matching rows")

    # Column statistics
    stats = reader.get_column_stats("measurements", "azimuth")
    print(f"Min: {stats['min']}, Max: {stats['max']}, Mean: {stats['mean']}")
```

### Batch Processing

```python
from xrose_reader import XRoseReader
from pathlib import Path

# Process all XRose files in a directory
for xrose_file in Path("data").glob("*.XRose"):
    with XRoseReader(xrose_file) as reader:
        summary = reader.get_summary()
        print(f"\n{xrose_file.name}:")
        print(f"  Layers: {summary['layer_count']}")
        print(f"  Datasets: {summary['dataset_count']}")
        print(f"  Data tables: {summary['data_table_count']}")

        # Export summary
        reader.export_summary_json(f"{xrose_file.stem}_summary.json")
```

## Integration with Swift Code

The Python reader complements the Swift `InMemoryStore` by providing:
- Quick inspection without loading into app
- Batch processing capabilities
- Export to standard formats (CSV/JSON)
- Database forensics (finding orphaned tables, etc.)

**Workflow:**
1. Use Python tools to inspect/validate XRose files
2. Export data for external analysis
3. Use Swift app for visualization and editing
4. Use Python tools again to verify changes

## Troubleshooting

### "Database file not found"
- Check file path and ensure `.XRose` extension
- Use quotes around paths with spaces: `"Unit Tests/file.XRose"`

### "Table not found"
- List tables first: `./xrose_reader.py file.XRose tables`
- Check exact table name (case-sensitive)

### "No such column"
- Check schema: `./xrose_reader.py file.XRose schema tablename`
- Verify column name spelling

### Empty results
- Check row count: `./xrose_reader.py file.XRose tables`
- For datasets with predicates, verify the filter logic

## Performance

The reader is optimized for:
- **Small to medium databases** (<10MB): Instant
- **Large databases** (>10MB): May take a few seconds
- **Very large tables** (>100k rows): Use `limit` parameter

**Tips:**
- Use `limit` when exploring large tables
- Export to CSV/JSON for analysis in specialized tools
- Use predicates to filter data before reading

## Future Enhancements

Potential additions:
- [ ] Circular statistics for azimuth data
- [ ] Data visualization (matplotlib integration)
- [ ] Database validation/repair tools
- [ ] Migration utilities (upgrade old formats)
- [ ] Batch export all tables
- [ ] Interactive mode (REPL)
