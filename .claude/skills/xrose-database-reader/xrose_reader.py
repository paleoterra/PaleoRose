#!/usr/bin/env python3
"""
XRose Database Reader

Python utility for reading and analyzing XRose SQLite database files.
"""

import sqlite3
import json
import csv
import sys
from pathlib import Path
from typing import Dict, List, Tuple, Optional, Any
from dataclasses import dataclass, asdict


@dataclass
class GeometryConfig:
    """Rose diagram geometry configuration."""
    isEqualArea: bool
    isPercent: bool
    MAXCOUNT: int
    MAXPERCENT: float
    HOLLOWCORE: float
    SECTORSIZE: float
    STARTINGANGLE: float
    SECTORCOUNT: int
    RELATIVESIZE: float


@dataclass
class Dataset:
    """Dataset definition."""
    id: int
    name: str
    tablename: str
    columnname: str
    predicate: Optional[str]
    comments: Optional[str]


@dataclass
class Layer:
    """Base layer information."""
    layerid: int
    type: str
    visible: bool
    active: bool
    bidir: bool
    layer_name: str
    lineweight: float
    maxcount: int
    maxpercent: float
    strokecolorid: Optional[int]
    fillcolorid: Optional[int]


class XRoseReader:
    """Reader for XRose database files."""

    def __init__(self, filepath: str):
        """Initialize reader with database file path."""
        self.filepath = Path(filepath)
        if not self.filepath.exists():
            raise FileNotFoundError(f"Database file not found: {filepath}")

        self.conn = sqlite3.connect(str(self.filepath))
        self.conn.row_factory = sqlite3.Row
        self.cursor = self.conn.cursor()

    def __enter__(self):
        """Context manager entry."""
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        """Context manager exit."""
        self.close()

    def close(self):
        """Close database connection."""
        if self.conn:
            self.conn.close()

    # ========== Table Discovery ==========

    def list_all_tables(self) -> List[str]:
        """List all tables in the database."""
        self.cursor.execute("""
            SELECT name FROM sqlite_master
            WHERE type='table'
            ORDER BY name
        """)
        return [row['name'] for row in self.cursor.fetchall()]

    def list_config_tables(self) -> List[str]:
        """List configuration tables (starting with _)."""
        self.cursor.execute("""
            SELECT name FROM sqlite_master
            WHERE type='table'
            AND name LIKE '\\_%' ESCAPE '\\'
            ORDER BY name
        """)
        return [row['name'] for row in self.cursor.fetchall()]

    def list_data_tables(self) -> List[str]:
        """List user data tables (not starting with _ or sqlite_)."""
        self.cursor.execute("""
            SELECT name FROM sqlite_master
            WHERE type='table'
            AND name NOT LIKE '\\_%' ESCAPE '\\'
            AND name NOT LIKE 'sqlite_%'
            ORDER BY name
        """)
        return [row['name'] for row in self.cursor.fetchall()]

    def get_table_schema(self, table_name: str) -> str:
        """Get CREATE TABLE statement for a table."""
        self.cursor.execute("""
            SELECT sql FROM sqlite_master
            WHERE type='table' AND name=?
        """, (table_name,))
        result = self.cursor.fetchone()
        return result['sql'] if result else None

    def get_table_columns(self, table_name: str) -> List[Dict[str, Any]]:
        """Get column information for a table."""
        self.cursor.execute(f"PRAGMA table_info({table_name})")
        return [dict(row) for row in self.cursor.fetchall()]

    # ========== Configuration Reading ==========

    def get_geometry_config(self) -> Optional[GeometryConfig]:
        """Read geometry controller configuration."""
        try:
            self.cursor.execute("SELECT * FROM _geometryController LIMIT 1")
            row = self.cursor.fetchone()
            if row:
                return GeometryConfig(**dict(row))
        except sqlite3.Error:
            pass
        return None

    def get_window_size(self) -> Optional[Tuple[float, float]]:
        """Get window dimensions (width, height)."""
        try:
            self.cursor.execute("SELECT width, height FROM _windowController LIMIT 1")
            row = self.cursor.fetchone()
            if row:
                return (row['width'], row['height'])
        except sqlite3.Error:
            pass
        return None

    def get_datasets(self) -> List[Dataset]:
        """Get all dataset definitions."""
        try:
            self.cursor.execute("SELECT * FROM _datasets ORDER BY _id")
            return [Dataset(
                id=row['_id'],
                name=row['NAME'],
                tablename=row['TABLENAME'],
                columnname=row['COLUMNNAME'],
                predicate=row['PREDICATE'] if 'PREDICATE' in row.keys() else None,
                comments=row['COMMENTS'] if 'COMMENTS' in row.keys() else None
            ) for row in self.cursor.fetchall()]
        except sqlite3.Error:
            return []

    def get_layers(self) -> List[Layer]:
        """Get all layer definitions."""
        try:
            self.cursor.execute("SELECT * FROM _layers ORDER BY LAYERID")
            return [Layer(
                layerid=row['LAYERID'],
                type=row['TYPE'],
                visible=bool(row['VISIBLE']),
                active=bool(row['ACTIVE']),
                bidir=bool(row['BIDIR']),
                layer_name=row['LAYER_NAME'],
                lineweight=row['LINEWEIGHT'],
                maxcount=row['MAXCOUNT'],
                maxpercent=row['MAXPERCENT'],
                strokecolorid=row['STROKECOLORID'] if 'STROKECOLORID' in row.keys() else None,
                fillcolorid=row['FILLCOLORID'] if 'FILLCOLORID' in row.keys() else None
            ) for row in self.cursor.fetchall()]
        except sqlite3.Error:
            return []

    def get_colors(self) -> List[Dict[str, Any]]:
        """Get color palette."""
        try:
            self.cursor.execute("SELECT * FROM _colors ORDER BY COLORID")
            return [dict(row) for row in self.cursor.fetchall()]
        except sqlite3.Error:
            return []

    # ========== Data Table Reading ==========

    def read_table(self, table_name: str, limit: Optional[int] = None) -> List[Dict[str, Any]]:
        """Read all rows from a data table."""
        query = f"SELECT * FROM {table_name}"
        if limit:
            query += f" LIMIT {limit}"

        self.cursor.execute(query)
        return [dict(row) for row in self.cursor.fetchall()]

    def read_table_with_predicate(self, table_name: str, predicate: str,
                                   limit: Optional[int] = None) -> List[Dict[str, Any]]:
        """Read rows from a data table with filter predicate."""
        query = f"SELECT * FROM {table_name} WHERE {predicate}"
        if limit:
            query += f" LIMIT {limit}"

        self.cursor.execute(query)
        return [dict(row) for row in self.cursor.fetchall()]

    def get_table_row_count(self, table_name: str) -> int:
        """Get row count for a table."""
        self.cursor.execute(f"SELECT COUNT(*) as count FROM {table_name}")
        return self.cursor.fetchone()['count']

    def get_column_stats(self, table_name: str, column_name: str) -> Dict[str, Any]:
        """Get basic statistics for a numeric column."""
        try:
            self.cursor.execute(f"""
                SELECT
                    COUNT({column_name}) as count,
                    MIN({column_name}) as min,
                    MAX({column_name}) as max,
                    AVG({column_name}) as mean
                FROM {table_name}
                WHERE {column_name} IS NOT NULL
            """)
            return dict(self.cursor.fetchone())
        except sqlite3.Error as e:
            return {'error': str(e)}

    # ========== Dataset Analysis ==========

    def find_orphaned_tables(self) -> List[str]:
        """Find data tables not referenced by any dataset."""
        all_data_tables = set(self.list_data_tables())
        datasets = self.get_datasets()
        used_tables = set(ds.tablename for ds in datasets)

        return sorted(all_data_tables - used_tables)

    def get_dataset_data(self, dataset_id: int, limit: Optional[int] = None) -> List[Dict[str, Any]]:
        """Get data for a specific dataset, applying its predicate."""
        datasets = self.get_datasets()
        dataset = next((ds for ds in datasets if ds.id == dataset_id), None)

        if not dataset:
            return []

        if dataset.predicate:
            return self.read_table_with_predicate(dataset.tablename, dataset.predicate, limit)
        else:
            return self.read_table(dataset.tablename, limit)

    # ========== Summary & Reporting ==========

    def get_summary(self) -> Dict[str, Any]:
        """Get comprehensive database summary."""
        geometry = self.get_geometry_config()
        window = self.get_window_size()
        datasets = self.get_datasets()
        layers = self.get_layers()
        data_tables = self.list_data_tables()
        orphaned = self.find_orphaned_tables()

        # Count layers by type
        layer_types = {}
        for layer in layers:
            layer_types[layer.type] = layer_types.get(layer.type, 0) + 1

        return {
            'file': str(self.filepath.name),
            'window_size': {
                'width': window[0] if window else None,
                'height': window[1] if window else None
            } if window else None,
            'geometry': asdict(geometry) if geometry else None,
            'layer_count': len(layers),
            'layers_by_type': layer_types,
            'dataset_count': len(datasets),
            'data_table_count': len(data_tables),
            'orphaned_table_count': len(orphaned),
            'datasets': [asdict(ds) for ds in datasets],
            'layers': [asdict(layer) for layer in layers],
            'data_tables': data_tables,
            'orphaned_tables': orphaned
        }

    # ========== Export Functions ==========

    def export_table_csv(self, table_name: str, output_file: str):
        """Export table to CSV file."""
        rows = self.read_table(table_name)
        if not rows:
            print(f"Table {table_name} is empty or doesn't exist")
            return

        with open(output_file, 'w', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=rows[0].keys())
            writer.writeheader()
            writer.writerows(rows)

        print(f"Exported {len(rows)} rows to {output_file}")

    def export_table_json(self, table_name: str, output_file: str):
        """Export table to JSON file."""
        rows = self.read_table(table_name)

        with open(output_file, 'w') as f:
            json.dump(rows, f, indent=2)

        print(f"Exported {len(rows)} rows to {output_file}")

    def export_summary_json(self, output_file: str):
        """Export database summary to JSON file."""
        summary = self.get_summary()

        with open(output_file, 'w') as f:
            json.dump(summary, f, indent=2)

        print(f"Exported summary to {output_file}")


# ========== Display Functions ==========

def print_table(rows: List[Dict[str, Any]], max_rows: int = 20):
    """Print table data in formatted columns."""
    if not rows:
        print("(empty)")
        return

    # Get column widths
    headers = list(rows[0].keys())
    widths = {h: len(h) for h in headers}

    for row in rows[:max_rows]:
        for key, value in row.items():
            widths[key] = max(widths[key], len(str(value)))

    # Print header
    header_line = " | ".join(h.ljust(widths[h]) for h in headers)
    print(header_line)
    print("-" * len(header_line))

    # Print rows
    for row in rows[:max_rows]:
        print(" | ".join(str(row[h]).ljust(widths[h]) for h in headers))

    if len(rows) > max_rows:
        print(f"\n... ({len(rows) - max_rows} more rows)")


def print_summary(reader: XRoseReader):
    """Print formatted summary of database."""
    summary = reader.get_summary()

    print(f"\n{'='*60}")
    print(f"XRose Database Summary: {summary['file']}")
    print(f"{'='*60}\n")

    # Window size
    if summary['window_size']:
        ws = summary['window_size']
        print(f"Window Size: {ws['width']} x {ws['height']}")

    # Geometry
    if summary['geometry']:
        geo = summary['geometry']
        print(f"\nGeometry Configuration:")
        print(f"  Equal Area: {geo['isEqualArea']}")
        print(f"  Sector Size: {geo['SECTORSIZE']}°")
        print(f"  Sector Count: {geo['SECTORCOUNT']}")
        print(f"  Starting Angle: {geo['STARTINGANGLE']}°")

    # Layers
    print(f"\nLayers: {summary['layer_count']} total")
    for layer_type, count in summary['layers_by_type'].items():
        print(f"  {layer_type}: {count}")

    # Datasets
    print(f"\nDatasets: {summary['dataset_count']}")
    for ds in summary['datasets']:
        print(f"  [{ds['id']}] {ds['name']}")
        print(f"      Table: {ds['tablename']}, Column: {ds['columnname']}")
        if ds['predicate']:
            print(f"      Predicate: {ds['predicate']}")

    # Data tables
    print(f"\nData Tables: {summary['data_table_count']}")
    for table in summary['data_tables']:
        row_count = reader.get_table_row_count(table)
        print(f"  {table}: {row_count} rows")

    # Orphaned tables
    if summary['orphaned_tables']:
        print(f"\nOrphaned Tables (not used by any dataset): {summary['orphaned_table_count']}")
        for table in summary['orphaned_tables']:
            row_count = reader.get_table_row_count(table)
            print(f"  {table}: {row_count} rows")

    print(f"\n{'='*60}\n")


# ========== CLI Interface ==========

def main():
    """Command-line interface."""
    if len(sys.argv) < 2:
        print("Usage: xrose_reader.py <database.XRose> [command] [args...]")
        print("\nCommands:")
        print("  summary                  - Show database summary")
        print("  tables                   - List all tables")
        print("  schema <table>           - Show table schema")
        print("  read <table> [limit]     - Read table data")
        print("  datasets                 - List datasets")
        print("  orphaned                 - Find orphaned tables")
        print("  export-csv <table> <out> - Export table to CSV")
        print("  export-json <table> <out> - Export table to JSON")
        return

    db_file = sys.argv[1]
    command = sys.argv[2] if len(sys.argv) > 2 else "summary"

    with XRoseReader(db_file) as reader:
        if command == "summary":
            print_summary(reader)

        elif command == "tables":
            print("Configuration Tables:")
            for table in reader.list_config_tables():
                print(f"  {table}")
            print("\nData Tables:")
            for table in reader.list_data_tables():
                row_count = reader.get_table_row_count(table)
                print(f"  {table} ({row_count} rows)")

        elif command == "schema":
            if len(sys.argv) < 4:
                print("Usage: schema <table_name>")
                return
            table = sys.argv[3]
            schema = reader.get_table_schema(table)
            if schema:
                print(schema)
            else:
                print(f"Table '{table}' not found")

        elif command == "read":
            if len(sys.argv) < 4:
                print("Usage: read <table_name> [limit]")
                return
            table = sys.argv[3]
            limit = int(sys.argv[4]) if len(sys.argv) > 4 else 20
            rows = reader.read_table(table, limit)
            print(f"\nTable: {table} ({reader.get_table_row_count(table)} total rows)\n")
            print_table(rows, limit)

        elif command == "datasets":
            datasets = reader.get_datasets()
            print(f"\nDatasets: {len(datasets)}\n")
            for ds in datasets:
                print(f"[{ds.id}] {ds.name}")
                print(f"    Table: {ds.tablename}")
                print(f"    Column: {ds.columnname}")
                if ds.predicate:
                    print(f"    Predicate: {ds.predicate}")
                print()

        elif command == "orphaned":
            orphaned = reader.find_orphaned_tables()
            if orphaned:
                print(f"\nOrphaned Tables: {len(orphaned)}\n")
                for table in orphaned:
                    row_count = reader.get_table_row_count(table)
                    print(f"  {table} ({row_count} rows)")
            else:
                print("\nNo orphaned tables found.")

        elif command == "export-csv":
            if len(sys.argv) < 5:
                print("Usage: export-csv <table_name> <output_file>")
                return
            table = sys.argv[3]
            output = sys.argv[4]
            reader.export_table_csv(table, output)

        elif command == "export-json":
            if len(sys.argv) < 5:
                print("Usage: export-json <table_name> <output_file>")
                return
            table = sys.argv[3]
            output = sys.argv[4]
            reader.export_table_json(table, output)

        else:
            print(f"Unknown command: {command}")


if __name__ == "__main__":
    main()
