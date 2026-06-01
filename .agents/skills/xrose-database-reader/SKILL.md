---
description: Read, inspect, and analyze XRose SQLite database files containing rose diagram documents
---

# XRose Database Reader

Read, inspect, and analyze XRose SQLite database files containing rose diagram documents.

## Capabilities

1. **Schema Inspection**
   - List all tables in XRose file
   - Show table schemas
   - Identify configuration vs. data tables
   - Detect orphaned data tables

2. **Data Reading**
   - Query configuration tables (_windowController, _geometryController, etc.)
   - Read layer definitions and configurations
   - Extract dataset metadata
   - Query user data tables
   - Export data to CSV/JSON

3. **Analysis**
   - Summarize document contents
   - List all layers and their types
   - Show dataset-to-table mappings
   - Identify unused data tables
   - Validate schema integrity

4. **Reporting**
   - Generate document summary reports
   - Create data inventory
   - Show layer hierarchy
   - List colors used in document

5. **Data Visualization Prep**
   - Extract data for specific layers
   - Calculate statistics (mean vector, spread, etc.)
   - Prepare data for plotting
   - Export binned data

## Workflow

When invoked, this skill will:

1. **Validate**: Ensure file is a valid XRose SQLite database
2. **Inspect**: Analyze schema and contents
3. **Query**: Execute user-requested queries
4. **Report**: Present results in clear format

## Usage Instructions

When the user invokes this skill:

1. Ask what operation to perform:
   - **Inspect**: Show schema and tables
   - **Read**: Query specific data
   - **Analyze**: Generate summary report
   - **Export**: Extract data for external use

2. For inspecting:
   - List all tables
   - Show configuration settings
   - Display layer information
   - Identify data tables

3. For reading data:
   - Specify table name
   - Show all rows or filtered subset
   - Format output (table, JSON, CSV)

4. For analysis:
   - Count layers by type
   - List datasets and their sources
   - Find orphaned tables
   - Validate relationships

---

# XRose File Format Specification

## Overview

XRose files (`.XRose` extension) are SQLite database files that store rose diagram documents for geological data visualization. Each file contains configuration tables for the diagram appearance, layer definitions, and one or more data tables containing the actual measurement data.

## File Structure

The XRose format uses SQLite as its container format. Each `.XRose` file contains:
- Configuration tables (prefixed with `_`)
- User data tables (dynamically named)

---

## Configuration Tables

### `_windowController`

Stores the document window dimensions.

| Column | Type | Description |
|--------|------|-------------|
| `height` | FLOAT | Window height in points |
| `width` | FLOAT | Window width in points |

**Purpose**: Stores the document window size (not the plot/canvas size).

---

### `_geometryController`

Stores global rose diagram geometry and plotting settings.

| Column | Type | Description |
|--------|------|-------------|
| `isEqualArea` | BOOL | True = equal area projection (default, more accurate). False = linear projection (overemphasizes strong directions) |
| `isPercent` | BOOL | Display values as percentages |
| `MAXCOUNT` | INT | Maximum count value for a sector (used for radial scale) |
| `MAXPERCENT` | FLOAT | Maximum percentage for the plot (calculated from layer maximums) |
| `HOLLOWCORE` | FLOAT | Size of hollow center that displaces central data for better visibility |
| `SECTORSIZE` | FLOAT | Size of each sector in degrees |
| `STARTINGANGLE` | FLOAT | Starting angle for the first sector |
| `SECTORCOUNT` | INT | Number of sectors in the rose diagram |
| `RELATIVESIZE` | FLOAT | Relative size scaling factor |

**Notes**:
- `MAXCOUNT` is the maximum count for a single sector, used with `TOTALCOUNT` from layers to layout the plot
- `MAXPERCENT` is calculated using individual layer `MAXPERCENT` values to determine the overall plot scale

---

### `_colors`

Color palette for the document.

| Column | Type | Description |
|--------|------|-------------|
| `COLORID` | INTEGER | Primary key, unique color identifier |
| `RED` | FLOAT | Red component (0.0 - 1.0) |
| `BLUE` | FLOAT | Blue component (0.0 - 1.0) |
| `GREEN` | FLOAT | Green component (0.0 - 1.0) |
| `ALPHA` | FLOAT | Alpha/transparency (0.0 - 1.0) |

**Purpose**: Centralized color definitions referenced by `STROKECOLORID` and `FILLCOLORID` in layers.

---

### `_datasets`

Defines data sources that are actively used by layers in the rose diagram.

| Column | Type | Description |
|--------|------|-------------|
| `_id` | INTEGER | Primary key, unique dataset identifier |
| `NAME` | TEXT | User-visible name for the dataset |
| `TABLENAME` | TEXT | Name of the SQLite table containing the data |
| `COLUMNNAME` | TEXT | Name of the column containing vector data |
| `PREDICATE` | TEXT | SQLite query or NSPredicate to filter the table data |
| `COMMENTS` | BLOB | User comments about the dataset |

**Notes**:
- Datasets are only created when layers reference them (via `_layerData.DATASET` or `_layerLineArrow.DATASET`)
- **Design Limitation**: Data tables in the file that are not referenced by any dataset are "orphaned" and won't appear in the datasets list
- Multiple datasets can reference the same `TABLENAME` with different `COLUMNNAME` and `PREDICATE` values to create filtered views
- Only one column per dataset can contain vector data
- The predicate allows users to dynamically filter data as needed

---

## Layer Tables

Layers control the visual representation of data and annotations. Each layer has a base entry in `_layers` and may have additional configuration in type-specific tables.

### `_layers`

Base configuration common to all layer types.

| Column | Type | Description |
|--------|------|-------------|
| `LAYERID` | INTEGER | Unique layer identifier |
| `TYPE` | TEXT | Layer type: "text", "data", "arrow", "core", "grid" |
| `VISIBLE` | BOOL | Whether the layer is currently visible |
| `ACTIVE` | BOOL | Whether the layer is currently selected by the user |
| `BIDIR` | BOOL | Bidirectional display - show vector in recorded direction AND reciprocal direction |
| `LAYER_NAME` | TEXT | User-visible layer name |
| `LINEWEIGHT` | FLOAT | Stroke width for drawing |
| `MAXCOUNT` | INT | Maximum count for this layer's data |
| `MAXPERCENT` | FLOAT | Maximum percentage for this layer (helps determine geometry controller's MAXPERCENT) |
| `STROKECOLORID` | INTEGER | Foreign key to `_colors.COLORID` for stroke color |
| `FILLCOLORID` | INTEGER | Foreign key to `_colors.COLORID` for fill color |

**Notes**:
- `ACTIVE` indicates the user-selected layer for editing
- `VISIBLE` controls rendering (independent of ACTIVE)
- `BIDIR` is used for vector data to show both direction and its reciprocal (180° opposite)

---

### `_layerText`

Configuration for text annotation layers.

| Column | Type | Description |
|--------|------|-------------|
| `LAYERID` | INTEGER | Foreign key to `_layers.LAYERID` |
| `CONTENTS` | BLOB | Text content |
| `RECT_POINT_X` | FLOAT | X coordinate of text box |
| `RECT_POINT_Y` | FLOAT | Y coordinate of text box |
| `RECT_SIZE_HEIGHT` | FLOAT | Height of text box |
| `RECT_SIZE_WIDTH` | FLOAT | Width of text box |

---

### `_layerLineArrow`

Configuration for vector/arrow display layers. Links to datasets.

| Column | Type | Description |
|--------|------|-------------|
| `LAYERID` | INTEGER | Foreign key to `_layers.LAYERID` |
| `DATASET` | INTEGER | Foreign key to `_datasets._id` |
| `ARROWSIZE` | FLOAT | Size of arrow heads |
| `VECTORTYPE` | INTEGER | Style of statistical vector line (multiple styles available) |
| `ARROWTYPE` | INTEGER | Style of arrow head (multiple styles available) |
| `SHOWVECTOR` | BOOL | Display the statistical vector line |
| `SHOWERROR` | BOOL | Display error bars |

**Notes**:
- `VECTORTYPE` draws a statistical vector line in one of two styles
- `ARROWTYPE` offers different arrow head styles pointing in the vector direction
- Statistical vectors and error bars are calculated from data (recalculated when configuration changes)

---

### `_layerCore`

Configuration for the core (center circle) layer.

| Column | Type | Description |
|--------|------|-------------|
| `LAYERID` | INTEGER | Foreign key to `_layers.LAYERID` |
| `RADIUS` | FLOAT | Radius of the core circle |
| `TYPE` | BOOL | Core type (purpose unclear - needs investigation) |

---

### `_layerGrid`

Configuration for grid (rings and radials) layer.

| Column | Type | Description |
|--------|------|-------------|
| `LAYERID` | INTEGER | Foreign key to `_layers.LAYERID` |
| `RINGS_ISFIXEDCOUNT` | BOOL | Use fixed count for rings vs. percentage increments |
| `RINGS_VISIBLE` | BOOL | Display rings |
| `RINGS_LABELS` | BOOL | Display ring labels |
| `RINGS_FIXEDCOUNT` | INTEGER | Fixed number of rings |
| `RINGS_COUNTINCREMENT` | INTEGER | Count increment between rings |
| `RINGS_PERCENTINCREMENT` | FLOAT | Percentage increment between rings |
| `RINGS_LABELANGLE` | FLOAT | Angle at which to place ring labels |
| `RINGS_FONTNAME` | TEXT | Font name for ring labels |
| `RINGS_FONTSIZE` | FLOAT | Font size for ring labels |
| `RADIALS_COUNT` | INTEGER | Number of radial lines |
| `RADIALS_ANGLE` | FLOAT | Angle between radials |
| `RADIALS_LABELALIGN` | INTEGER | Label alignment option |
| `RADIALS_COMPASSPOINT` | INTEGER | On/off setting for compass point labels (N/S/E/W) |
| `RADIALS_ORDER` | INTEGER | Quadrant compass labeling order OR 0-360 angle order |
| `RADIALS_FONT` | TEXT | Font name for radial labels |
| `RADIALS_FONTSIZE` | FLOAT | Font size for radial labels |
| `RADIALS_SECTORLOCK` | BOOL | Lock radials to sector boundaries |
| `RADIALS_VISIBLE` | BOOL | Display radials |
| `RADIALS_ISPERCENT` | BOOL | Display radial values as percentages |
| `RADIALS_TICKS` | BOOL | Display major ticks |
| `RADIALS_MINORTICKS` | BOOL | Display minor ticks |
| `RADIALS_LABELS` | BOOL | Display radial labels |

**Notes**:
- Rings are concentric circles showing magnitude
- Radials are lines emanating from center
- `RADIALS_COMPASSPOINT` controls N/S/E/W labeling
- `RADIALS_ORDER` controls whether labels follow quadrant order or 0-360° order

---

### `_layerData`

Configuration for data visualization layers. Links to datasets.

| Column | Type | Description |
|--------|------|-------------|
| `LAYERID` | INTEGER | Foreign key to `_layers.LAYERID` |
| `DATASET` | INTEGER | Foreign key to `_datasets._id` |
| `PLOTTYPE` | INTEGER | Type of plot visualization |
| `TOTALCOUNT` | INTEGER | Total count of data points being plotted |
| `DOTRADIUS` | FLOAT | Radius of dots (for dot plot types) |

**Plot Types** (`PLOTTYPE` values):
- Petals (rose diagram sectors)
- Kite
- Dot
- Dot deviation (shows individual data points that deviate from mean vector)
- Histogram
- Histogram deviation (shows deviation from average in each sector)

**Notes**:
- `TOTALCOUNT` is the actual count of data points, used with `_geometryController.MAXCOUNT` to layout the plot
- Multiple layers can display the same dataset with different visualization settings
- Deviation plot types show how individual measurements deviate from the average (more or less), different from error bars

---

## Data Tables

User data is stored in dynamically named tables (e.g., `rtest`, `measurements`, etc.). The table name is referenced by `_datasets.TABLENAME`.

### Data Table Structure

Each data table has:
- `_id` (INTEGER PRIMARY KEY) - Auto-generated row identifier
- One or more user-defined columns containing:
  - Vector data (NUMERIC or TEXT) - angles, directions, measurements
  - Additional metadata columns

**Example**:
```sql
CREATE TABLE rtest (
    _id INTEGER PRIMARY KEY,
    "azimuth" NUMERIC,
    "dip" NUMERIC,
    "location" TEXT
);
```

**Notes**:
- Column names are user-defined and can be anything
- Only one column per dataset contains the vector data (specified by `_datasets.COLUMNNAME`)
- Users can import tables with many columns; datasets select which column to visualize
- Data can be filtered using `_datasets.PREDICATE` for flexible data views
- **Design Limitation**: Data tables can exist in the XRose file without any corresponding entry in `_datasets` (orphaned tables). This happens when:
  - Data is imported but never used in a layer
  - A layer/dataset referencing the table is deleted
  - No mechanism exists to track or clean up unused tables

---

## Relationships

### Foreign Key Relationships

```
_colors.COLORID
    ← _layers.STROKECOLORID
    ← _layers.FILLCOLORID

_layers.LAYERID
    ← _layerText.LAYERID
    ← _layerLineArrow.LAYERID
    ← _layerCore.LAYERID
    ← _layerGrid.LAYERID
    ← _layerData.LAYERID

_datasets._id
    ← _layerData.DATASET
    ← _layerLineArrow.DATASET

_datasets.TABLENAME
    → [User Data Tables]
```

### Layer Type Mapping

Each layer must have an entry in `_layers` and may have an entry in one type-specific table:

- `TYPE = "text"` → entry in `_layerText`
- `TYPE = "data"` → entry in `_layerData`
- `TYPE = "arrow"` → entry in `_layerLineArrow`
- `TYPE = "core"` → entry in `_layerCore`
- `TYPE = "grid"` → entry in `_layerGrid`

Only `_layerData` and `_layerLineArrow` reference datasets (via `DATASET` column).

---

## Design Principles

1. **Separation of Concerns**: Configuration (layers, geometry) is separated from data (user tables)
2. **Flexible Data Import**: Users can import tables with any structure; datasets define which columns to use
3. **Multiple Views**: Multiple datasets can reference the same table with different filters and columns
4. **Layer Composition**: Complex visualizations are built by combining multiple typed layers
5. **Reusable Colors**: Centralized color palette prevents duplication
6. **Statistical Calculations**: Vectors and error bars are calculated from data and cached until configuration changes

## Design Limitations

1. **Orphaned Data Tables**: The current design creates datasets only when layers reference them. This means:
   - Data tables can exist in the file without any `_datasets` entry
   - There's no inventory of all available data tables in the document
   - Users cannot see or manage imported data that isn't currently being visualized
   - Deleted layers/datasets leave their data tables behind with no cleanup mechanism

2. **No Data Table Discovery**: To find all data tables in a document, you must:
   - Query SQLite system tables to list all non-configuration tables
   - Filter out tables starting with `_` (configuration tables)
   - This is an implementation detail, not part of the documented format

---

## Common Queries

### List All Tables
```bash
sqlite3 file.XRose ".tables"
```

### Show Document Summary
```sql
-- Get geometry settings
SELECT * FROM _geometryController;

-- Count layers by type
SELECT TYPE, COUNT(*) as count
FROM _layers
GROUP BY TYPE;

-- List all datasets
SELECT _id, NAME, TABLENAME, COLUMNNAME
FROM _datasets;
```

### Find All Data Tables (Including Orphaned)
```sql
-- Get all table names
SELECT name FROM sqlite_master
WHERE type='table'
AND name NOT LIKE '_%'
AND name NOT LIKE 'sqlite_%';
```

### Show Layer Configuration
```sql
-- Get all layers with their colors
SELECT
    l.LAYERID,
    l.LAYER_NAME,
    l.TYPE,
    l.VISIBLE,
    sc.RED as stroke_r, sc.GREEN as stroke_g, sc.BLUE as stroke_b,
    fc.RED as fill_r, fc.GREEN as fill_g, fc.BLUE as fill_b
FROM _layers l
LEFT JOIN _colors sc ON l.STROKECOLORID = sc.COLORID
LEFT JOIN _colors fc ON l.FILLCOLORID = fc.COLORID;
```

### Export Data from Table
```bash
# Export to CSV
sqlite3 file.XRose ".mode csv" ".headers on" "SELECT * FROM rtest;"

# Export to JSON
sqlite3 file.XRose ".mode json" "SELECT * FROM rtest;"
```

### Get Dataset Data with Predicate
```sql
-- Example: If dataset has PREDICATE="location='Site A'"
SELECT * FROM measurements WHERE location='Site A';
```

---

## Usage Examples

### Example 1: Inspect File
```bash
# When user asks: "What's in this XRose file?"
sqlite3 "Unit Tests/rtest1.XRose" << EOF
.tables
SELECT 'Geometry:' as info;
SELECT * FROM _geometryController;
SELECT 'Layers:' as info;
SELECT LAYERID, LAYER_NAME, TYPE, VISIBLE FROM _layers;
SELECT 'Datasets:' as info;
SELECT NAME, TABLENAME, COLUMNNAME FROM _datasets;
EOF
```

### Example 2: Read Data Table
```bash
# When user asks: "Show me the data from the rtest table"
sqlite3 "Unit Tests/rtest1.XRose" << EOF
.mode column
.headers on
SELECT * FROM rtest LIMIT 20;
EOF
```

### Example 3: Find Orphaned Tables
```bash
# When user asks: "Are there any unused data tables?"
sqlite3 "Unit Tests/rtest1.XRose" << EOF
-- Get all non-config tables
WITH all_tables AS (
    SELECT name FROM sqlite_master
    WHERE type='table'
    AND name NOT LIKE '_%'
    AND name NOT LIKE 'sqlite_%'
),
used_tables AS (
    SELECT DISTINCT TABLENAME as name FROM _datasets
)
SELECT at.name as "Orphaned Tables"
FROM all_tables at
LEFT JOIN used_tables ut ON at.name = ut.name
WHERE ut.name IS NULL;
EOF
```

### Example 4: Layer Details
```bash
# When user asks: "Tell me about the data layers"
sqlite3 "Unit Tests/rtest1.XRose" << EOF
.mode column
.headers on
SELECT
    l.LAYER_NAME,
    ld.PLOTTYPE,
    ld.TOTALCOUNT,
    d.NAME as dataset_name,
    d.TABLENAME,
    d.COLUMNNAME
FROM _layers l
JOIN _layerData ld ON l.LAYERID = ld.LAYERID
JOIN _datasets d ON ld.DATASET = d._id
WHERE l.TYPE = 'data';
EOF
```

---

## Quick Reference Card

| Task | Command Pattern |
|------|----------------|
| List all tables | `sqlite3 file.XRose ".tables"` |
| Show schema | `sqlite3 file.XRose ".schema table_name"` |
| Query table | `sqlite3 file.XRose "SELECT * FROM table_name;"` |
| Export CSV | `sqlite3 file.XRose ".mode csv" "SELECT * FROM table;"` |
| Count rows | `sqlite3 file.XRose "SELECT COUNT(*) FROM table;"` |
| Get geometry | `sqlite3 file.XRose "SELECT * FROM _geometryController;"` |
| List datasets | `sqlite3 file.XRose "SELECT * FROM _datasets;"` |
| Show layers | `sqlite3 file.XRose "SELECT * FROM _layers;"` |

---

## Configuration

Store reader settings in `.xrose-reader.json`:
```json
{
  "defaultDisplayMode": "column",
  "showHeaders": true,
  "maxRowsDefault": 100,
  "autoDetectDataTables": true,
  "highlightOrphanedTables": true,
  "exportFormat": "csv"
}
```
