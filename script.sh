#!/bin/bash
'
//THIS IS OUR GLOBAL VARIABLE WHICH HOLDS THE PATH TO OUR RECORD DATA BASE
filename=$1
//checking if the file exist and creating one if not.

function CheckFile () {
    if ! [ -f $filename ]
    then
        read -p 'file dont exist,
        do you whant to create one with the same name??
        YES?
        NO?
        ' answer
        answer=$( echo $answer | tr '[:upper:]' '[:lower:]')
        case $answer in
            yes | y)
                touch $filename
            echo file created successfully! ;;
            no | n)
                echo file wasnt created! thank you and good-bye
            exit 0 ;;
            *)
                echo not valid input, please try again
            exit 0 ;;
        esac
        #echo file created
    fi
}


//The function runs until the input string is correct - no spaces,letters & numbers only
function CheckString() {
    local check='^[a-zA-Z0-9]+$'
    local recName
    local inputCorrect=1   #incorrect input
    local message="Please enter the record name: "
    
    while [ $inputCorrect -eq 1 ]   #runs as long as the input is incorrect
    do
        read -p "$message" recName
        inputCorrect=0  #correct, exits while loop
        if ! [[ $recName =~ $check ]]
        then
            inputCorrect=1  #incorrect, enters while loop again
            message="This is not a valid name. Please enter a name consisting of letters and numbers only, no spaces. "
        fi
    done
    echo $recName
    
}
