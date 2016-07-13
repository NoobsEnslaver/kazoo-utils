-module(haproxy).
-include("../include/config.hrl").
-export([install/2, test/2, configure/3]).

-define(DEFAULT_TIMEOUT, 60000).
-define(DEPS, ["haproxy", "kazoo-configs"]).
-define(COMMANDS, ["curl -o /etc/yum.repos.d/2600hz.repo http://repo.2600hz.com/2600hz.repo -s"
                  ,"yum -y install " ++ lists:flatten(lists:join(" ", ?DEPS)) %install deps
                  ,"rm -rf /etc/haproxy/haproxy.cfg && ln -s /etc/kazoo/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg"]).
-define(TESTS, []).

-record(haproxy_config, {
          dbservers :: [server],
          server :: {domainName, ip, port, options}
}).

install(ConnectionRef, Options)->
    lists:zip(?COMMANDS, [ssh_lib:ssh_call(ConnectionRef, Cmd, ?DEFAULT_TIMEOUT, Options) || Cmd <- ?COMMANDS]).
    
test(ConnectionRef, Options)->
    lists:zip(?TESTS, [ssh_lib:ssh_call(ConnectionRef, Cmd, ?DEFAULT_TIMEOUT, Options) || Cmd <- ?TESTS]).

configure(ConnectionRef, Options, #haproxy_config{ dbservers = DBServers})->
    Configure = lists:duplicate(15, "sed -i '$d' /etc/kazoo/haproxy/haproxy.cfg")
        ++ ["listen couchdb-data 127.0.0.1:15984\n\tbalance roundrobin\n"]
        ++ ["\t\tserver "++DomainName++" "++IP++":"++Port++" "++utils:flat(DBOptions)++"\n"|| {DomainName, IP, Port, DBOptions} <- DBServers]
        ++ ["\nlisten couchdb-mgr 127.0.0.1:15986\n\tbalance roundrobin\n"]
        ++ ["\t\tserver "++DomainName++" "++IP++":"++Port++" "++utils:flat(DBOptions)++"\n"|| {DomainName, IP, Port, DBOptions} <- DBServers]
        ,lists:zip(Configure, [ssh_lib:ssh_call(ConnectionRef, Cmd, ?DEFAULT_TIMEOUT, Options) || Cmd <- Configure]);

configure(ConnectionRef, Options, Config)->
    configure(ConnectionRef, Options, makeHPConfig(Config)).

makeHPConfig(#config{cookie = A})->
    #haproxy_config{}.
