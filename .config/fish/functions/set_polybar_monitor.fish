# Define a function to set the POLYBAR_MONITOR variable with a monitor type argument
function set_polybar_monitor --argument monitor_type
    # Check if an argument was provided
    if test -z "$monitor_type"
        echo "Please provide a monitor type as an argument (e.g., HDMI, DP, etc.)"
        return 1
    end

    # Run the command to get the monitor name based on the given monitor type
    set -l monitor_name (polybar -M | cut -d ':' -f 1 | grep "$monitor_type" | head -n 1)

    # Check if the output is non-empty and set the environment variable
    if test -n "$monitor_name"
        set --global --export POLYBAR_MONITOR $monitor_name
        echo "POLYBAR_MONITOR set to $POLYBAR_MONITOR"
    else
        echo "No $monitor_type monitor found, POLYBAR_MONITOR not set"
    end
end

# Call the function to set the variable when the script runs. E.g.
# set_polybar_monitor "HDMI"
