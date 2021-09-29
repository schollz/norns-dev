.phony: build run run-bash run-bash-root shell shell-root

build:
	docker build -t samdoshi/norns-test-dummy .

build2:
	docker build -t schollz/norns:dust .

run: dust
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
		-v `pwd`/dust:/home/we/dust \
		-p 10111:10111/udp \
		--name norns-test-dummy \
		samdoshi/norns-test-dummy

dust:
	mkdir -p dust && \
	mkdir -p dust/data && \
	mkdir -p dust/audio && \
	mkdir -p dust/audio/tape && \
	mkdir -p dust/code && \
	cd dust/code && \
	git clone https://github.com/tehn/awake.git && \
    git clone https://github.com/jaseknighter/flora.git  && \
    git clone https://github.com/synthetiv/euclidigons.git && \
    git clone https://github.com/justmat/showers.git && \
    git clone https://github.com/distropolis/pixels.git && \
    git clone https://github.com/ambalek/fall.git && \
    git clone https://github.com/ambalek/raindrops.git && \
    git clone https://github.com/tomwaters/spirals.git && \
    git clone https://github.com/tomwaters/breakthrough.git && \
    git clone https://github.com/northern-information/dronecaster.git  && \
    git clone https://github.com/schollz/o-o-o.git
	rm -rf lua-cjson
	git clone --depth 1 https://github.com/mpx/lua-cjson.git
	cd lua-cjson && cc -c -O3 -Wall -pedantic -DNDEBUG  -I/usr/include/lua5.3 -fpic -o lua_cjson.o lua_cjson.c
	cd lua-cjson && cc -c -O3 -Wall -pedantic -DNDEBUG  -I/usr/include/lua5.3 -fpic -o strbuf.o strbuf.c
	cd lua-cjson && cc -c -O3 -Wall -pedantic -DNDEBUG  -I/usr/include/lua5.3 -fpic -o fpconv.o fpconv.c
	cd lua-cjson && cc  -shared -o cjson.so lua_cjson.o strbuf.o fpconv.o
	mv lua-cjson/cjson.so dust/code/o-o-o/lib/
	rm -rf lua-cjson


pub: dust
	docker run -d --rm -it \
		--cap-add=SYS_NICE \
		--cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
		--ulimit rtprio=95 --ulimit memlock=-1 --shm-size=256m \
		-p 5000:5000 \
		-p 5555:5555 \
		-p 5556:5556 \
		-p 8889:8889 \
		-p 8000:8000 \
		-v `pwd`/dust:/home/we/dust \
		--name norns-test-dummy \
		samdoshi/norns-test-dummy

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
		-v /tmp/jackdrc:/etc/jackdrc \
		samdoshi/norns-test-dummy

run-bash:
	docker run --rm -it \
		--cap-add=SYS_NICE \
		--cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
		--ulimit rtprio=95 --ulimit memlock=-1 --shm-size=256m \
		-p 5000:5000 \
		-p 5555:5555 \
		-p 5556:5556 \
		--name norns-test-dummy \
		samdoshi/norns-test-dummy \
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
		samdoshi/norns-test-dummy \
		bash

shell:
	docker exec -it norns-test-dummy bash

shell-root:
	docker exec -it --user root norns-test-dummy bash
