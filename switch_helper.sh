#!/bin/bash

# Function to search for branches matching the keyword (case-insensitive)
search_branches() {
  local keyword="$1"
  git branch | awk -v keyword="$keyword" 'BEGIN{IGNORECASE=1} /^[^*]/ && tolower($0) ~ tolower(keyword) {print $1}'
}

# Function to print branch list
print_branches() {
  local branches=("$@")
  local count=${#branches[@]}
  
  echo "Found $count branches matching '$keyword':"
  
  for ((i=0; i<count; i++)); do
    echo "[$((i+1))] ${branches[i]}"
  done
  
  echo "Please enter the number corresponding to the branch you want to switch to (1-$count), or press Enter for more results:"
}

# Function to switch branches
switch_branch() {
  local branch="${branches[$1-1]}"
  
  if [[ -n "$branch" ]]; then
    git checkout "$branch"
    echo "Switched to branch '$branch'."
  else
    echo "Invalid branch number. Please try again."
    prompt_for_branch_selection
  fi
}

# Function to prompt for branch selection
prompt_for_branch_selection() {
  local current_page="$1"
  local branches_to_display=("${@:2}")
  local branches_count=${#branches_to_display[@]}
  
  echo "Page: $current_page"
  print_branches "${branches_to_display[@]}"
  
  while true; do
    read choice
    
    if [[ -z "$choice" ]]; then
      next_page=$((current_page + 1))
      start_index=$((next_page * 10))
      end_index=$((start_index + 9))
      
      if [[ $end_index -lt $branches_count ]]; then
        branches_to_display=("${branches[@]:start_index:end_index}")
        prompt_for_branch_selection "$next_page" "${branches_to_display[@]}"
        break
      else
        echo "No more branches to display."
        exit 0
      fi
    elif [[ $choice =~ ^[0-9]+$ && $choice -ge 1 && $choice -le $branches_count ]]; then
      switch_branch "$choice"
      break
    else
      echo "Invalid choice. Please enter a valid number (1-$branches_count), or press Enter for more results:"
    fi
  done
}

keyword="$1"

# Search for branches matching the keyword (case-insensitive)
branches=($(search_branches "$keyword"))
branch_count=${#branches[@]}

# Check number of matches
if [[ $branch_count -eq 0 ]]; then
  echo "No branches found matching '$keyword'. Exiting..."
  exit 1
elif [[ $branch_count -eq 1 ]]; then
  switch_branch 1
else
  # Check number of matches for user interaction
  if [[ $branch_count -gt 10 ]]; then
    branches_to_display=("${branches[@]:0:10}")
    prompt_for_branch_selection 1 "${branches_to_display[@]}"
  else
    prompt_for_branch_selection 1 "${branches[@]}"
  fi
fi

