#!/bin/bash

CRASHLOOP_COUNT=$(kubectl get pods --all-namespaces --no-headers --context=gke_bird-nest-prod_europe-north1_bird-nest-cluster | grep -c 'CrashLoopBackOff')

if [ "$CRASHLOOP_COUNT" -eq 0 ]; then
  sketchybar --remove item kube_crashloop
  exit 0
fi

ICON="􀇾"
ICON_COLOR="0xFFFF0000"

sketchybar --query kube_crashloop >/dev/null 2>&1 || sketchybar --add item kube_crashloop right

sketchybar --set kube_crashloop icon.color="$ICON_COLOR" icon="$ICON" label="$CRASHLOOP_COUNT" icon.highlight_color=$ICON_COLOR label.color="$ICON_COLOR"
