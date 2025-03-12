#!/bin/bash

# Ensure all calendar variables are set
if [[ -z "$ICAL_FREDRIK" || -z "$ICAL_JOLINE" || -z "$ICAL_NOAH" || -z "$ICAL_ALBIN" || -z "$ICAL_FAMILY" ]]; then
  echo "Error: One or more ICAL_* environment variables are not set."
  exit 1
fi

# Join calendar names into a single comma-separated string
ICAL_CALENDARS="${ICAL_FREDRIK}, ${ICAL_JOLINE}, ${ICAL_NOAH}, ${ICAL_ALBIN}, ${ICAL_FAMILY}"

# SQLite database file
DB_FILE="./task_data.db"

# Set default LLM to Mistral
DEFAULT_LLM_ID="mistral"

# Check if Mistral model is installed
if ! ollama list | grep -q "$DEFAULT_LLM_ID"; then
  echo "Mistral model not found. Pulling..."
  ollama pull "$DEFAULT_LLM_ID"
fi

# Get calendar events for the upcoming week
events=$(icalBuddy -npn -nc -nrd -li 10 -ic "$ICAL_CALENDARS" eventsFrom:today to:7days)

# If no events, exit
if [[ -z "$events" ]]; then
  echo "No upcoming events for the next week."
  exit 0
fi

# Process each event one by one
while IFS= read -r raw_event; do
  # Trim spaces and replace bullet points
  event_name=$(echo "$raw_event" | sed 's/^• *//g' | xargs)

  # Skip empty events (to avoid `choose` breaking)
  [[ -z "$event_name" ]] && continue

  # Generate summary with Ollama (Mistral)
  summary=$(echo "$event_name" | ollama run "$DEFAULT_LLM_ID" "Sammanfatta det här evenemanget på svenska och ge en påminnelse.")

  # Use choose to ask user for action
  choice=$(printf "Spara\nHoppa över\nRedigera påminnelse" | choose -i)

  case "$choice" in
  "Spara")
    reminder=$(choose -i --header "Skriv en påminnelse för: $event_name")
    sqlite3 "$DB_FILE" "INSERT INTO event_summary (event_name, summary, reminder, llm_id) VALUES ('$event_name', '$summary', '$reminder', '$DEFAULT_LLM_ID');"
    echo "✅ Sammanfattning sparad för '$event_name'."
    ;;
  "Redigera påminnelse")
    reminder=$(choose -i --header "Redigera din påminnelse för: $event_name")
    sqlite3 "$DB_FILE" "INSERT INTO event_summary (event_name, summary, reminder, llm_id) VALUES ('$event_name', '$summary', '$reminder', '$DEFAULT_LLM_ID');"
    echo "📝 Påminnelse uppdaterad för '$event_name'."
    ;;
  *)
    echo "⏩ Skipping '$event_name'."
    ;;
  esac

done <<<"$events"

echo "✅ Klart!"
