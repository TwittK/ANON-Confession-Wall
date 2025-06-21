#!/bin/bash

MIGRATION_NAME="$1"

if [ -z "$MIGRATION_NAME" ]; then
  read -p "Enter migration name: " MIGRATION_NAME
fi

OUTPUT_DIR="Migrations/Development"
DB_CONTEXT="AppDbContext"  
PROJECT_NAME="AnonConfessionWall.csproj"

echo "Creating EF migration: $MIGRATION_NAME in $OUTPUT_DIR..."
dotnet ef migrations add "$MIGRATION_NAME" \
  --context "$DB_CONTEXT" \
  --project "$PROJECT_NAME" \
  --startup-project . \
  --output-dir "$OUTPUT_DIR" \
  --verbose

if [ $? -ne 0 ]; then
    echo "Migration failed."
    exit 1
fi

echo "Applying migration to local MySQL database (Development)..."
dotnet ef database update --context "$DB_CONTEXT" -- --environment Development
if [ $? -ne 0 ]; then
    echo "Database update failed."
    exit 1
fi

echo "Local migration complete!"
