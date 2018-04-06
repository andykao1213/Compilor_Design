%{
#include <stdio.h>
#include <string.h>

char buffer[1000];
int line_count = 0;
int source_on = 1;
int token_on = 1;
%}

%x COMMENT

SPACE ([ \t\r]+)
SOURCE_ON (#{SPACE}?"pragma"{SPACE}"source"{SPACE}"on")
SOURCE_OFF (#{SPACE}?"pragma"{SPACE}"source"{SPACE}"off")
TOKEN_ON (#{SPACE}?"pragma"{SPACE}"token"{SPACE}"on")
TOKEN_OFF (#{SPACE}?"pragma"{SPACE}"token"{SPACE}"off")

NUM ([0-9])
NUMs ([0-9]+)
L ("l"|"L"|"ll"|"LL")
U ("u"|"U")
DT ({L}|{U}|{L}{U}|{U}{L})
INT (({NUM}|[1-9]{NUM}*){DT}?)

FLOATP (({NUMs}?"."{NUMs})|({NUMs}"."))
FLOATS ("f"|"F"|"l"|"L")
DOUBLE ({FLOATP}{FLOATS}?)

SCI (({FLOATP}|{NUMs})[Ee][+-]?{NUMs}{FLOATS}?)

KEY ("void"|"int"|"double"|"bool"|"char"|"null"|"for"|"while"|"do"|"if"|"else"|"switch"|"return"|"break"|"continue"|"const"|"true"|"false"|"struct"|"case"|"default")
OP ("+"|"-"|"*"|"/"|"%"|"++"|"--"|"<"|"<="|">"|">="|"=="|"!="|"="|"&&"|"||"|"!"|"&")
PUNC (":"|";"|","|"."|"["|"]"|"("|")"|"{"|"}")
STDIO ("fclose"|"clearerr"|"feof"|"ferror"|"fflush"|"fgetpos"|"fopen"|"fread"|"freopen"|"fseek"|"fsetpos"|"ftell"|"fwrite"|"remove"|"rename"|"rewind"|"setbuf"|"setvbuf"|"tmpfile"|"tmpnam"|"fprintf"|"printf"|"sprintf"|"vfprintf"|"vprintf"|"vsprintf"|"fscanf"|"scanf"|"sscanf"|"fgetc"|"fgets"|"fputc"|"fputs"|"getc"|"getchar"|"gets"|"putc"|"putchar"|"puts"|"ungetc"|"perror")

ID ([a-zA-Z_]+[a-zA-Z_0-9]*)

CHAR (L?'(((\\n)|(\\t))|[^'\\\n])')
STRING (L?\"(((\\n)|(\\t))|[^"\\\n])*\")

%%
{SOURCE_ON} { source_on = 1; strcat(buffer, yytext); }
{SOURCE_OFF} { source_on = 0; strcat(buffer, yytext); }
{TOKEN_ON} { token_on = 1; strcat(buffer, yytext); }
{TOKEN_OFF} { token_on = 0; strcat(buffer, yytext); }

"/*" { 
	BEGIN(COMMENT); 
	strcat(buffer, yytext); 
}

<COMMENT>"*/" {
    BEGIN(INITIAL);
    strcat(buffer, yytext);
}

<COMMENT>"\n" {
    line_count ++;
	if(source_on == 1)
		printf("%d:%s\n", line_count, buffer);
    memset(buffer, 0, sizeof(buffer));
}

<COMMENT>. {
    strcat(buffer, yytext);
}

"//".* {
    strcat(buffer, yytext);
}

{KEY} {
    if(token_on == 1) 
    	printf("#key:%s\n", yytext);
    strcat(buffer, yytext);
}

{STDIO}  {
    if(token_on == 1)    
    	printf("#key:%s\n",yytext);
    strcat(buffer, yytext);

}

{OP} {
    if(token_on == 1) 
    	printf("#op:%s\n", yytext);
    strcat(buffer, yytext);
}

{PUNC} {
    if(token_on == 1) 
    	printf("#punc:%s\n", yytext);
    strcat(buffer, yytext);
}

{ID} {
    if(token_on == 1) 
    	printf("#id:%s\n", yytext);
    strcat(buffer, yytext);
}

{INT} {
    if(token_on == 1) 
    	printf("#integer:%s\n", yytext);
    strcat(buffer, yytext);
}

{DOUBLE} {
    if(token_on == 1) 
    	printf("#double:%s\n", yytext);
    strcat(buffer, yytext);
}

{CHAR} {
    if(token_on == 1) 
    	printf("#char:%s\n", yytext);
    strcat(buffer, yytext);
}

{SCI} {
    if(token_on == 1) 
    	printf("#sci:%s\n", yytext);
    strcat(buffer, yytext);
}

{SPACE} {
    strcat(buffer, yytext);
}

{STRING} {
    char temp[1000];

    if(yytext[0] == 'L')	
    	strcpy(temp, yytext + 2);
    else 
    	strcpy(temp, yytext + 1);

    int length = strlen(temp);
    temp[length - 1] = 0;

    if(token_on == 1) 
    	printf("#string:%s\n", temp);

    strcat(buffer, yytext);
}

"\n" {
    line_count ++;
	if(source_on == 1)
		printf("%d:%s\n",line_count, buffer);
    memset(buffer, 0, sizeof(buffer));
}

. {
    fprintf(stderr, "Error at line %d: %s\n", line_count, yytext);
    exit(1);

    strcat(buffer, yytext);
}


%%
int main() {
    yylex();
    return 0;
}

