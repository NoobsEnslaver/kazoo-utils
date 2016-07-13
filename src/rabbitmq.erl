-module(rabbitmq).
-include("../include/config.hrl").
-export([install/2, test/2, configure/3]).

-define(DEFAULT_TIMEOUT, 60000).
-define(DEPS, []).
-define(COMMANDS, []).
-define(TESTS, []).

-record(rabbitmq_config, {
          bind_address = "0.0.0.0",
          slaves_server_list = "[]"
}).

install(ConnectionRef, Options)->
    lists:zip(?COMMANDS, [ssh_lib:ssh_call(ConnectionRef, Cmd, ?DEFAULT_TIMEOUT, Options) || Cmd <- ?COMMANDS]).
    
test(ConnectionRef, Options)->
    lists:zip(?TESTS, [ssh_lib:ssh_call(ConnectionRef, Cmd, ?DEFAULT_TIMEOUT, Options) || Cmd <- ?TESTS]).

configure(ConnectionRef, Options, #rabbitmq_config{ })->    
    "";
configure(ConnectionRef, Options, Config)->
    configure(ConnectionRef, Options, makeRMQConfig(Config)).

makeRMQConfig(#config{cookie = A})->
    #rabbitmq_config{}.
