#!/bin/bash
#
# Generate random password with specify char set and number of chars
#
# Reference:
# - https://www.howtogeek.com/howto/30184/10-ways-to-generate-a-random-password-from-the-command-line/
#

# settings
# password set of: NUMERIC, ALPHA, UPPER, LOWER, UPPER_NUMERIC, LOWER_NUMERIC, ALPHA_NUMERIC, ALPHA_NUMERIC_SPECIAL
PASSWORD_COUNT=1
PASSWORD_SET="ALPHA_NUMERIC"
PASSWORD_CHARS=32
NUM_ARGS=0

# Function
SCRIPT_NAME=${0##*/}
Usage () {
    echo
    echo "Description:"
    echo "Generate random password with specify char set and number of chars"
    echo
    echo "Usage: $SCRIPT_NAME"
    echo "Options:"
    echo " -c  [count]                  Count of passwords to be generated (default $PASSWORD_COUNT)"
    echo " -s  [set]                    Password set of: NUMERIC, ALPHA, UPPER, LOWER, SPECIAL, UPPER_NUMERIC, LOWER_NUMERIC, ALPHA_NUMERIC, ALPHA_NUMERIC_SPECIAL (default $PASSWORD_SET)"
    echo " -n  [num]                    Password number of characters; default $PASSWORD_CHARS)"
    echo " -h                           Print this help message"
    echo
}

# Parse input argument(s)
while [ "${1:0:1}" == "-" ]; do
    OPT=${1:1:1}
    case "$OPT" in
    "c")
        PASSWORD_COUNT=$2
        shift
        ;;
    "s")
        PASSWORD_SET=$2
        shift
        ;;
    "n")
        PASSWORD_CHARS=$2
        shift
        ;;
    "h")
        Usage
        exit
        ;;
    esac
    shift
done

if [ "$#" -lt "$NUM_ARGS" ]; then
    echo "Invalid parameter!"
	Usage
	exit 1
fi

# handle password set of: NUMERIC, ALPHA, UPPER, LOWER, UPPER_NUMERIC, LOWER_NUMERIC, ALPHA_NUMERIC, ALPHA_NUMERIC_SPECIAL
chars_upper='A-Z'
chars_lower='a-z'
chars_numeric='0-9'
chars_special='-_.~'
chars_alpha=$chars_upper$chars_lower
chars_upper_numeric="$chars_upper$chars_numeric"
chars_lower_numeric="$chars_lower$chars_numeric"
chars_alpha_numeric="$chars_alpha$chars_numeric"
chars_alpha_numeric_special="$chars_alpha$chars_numeric$chars_special"
case "$PASSWORD_SET" in
    "UPPER")
    password_set=$chars_upper
    ;;
    "LOWER")
    password_set=$chars_lower
    ;;
    "NUMERIC")
    password_set=$chars_numeric
    ;;
    "ALPHA")
    password_set=$chars_alpha
    ;;
    "UPPER_NUMERIC")
    password_set=$chars_upper_numeric
    ;;
    "LOWER_NUMERIC")
    password_set=$chars_lower_numeric
    ;;
    "ALPHA_NUMERIC")
    password_set=$chars_alpha_numeric
    ;;
    "ALPHA_NUMERIC_SPECIAL")
    password_set=$chars_alpha_numeric_special
    ;;
    *)
    password_set=$chars_alpha_numeric
    ;;
esac

for (( i=0; i<$PASSWORD_COUNT; i++)); do
    < /dev/urandom tr -dc $password_set | head -c$PASSWORD_CHARS; echo;
done
