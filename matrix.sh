#!/bin/bash

# Set a trap to restore terminal on Ctrl-c (exit).
# Reset character attributes, make cursor visible, show user input, and restore
# previous screen contents (if possible).
trap "tput sgr0; tput cnorm; stty echo; tput rmcup || clear; exit 0" SIGINT

# Save screen contents, make cursor invisible, and hide user input
tput smcup; tput civis; stty -echo

# Create array of possible matrix characters
chars=()
for ((i=0; i < 10; i++)); do
  chars[i]=$i
done
chars[10]=+
chars[11]=:
for ((i=101; i < 160; i++)); do
  chars[i-89]="\\uff$(printf '%x' $i)"
done

# Main render loop
declare -A matrix=()
i=0
while true; do
  num_cols="$(tput cols)"
  num_rows="$(tput lines)"

  # Update each column
  for ((i=0; i < num_cols; i++)); do
    if ((${#col_starts[@]} <= i)); then
      col_starts[$i]=-1
      col_ends[$i]=-1
    fi

    # Don't add chars offscreen
    if ((col_starts[$i] >= num_rows + 6)); then
      col_starts[$i]=999999
    fi
    # If the col is not started, start it with some probability
    if ((col_starts[i] == -1 && RANDOM % 1000 < 3)); then
      col_starts[$i]=0
    fi
    # If the col is already started, add a random character to the col
    if ((col_starts[i] > -1 && col_starts[i] != 999999)); then
      col_start=${col_starts[i]}
      # Change colors of latest 6 chars
      if ((col_start < num_rows)); then matrix[$i,$col_start]="\e[97m${chars[((RANDOM % ${#chars[@]}))]}"; fi
      if ((col_start - 1 >= 0 && col_start - 1 < num_rows)); then matrix[$i,$(($col_start-1))]="\e[38;5;49m${matrix[$i,$((col_start-1))]#*m}"; fi
      if ((col_start - 2 >= 0 && col_start - 2 < num_rows)); then matrix[$i,$(($col_start-2))]="\e[38;5;43m${matrix[$i,$((col_start-2))]#*m}"; fi
      if ((col_start - 3 >= 0 && col_start - 3 < num_rows)); then matrix[$i,$(($col_start-3))]="\e[38;5;42m${matrix[$i,$((col_start-3))]#*m}"; fi
      if ((col_start - 4 >= 0 && col_start - 4 < num_rows)); then matrix[$i,$(($col_start-4))]="\e[38;5;41m${matrix[$i,$((col_start-4))]#*m}"; fi
      if ((col_start - 5 >= 0 && col_start - 5 < num_rows)); then matrix[$i,$(($col_start-5))]="\e[38;5;40m${matrix[$i,$((col_start-5))]#*m}"; fi
      # Set col and increment col_starts
      ((col_starts[$i]++))
    fi

    # Don't remove chars offscreen
    if ((col_ends[i] >= num_rows + 4)); then
      col_ends[$i]=-1
      col_starts[$i]=-1
    fi
    # If the col is not ended, end it with some probability
    if ((col_ends[i] == -1 && col_starts[i] > 100 && RANDOM % 100 < 20)); then
      col_ends[$i]=0
    fi
    # If the col is already ended, remove the latest character from it
    if ((col_ends[i] > -1)); then
      col_end=${col_ends[i]}
      # Change colors of last 3 chars
      if ((col_end < num_rows)); then matrix[$i,$col_end]="\e[38;5;40m${matrix[$i,$col_end]#*m}"; fi
      if ((col_end - 1 >= 0 && col_end - 1 < num_rows)); then matrix[$i,$(($col_end-1))]="\e[38;5;34m${matrix[$i,$((col_end-1))]#*m}"; fi
      if ((col_end - 2 >= 0 && col_end - 2 < num_rows)); then matrix[$i,$(($col_end-2))]="\e[38;5;28m${matrix[$i,$((col_end-2))]#*m}"; fi
      if ((col_end - 3 >= 0 && col_end - 3 < num_rows)); then matrix[$i,$(($col_end-3))]="\e[38;5;22m${matrix[$i,$((col_end-3))]#*m}"; fi
      if ((col_end - 4 >= 0)); then matrix[$i,$(($col_end-4))]=''; fi
      # Set col and increment col_ends
      ((col_ends[$i]++))
    fi
  done

  # Paint the screen
  output=''
  for ((j=0; j < num_rows; j++)); do
    for ((i=0; i < num_cols; i++)); do
      a=${matrix[$i,$j]}
      if [[ -z $a ]]; then
        output+=' '
      else
        # Flicker the character with some probability
        if ((RANDOM % 100 < 5)); then
          a="${chars[((RANDOM % ${#chars[@]}))]}"
          matrix[$i,$j]="${matrix[$i,$j]%m*}m$a"
          a=${matrix[$i,$j]}
        fi
        output+=$a
      fi
    done
    if ((j < num_rows - 1)); then
      output+='\n'
    fi
  done
  tput home
  echo -en "$output"
done
