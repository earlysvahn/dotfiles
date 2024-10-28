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
    echo "Making API call to: $HA_LOCAL_URL/scene/turn_on"
    response=$(gtimeout 1 curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $HA_CLITOKEN" -d "{\"entity_id\": \"$entity_id\"}" "$HA_LOCAL_URL/scene/turn_on > /dev/null 2>&1")

    if [ -z "$response" ]; then
        # If the primary URL fails, use the backup service URL
        echo "Initial API call timed out. Making backup API call to: $HA_REMOTE_URL/scene/turn_on"
        response=$(curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $HA_CLITOKEN" -d "{\"entity_id\": \"$entity_id\"}" "$HA_REMOTE_URL/scene/turn_on > /dev/null 2>&1")
    fi

    echo "API response: ${response:-No response}"
}

office() {
    local brightness=20
    local color_name=""

    if [[ "$1" == "off" ]]; then
        curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $HA_CLITOKEN" \
            -d "{\"entity_id\": \"light.upstairs_office_lights\"}" \
            "$HA_LOCAL_URL/api/services/light/turn_off" >/dev/null 2>&1

        curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $HA_CLITOKEN" \
            -d "{\"entity_id\": \"switch.monitor_backlight_switch\"}" \
            "$HA_LOCAL_URL/api/services/switch/turn_off" >/dev/null 2>&1

        return
    fi

    if [[ "$1" =~ ^[0-9]+$ ]]; then
        brightness=$1
        color_name=${2:-""}
    else
        color_name=$1
        brightness=${2:-20}
    fi

    if [[ -z "$color_name" ]]; then
        r=255
        g=160
        b=0
    else
        case "$color_name" in
        "green")
            r=106
            g=127
            b=87
            ;;
        "blue")
            r=75
            g=103
            b=137
            ;;
        "yellow")
            r=179
            g=140
            b=83
            ;;
        "red")
            r=163
            g=82
            b=82
            ;;
        "purple")
            r=132
            g=97
            b=124
            ;;
        "orange")
            r=174
            g=109
            b=68
            ;;
        *)
            r=255
            g=160
            b=0
            ;;
        esac
    fi

    curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $HA_CLITOKEN" \
        -d "{\"entity_id\": \"light.upstairs_office_lights\", \"brightness_pct\": $brightness, \"rgb_color\": [$r, $g, $b]}" \
        "$HA_LOCAL_URL/api/services/light/turn_on" >/dev/null 2>&1

    curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $HA_CLITOKEN" \
        -d "{\"entity_id\": \"switch.monitor_backlight_switch\"}" \
        "$HA_LOCAL_URL/api/services/switch/turn_on" >/dev/null 2>&1

}
