clean:
	rm ./target/*
	cp ./fonts/CaskaydiaMonoNerdFont-Regular.ttf ./target/caskaydia.ttf

test:
	odin test ./src -out=./target/tests -define:ODIN_TEST_ALWAYS_REPORT_MEMORY=true -define:ODIN_TEST_FAIL_ON_BAD_MEMORY=true

build-exe:
	odin build ./src -out=./target/dui-exe --build-mode:exe -debug

run-exe: build-exe
	./target/dui-exe

build-lib:
	odin build ./src -out=./target/dui --build-mode:static -debug
	
