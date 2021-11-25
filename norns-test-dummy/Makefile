.phony: build run run-bash run-bash-root shell shell-root

build:
	docker build -t wwinder/norns-test-dummy .

run:
	docker run --rm -it \
		--cap-add=SYS_NICE \
		--cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
		--ulimit rtprio=95 --ulimit memlock=-1 --shm-size=256m \
		-p 5000:5000 \
		-p 5555:5555 \
		-p 5556:5556 \
		-p 5900:5900 \
		-p 8889:8889 \
		-p 8000:8000 \
		-p 10111:10111/udp \
		-v ${PWD}/code:/home/we/dust/code \
		-v ${PWD}/audio:/home/we/dust/audio \
		--name norns-test-dummy \
		wwinder/norns-test-dummy

pub:
	docker run -d --rm -it \
		--cap-add=SYS_NICE \
		--cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
		--ulimit rtprio=95 --ulimit memlock=-1 --shm-size=256m \
		-p 5000:5000 \
		-p 5555:5555 \
		-p 5556:5556 \
		-p 5900:5900 \
		-p 8889:8889 \
		-p 8000:8000 \
		-p 10111:10111/udp \
		-v ${PWD}/code:/home/we/dust/code \
		-v ${PWD}/audio:/home/we/dust/audio \
		--name norns-test-dummy \
		wwinder/norns-test-dummy

radio:
	mkdir -p code
	rm -rf code/pirate-radio
	git clone https://github.com/schollz/pirate-radio code/pirate-radio
	echo "dust2dust"
	git clone --depth 1 https://github.com/schollz/dust2dust 
	cd dust2dust && go build -v 
	mv dust2dust/dust2dust code/pirate-radio/
	rm -rf dust2dust
	echo "cjson.so"
	rm -rf lua-cjson
	git clone --depth 1 https://github.com/mpx/lua-cjson.git
	cd lua-cjson && cc -c -O3 -Wall -pedantic -DNDEBUG  -I/usr/include/lua5.3 -fpic -o lua_cjson.o lua_cjson.c
	cd lua-cjson && cc -c -O3 -Wall -pedantic -DNDEBUG  -I/usr/include/lua5.3 -fpic -o strbuf.o strbuf.c
	cd lua-cjson && cc -c -O3 -Wall -pedantic -DNDEBUG  -I/usr/include/lua5.3 -fpic -o fpconv.o fpconv.c
	cd lua-cjson && cc  -shared -o cjson.so lua_cjson.o strbuf.o fpconv.o
	cp lua-cjson/cjson.so code/pirate-radio/lib/cjson.so
	rm -rf lua-cjson

run-audio:
	docker run --rm -it \
		--device /dev/snd \
		--group-add $(shell getent group audio | cut -d: -f3) \
		--cap-add=SYS_NICE \
		--cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
		--ulimit rtprio=95 --ulimit memlock=-1 --shm-size=256m \
		-p 5000:5000 \
		-p 5555:5555 \
		-p 5556:5556 \
		-p 5900:5900 \
		-p 8889:8889 \
		-p 10111:10111/udp \
		--name norns-test-dummy \
		-v ${PWD}/matronrc.lua:/home/we/norns/matronrc.lua \
		-v ${PWD}/my_jackdrc:/etc/jackdrc \
		wwinder/norns-test-dummy

run-bash:
	docker run --rm -it \
		--cap-add=SYS_NICE \
		--cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
		--ulimit rtprio=95 --ulimit memlock=-1 --shm-size=256m \
		-p 5000:5000 \
		-p 5555:5555 \
		-p 5556:5556 \
		--name norns-test-dummy \
		wwinder/norns-test-dummy \
		bash

run-bash-root:
	docker run --rm -it \
		--user root \
		--cap-add=SYS_NICE \
		--cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
		--ulimit rtprio=95 --ulimit memlock=-1 --shm-size=256m \
		-p 5000:5000 \
		-p 5555:5555 \
		-p 5556:5556 \
		--name norns-test-dummy \
		wwinder/norns-test-dummy \
		bash

shell:
	docker exec -it norns-test-dummy bash

shell-root:
	docker exec -it --user root norns-test-dummy bash
