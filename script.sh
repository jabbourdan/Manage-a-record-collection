#!/bin/bash

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

###This function searches for a string and outputs in a numbered menu the list of matches for the string. 
function MakeList()
{
    local final_result=""
    local search_string=$1
    local outside_varname=$2
    local search_result=""
    local array_of_result=()
    local number=0
    local counter=1
    local status=1
    local charType='^[0-9]+$'
    local i=""

    #while loop until the user chose the correct option
    status=1
    local readFile=1
    while [[ $status -eq 1 ]] ; do
    # read filename line by line using grep and add all the result to array
        while [[ $readFile -eq 1 ]]
        do
        search_result=$(grep "$search_string" "$filename")
       
        for i in $search_result; do
           
            array_of_result+=("$i")
        done
        readFile=0  #finished reading file, exiting while
        done 
        
        counter=1
        number=0
        
        if [[ ${#array_of_result[@]} -eq 1 ]]   #checking if only one value in array
        then
            echo "The search result is ${array_of_result[0]}"
            number=0  #first index ->final result at the end of function
	    Log $FUNCNAME success
            status=0 # exits while loop
        elif  [[ ${#array_of_result[@]} -eq 0 ]]   #checking if no values in array
        then
            ##Log $FUNCNAME Failure   #should this be recorded????
            echo "No matching results"
            search_string=$(CheckString)
        else
            for value in "${array_of_result[@]}"; do
                echo "$counter) $value"
                let "counter=($counter+1)"
            done
            let "counter=($counter-1)"
            # prompt for user
            read -rp "Please choose a number  between 1 to $counter: " number      
            if [[ $number =~ $charType ]] && [[ $number -le $counter ]] && [[ $number -gt 0 ]]    
	    #######changed to greater then to avoid negative values, added char validaion
            then
                let number=$number-1
		Log $FUNCNAME success
                status=0
            else
                echo "Invalid input, please choose again."
                Log $FUNCNAME failure
            fi
        fi
    done
    final_result="${array_of_result[$number]}"
    eval $outside_varname="'$final_result'"
}
