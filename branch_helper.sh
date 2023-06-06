# Bash script to search git branch names easier
# By default looks only at local branches and is case insensitive
# Takes possible flags:
# -r/--remote          Look for only remote branches
# -a/--all             Look for both local and remote branches
# -f/--fuzzy           Filters branches by allowing matches with the characters in that order
# -s/--sensitive       Makes text matching case sensitive
for word in $@
do
  case $word in 
    -r | --remote ) REMOTE=1 ;;
    -a | --all ) ALL=1 ;;
    -f | --fuzzy ) FUZZY=1;;
    -s | --sensitive ) SENSITIVE=1;;
    * ) ;;
  esac
done

if [[ "$REMOTE" == "1" && -z "$ALL" ]]
  then BRANCH_ARG="-r"
elif [[ "$ALL" == "1" ]]
  then BRANCH_ARG="-a"
fi

if [[ "$FUZZY" == "1" ]]
then
  word=$(echo "$word" | sed 's/\(.\)/\1.*/g')
fi

GREP_ARG="-i"

if [[ "$SENSITIVE" == "1" ]]
  then GREP_ARG=
fi

git branch $BRANCH_ARG | grep $GREP_ARG "$word"
