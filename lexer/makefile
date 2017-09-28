all:
	flex lex.l
	gcc -fpic -c -o lex.o lex.yy.c
	gcc -shared -o llex.so lex.o

clean:
	rm *.yy.c
	rm *.o
	rm *.so
