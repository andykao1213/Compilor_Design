%{

	#include <stdio.h>
	#include <string.h>
	char buffer[1000];
	int line_number = 0;
%}

KEY		void|int|double|bool|char|null|for|while|do|if|else|switch|return|break|continue|const|true|false|struct|case|default|fclose|clearerr|feof|ferror|fflush|fgetpos|fopen|fread|freopen|fseek|fsetpos|ftell|fwrite|remove|rename|rewind|setbuf|setvbuf|tmpfile|tmpnam|fprintf|printf|sprintf|vfprintf|vprintf|vsprintf|fscanf|scanf|sscanf|fgetc|fgets|fputc|fputs|getc|getchar|gets|putc|putchar|puts|ungetc|perror
SPACE	[ \t\t]+
OP		"+"|"-"|"*"|"/"|"%"|"++"|"--"|"<"|"<="|">"|">="|"=="|"!="|"="|"&&"|"||"|"!"
PUNC	":"|";"|","|"."|"["|"]"|"("|")"|"{"|"}"
INT		[1-9][0-9]*|0
DOUB	{INT}?"."{INT}
CH		[a-z]
CHAR	\'.\'
ID		[[:alpha:]]+

%%

{KEY}	{ 
	fprintf(yyout, "#key:%s\n", yytext);
	strcat(buffer, yytext); 
} 
{SPACE}	{ 
	strcat(buffer, yytext);
}
{OP}	{ 
	fprintf(yyout, "#op:%s\n", yytext);
	strcat(buffer, yytext);
}
{PUNC}  { 
	fprintf(yyout, "#punc:%s\n", yytext);
	strcat(buffer, yytext);
}
{INT}	{ 
	fprintf(yyout, "#integer:%s\n", yytext);
	strcat(buffer, yytext);
}
{DOUB}	{ 
	fprintf(yyout, "#double:%s\n", yytext);
	strcat(buffer, yytext); 
}
{CHAR}	{ 
	fprintf(yyout, "#char:%s\n", yytext);
	strcat(buffer, yytext); 
}
{ID}	{ 
	fprintf(yyout, "#id:%s\n", yytext); 
	strcat(buffer, yytext);
}
\n	{
	line_number++;
	fprintf(yyout, "%d:%s\n", line_number, buffer);
	memset(buffer, 0, sizeof(buffer));
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
