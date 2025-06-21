#!/bin/bash

# === Configuration ===
EC2_USER="student19"
EC2_HOST="3.15.165.2"
SSH_KEY_PATH="$HOME/.ssh/ICT2216-student19.pem"
LOCAL_PORT=8080
REMOTE_PORT=3306
MIGRATION_NAME="$1"
MIGRATION_DIR="Migrations/Deployment"

# === Step 1: Check if PEM file is in ssh folder ===
if [ ! -f "$SSH_KEY_PATH" ]; then
  echo "SSH key not found at $SSH_KEY_PATH"
  exit 1
fi

# === Step 2: Start SSH Tunnel in background and track PID ===
echo "Establishing SSH tunnel to $EC2_HOST..."
ssh -f -i "$SSH_KEY_PATH" -L $LOCAL_PORT:localhost:$REMOTE_PORT $EC2_USER@$EC2_HOST -N

# Wait a moment to ensure tunnel starts
sleep 2

# Get PID of tunnel process
TUNNEL_PID=$(pgrep -f "ssh -f -i $SSH_KEY_PATH -L $LOCAL_PORT:localhost:$REMOTE_PORT $EC2_USER@$EC2_HOST")
if [ -z "$TUNNEL_PID" ]; then
  echo "Failed to establish SSH tunnel (no PID found). Exiting."
  exit 1
fi

echo "SSH tunnel established (PID: $TUNNEL_PID): localhost:$LOCAL_PORT -> $EC2_HOST:$REMOTE_PORT"

# === Step 3: Run EF Core commands ===
if [ -z "$MIGRATION_NAME" ]; then
  read -p "Enter migration name: " MIGRATION_NAME
fi

echo "Creating EF migration: $MIGRATION_NAME"
dotnet ef migrations add "$MIGRATION_NAME" --output-dir "$MIGRATION_DIR" --context AppDbContext
if [ $? -ne 0 ]; then
  echo "Migration failed. Cleaning up SSH tunnel..."
  kill "$TUNNEL_PID"
  exit 1
fi

echo "Applying migration to remote MySQL database..."
dotnet ef database update -- --environment Production
if [ $? -ne 0 ]; then
  echo "Database update failed. Cleaning up SSH tunnel..."
  kill "$TUNNEL_PID"
  exit 1
fi

echo "Migration complete and applied to remote DB!"

# === Step 4: Clean up SSH Tunnel ===
echo "Closing SSH tunnel (PID: $TUNNEL_PID)..."
kill "$TUNNEL_PID"
echo "Tunnel closed."
