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
	mkdir -p dust
	mkdir -p dust/data
	mkdir -p dust/audio 
	mkdir -p dust/audio/tape
	mkdir -p dust/code
	mkdir -p dust/audio/mx.samples 
	cd dust/audio/mx.samples && \
	wget https://github.com/schollz/mx.samples/releases/download/samples/alto_sax_choir.zip && \
	wget https://github.com/schollz/mx.samples/releases/download/samples/drums_violin.zip && \
	wget https://github.com/schollz/mx.samples/releases/download/samples/fender_rhodes.zip && \
	wget https://github.com/schollz/mx.samples/releases/download/samples/gentle_vibes.zip && \
	wget https://github.com/schollz/mx.samples/releases/download/samples/ghost_piano.zip && \
	wget https://github.com/schollz/mx.samples/releases/download/samples/music_box.zip && \
	wget https://github.com/schollz/mx.samples/releases/download/samples/steinway_model_b.zip && \
	wget https://github.com/schollz/mx.samples/releases/download/samples/kalimba.zip && \
	wget https://github.com/schollz/mx.samples/releases/download/samples/tatak_piano.zip && \
	wget https://github.com/schollz/mx.samples/releases/download/samples/fender_strato_vib.zip && \
	wget https://github.com/schollz/mx.samples/releases/download/samples/music_box.zip && \
	wget https://github.com/schollz/mx.samples/releases/download/samples/discord_choir.zip
	chmod +x mx.samples.sh
	cd dust/audio/mx.samples && ../../../mx.samples.sh
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
    git clone https://github.com/schollz/synthy.git && \
    git clone https://github.com/schollz/amen.git && \
    git clone https://github.com/schollz/mx.samples.git && \
    git clone https://github.com/schollz/supertonic.git && \
    git clone https://github.com/schollz/downtown.git && \
    git clone https://github.com/jlmitch5/m18s && \
    git clone https://github.com/northern-information/bakeneko && \
    git clone https://github.com/pangrus/hachi && \
    git clone https://github.com/21echoes/cyrene && \
    git clone https://github.com/robmckinnon/pitfalls && \
    git clone https://github.com/aidanreilly/saws && \
    git clone https://github.com/northern-information/fiahod && \
    git clone --recurse-submodules https://github.com/yotamorimoto/norns_grd grd && \
    git clone https://github.com/markwheeler/arp_index && \
    git clone https://github.com/linusschrab/less_concepts_3 && \
    git clone https://github.com/cfdrake/twine && \
    git clone https://github.com/aidanreilly/squares && \
    git clone https://github.com/aidanreilly/bp_noise && \
    git clone https://github.com/frederickk/stjoernuithrott.git && \
    git clone https://github.com/speakerdamage/here-there.git && \
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
