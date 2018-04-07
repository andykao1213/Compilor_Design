%{

	#include <stdio.h>
	#include <string.h>
	char buffer[1000];
	char errorMessage[1000];
	int line_number = 0;
	int token = 1;
	int source = 1;
%}

%x COMMENT
%x ERR

KEY		void|int|double|bool|char|null|for|while|do|if|else|switch|return|break|continue|const|true|false|struct|case|default|fclose|clearerr|feof|ferror|fflush|fgetpos|fopen|fread|freopen|fseek|fsetpos|ftell|fwrite|remove|rename|rewind|setbuf|setvbuf|tmpfile|tmpnam|fprintf|printf|sprintf|vfprintf|vprintf|vsprintf|fscanf|scanf|sscanf|fgetc|fgets|fputc|fputs|getc|getchar|gets|putc|putchar|puts|ungetc|perror
SPACE	[ \t\t]+
OP		"+"|"-"|"*"|"/"|"%"|"++"|"--"|"<"|"<="|">"|">="|"=="|"!="|"="|"&&"|"||"|"!"
PUNC	":"|";"|","|"."|"["|"]"|"("|")"|"{"|"}"
INT		[1-9][0-9]*|0
DOUB	(([0-9]*)"."([0-9]+))|([0-9]+".")
CH		[a-z]
CHAR	\'.\'
ID		[[:alpha:]]+
STR		L?\"(\\.|[^\\"])*\"
SCI		({DOUB}|{INT})[Ee][+-]?[0-9]+
S_ON	#{SPACE}?"pragma"{SPACE}"source"{SPACE}"on"
S_OFF	#{SPACE}?"pragma"{SPACE}"source"{SPACE}"off"
T_ON	#{SPACE}?"pragma"{SPACE}"token"{SPACE}"on"
T_OFF	#{SPACE}?"pragma"{SPACE}"token"{SPACE}"off"
ERRVAR	({INT}|{DOUB}|{ID}|{SCI})({INT}|{DOUB}|{ID}|{SCI})+

%%
"/*"	{
	BEGIN(COMMENT);
	strcat(buffer, yytext);
}
<COMMENT>"*/"	{
	strcat(buffer, yytext);
	BEGIN(INITIAL);
}
<COMMENT>"\n"	{
	line_number++;
	if(source)	fprintf(yyout, "%d:%s\n", line_number, buffer);
	memset(buffer, 0, sizeof(buffer));
}
<COMMENT>.	{
	strcat(buffer, yytext);
}
"//".*	{
	strcat(buffer, yytext);
}
{S_ON}	{
	source = 1;
	strcat(buffer, yytext);
}
{S_OFF}	{
	source = 0;
	strcat(buffer, yytext);
}
{T_ON}	{
	token = 1;
	strcat(buffer, yytext);
}
{T_OFF}	{
	token = 0;
	strcat(buffer, yytext);
}
{KEY}	{ 
	if(token)	fprintf(yyout, "#key:%s\n", yytext);
	strcat(buffer, yytext); 
} 
{SPACE}	{ 
	strcat(buffer, yytext);
}
{OP}	{ 
	if(token)	fprintf(yyout, "#op:%s\n", yytext);
	strcat(buffer, yytext);
}
{PUNC}  { 
	if(token)	fprintf(yyout, "#punc:%s\n", yytext);
	strcat(buffer, yytext);
}
{INT}	{ 
	if(token)	fprintf(yyout, "#integer:%s\n", yytext);
	strcat(buffer, yytext);
}
{DOUB}	{ 
	if(token)	fprintf(yyout, "#double:%s\n", yytext);
	strcat(buffer, yytext); 
}
{CHAR}	{ 
	if(token)	fprintf(yyout, "#char:%s\n", yytext);
	strcat(buffer, yytext); 
}
{ID}	{ 
	if(token)	fprintf(yyout, "#id:%s\n", yytext); 
	strcat(buffer, yytext);
}
{STR}	{
	char str_out[1000];
	if(token){
		if(yytext[0] == 'L')	strcpy(str_out, yytext + 2);
		else	strcpy(str_out, yytext + 1);
		str_out[strlen(str_out)-1] = 0;
		fprintf(yyout, "#string:%s\n", str_out);
	}
	strcat(buffer, yytext);
}
{SCI}	{
	if(token)	fprintf(yyout, "#sci:%s\n", yytext);
	strcat(buffer, yytext);
}
{ERRVAR}	{
	strcat(errorMessage, yytext);
	BEGIN(ERR);
}
\n	{
	line_number++;
	if(source)	fprintf(yyout, "%d:%s\n", line_number, buffer);
	memset(buffer, 0, sizeof(buffer));
}
.	{
	BEGIN(ERR);
    strcat(errorMessage, yytext);
}
<ERR>\n	{
	line_number++;
	fprintf(stderr, "Error at line %d: %s\n", line_number, errorMessage); exit(1); 
}
<ERR>.*	{
	strcat(errorMessage, yytext);
}
%%

int main(int argc, char* argv[])
{
	// Read File
	++argv;
	--argc;
	if(0 < argc){
		yyin = fopen(argv[0], "r");
		yyout = fopen(argv[1], "w");
	} else{
		yyin = stdin;
	}

	yylex();
	//fprintf(yyout, "Finish!!\n");
	return 0;
}
