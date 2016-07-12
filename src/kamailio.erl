-module(kamailio).
-include("../include/kamailio.hrl").
-export([install/2, test/2]).

-define(DEFAULT_TIMEOUT, 60000).
-define(DEPS, ["json-c", "kamailio", "librabbitmq", "libuuid", "libevent"
              ,"bison", "flex", "librabbitmq-devel", "libevent-devel"
              ,"json-c-devel"]).

-define(COMMANDS, [%% "curl -o /etc/yum.repos.d/2600hz.repo http://repo.2600hz.com/2600hz.repo -s" %add 2600 repo
                   "yum -y install epel-release" %add epel repo
                  ,"curl -o /etc/yum.repos.d/kamailio.repo http://download.opensuse.org/repositories/home:/kamailio:/v4.4.x-rpms/CentOS_7/home:kamailio:v4.4.x-rpms.repo"
                  ,"yum -y install " ++ lists:flatten(lists:join(" ", ?DEPS)) %install deps
                  ,"git clone https://github.com/kamailio/kamailio.git"
                  ,"cd kamailio/modules/kazoo && git checkout 4.4 && make"
                  ,"mv kazoo.so /lib64/kamailio/modules && cd ../../../ && rm -rf kamailio"
                  %% ,"echo 'loadmodule \"kazoo.so\"' >> /etc/kamailio/kamailio.cfg"
                  ,"echo '10.11.102.134 nikitafs16.siplabs.local' >> /etc/hosts" %FIXME
                  ,"systemctl restart kamailio && systemctl enable kamailio"
                  %% ,"mkdir /etc/kazoo/logs -p"
                  %% ,"ln -s /etc/kamailio /etc/kazoo"
                  ]).

-define(TESTS, ["curl http://localhost:5984"]).

install(ConnectionRef, Options)->
    lists:zip(?COMMANDS, [ssh_lib:ssh_call(ConnectionRef, Cmd, ?DEFAULT_TIMEOUT, Options) || Cmd <- ?COMMANDS]).
    
test(ConnectionRef, Options)->
    lists:zip(?COMMANDS, [ssh_lib:ssh_call(ConnectionRef, Cmd, ?DEFAULT_TIMEOUT, Options) || Cmd <- ?TESTS]).
