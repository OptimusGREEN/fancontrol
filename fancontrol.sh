#!/bin/bash

# Fan control script for system fans
set_fan_speeds() {
    local pwm1=$1
    local pwm2=$2
    local pwm3=$3
    local pwm4=$4
    local pwm5=$5

    # Set manual mode for all fans
    for i in {1..5}; do
        echo 1 | sudo tee /sys/class/hwmon/hwmon2/pwm${i}_enable >/dev/null
    done

    # Set speeds
    echo $pwm1 | sudo tee /sys/class/hwmon/hwmon2/pwm1 >/dev/null
    echo $pwm2 | sudo tee /sys/class/hwmon/hwmon2/pwm2 >/dev/null
    echo $pwm3 | sudo tee /sys/class/hwmon/hwmon2/pwm3 >/dev/null
    echo $pwm4 | sudo tee /sys/class/hwmon/hwmon2/pwm4 >/dev/null
    echo $pwm5 | sudo tee /sys/class/hwmon/hwmon2/pwm5 >/dev/null

    echo "Fan speeds set to:"
    sensors | grep -E "fan[1-6]:"
    echo -e "\nCPU Temperatures:"
    sensors | grep "Core" | head -n 1
}

case "$1" in
    quiet)
        echo "Setting quiet profile (lowest speeds)"
        set_fan_speeds 51 25 51 51 51
        ;;
    normal)
        echo "Setting normal profile (balanced speeds)"
        set_fan_speeds 77 51 77 77 77
        ;;
    performance)
        echo "Setting performance profile (high speeds)"
        set_fan_speeds 180 128 180 180 180
        ;;
    auto)
        echo "Setting automatic control"
        for i in {1..5}; do
            echo 2 | sudo tee /sys/class/hwmon/hwmon2/pwm${i}_enable >/dev/null
        done
        sensors | grep -E "fan[1-6]:"
        ;;
    status)
        echo "Current PWM values:"
        for i in {1..5}; do
            echo -n "PWM$i: "
            cat /sys/class/hwmon/hwmon2/pwm$i 2>/dev/null
            echo -n "PWM$i enable mode: "
            cat /sys/class/hwmon/hwmon2/pwm${i}_enable 2>/dev/null
        done
        echo -e "\nFan speeds:"
        sensors | grep -E "fan[1-6]:"
        echo -e "\nCPU Temperatures:"
        sensors | grep "Core" | head -n 1
        ;;
    *)
        echo "Usage: $0 {quiet|normal|performance|auto|status}"
        echo "  quiet       - Lowest possible speeds"
        echo "  normal      - Balanced speeds"
        echo "  performance - High speeds"
        echo "  auto        - Automatic control"
        echo "  status      - Show current settings"
        exit 1
esac
