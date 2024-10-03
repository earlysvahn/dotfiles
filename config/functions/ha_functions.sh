#!/bin/bash

# Scene Function for Selecting and Activating Scenes
scene() {
    echo "Select a scene:"
    echo "1. Work"
    echo "2. Gaming"
    echo "3. Chill"
    echo "4. Off"
    echo -n "Enter the number of the scene: "

    read -r choice

    case $choice in
    1)
        entity_id="scene.work"
        ;;
    2)
        entity_id="scene.gaming"
        ;;
    3)
        entity_id="scene.chill"
        ;;
    4)
        entity_id="light.upstairs_office_lights"
        ;;
    *)
        echo "Invalid choice. Please select a valid option."
        return 1
        ;;
    esac

    # Make the initial API call to the primary service URL
    echo "Making API call to: $API_SERVICE_URL/scene/turn_on"
    response=$(gtimeout 1 curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $HA_CLITOKEN" -d "{\"entity_id\": \"$entity_id\"}" "$API_SERVICE_URL/scene/turn_on > /dev/null 2>&1")

    if [ -z "$response" ]; then
        # If the primary URL fails, use the backup service URL
        echo "Initial API call timed out. Making backup API call to: $API_SERVICE_URL_BACKUP/scene/turn_on"
        response=$(curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $HA_CLITOKEN" -d "{\"entity_id\": \"$entity_id\"}" "$API_SERVICE_URL_BACKUP/scene/turn_on > /dev/null 2>&1")
    fi

    echo "API response: ${response:-No response}"
}
