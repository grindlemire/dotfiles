# activate venv, otherwise create and activate
# This also rewrites the PYTHONPATH to be inside the virtualenv
venv() {
    # If we are already in a venv then end it and return early
    if [ "$PYTHONPATH" == $(pwd) ]; then
        vend
        return
    fi 

    # If a venv is not configured then create it
    if [ ! -d venv ]; then
        virtualenv venv
    fi

    # With an existing venv enter into it
    export _OLD_VIRTUAL_PYTHONPATH=${PYTHONPATH}
    export PYTHONPATH=`pwd`
    source venv/bin/activate
}

# activate venv, otherwise create and activate a virtualenv for python3
# This also rewrites the PYTHONPATH to be inside the virtualenv 
venv3() {
    # If we are already in a venv then end it and return early
    if [ "$PYTHONPATH" == $(pwd) ]; then
        vend
        return
    fi 

    # If a venv is not configured then create it
    if [ ! -d venv ]; then
        python3 -m venv venv
    fi

    # With an existing venv enter into it
    export _OLD_VIRTUAL_PYTHONPATH=${PYTHONPATH}
    export PYTHONPATH=`pwd`
    source venv/bin/activate
}

vend() {
    deactivate
    export PYTHONPATH=${_OLD_VIRTUAL_PYTHONPATH}
    unset _OLD_VIRTUAL_PYTHONPATH
}