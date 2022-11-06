#!/bin/bash
'
#THIS IS OUR GLOBAL VARIABLE WHICH HOLDS THE PATH TO OUR RECORD DATA BASE
filename=$1
##checking if the file exist and creating one if not.

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
