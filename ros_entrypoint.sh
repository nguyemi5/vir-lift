#!/bin/bash
set -e

# setup ros environment
source "/usr/local/ros/$ROS_DISTRO/setup.bash"
exec "$@"
