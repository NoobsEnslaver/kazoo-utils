-module(kamailio).
-include("../include/config.hrl").
-export([install/2, test/2, configure/3]).

-define(DEFAULT_TIMEOUT, 60000).
-define(DEPS, ["json-c", "kamailio", "librabbitmq", "libuuid", "libevent"
              ,"bison", "flex", "librabbitmq-devel", "libevent-devel"
              ,"json-c-devel", "kazoo-config"]).

-define(COMMANDS, ["curl -o /etc/yum.repos.d/2600hz.repo http://repo.2600hz.com/2600hz.repo -s" %add 2600 repo
                   "yum -y install epel-release" %add epel repo
                  ,"curl -o /etc/yum.repos.d/kamailio.repo http://download.opensuse.org/repositories/home:/kamailio:/v4.4.x-rpms/CentOS_7/home:kamailio:v4.4.x-rpms.repo"
                  ,"yum -y install " ++ utils:flat(?DEPS) %install deps
                  ,"git clone https://github.com/kamailio/kamailio.git"
                  ,"cd kamailio/modules/kazoo && git checkout 4.4.2 && make && mv kazoo.so /lib64/kamailio/modules && cd ../../../ && rm -rf kamailio"
                  ,"ln -s /usr/lib64/kamailio/libkcore.so.1 /usr/lib64/libkcore.so.1"
                  ,"ln -s /usr/lib64/kamailio/libcore.so.1 /usr/lib64/libcore.so.1"
                  ,"ln -s /usr/lib64/kamailio/libkmi.so.1 /usr/lib64/libkmi.so.1"
                  ,"ln -s /usr/lib64/kamailio/libsrdb1.so.1 /usr/lib64/libsrdb1.so.1"
                  ,"ln -s /usr/lib64/kamailio/libsrdb2.so.1 /usr/lib64/libsrdb2.so.1"
                  ,"rm -rf /etc/kamailio && ln -s /etc/kazoo/kamailio"
                  %% ,"echo 'loadmodule \"kazoo.so\"' >> /etc/kamailio/kamailio.cfg"
                  
                  ,"systemctl enable kamailio"
                  %% ,"mkdir /etc/kazoo/logs -p"
                  %% ,"ln -s /etc/kamailio /etc/kazoo"
                  ]).

-define(TESTS, ["systemctl restart kamailio"
               ,"curl http://localhost:5984"]).
-record(kamailio_config, {rabbit_ip     :: string()
                         ,host_name     :: string()
                         ,host_ip       :: string()
                         ,dispatchers   :: {string(), string(), string(), string()}
                         }).

install(ConnectionRef, Options)->
    lists:zip(?COMMANDS, [ssh_lib:ssh_call(ConnectionRef, Cmd, ?DEFAULT_TIMEOUT, Options) || Cmd <- ?COMMANDS]).
    
test(ConnectionRef, Options)->
    lists:zip(?TESTS, [ssh_lib:ssh_call(ConnectionRef, Cmd, ?DEFAULT_TIMEOUT, Options) || Cmd <- ?TESTS]).

configure(ConnectionRef, Options, #kamailio_config{rabbit_ip = RabbitIP
                                                  ,host_ip = HostIP
                                                  ,host_name = HostName
                                                  ,dispatchers = Dispatchers})->
    Configure = ["sed -i 's/guest:guest@127.0.0.1:5672\/dialoginfo/guest:guest@"++RabbitIP++":5672\/dialoginfo/g' /etc/kazoo/kamailio/local.cfg"
                ,"sed -i 's/guest:guest@127.0.0.1:5672\/callmgr/guest:guest@"++RabbitIP++":5672\/callmgr/g' /etc/kazoo/kamailio/local.cfg"
                ,"sed -i 's/127.0.0.1/"++HostIP++"/g' /etc/kazoo/kamailio/local.cfg"
                ,"sed -i 's/kamailio.2600hz.com/"++HostName++"/g' /etc/kazoo/kamailio/local.cfg"
                ,"sed -i '$d' /etc/kazoo/kamailio/dbtext/dispatcher"]
        ++ ["echo '"++Type ++ " sip:"++IP++":"++Port++" "++Flag++"' >> /etc/kazoo/kamailio/dbtext/dispatcher" || {Type, IP, Port, Flag} <- Dispatchers]
        ++ ["echo '10.11.102.134 nikitafs16.siplabs.local' >> /etc/hosts" %FIXME
           ],
        lists:zip(Configure, [ssh_lib:ssh_call(ConnectionRef, Cmd, ?DEFAULT_TIMEOUT, Options) || Cmd <- Configure]);
configure(ConnectionRef, Options, Config)->
    configure(ConnectionRef, Options, makeKamConfig(Config)).

makeKamConfig(#config{cookie = A})->
    #kamailio_config{}.
