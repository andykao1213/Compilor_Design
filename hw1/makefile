scanner: scanner.l lex.yy.c
	gcc -o scanner lex.yy.c -lfl
lex.yy.c: scanner.l
	flex scanner.l
clean:
	rm -f scanner lex.yy.c
