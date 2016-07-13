function precmd() {
  check_venv
}

function maybeworkon() {
  if [ "$1" != "$(basename $VIRTUAL_ENV)" ]; then
     if [ -z "$AUTOSWITCH_SILENT" ]; then
        printf "Switching virtualenv: %s  " $1
     fi

     workon "$1"

     if [ -z "$AUTOSWITCH_SILENT" ]; then
       # For some reason python --version writes to stderr
       printf "[%s]\n" "$(python --version 2>&1)"
     fi
  fi
}

# Automatically switch virtualenv when .venv file detected
function check_venv()
{
    if [ "$PWD" != "$MYOLDPWD" ]; then
        MYOLDPWD="$PWD"
        if [[ -f ".venv" ]]; then
           maybeworkon "$(cat .venv)"
        elif [[ -n "$AUTOSWITCH_DEFAULTENV" ]]; then
           maybeworkon "$AUTOSWITCH_DEFAULTENV"
        elif [[ -n "$VIRTUAL_ENV" ]]; then
           deactivate
        fi
    fi
}
