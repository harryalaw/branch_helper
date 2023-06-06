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
  
  echo "Please enter the number corresponding to the branch you want to switch to:"
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
  print_branches "${branches[@]}"
  
  while true; do
    read choice
    
    if [[ $choice =~ ^[0-9]+$ && $choice -le $branch_count ]]; then
      switch_branch "$choice"
      break
    else
      echo "Invalid choice. Please enter a valid number:"
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
  if [[ $branch_count -gt 5 ]]; then
    while true; do
      echo "Too many matches found. Please enter a different keyword:"
      read keyword
      
      branches=($(search_branches "$keyword"))
      branch_count=${#branches[@]}
      
      if [[ $branch_count -lt 6 ]]; then
        break
      fi
    done
  fi
  
  prompt_for_branch_selection
fi

