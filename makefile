DFLAGS=-debug
EXE=alefc
all:
	dub build $(DFLAGS)

clean:
	dub clean

tst:
	dub test

unit:
	find test/**/*.al | xargs -n1 ./$(EXE)

run:
	./$(EXE) --repl

.PHONY: tst unit clean run
