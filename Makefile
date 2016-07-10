compile: subdirs

run:
	escript kazoo-utils.esc

subdirs:
	erlc -o ebin src/*.erl

clean:	
	rm -rf ebin/*.beam src/erl_crash.dump
	cd ebin; rm -rf
