#!/bin/expect -f
#
# This script automates 'ssh-add' to provide a passphrase.
#
# Usage: ./add_key.exp <path_to_key> <passphrase>

# Get the arguments passed to the script
set key_path [lindex $argv 0]
set passphrase [lindex $argv 1]

# --- Argument Validation ---
if { $key_path == "" } {
    send_user "Error: Missing argument 1: path_to_key\n"
    send_user "Usage: $argv0 <path_to_key> <passphrase>\n"
    exit 1
}

if { $passphrase == "" } {
    send_user "Error: Missing argument 2: passphrase\n"
    send_user "Usage: $argv0 <path_to_key> <passphrase>\n"
    exit 1
}

# --- Main Logic ---

# Spawn the ssh-add command with the key path
spawn ssh-add $key_path

# Wait for specific outputs from the spawned command
expect {
    # Case 1: Success - it asks for the passphrase
    "*Enter passphrase for $key_path*" {
        # Send the passphrase (and a carriage return)
        send "$passphrase\r"

        # After sending, wait for the *result*
        expect {
            "*Identity added*" {
                # Success!
                send_user "Success: Identity added: $key_path\n"
                exit 0
            }
            "*Bad passphrase*" {
                # Failure
                send_user "Error: Bad passphrase provided for $key_path.\n"
                exit 1
            }
        }
    }

    # Case 2: The key is already in the agent
    "*Identity already in agent*" {
        send_user "Info: Identity $key_path is already in the agent.\n"
        exit 3
    }

    # Case 3: Error connecting to the agent
    "*Could not open a connection to your authentication agent*" {
        send_user "Error: ssh-agent is not running.\n"
        send_user "Run 'eval \$(ssh-agent -s)' before this script.\n"
        exit 2
    }

    # Case 4: General timeout
    timeout {
        send_user "Error: Script timed out waiting for ssh-add prompt.\n"
        exit 1
    }

    # Case 5: End of file (command finished unexpectedly)
    eof {
        send_user "Error: ssh-add exited unexpectedly.\n"
        exit 1
    }
}