#!/bin/bash

# Function to search for branches matching the keyword (case-insensitive)
search_branches() {
    local keyword="$1"
    local local_branches=$(git branch | awk -v keyword="$keyword" 'BEGIN{IGNORECASE=1} /^[^*]/ && tolower($0) ~ tolower(keyword) {print $1}')
    local remote_branches=$(git branch -r | awk -v keyword="$keyword" 'BEGIN{IGNORECASE=1} /^[^*]/ && tolower($0) ~ tolower(keyword) {print $1}')
    remote_branches="$remote_branches" | sed 's/^[[:space:]]*origin\///'

    echo "$local_branches"
    echo "$remote_branches"
}

# Function to print branch list
print_branches() {
    local start_index=("$1")
    local end_index=$((start_index+10));
    local branches=("${@:2}")
    local branches_count=${#branches[@]}

    echo "Found $branches_count branches matching '$keyword':"
    echo ""

    if [[ $branches_count -lt $end_index ]]; then
        end_index=$branches_count
    fi

    for ((i=start_index; i<end_index; i++)); do
        echo "[$((i+1))] ${branches[i]}"
    done

    echo ""
    echo "Enter the number corresponding to the branch you want to switch to (1-$((branches_count)))"
    echo "or press Enter for more results:"
}

# Function to switch branches
switch_branch() {
    local branch="${branches[$(($1-1))]}"

    if [[ -n "$branch" ]]; then
        # if it's a remote branch then get rid of this
        branch=$(echo "$branch" | sed 's/^[[:space:]]*origin\///')
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

    echo -e "\033c"  # Clear the screen

    echo "Page: $(($current_page+1))"
    print_branches $((current_page*10)) "${branches_to_display[@]}"

    while true; do
        read choice

        if [[ -z "$choice" ]]; then
            start_index=$((next_page * 10))
            next_page=$((current_page + 1))
            end_index=$((start_index + 9))

            if [[ $start_index -lt $branches_count ]]; then
                if [[ $end_index -ge $branches_count ]]; then
                    end_index=$((branches_count - 1))
                    next_page=0
                fi

                prompt_for_branch_selection $next_page "${branches_to_display[@]}"
                break
            else
                echo "No more branches to display."
                exit 0
            fi
        elif [[ $choice =~ ^[0-9]+$ && $choice -ge 1 && $choice -le $branches_count ]]; then
            switch_branch "$choice"
            break
        else
            echo "Invalid choice."
            echo "Please enter a valid number (1-$branches_count), or press Enter for more results:"
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
    prompt_for_branch_selection 0 "${branches[@]}"
fi

