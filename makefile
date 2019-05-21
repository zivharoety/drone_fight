all: ass3 

ass3: ass3.o drone.o printer.o scheduler.o target.o
	gcc -m32 -g -Wall -o ass3 ass3.o drone.o printer.o scheduler.o target.o

ass3.o:
	nasm -g -f elf -o ass3.o ass3.s

drone.o:
	nasm -g -f elf -o drone.o drone.s
	
printer.o:
	nasm -g -f elf -o printer.o printer.s
	
scheduler.o:
	nasm -g -f elf -o scheduler.o scheduler.s

target.o:
	nasm -g -f elf -o target.o target.s
	

clean: 
	rm -f *.o ass3
