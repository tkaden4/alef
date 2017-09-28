DFLAGS=-debug
build:
	dub build $(DFLAGS)

clean:
	dub clean

.PHONY: tst
tst:
	dub test

.PHONY: unit
unit:
	find test/**/*.al | xargs -n1 ./alephc

.PHONY: run
run:
	./alephc test/main.al
