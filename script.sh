#!/bin/bash

##THIS IS OUR GLOBAL VARIABLE WHICH HOLDS THE PATH TO OUR RECORD DATA BASE
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


##The function runs until the input string is correct - no spaces,letters & numbers only
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

##Validates the entered amount, only whole numbers allowed, no spaces, >0
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

##This is the log which holds the information about success and failure of functions.
##The log opens new log for every record data base.
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
            # Log $FUNCNAME Failure   #should this be recorded????
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

### This function adds a record to the system. It has a few options: it can make quntity of certain record larger, and can add a new record to the data base.
function Insert()
{
    local input_string=0
    local input_amount=0
    local user_choice=""
    local num=0
    local status=0
    
    while [[ $status -eq 0 ]]
    do
        echo "Hello! please choose the number of the following options:"
	echo "1)Add new record"
	read -p "2)Add copies to existing record: " num
	#read number

    if [[ $num -eq 1 ]]
    then
    input_string=$(CheckString)
    input_amount=$(CheckInt)

    find_in_file=`grep ^"$input_string" "$filename"`


    while [ -n "$find_in_file" ]
    do 
        echo "a record with the same name exists."
        input_string=$(CheckString)
        find_in_file=`grep ^"$input_string" "$filename"`

    done
    Log $FUNCNAME success

    echo "$input_string,$input_amount" >> $filename
    echo "new record has been added!"
    status=1 

    elif [[ $num -eq 2 ]]
    then 
        input_string=$(CheckString)
        input_amount=$(CheckInt)

        MakeList $input_string user_choice

        declare old_count=`echo "$user_choice" | cut -d',' -f 2`

        # find the value to add
        let added_value=$input_amount
        declare new_count=$((old_count+added_value))

        # create the text for the new value
        new_string=`echo "$user_choice" | cut -d',' -f 1`
        new_text=`echo $new_string,$new_count`

        # this command replaces the text
        sed -i "s/$user_choice/$new_text/g" $filename

        echo "record added successfully: $new_text" 
        Log $FUNCNAME success
        status=1

        else

        echo "invalid text. Please enter 1 or 2!"
        status=0
        Log $FUNCNAME failure
        fi

    done

    MainMenu
}

##The function deletes the wanted amount of a certain record.
function Delete()
{
    local SearchString=$(CheckString)
    local choiceAmount=$(CheckInt)    #chosen amount to delete 
    local full_tapename
    local tapename=""
    local tapeamount=""
    local inputCorrect=1 #incorrect,enters while loop

    MakeList $SearchString full_tapename  
    tapename=$(echo $full_tapename | cut -d "," -f "1")
    tapeamount=$(echo $full_tapename | cut -d "," -f "2")
    
    echo "You have selected a tape $tapename with amount of $tapeamount copies"
    
    while [ $inputCorrect -eq 1 ] #runs as long as the input is incorrect
    do
        # Check if choice is validate
        if [[ $choiceAmount -le $tapeamount ]]; then
            
            inputCorrect=0  #correct, exits while loop
            # Subtracting amount of copies
            let finalamount=($tapeamount - $choiceAmount)
            if [[ "$finalamount" -gt 0 ]]; then
                sed -i "s/$full_tapename/$tapename,$finalamount/g" $filename
                echo "New amount copies of $tapename is $finalamount"
                Log $FUNCNAME Success          
            else [[ "$finalamount" -eq 0 ]]
                sed -i "/$full_tapename/d" $filename
                echo "You have deleted all copies of $tapename"
                Log $FUNCNAME Success           
            fi
        else
            echo "Incorrect"
            inputCorrect=1
            Log $FUNCNAME Failure
            echo "How many copies would you like to delete? - Maximum  $tapeamount"
            choiceAmount=$(CheckInt $choice)
        fi
    done
    MainMenu    
}


##the function outputs the results of a string search.
###It will output a list of matching records.
function Search()
{
    local string_input=$(CheckString) #the input of the user's string
    local array_of_result=() #the array of which we will print the results
    local array_sorted=()
    local search_result=""
    local sorted=""

    # read filename line by line using grep and add all the result to array
    search_result=$(grep "$string_input" "$filename")

    if [ -n "$search_result" ]
    then
        #this is the command to sort the rsults of the search
        sorted=$(echo $search_result | tr ' ' '\n' | sort )
        #this is moving the results into an array
        for i in $sorted; do
            array_of_result+=("$i")
        done
      
        Log $FUNCNAME Success
    else
        echo Sorry, no matches.
        Log $FUNCNAME Failure
    fi
        
    #prints the sorted search results:
    for value in "${array_of_result[@]}"; do
        echo "$value"

    done

    MainMenu
}

###This function allows the user to change a record's name.
function UpdateName() {
    local userinput=""
    local full_tapename=""
    local search_string_old=$(CheckString)
    MakeList $search_string_old full_tapename
    local isNewNameUnique=1
    local line_search=""
    local tapename=$(echo $full_tapename | cut -d "," -f "1")
    local tapeamount=$(echo $full_tapename | cut -d "," -f "2")
    echo "A new file name ->"
    while [[ $isNewNameUnique -eq 1 ]]
    do
    userinput=$(CheckString)
    isNewNameUnique=0
    local line_search=`grep -w $userinput $filename`
        if [[ ! -z $line_search ]]
        then
            echo "Record name already exists, please choose a different name."
            isNewNameUnique=1
        fi
    done
    if sed -i "s/$tapename/$userinput/g" "$filename"
    then
        Log $FUNCNAME Success
    else
        Log $FUNCNAME Failure
    fi
MainMenu
}

##This function replaces the amount of a certain type of record with a new amount chosen by the user.
function UpdateAmount() {
    local input_string=$(CheckString)
    local new_amount=$(CheckInt)
    #this is the name of a record and an amount input by the user
    local status=0 #the condition to enter the while loop.
    while [[ $status -eq 0 ]]
    do       
        #line_search=`grep $inpu $filename`  #searches for the record in the file
        MakeList $input_string full_tapename

    	local tapename=$(echo $full_tapename | cut -d "," -f "1")
    	local old_amount=$(echo $full_tapename | cut -d "," -f "2")

        sed -i "s/"$full_tapename"/"$tapename,$new_amount"/" $filename
        echo "The change has been made successfully. New amount of copies for $tapename is $new_amount"
        Log $FUNCNAME Success
        
        status=1
        
    done
    MainMenu
}

### This function prints the entire data base in order. 
function PrintAll() {
    local allRecords=$(sort $filename)
    if [ -s $filename ]
    then
        for single in $allRecords
        do
            local recordsOnly=$(echo $single | cut -d "," -f "1")
            local amountOnly=$(echo $single | cut -d "," -f "2")
            echo Record name: $recordsOnly, Copies: $amountOnly
            Log $FUNCNAME $recordsOnly $amountOnly
        done
    else
        echo file empty
        Log $FUNCNAME the_file_is_empty
    fi
MainMenu
}

### This function is the main menu and the interface of our our program! it also updates the data base after it changes.
function MainMenu() {
    local chosenAction
    local inputString
    local inputAmount
    local chosenEntry
    CheckFile
    local fileDataUpdate=""

    fileDataUpdate=$(cat $filename)

    #echo printing $1
    select choice in  Add Delete Search Update_Name Update_Amount Print_Sorted_Collection Exit
    do
        case $choice in
            Add)
            echo "You have chosen to add records, record name and number of copies to add are required."                  
            Insert 
            ;;
            Delete)
            echo "You have chosen to delete records, record name and number of copies to delete are required." 
            Delete   
            ;;
            Search)
            echo "You have chosen to search for records, record name is required."
            Search    
            ;;
            Update_Name)
            echo "You have chosen to update record name, old record name and new record name are required."
            UpdateName   
            ;;
            Update_Amount)
            echo "You have chosen to change the record amount, record name and number of copies are required."
            UpdateAmount   
            ;;
            Print_Sorted_Collection)
            echo "You have chosen to print the record collection."   
            PrintAll   
            ;;
            Exit)
            echo "Exiting record collection database."
            exit
            ;;
            *)
            echo "Please enter a number, 1-8 only"
            ;;
        esac
    done    
}

##################################################################################################
#########################################@@@MAIN@@@###############################################
MainMenu
