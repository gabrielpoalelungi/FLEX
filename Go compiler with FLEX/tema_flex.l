%{
// Poalelungi Gabriel 331CC

#include <stdio.h>
#include <stdlib.h>

int line_nr = 1;

// Change this value to 1 if you want to see all the variables and their values
// stored. The printing is done when a variable is initialised
// Change this value to 0 otherwise.
int print_values = 0;

char current_func_name[20] = "main";
char return_type[8];

// Int variables
struct variable_int {
    char name;
    char func_name[20];
    int value;
};
struct variable_int variables_int[20];
int variables_count_int = 0;

// Strings
struct variable_string {
    char name;
    char func_name[20];
    char value[20];
};
struct variable_string variables_string[20];
int variables_count_string = 0;

// Float variables
struct variable_float32 {
    char name;
    char func_name[20];
    float value;
};
struct variable_float32 variables_float[20];
int variables_count_float = 0;

// Bool variables
struct variable_bool {
    char name;
    char func_name[20];
    char value[6];
};
struct variable_bool variables_bool[20];
int variables_count_bool = 0;

// Variables name buffer
char variables_buffer[20];
int nr_variables = 0;
int variables_buff_count = 0;

char function_names[20][20];
int nr_functions = 0;

%}

%s COMMSIMPLU COMMCOMPUS VAR
%s ATRIBUIRE ATRIBUIRE_ALTERNATIVA
%s INT_TYPE STRING_TYPE FLOAT32_TYPE BOOL_TYPE ANYTHING_TYPE
%s GARBAGE GARBAGE_FUNCTION
%s FUNC ANTET FUNCTION_CONTENT RETURN FUNC_TYPE

ComentariuSimplu "//"
ComentariuCompus "/*"

Cuvant [A-Za-z0-9]*[ \t]*

Var "var "
Separator ", "
NumeVariabila [a-zA-Z]
Atribuire " = "
AtribuireAlternativa " := "
Func "func "
Return [\t]*"return "

Int [+-]?[0-9]+
Float32 {Int}\.[0-9]+?
String "\""{Cuvant}*"\""
Bool "true"|"false"

int_type " int"[ ]*"="?[ ]*
float32_type " float32"[ ]*"="?[ ]*
string_type " string"[ ]*"="?[ ]*
bool_type " bool"[ ]*"="?[ ]*
anything_type [ ]*"="?[ ]*

%%
<GARBAGE_FUNCTION>. {
    // When in this state, it means that it was an error with the current function,
    // so skip everything inside function
}

<GARBAGE_FUNCTION>[ \n] {line_nr++;}

<GARBAGE_FUNCTION>"}"[ \n] {
    BEGIN(INITIAL);
    nr_variables = 0;
    variables_buff_count = 0;
    line_nr++;
}

<GARBAGE>. {
    // When in this state, everything until new line is ignored;
}

<GARBAGE>[\n]* {
    // Begin INITIAL state, increment line counter and reset variables name buffer;
    BEGIN(INITIAL);
    nr_variables = 0;
    variables_buff_count = 0;
    line_nr += yyleng;
}

<INITIAL>{ComentariuSimplu} {
    // State that implements the functionality of a simple comment
    BEGIN(COMMSIMPLU);
}

<INITIAL>{ComentariuCompus} {
    // State that implements the functionality of a multi-line comment
    BEGIN(COMMCOMPUS);
}

<INITIAL>{Var} {
    // Begin VAR state
    BEGIN(VAR);
}

<INITIAL>{Func} {
    // Begin FUNC state
    BEGIN(FUNC);
}

<FUNC>{Cuvant} {
    int OK = 1;
    // Check if this function name has been used;
    for(int i = 1; i <= nr_functions; i++) {
        if(strcmp(function_names[i], yytext) == 0) {
            printf("line %d: '%s' redeclared in this file\n", line_nr, yytext);
            BEGIN(GARBAGE_FUNCTION);
            OK = 0;
            break;
        }
    }
    // If the check was successful, add this name in the list of function names
    if(OK == 1) {
        nr_functions++;
        strcpy(function_names[nr_functions], yytext);
        strcpy(current_func_name, yytext);
    }
}

<FUNC>"(" {BEGIN(ANTET);}

<ANTET>{NumeVariabila}{Separator}? {
    // Store all variables in the buffer until we find their type
    nr_variables++;
    variables_buffer[nr_variables] = *yytext;
}

<ANTET>" int"{Separator}? {
    // Add all the variables in the int category
    variables_buff_count = nr_variables;
    while(nr_variables != 0) {
        variables_count_int++;
        nr_variables--;
        strcpy(variables_int[variables_count_int].func_name, current_func_name);
        variables_int[variables_count_int].name = variables_buffer[variables_buff_count - nr_variables];
    }
}

<ANTET>" string"{Separator}? {
    // Add all the variables in the string category
    variables_buff_count = nr_variables;
    while(nr_variables != 0) {
        variables_count_string++;
        nr_variables--;
        strcpy(variables_string[variables_count_string].func_name, current_func_name);
        variables_string[variables_count_string].name = variables_buffer[variables_buff_count - nr_variables];
    }
}

<ANTET>" float32"{Separator}? {
    // Add all the variables in the float category
    variables_buff_count = nr_variables;
    while(nr_variables != 0) {
        variables_count_float++;
        nr_variables--;
        strcpy(variables_float[variables_count_float].func_name, current_func_name);
        variables_float[variables_count_float].name = variables_buffer[variables_buff_count - nr_variables];
    }
}

<ANTET>" bool"{Separator}? {
    // Add all the variables in the bool category
    variables_buff_count = nr_variables;
    while(nr_variables != 0) {
        variables_count_bool++;
        nr_variables--;
        strcpy(variables_bool[variables_count_bool].func_name, current_func_name);
        variables_bool[variables_count_bool].name = variables_buffer[variables_buff_count - nr_variables];
    }
}

<ANTET>") " {
    // In the FUNC_TYPE state, we read what type function has and store its
    // type in order to check if the return variable matches or not;
    BEGIN(FUNC_TYPE);
}
<ANTET>") {" {
    // If it has no type, we store the return type as "nothing".
    // If we reach the return word and the return_type is "nothing", we print
    // an error;
    BEGIN(INITIAL); strcpy(return_type, "nothing");
}

<FUNC_TYPE>"int " {strcpy(return_type, yytext);}
<FUNC_TYPE>"string " {strcpy(return_type, yytext);}
<FUNC_TYPE>"float32 " {strcpy(return_type, yytext);}
<FUNC_TYPE>"bool " {strcpy(return_type, yytext);}
<FUNC_TYPE>"{" {BEGIN(INITIAL);}

<RETURN>{NumeVariabila} {
    int OK = 0;
    // Check if we can return this variable (if its type matches with func type)
    if(strcmp(return_type, "int ") == 0) {
        for(int i = 1; i <= variables_count_int; i++) {
            if(variables_int[i].name == *yytext &&
                strcmp(variables_int[i].func_name, current_func_name) == 0) {
                    OK = 1;
                    break;
                }
        }
    }

    if(strcmp(return_type, "string ") == 0) {
        for(int i = 1; i <= variables_count_string; i++) {
            if(variables_string[i].name == *yytext &&
                strcmp(variables_string[i].func_name, current_func_name) == 0) {
                    OK = 1;
                    break;
                }
        }
    }

    if(strcmp(return_type, "float32 ") == 0) {
        for(int i = 1; i <= variables_count_float; i++) {
            if(variables_float[i].name == *yytext &&
                strcmp(variables_float[i].func_name, current_func_name) == 0) {
                    OK = 1;
                    break;
                }
        }
    }

    if(strcmp(return_type, "bool ") == 0) {
        for(int i = 1; i <= variables_count_bool; i++) {
            if(variables_bool[i].name == *yytext &&
                strcmp(variables_bool[i].func_name, current_func_name) == 0) {
                    OK = 1;
                    break;
                }
        }
    }

    // Print error if it was no match
    if(OK == 0) {
        printf("line %d: Invalid return type for function '%s'\n", line_nr, current_func_name);
    }
}

<RETURN>[\n] {line_nr++;}

<RETURN>"}" {BEGIN(GARBAGE);}

<INITIAL>{Return} {
    // Initial state works insides function. If we reach the word "return",
    // if the functions has no type, we print an error. Else we move to RETURN STATE 
    if(strcmp(return_type, "nothing") == 0) {
        printf("line %d: Too many arguments to return\n", line_nr);
        BEGIN(GARBAGE_FUNCTION);
    } else {
        BEGIN(RETURN);
    }
}

<INITIAL>[\n] {line_nr++;}

<INITIAL>{NumeVariabila}{Separator}? {
    // Every variable that is read at the beginning of the line is recorded for
    // a further initialization or changing of value;
    nr_variables++;
    variables_buffer[nr_variables] = *yytext;
}

<INITIAL>{Atribuire} {
    // If it is a simple " = ", then it means that these variables are already declared
    // and will change their values (var x int ; x = 9)
    BEGIN(ATRIBUIRE);
}

<INITIAL>{AtribuireAlternativa} {
    // If the declaration and initialisation is used with " := " (x, y := 9.1, "string")
    int OK = 1;

    // Check if they are already declared. If yes, print error message and go to GARBAGE
    // state in order to skip this line;
    for (int j = 1; j <= nr_variables; j++) {
        for(int i = 1; i <= variables_count_int; i++) {
            if(variables_buffer[j] == variables_int[i].name  && strcmp(variables_int[i].func_name, current_func_name) == 0) {
                printf("line %d: No new variables on the left side of :=\n", line_nr);
                OK = 0;
                break;
            }
        }

        for(int i = 1; i <= variables_count_float; i++) {
            if(variables_buffer[j] == variables_float[i].name && strcmp(variables_float[i].func_name, current_func_name) == 0) {
                printf("line %d: No new variables on the left side of :=\n", line_nr);
                OK = 0;
                break;
            }
        }

        for(int i = 1; i <= variables_count_string; i++) {
            if(variables_buffer[j] == variables_string[i].name && strcmp(variables_string[i].func_name, current_func_name) == 0) {
                printf("line %d: No new variables on the left side of :=\n", line_nr);
                OK = 0;
                break;
            }
        }

        for(int i = 1; i <= variables_count_bool; i++) {
            if(variables_buffer[j] == variables_bool[i].name && strcmp(variables_bool[i].func_name, current_func_name) == 0) {
                printf("line %d: No new variables on the left side of :=\n", line_nr);
                OK = 0;
                break;
            }
        }
    }
    if (OK == 1) {
        // If all variables are new, go to ANYTHING_TYPE state in order to record them
        variables_buff_count = nr_variables;
        BEGIN(ANYTHING_TYPE);
    } else {
        // If not, skip this line and go to GARBAGE
        nr_variables = 0;
        variables_buff_count = 0;
        BEGIN(GARBAGE);
    }
}

<INITIAL>. {
    // If it reads something that is not part of this language, just skip it;
}

<ATRIBUIRE>{Int} {
    // Check if this variable already exits. If yes, change its value;
    int OK = 0;
    for(int i = 1; i <= variables_count_int; i++) {
        if(variables_int[i].name == variables_buffer[nr_variables]) {
            variables_int[i].value = atoi(yytext);
            nr_variables--;
            OK = 1;
            break;
        }
    }
    // If not, print error message;
    if (OK == 0) {
        printf("line %d: \"%c\" is not declared or has not int type\n", line_nr, variables_buffer[nr_variables]);
        nr_variables--;
    }
    BEGIN(GARBAGE);
}

<ATRIBUIRE>{Float32} {
    // Check if this variable already exits. If yes, change its value;
    int OK = 0;
    for(int i = 1; i <= variables_count_float; i++) {
        if(variables_float[i].name == variables_buffer[nr_variables]) {
            variables_float[i].value = atof(yytext);
            nr_variables--;
            OK = 1;
            break;
        }
    }
    // If not, print error message;
    if (OK == 0) {
        printf("line %d: \"%c\" is not declared or has not float32 type\n", line_nr, variables_buffer[nr_variables]);
        nr_variables--;
    }
    BEGIN(GARBAGE);
}

<ATRIBUIRE>{String} {
    // Check if this variable already exits. If yes, change its value;
    int OK = 0;
    for (int i = 1; i <= variables_count_string; i++) {
        if(variables_string[i].name == variables_buffer[nr_variables]) {
            strcpy(variables_string[i].value, yytext);
            nr_variables--;
            OK = 1;
            break;
        }
    }
    // If not, print error message;
    if (OK == 0) {
        printf("line %d: \"%c\" is not declared or has not string type\n", line_nr, variables_buffer[nr_variables]);
        nr_variables--;
    }
    BEGIN(GARBAGE);
}

<ATRIBUIRE>{Bool} {
    // Check if this variable already exits. If yes, change its value;
    int OK = 0;
    for (int i = 1; i <= variables_count_bool; i++) {
        if(variables_bool[i].name == variables_buffer[nr_variables]) {
            strcpy(variables_bool[i].value, yytext);
            nr_variables--;
            OK = 1;
            break;
        }
    }
    // If not, print error message;
    if (OK == 0) {
        printf("line %d: \"%c\" is not declared or has not bool\n", line_nr, variables_buffer[nr_variables]);
        nr_variables--;
    }
    BEGIN(GARBAGE);
}

<VAR>{NumeVariabila}{Separator}? {
    nr_variables++;
    variables_buffer[nr_variables] = *yytext;
    // Check if these variables are already declared. If yes, print error message and
    // go to GARBAGE state;
    for(int i = 1; i <= variables_count_int; i++) {
        if(*yytext == variables_int[i].name && strcmp(variables_int[i].func_name, current_func_name) == 0) {
            printf("line %d: '%s' redeclared in this block\n", line_nr, yytext);
            BEGIN(GARBAGE);
        }
    }

    for(int i = 1; i <= variables_count_float; i++) {
        if(*yytext == variables_float[i].name && strcmp(variables_float[i].func_name, current_func_name) == 0) {
            printf("line %d: '%s' redeclared in this block\n", line_nr, yytext);
            BEGIN(GARBAGE);
        }
    }

    for(int i = 1; i <= variables_count_string; i++) {
        if(*yytext == variables_string[i].name && strcmp(variables_string[i].func_name, current_func_name) == 0) {
            printf("line %d: '%s' redeclared in this block\n", line_nr, yytext);
            BEGIN(GARBAGE);
        }
    }

    for(int i = 1; i <= variables_count_bool; i++) {
        if(*yytext == variables_bool[i].name && strcmp(variables_bool[i].func_name, current_func_name) == 0) {
            printf("line %d: '%s' redeclared in this block\n", line_nr, yytext);
            BEGIN(GARBAGE);
        }
    }
}

<VAR>{string_type} {
    // If variables after "var" have "string" type, begin STRING_TYPE state;
    // (var x, y string = )
    BEGIN(STRING_TYPE);
    variables_buff_count = nr_variables;
}

<VAR>{anything_type} {
    // If variables after "var" don't have a type (var x, y =), begin ANYTHING_TYPE
    // state
    BEGIN(ANYTHING_TYPE);
    variables_buff_count = nr_variables;
}

<VAR>{int_type} {
    // If variables after "var" have "int" type, begin INT_TYPE state;
    // (var x, y int = )
    BEGIN(INT_TYPE);
    variables_buff_count = nr_variables;
}

<VAR>{float32_type} {
    // If variables after "var" have "float32" type, begin FLOAT32_TYPE state;
    // (var x, y float32 = )
    BEGIN(FLOAT32_TYPE);
    variables_buff_count = nr_variables;
}

<VAR>{bool_type} {
    // If variables after "var" have "bool" type, begin BOOL_TYPE state;
    // (var x, y bool = )
    BEGIN(BOOL_TYPE);
    variables_buff_count = nr_variables;
}

<VAR>[\n]+ {
    // If new line, reset variables buffer and begin INITIAL state
    line_nr++; 
    nr_variables = 0; 
    variables_buff_count = 0; 
    BEGIN(INITIAL);
}

<ANYTHING_TYPE>{String}{Separator}? {
    // If the value is a string, make this variable a string type and record it and its
    // value
    variables_count_string++;
    nr_variables--;
    strcpy(variables_string[variables_count_string].func_name, current_func_name);
    variables_string[variables_count_string].name = variables_buffer[variables_buff_count - nr_variables];
    strcpy(variables_string[variables_count_string].value, yytext);
    // If there are no variables left in buffer, it means that the declaration was 
    // successful and print all the variables and their values;
    if(nr_variables == 0) {
        if(print_values == 1) {
            for(int i = 1; i <= variables_count_string; i++) {
                printf("Din vector string: %s ; ", variables_string[i].value);
            }

            for(int i = 1; i <= variables_count_int; i++) {
                printf("Din vector int: %d ; ", variables_int[i].value);
            }

            for(int i = 1; i <= variables_count_bool; i++) {
                printf("Din vector bool: %s ; ", variables_bool[i].value);
            }

            for(int i = 1; i <= variables_count_float; i++) {
                printf("Din vector float: %f ; ", variables_float[i].value);
            }
            printf("\n");
        }
        BEGIN(GARBAGE);
    }
}

<ANYTHING_TYPE>{Int}{Separator}? {
    // If the value is a int, make this variable a int type and record it and its
    // value
    variables_count_int++;
    nr_variables--;
    strcpy(variables_int[variables_count_int].func_name, current_func_name);
    variables_int[variables_count_int].value = atoi(yytext);
    variables_int[variables_count_int].name = variables_buffer[variables_buff_count - nr_variables];
    // If there are no variables left in buffer, it means that the declaration was 
    // successful and print all the variables and their values;
    if(nr_variables == 0) {
        if(print_values == 1) {
            for(int i = 1; i <= variables_count_string; i++) {
                printf("Din vector string: %s ; ", variables_string[i].value);
            }

            for(int i = 1; i <= variables_count_int; i++) {
                printf("Din vector int: %d ; ", variables_int[i].value);
            }

            for(int i = 1; i <= variables_count_bool; i++) {
                printf("Din vector bool: %s ; ", variables_bool[i].value);
            }

            for(int i = 1; i <= variables_count_float; i++) {
                printf("Din vector float: %f ; ", variables_float[i].value);
            }
            printf("\n");
        }
        BEGIN(GARBAGE);
    }
}

<ANYTHING_TYPE>{Float32}{Separator}? {
    // If the value is a float, make this variable a float type and record it and its
    // value
    variables_count_float++;
    nr_variables--;
    strcpy(variables_float[variables_count_float].func_name, current_func_name);
    variables_float[variables_count_float].value = atof(yytext);
    variables_float[variables_count_float].name = variables_buffer[variables_buff_count - nr_variables];
    // If there are no variables left in buffer, it means that the declaration was 
    // successful and print all the variables and their values;
    if(nr_variables == 0) {
        if(print_values == 1) {
            for(int i = 1; i <= variables_count_string; i++) {
                printf("Din vector string: %s ; ", variables_string[i].value);
            }

            for(int i = 1; i <= variables_count_int; i++) {
                printf("Din vector int: %d ; ", variables_int[i].value);
            }

            for(int i = 1; i <= variables_count_bool; i++) {
                printf("Din vector bool: %s ; ", variables_bool[i].value);
            }

            for(int i = 1; i <= variables_count_float; i++) {
                printf("Din vector float: %f ; ", variables_float[i].value);
            }
            printf("\n");
        }
        BEGIN(GARBAGE);
    }
}

<ANYTHING_TYPE>{Bool}{Separator}? {
    // If the value is a bool, make this variable a bool type and record it and its
    // value
    variables_count_bool++;
    nr_variables--;
    strcpy(variables_bool[variables_count_bool].func_name, current_func_name);
    strcpy(variables_bool[variables_count_bool].value, yytext);
    variables_bool[variables_count_bool].name = variables_buffer[variables_buff_count - nr_variables];
    // If there are no variables left in buffer, it means that the declaration was 
    // successful and print all the variables and their values;
    if(nr_variables == 0) {
        if(print_values == 1) {
            for(int i = 1; i <= variables_count_string; i++) {
                printf("Din vector string: %s ; ", variables_string[i].value);
            }

            for(int i = 1; i <= variables_count_int; i++) {
                printf("Din vector int: %d ; ", variables_int[i].value);
            }

            for(int i = 1; i <= variables_count_bool; i++) {
                printf("Din vector bool: %s ; ", variables_bool[i].value);
            }

            for(int i = 1; i <= variables_count_float; i++) {
                printf("Din vector float: %f ; ", variables_float[i].value);
            }
            printf("\n");
        }
        BEGIN(GARBAGE);
    }
}

<INT_TYPE>{Int}{Separator}? {
    // If variables have the int descriptor, record all of them and their values;
    variables_count_int++;
    nr_variables--;
    strcpy(variables_int[variables_count_int].func_name, current_func_name);
    variables_int[variables_count_int].value = atoi(yytext);
    variables_int[variables_count_int].name = variables_buffer[variables_buff_count - nr_variables];
    
    if(nr_variables == 0) {
        if(print_values == 1) {
            for(int i = 1; i <= variables_count_string; i++) {
                printf("Din vector string: %s ; ", variables_string[i].value);
            }

            for(int i = 1; i <= variables_count_int; i++) {
                printf("Din vector int: %d ; ", variables_int[i].value);
            }

            for(int i = 1; i <= variables_count_bool; i++) {
                printf("Din vector bool: %s ; ", variables_bool[i].value);
            }

            for(int i = 1; i <= variables_count_float; i++) {
                printf("Din vector float: %f ; ", variables_float[i].value);
            }
            printf("\n");
        }
        BEGIN(GARBAGE);
    }
}

<INT_TYPE>{String} {
    // If the variable is int type and receives an non-int type, print error message and
    // go to GARBAGE state
    if (nr_variables != 0) 
        {printf("line %d: (String) cannot be represented by the (Integer)\n", line_nr); nr_variables = 0;} 
    BEGIN(GARBAGE);
}

<INT_TYPE>{Float32} {
    // If the variable is int type and receives an non-int type, print error message and
    // go to GARBAGE state
    if (nr_variables != 0) 
        {printf("line %d: (Float32) cannot be represented by the (Integer)\n", line_nr);nr_variables = 0;} 
    BEGIN(GARBAGE);      
}

<INT_TYPE>{Bool} {
    // If the variable is int type and receives an non-int type, print error message and
    // go to GARBAGE state
    if (nr_variables != 0) 
        {printf("line %d: (Bool) cannot be represented by the (Integer)\n", line_nr);nr_variables = 0;} 
    BEGIN(GARBAGE);       
}

<INT_TYPE>{NumeVariabila}{Separator}? {
    // If the int variable receives a variable as value (not a direct value), check
    // what type is that variable. If it is int type, take its value and continue;
    int OK = 0;
    for(int i = 1; i <= variables_count_int; i++) {
        // TODO: only if they are in the same function
        if (variables_int[i].name == *yytext && strcmp(variables_int[i].func_name, current_func_name) == 0) {
            OK = 1;
            nr_variables--;
            strcpy(variables_int[variables_count_int + 1].func_name, current_func_name);
            variables_int[variables_count_int + 1].value = variables_int[i].value;
            variables_int[variables_count_int + 1].name = variables_buffer[variables_buff_count - nr_variables];
            if(print_values == 1) {
                for(int i = 1; i <= variables_count_string; i++) {
                    printf("Din vector string: %s ; ", variables_string[i].value);
                }

                for(int i = 1; i <= variables_count_int; i++) {
                    printf("Din vector int: %d ; ", variables_int[i].value);
                }

                for(int i = 1; i <= variables_count_bool; i++) {
                    printf("Din vector bool: %s ; ", variables_bool[i].value);
                }

                for(int i = 1; i <= variables_count_float; i++) {
                    printf("Din vector float: %f ; ", variables_float[i].value);
                }
                printf("\n");
            }
        }
    }
    if (OK == 1) {
        // Did this in order to not check this variable with itself if the last
        // step was successful
        variables_count_int++;
    } else {
        // If the type of the received variable doesn't match with this variable,
        // print error message and go to GARBAGE state;
        for(int i = 1; i <= variables_count_string; i++) {
            if(variables_string[i].name == *yytext && strcmp(variables_string[i].func_name, current_func_name) == 0) {
                printf("line %d: (String) cannot be represented by the (Integer)\n", line_nr);
                nr_variables = 0;
                break;
            }
        }
        for(int i = 1; i <= variables_count_float; i++) {
            if(variables_float[i].name == *yytext && strcmp(variables_float[i].func_name, current_func_name) == 0) {
                printf("line %d: (Float32) cannot be represented by the (Integer)\n", line_nr);
                nr_variables = 0;
                break;
            }
        }
        for(int i = 1; i <= variables_count_bool; i++) {
            if(variables_bool[i].name == *yytext && strcmp(variables_bool[i].func_name, current_func_name) == 0) {
                printf("line %d: (Bool) cannot be represented by the (Integer)\n", line_nr);
                nr_variables = 0;
                break;
            }
        }
        BEGIN(GARBAGE);
    }
}

<INT_TYPE>[ \n]* {
    // if the variables have received int type, but there are no values, just record them
    // and begin INITIAL state;
    while(nr_variables != 0) {
        nr_variables--;
        variables_count_int++;
        strcpy(variables_int[variables_count_int].func_name, current_func_name);
        variables_int[variables_count_int].name = variables_buffer[variables_buff_count - nr_variables];
    }
    BEGIN(INITIAL);
    line_nr++;
}

<STRING_TYPE>{String}{Separator}? {
    // If variables have the string descriptor, record all of them and their values;
    variables_count_string++;
    nr_variables--;
    strcpy(variables_string[variables_count_string].func_name, current_func_name);
    variables_string[variables_count_string].name = variables_buffer[variables_buff_count - nr_variables];
    strcpy(variables_string[variables_count_string].value, yytext);
    
    if(nr_variables == 0) {
        BEGIN(GARBAGE);
        if(print_values == 1) {
            for(int i = 1; i <= variables_count_string; i++) {
                printf("Din vector string: %s ; ", variables_string[i].value);
            }

            for(int i = 1; i <= variables_count_int; i++) {
                printf("Din vector int: %d ; ", variables_int[i].value);
            }

            for(int i = 1; i <= variables_count_bool; i++) {
                printf("Din vector bool: %s ; ", variables_bool[i].value);
            }

            for(int i = 1; i <= variables_count_float; i++) {
                printf("Din vector float: %f ; ", variables_float[i].value);
            }
            printf("\n");
        }
    }
}

<STRING_TYPE>{Int} {
    // If the variable is string type and receives an non-string type, 
    //print error message and go to GARBAGE state
    if (nr_variables != 0) 
        {printf("line %d: (Integer) cannot be represented by the (String)\n", line_nr); nr_variables = 0;} 
    BEGIN(GARBAGE);
}

<STRING_TYPE>{Float32} {
    // If the variable is string type and receives an non-string type, 
    //print error message and go to GARBAGE state
    if (nr_variables != 0) 
        {printf("line %d: (Float32) cannot be represented by the (String)\n", line_nr);nr_variables = 0;} 
    BEGIN(GARBAGE);      
}

<STRING_TYPE>{Bool} {
    // If the variable is string type and receives an non-string type, 
    //print error message and go to GARBAGE state
    if (nr_variables != 0) 
        {printf("line %d: (Bool) cannot be represented by the (String)\n", line_nr);nr_variables = 0;} 
    BEGIN(GARBAGE);      
}

<STRING_TYPE>{NumeVariabila}{Separator}? {
    // If the int variable receives a variable as value (not a direct value), check
    // what type is that variable. If it is string type, take its value and continue;
    int OK = 0;
    for(int i = 1; i <= variables_count_string; i++) {
        // TODO: only if they are in the same function
        if (variables_string[i].name == *yytext && strcmp(variables_string[i].func_name, current_func_name) == 0) {
            OK = 1;
            nr_variables--;
            strcpy(variables_string[variables_count_string + 1].func_name, current_func_name);
            strcpy(variables_string[variables_count_string + 1].value, variables_string[i].value);
            variables_string[variables_count_string + 1].name = variables_buffer[variables_buff_count - nr_variables];
            if(print_values == 1) {
                for(int i = 1; i <= variables_count_string; i++) {
                    printf("Din vector string: %s ; ", variables_string[i].value);
                }

                for(int i = 1; i <= variables_count_int; i++) {
                    printf("Din vector int: %d ; ", variables_int[i].value);
                }

                for(int i = 1; i <= variables_count_bool; i++) {
                    printf("Din vector bool: %s ; ", variables_bool[i].value);
                }

                for(int i = 1; i <= variables_count_float; i++) {
                    printf("Din vector float: %f ; ", variables_float[i].value);
                }
                printf("\n");
            }
        }
    }
    if (OK == 1) {
        // Did this in order to not check this variable with itself if the last
        // step was successful
        variables_count_string++;
    } else {

        // If the type of the received variable doesn't match with this variable,
        // print error message and go to GARBAGE state;
        for(int i = 1; i <= variables_count_int; i++) {
            if(variables_int[i].name == *yytext && strcmp(variables_int[i].func_name, current_func_name) == 0) {
                printf("line %d: (Integer) cannot be represented by the (String)\n", line_nr);
                nr_variables = 0;
                break;
            }
        }
        for(int i = 1; i <= variables_count_float; i++) {
            if(variables_float[i].name == *yytext && strcmp(variables_float[i].func_name, current_func_name) == 0) {
                printf("line %d: (Float32) cannot be represented by the (String)\n", line_nr);
                nr_variables = 0;
                break;
            }
        }
        for(int i = 1; i <= variables_count_bool; i++) {
            if(variables_bool[i].name == *yytext && strcmp(variables_bool[i].func_name, current_func_name) == 0) {
                printf("line %d: (Bool) cannot be represented by the (String)\n", line_nr);
                nr_variables = 0;
                break;
            }
        }
        BEGIN(GARBAGE);
    }
}

<STRING_TYPE>[ \n]* {
    // if the variables have received string type, but there are no values, 
    // just record them and begin INITIAL state;
    while(nr_variables != 0) {
        nr_variables--;
        variables_count_string++;
        strcpy(variables_string[variables_count_string].func_name, current_func_name);
        variables_string[variables_count_string].name = variables_buffer[variables_buff_count - nr_variables];      
    }
    line_nr++;
    BEGIN(INITIAL);
}

<FLOAT32_TYPE>{Float32}{Separator}? {
    // If variables have the float32 descriptor, record all of them and their values;
    variables_count_float++;
    nr_variables--;
    strcpy(variables_float[variables_count_float].func_name, current_func_name);
    variables_float[variables_count_float].value = atof(yytext);
    variables_float[variables_count_float].name = variables_buffer[variables_buff_count - nr_variables];
    
    if(nr_variables == 0) {
        if(print_values == 1) {
            for(int i = 1; i <= variables_count_string; i++) {
                printf("Din vector string: %s ; ", variables_string[i].value);
            }

            for(int i = 1; i <= variables_count_int; i++) {
                printf("Din vector int: %d ; ", variables_int[i].value);
            }

            for(int i = 1; i <= variables_count_bool; i++) {
                printf("Din vector bool: %s ; ", variables_bool[i].value);
            }

            for(int i = 1; i <= variables_count_float; i++) {
                printf("Din vector float: %f ; ", variables_float[i].value);
            }
            printf("\n");
        }
       BEGIN(GARBAGE);
    }
}

<FLOAT32_TYPE>{Int} {
    // If the variable is float32 type and receives an non-float32 type, 
    //print error message and go to GARBAGE state
    if (nr_variables != 0) 
        {printf("line %d: (Integer) cannot be represented by the (Float32)\n", line_nr); nr_variables = 0;} 
    BEGIN(GARBAGE);
}

<FLOAT32_TYPE>{String} {
    // If the variable is float32 type and receives an non-float32 type, 
    //print error message and go to GARBAGE state
    if (nr_variables != 0) 
        {printf("line %d: (String) cannot be represented by the (Float32)\n", line_nr);nr_variables = 0;} 
    BEGIN(GARBAGE);      
}

<FLOAT32_TYPE>{Bool} {
    // If the variable is float32 type and receives an non-float32 type, 
    //print error message and go to GARBAGE state
    if (nr_variables != 0) 
        {printf("line %d: (Bool) cannot be represented by the (Float32)\n", line_nr);nr_variables = 0;} 
    BEGIN(GARBAGE);      
}

<FLOAT32_TYPE>{NumeVariabila}{Separator}? {
    // If the int variable receives a variable as value (not a direct value), check
    // what type is that variable. If it is float32 type, take its value and continue;
    int OK = 0;
    for(int i = 1; i <= variables_count_float; i++) {
        // TODO: Only if it is the same function
        if (variables_float[i].name == *yytext && strcmp(variables_float[i].func_name, current_func_name) == 0) {
            OK = 1;
            nr_variables--;
            strcpy(variables_float[variables_count_float + 1].func_name, current_func_name);
            variables_float[variables_count_float + 1].value = variables_float[i].value;
            variables_float[variables_count_float + 1].name = variables_buffer[variables_buff_count - nr_variables];
            if(print_values == 1) {
                for(int i = 1; i <= variables_count_string; i++) {
                    printf("Din vector string: %s ; ", variables_string[i].value);
                }

                for(int i = 1; i <= variables_count_int; i++) {
                    printf("Din vector int: %d ; ", variables_int[i].value);
                }

                for(int i = 1; i <= variables_count_bool; i++) {
                    printf("Din vector bool: %s ; ", variables_bool[i].value);
                }

                for(int i = 1; i <= variables_count_float; i++) {
                    printf("Din vector float: %f ; ", variables_float[i].value);
                }
                printf("\n");
            }
        }
    }
    if (OK == 1) {
        // Did this in order to not check this variable with itself if the last
        // step was successful
        variables_count_float++;
    } else {
        // If the type of the received variable doesn't match with this variable,
        // print error message and go to GARBAGE state;
        for(int i = 1; i <= variables_count_string; i++) {
            if(variables_string[i].name == *yytext  && strcmp(variables_string[i].func_name, current_func_name) == 0) {
                printf("line %d: (String) cannot be represented by the (Float32)\n", line_nr);
                nr_variables = 0;
                break;
            }
        }
        for(int i = 1; i <= variables_count_int; i++) {
            if(variables_int[i].name == *yytext && strcmp(variables_int[i].func_name, current_func_name) == 0) {
                printf("line %d: (Integer) cannot be represented by the (Float32)\n", line_nr);
                nr_variables = 0;
                break;
            }
        }
        for(int i = 1; i <= variables_count_bool; i++) {
            if(variables_bool[i].name == *yytext && strcmp(variables_bool[i].func_name, current_func_name) == 0) {
                printf("line %d: (Bool) cannot be represented by the (Float32)\n", line_nr);
                nr_variables = 0;
                break;
            }
        }
        BEGIN(GARBAGE);
    }
}

<FLOAT32_TYPE>[ \n]* {
    // if the variables have received float32 type, but there are no values, 
    // just record them and begin INITIAL state;
    while(nr_variables != 0) {
        nr_variables--;
        variables_count_float++;
        strcpy(variables_float[variables_count_float].func_name, current_func_name);
        variables_float[variables_count_float].name = variables_buffer[variables_buff_count - nr_variables];
    }
    line_nr++;
    BEGIN(INITIAL);
}

<BOOL_TYPE>{Bool}{Separator}? {
    // If variables have the bool descriptor, record all of them and their values;
    variables_count_bool++;
    nr_variables--;
    strcpy(variables_bool[variables_count_bool].func_name, current_func_name);
    strcpy(variables_bool[variables_count_bool].value, yytext);
    variables_bool[variables_count_bool].name = variables_buffer[variables_buff_count - nr_variables];
    
    if(nr_variables == 0) {
        BEGIN(GARBAGE);
        if(print_values == 1) {
            for(int i = 1; i <= variables_count_string; i++) {
                printf("Din vector string: %s ; ", variables_string[i].value);
            }

            for(int i = 1; i <= variables_count_int; i++) {
                printf("Din vector int: %d ; ", variables_int[i].value);
            }

            for(int i = 1; i <= variables_count_bool; i++) {
                printf("Din vector bool: %s ; ", variables_bool[i].value);
            }

            for(int i = 1; i <= variables_count_float; i++) {
                printf("Din vector float: %f ; ", variables_float[i].value);
            }
            printf("\n");
        }
    }
}

<BOOL_TYPE>{Int} {
    // If the variable is bool type and receives an non-bool type, 
    //print error message and go to GARBAGE state
    if (nr_variables != 0) 
        {printf("line %d: (Integer) cannot be represented by the (Bool)\n", line_nr); nr_variables = 0;} 
    BEGIN(GARBAGE);
}

<BOOL_TYPE>{String} {
    // If the variable is bool type and receives an non-bool type, 
    //print error message and go to GARBAGE state
    if (nr_variables != 0) 
        {printf("line %d: (String) cannot be represented by the (Bool)\n", line_nr);nr_variables = 0;} 
    BEGIN(GARBAGE);      
}

<BOOL_TYPE>{Float32} {
    // If the variable is bool type and receives an non-bool type, 
    //print error message and go to GARBAGE state
    if (nr_variables != 0) 
        {printf("line %d: (Float32) cannot be represented by the (Bool)\n", line_nr);nr_variables = 0;} 
    BEGIN(GARBAGE);      
}

<BOOL_TYPE>{NumeVariabila}{Separator}? {
    // If the int variable receives a variable as value (not a direct value), check
    // what type is that variable. If it is bool type, take its value and continue;
    int OK = 0;
    for(int i = 1; i <= variables_count_bool; i++) {
        // TODO
        if (variables_bool[i].name == *yytext && strcmp(variables_bool[i].func_name, current_func_name) == 0) {
            OK = 1;
            nr_variables--;
            strcpy(variables_bool[variables_count_bool + 1].func_name, current_func_name);
            strcpy(variables_bool[variables_count_bool + 1].value, variables_bool[i].value);
            variables_bool[variables_count_bool + 1].name = variables_buffer[variables_buff_count - nr_variables];
            if(print_values == 1) {
                for(int i = 1; i <= variables_count_string; i++) {
                    printf("Din vector string: %s ; ", variables_string[i].value);
                }

                for(int i = 1; i <= variables_count_int; i++) {
                    printf("Din vector int: %d ; ", variables_int[i].value);
                }

                for(int i = 1; i <= variables_count_bool; i++) {
                    printf("Din vector bool: %s ; ", variables_bool[i].value);
                }

                for(int i = 1; i <= variables_count_float; i++) {
                    printf("Din vector float: %f ; ", variables_float[i].value);
                }
                printf("\n");
            }
        }
    }
    if (OK == 1) {
        // Did this in order to not check this variable with itself if the last
        // step was successful
        variables_count_bool++;
    } else {
        // If the type of the received variable doesn't match with this variable,
        // print error message and go to GARBAGE state;
        for(int i = 1; i <= variables_count_int; i++) {
            if(variables_int[i].name == *yytext && strcmp(variables_int[i].func_name, current_func_name) == 0) {
                printf("line %d: (Integer) cannot be represented by the (Bool)\n", line_nr);
                nr_variables = 0;
                break;
            }
        }
        for(int i = 1; i <= variables_count_float; i++) {
            if(variables_float[i].name == *yytext && strcmp(variables_float[i].func_name, current_func_name) == 0) {
                printf("line %d: (Float32) cannot be represented by the (Bool)\n", line_nr);
                nr_variables = 0;
                break;
            }
        }
        for(int i = 1; i <= variables_count_string; i++) {
            if(variables_string[i].name == *yytext && strcmp(variables_string[i].func_name, current_func_name) == 0) {
                printf("line %d: (String) cannot be represented by the (Bool)\n", line_nr);
                nr_variables = 0;
                break;
            }
        }
        BEGIN(GARBAGE);
    }
}

<BOOL_TYPE>[ \n]* {
    // if the variables have received bool type, but there are no values, 
    // just record them and begin INITIAL state;
    while(nr_variables != 0) {
        nr_variables--;
        variables_count_bool++;
        strcpy(variables_bool[variables_count_bool].func_name, current_func_name);
        variables_bool[variables_count_bool].name = variables_buffer[variables_buff_count - nr_variables];
    }
    line_nr++;
    BEGIN(INITIAL);
}

<COMMSIMPLU>. {
    // Everything after simple comment (besides new line) is ignored;
}

<COMMSIMPLU>[\n] {line_nr++; BEGIN(INITIAL);}

<COMMCOMPUS>. {
    // Everything after multi-line comment (besides new line) is ignored;
}

<COMMCOMPUS>[\n] { line_nr++;}

<COMMCOMPUS>"*/" {BEGIN(INITIAL);}

%%

int yywrap(){return(1);}

int main(int argc, char **argv)
{ 
    // check if the input file is valid
    yyin = fopen(argv[1], "r");
    if (!yyin) {
        printf("!!!eroare!!!"); exit(1);
    }
    // start lexical analyzer
    yylex();
}