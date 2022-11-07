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

//Validates the entered amount, only whole numbers allowed, no spaces, >0
function CheckInt() {
    local check='^[0-9]+$'
    local amount
    local inputCorrect=1   #incorrect,enters while loop
    local message="Please enter the required amount of records: "

    while [ $inputCorrect -eq 1 ]   #runs as long as the input is incorrect
    do
        read -p "$message" amount
        inputCorrect=0  #correct, exits while loop
        if ! [[ $amount =~ $check ]]
        then
            inputCorrect=1  #incorrect, enters while loop again
            message="This is not a valid number. Please enter positive whole numbers only, no spaces: "
        elif [[ $amount -eq 0 ]]
        then
            inputCorrect=1  #incorrect, enters while loop again
            message="This is not a valid number. Please enter numbers greater then 0: "
        fi
    done
    echo $amount 
    
}

//This is the log which holds the information about success and failure of functions.
//The log opens new log for every record data base.
function Log() {
    local calledFun=$1
    local status1=$2
    local status2=$3
    
    echo $(date +%d/%m/%y" "%T) $calledFun $status1 $status2 >> "$filename"_log
    status2=""
}
