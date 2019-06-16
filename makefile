all:
	rm -f parser.out
	lex lex.l
	yacc parser.y -d -v -g -Wno-yacc
	gcc lex.yy.c y.tab.c -ly -ll -o parser.out
