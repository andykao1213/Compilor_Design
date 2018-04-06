%{

	#include <stdio.h>

%}

ch	[a-z]
key	void|int|double|bool|char|null|for|while|do|if|else|switch|return|break|continue|const|true|false|struct|case|default

%%

{key}	{ fprintf(yyout, "#key: "); ECHO; fprintf(yyout, "\n"); } 
[ \n\t\r]+	{ REJECT; }


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
