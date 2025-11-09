---
description: Manage SQLite database schema migrations, generate migration scripts, and maintain data integrity during schema changes
---

# Database Migration Helper

Manage SQLite database schema migrations, generate migration scripts, and maintain data integrity during schema changes.

## Capabilities

1. **Schema Analysis**
   - Analyze current SQLite schema from code (TableRepresentable types)
   - Detect schema changes between versions
   - Compare database file schema vs code definitions
   - Identify missing tables, columns, or indexes

2. **Migration Generation**
   - Auto-generate migration SQL for schema changes
   - Create versioned migration files
   - Generate rollback scripts
   - Support for complex migrations (data transformations)

3. **Migration Execution**
   - Apply migrations safely with transactions
   - Verify migration success
   - Handle migration failures and rollbacks
   - Track applied migrations

4. **Data Preservation**
   - Generate data migration scripts for schema changes
   - Create backup strategies
   - Transform data during migrations
   - Validate data after migration

5. **Model Code Generation**
   - Generate Swift TableRepresentable types from existing database
   - Update existing models when schema changes
   - Create test fixtures from database data
   - Generate documentation for database schema

## Workflow

When invoked, this skill will:

1. **Analyze**: Scan TableRepresentable types and database files
2. **Compare**: Detect differences between code and database
3. **Plan**: Generate migration strategy
4. **Execute**: Apply migrations safely
5. **Verify**: Confirm schema and data integrity

## Usage Instructions

When the user invokes this skill:

1. Identify the task:
   - Create new migration
   - Apply pending migrations
   - Generate models from database
   - Analyze schema differences
   - Rollback migrations

2. For **creating migrations**:
   - Analyze current TableRepresentable types
   - Compare with previous version (git history)
   - Generate migration SQL
   - Create migration file with version number
   - Generate rollback script

3. For **applying migrations**:
   - Check migration history table
   - Identify unapplied migrations
   - Apply in order within transactions
   - Update migration history
   - Verify schema matches code

4. For **model generation**:
   - Read SQLite schema from database file
   - Generate Swift structs conforming to TableRepresentable
   - Include proper CodingKeys
   - Add convenience methods

## Project-Specific Integration

### Your CodableSQLiteNonThread Framework

Based on your project structure:

```swift
// Example TableRepresentable type from your project
struct Layer: TableRepresentable {
    static var tableName: String { "Layer" }
    static var primaryKey: String? { "id" }

    let id: UUID
    let name: String
    let layerType: Int
    // ... other properties
}
```

The skill understands:
- `TableRepresentable` protocol requirements
- `QueryProtocol` for SQL generation
- `Bindable` types for parameter binding
- SQLiteInterface for database operations

## Migration File Format

### Migration Naming Convention
```
YYYYMMDD_HHMM_description.sql
```

Example: `20250125_1430_add_datasets_table.sql`

### Migration File Structure
```sql
-- Migration: Add datasets table
-- Version: 20250125_1430
-- Description: Creates the datasets table with foreign key to layers

BEGIN TRANSACTION;

-- Up Migration
CREATE TABLE IF NOT EXISTS DataSet (
    id TEXT PRIMARY KEY,
    layerId TEXT NOT NULL,
    name TEXT NOT NULL,
    dataType INTEGER NOT NULL,
    createdAt REAL NOT NULL,
    FOREIGN KEY (layerId) REFERENCES Layer(id) ON DELETE CASCADE
);

CREATE INDEX idx_dataset_layer ON DataSet(layerId);

-- Record migration
INSERT INTO schema_migrations (version, applied_at)
VALUES ('20250125_1430', datetime('now'));

COMMIT;

-- Down Migration (for rollback)
-- BEGIN TRANSACTION;
-- DROP TABLE IF EXISTS DataSet;
-- DELETE FROM schema_migrations WHERE version = '20250125_1430';
-- COMMIT;
```

## Common Migration Scenarios

### 1. Adding a Column
```sql
-- Add optional column (safe)
ALTER TABLE Layer ADD COLUMN color TEXT;

-- Add non-null column (requires default or data migration)
ALTER TABLE Layer ADD COLUMN orderIndex INTEGER NOT NULL DEFAULT 0;
```

### 2. Renaming a Column
SQLite doesn't support RENAME COLUMN directly (before 3.25.0), so we use table recreation:

```sql
-- Create new table with correct schema
CREATE TABLE Layer_new (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    displayName TEXT NOT NULL, -- renamed from 'title'
    layerType INTEGER NOT NULL
);

-- Copy data
INSERT INTO Layer_new (id, name, displayName, layerType)
SELECT id, name, title, layerType FROM Layer;

-- Drop old table and rename new one
DROP TABLE Layer;
ALTER TABLE Layer_new RENAME TO Layer;
```

### 3. Adding Foreign Key Constraints
```sql
-- Create new table with FK
CREATE TABLE DataSet_new (
    id TEXT PRIMARY KEY,
    layerId TEXT NOT NULL,
    name TEXT NOT NULL,
    FOREIGN KEY (layerId) REFERENCES Layer(id) ON DELETE CASCADE
);

-- Copy data
INSERT INTO DataSet_new SELECT * FROM DataSet;

-- Swap tables
DROP TABLE DataSet;
ALTER TABLE DataSet_new RENAME TO DataSet;

-- Enable FK enforcement
PRAGMA foreign_keys = ON;
```

### 4. Data Transformation Migration
```sql
-- Example: Migrate color from Int to hex string
BEGIN TRANSACTION;

ALTER TABLE Layer ADD COLUMN colorHex TEXT;

UPDATE Layer SET colorHex =
    CASE
        WHEN colorInt = 0 THEN '#FF0000'
        WHEN colorInt = 1 THEN '#00FF00'
        WHEN colorInt = 2 THEN '#0000FF'
        ELSE '#000000'
    END;

-- After verification, can drop old column via table recreation

COMMIT;
```

## Swift Model Update Workflow

When schema changes:

1. **Update TableRepresentable Model**
```swift
struct Layer: TableRepresentable {
    static var tableName: String { "Layer" }
    static var primaryKey: String? { "id" }

    let id: UUID
    let name: String
    let displayName: String // Changed from 'title'
    let layerType: Int
    let colorHex: String? // New optional column

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case displayName
        case layerType
        case colorHex
    }
}
```

2. **Generate Migration SQL**
3. **Update Tests** to use new schema
4. **Verify** with integration tests

## Migration Tracking

### Schema Migrations Table
```sql
CREATE TABLE IF NOT EXISTS schema_migrations (
    version TEXT PRIMARY KEY,
    applied_at TEXT NOT NULL,
    description TEXT
);
```

### Migration Manager (Swift)
```swift
struct MigrationManager {
    let db: SQLiteInterface

    func pendingMigrations() throws -> [Migration] {
        // Read migration files
        // Query schema_migrations table
        // Return unapplied migrations
    }

    func applyMigration(_ migration: Migration) throws {
        try db.execute("""
            BEGIN TRANSACTION;
            \(migration.sql)
            INSERT INTO schema_migrations (version, applied_at, description)
            VALUES (?, datetime('now'), ?);
            COMMIT;
        """, bindings: [migration.version, migration.description])
    }

    func rollback(to version: String) throws {
        // Apply down migrations in reverse order
    }
}
```

## Schema Inspection Queries

### List All Tables
```sql
SELECT name FROM sqlite_master
WHERE type='table'
ORDER BY name;
```

### Get Table Schema
```sql
PRAGMA table_info(Layer);
```

### Get Foreign Keys
```sql
PRAGMA foreign_key_list(DataSet);
```

### Get Indexes
```sql
PRAGMA index_list(Layer);
```

## Best Practices

1. **Always Use Transactions**
   - Wrap migrations in BEGIN/COMMIT
   - Automatic rollback on failure

2. **Versioned Migrations**
   - Never modify applied migrations
   - Create new migration for changes
   - Keep migrations in version control

3. **Data Safety**
   - Test migrations on copy of production data
   - Generate rollback scripts
   - Backup before migration

4. **Schema Evolution**
   - Add columns as nullable first
   - Migrate data, then add constraints
   - Use default values when possible

5. **Testing**
   - Test both up and down migrations
   - Verify data integrity after migration
   - Test on various schema versions

## Integration with Your Project

### Current Database Models

Based on your git status and code:
- `Layer` - Base layer type
- `LayerCore`, `LayerData`, `LayerGrid`, `LayerLineArrow`, `LayerText` - Layer subtypes
- `DataSet` - Dataset storage (you're on branch 43-DatasetsTable)
- `Geometry`, `Color`, `Encoding` - Supporting types
- `WindowControllerSize` - UI state

### Migration Use Cases

1. **Adding DataSet Table** (current branch work)
   - Generate create table migration
   - Add foreign keys to Layer
   - Create indexes for performance

2. **Refactoring Layer Hierarchy**
   - Migrate from inheritance to composition
   - Update foreign key relationships
   - Transform layer type data

3. **Performance Optimizations**
   - Add indexes based on query patterns
   - Denormalize frequently joined data
   - Add computed columns

## Configuration

Store migration settings in `.database-migration.json`:
```json
{
  "migrationsPath": "./Migrations",
  "databasePath": "./testfile.sqlite",
  "trackingTable": "schema_migrations",
  "backupBeforeMigration": true,
  "autoBackup": {
    "enabled": true,
    "path": "./Backups"
  }
}
```

## Commands Reference

### Generate New Migration
```bash
# Analyze changes and create migration file
claude-skill database-migration-helper generate "add datasets table"
```

### Apply Pending Migrations
```bash
# Apply all unapplied migrations
claude-skill database-migration-helper migrate
```

### Rollback Last Migration
```bash
# Rollback the most recent migration
claude-skill database-migration-helper rollback
```

### Generate Models from Database
```bash
# Create Swift models from existing database
claude-skill database-migration-helper generate-models --from testfile.sqlite
```

### Schema Diff
```bash
# Compare code models vs database schema
claude-skill database-migration-helper diff
```
