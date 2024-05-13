
CC = gcc
CFLAGS = -Wall -Isrc -D_GNU_SOURCE -Iinclude -std=c99 -g

.PHONY: all build clean graphs main pthread_main

SRC_DIR = src
TST_DIR = tst
INSTALL_DIR = install
MAIN_PROGRAM = main.o

SRCS = ${SRC_DIR}/*.c
MAIN_OBJ = 01-main.o
SWITCH_OBJ = 02-switch.o
EQUITY_OBJ = 03-equity.o
JOIN_OBJ = 11-join.o
JOIN-MAIN_OBJ = 12-join-main.o
CREATE-MANY = 21-create-many.o
CREATE-MANY-RECURSIVE = 22-create-many-recursive.o
CREATE-MANY-ONCE = 23-create-many-once.o
SWITCH_MANY = 31-switch-many.o
SWITCH_MANY_JOIN = 32-switch-many-join.o
SWITCH_MANY_CASCADE = 33-switch-many-cascade.o
FIBONACCI = 51-fibonacci.o
MUTEX = 61-mutex.o
MUTEX_2 = 62-mutex.o
MUTEX_2 = 62-mutex.o
MUTEX_3 = 63-mutex-equity.o
PREEMPTION = 71-preemption.o
DEADLOCK = 81-deadlock.o


%.o: ${SRC_DIR}/%.c 
	${CC} ${CFLAGS} -fPIC -c $< -o $@

%_p.o: ${SRC_DIR}/%.c 
	${CC} ${CFLAGS} -fPIC -DUSE_PTHREAD -c $< -o $@
	
%.o: ${TST_DIR}/%.c
	${CC} ${CFLAGS} -fPIC -c $< -o $@
	
thread_with_enable_preemption.o: src/thread.c 
	${CC} ${CFLAGS} -DENABLEPREEMPTION -fPIC -c $< -o $@

all: install

install: main ${MAIN_OBJ} ${MAIN_OBJ_p} ${SWITCH_OBJ} ${EQUITY_OBJ} ${JOIN_OBJ} ${JOIN-MAIN_OBJ} ${CREATE-MANY} ${CREATE-MANY-RECURSIVE} ${CREATE-MANY-ONCE} ${SWITCH_MANY} ${SWITCH_MANY_JOIN} ${SWITCH_MANY_CASCADE} ${FIBONACCI} ${MUTEX} ${MUTEX_2} ${PREEMPTION} ${DEADLOCK} ${SIGNAL} ${MUTEX_3} thread_with_enable_preemption.o build
main: thread.o ${MAIN_PROGRAM} 
	${CC} ${CFLAGS} $^ -o $@

pthread_main: ${SRC_DIR}/main.c ${SRC_DIR}/thread.h 
	${CC} ${CFLAGS} $^ -o $@ -DUSE_PTHREAD -lpthread 

run: install
	@echo "Running all executables..."
	@for file in $(wildcard $(INSTALL_DIR)/bin/*); do \
        echo "Running $$file"; \
        if echo $$file | grep -q -E "install/bin/(2|3|5)"; then \
            if [ $$file = install/bin/31-switch-many ] || [ $$file = install/bin/32-switch-many-join ] || [ $$file = install/bin/33-switch-many-cascade ]; then \
                ./$$file 20 30; \
            else \
                ./$$file 20; \
            fi; \
		elif [ $$file = install/bin/71-preemption ]; then \
            ./$$file 20 5; \
        else \
            ./$$file; \
        fi; \
    done



graphs:
	python3 graphs/evaluate_performance.py

build: thread.o 

	mkdir -p ${INSTALL_DIR}
	mkdir -p ${INSTALL_DIR}/bin
	${CC} -shared $^ -o ${INSTALL_DIR}/libthread.so
	${CC} ${CFLAGS} ${MAIN_OBJ} thread.o -o ${INSTALL_DIR}/bin/01-main
	${CC} ${CFLAGS} ${SWITCH_OBJ} thread.o -o ${INSTALL_DIR}/bin/02-switch
	${CC} ${CFLAGS} ${EQUITY_OBJ} thread.o -o ${INSTALL_DIR}/bin/03-equity
	${CC} ${CFLAGS} ${JOIN_OBJ} thread.o -o ${INSTALL_DIR}/bin/11-join
	${CC} ${CFLAGS} ${JOIN-MAIN_OBJ} thread.o -o ${INSTALL_DIR}/bin/12-join-main
	${CC} ${CFLAGS} ${CREATE-MANY} thread.o -o ${INSTALL_DIR}/bin/21-create-many
	${CC} ${CFLAGS} ${CREATE-MANY-RECURSIVE} thread.o -o ${INSTALL_DIR}/bin/22-create-many-recursive
	${CC} ${CFLAGS} ${CREATE-MANY-ONCE} thread.o -o ${INSTALL_DIR}/bin/23-create-many-once
	${CC} ${CFLAGS} ${SWITCH_MANY} thread.o -o ${INSTALL_DIR}/bin/31-switch-many
	${CC} ${CFLAGS} ${SWITCH_MANY_JOIN} thread.o -o ${INSTALL_DIR}/bin/32-switch-many-join
	${CC} ${CFLAGS} ${SWITCH_MANY_CASCADE} thread.o -o ${INSTALL_DIR}/bin/33-switch-many-cascade
	${CC} ${CFLAGS} ${FIBONACCI} thread.o -o ${INSTALL_DIR}/bin/51-fibonacci
	${CC} ${CFLAGS} ${MUTEX} thread.o -o ${INSTALL_DIR}/bin/61-mutex
	${CC} ${CFLAGS} ${MUTEX_2} thread.o -o ${INSTALL_DIR}/bin/62-mutex
	${CC} ${CFLAGS} ${MUTEX_3} thread.o -o ${INSTALL_DIR}/bin/63-mutex-equity
	${CC} ${CFLAGS} ${PREEMPTION} thread_with_enable_preemption.o -o ${INSTALL_DIR}/bin/71-preemption 
	# ${CC} ${CFLAGS} ${DEADLOCK} thread.o -o ${INSTALL_DIR}/bin/81-deadlock

clean:
	rm -f *.o example ${MAIN_OBJ} ${SWITCH_OBJ} ${EQUITY_OBJ} ${JOIN_OBJ} ${JOIN-MAIN_OBJ} ${CREATE-MANY} ${CREATE-MANY-RECURSIVE} ${CREATE-MANY-ONCE} ${SWITCH_MANY} ${SWITCH_MANY_JOIN} ${SWITCH_MANY_CASCADE} ${FIBONACCI} ${MUTEX} ${MUTEX_2} ${MUTEX_3} ${PREEMPTION} ${DEADLOCK} 
	rm -rf ./graphs/figures/* install main pthread_main 