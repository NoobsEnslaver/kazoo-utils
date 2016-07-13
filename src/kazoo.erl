-module(kazoo).
-include("../include/config.hrl").
-export([install/2, test/2, configure/3]).

-define(DEFAULT_TIMEOUT, 60000).
-define(DEPS, ["gcc-c++", "autoconf", "automake", "libtool"
                    ,"python", "ncurses-devel", "zlib-devel", "libjpeg-devel"
                    ,"openssl-devel", "e2fsprogs-devel", "libcurl-devel", "pcre-devel"
                    ,"speex-devel", "ldns-devel", "libedit-devel", "libxml2-devel","wget"
                    ,"build-essential" ,"libxslt-dev", "zip" ,"unzip", "expat"
                    ,"zlib1g-dev", "libssl-dev" ,"curl", "libncurses5-dev" ,"git-core"
                    ,"libexpat1-dev" ,"htmldoc", "erlang-18.3"]).

-define(COMMANDS, ["curl -o /etc/yum.repos.d/2600hz.repo http://repo.2600hz.com/2600hz.repo -s" %add 2600 repo
                  ,"yum -y install epel-release" %add epel repo
                  ,"curl -o /etc/yum.repos.d/erlang_solutions.repo http://packages.erlang-solutions.com/rpm/centos/erlang_solutions.repo" %add erlang_solutions repo
                  ,"yum -y install " ++ utils:flat(?DEPS) %install deps
                  ,"git clone https://github.com/2600Hz/kazoo.git /opt/kazoo "++
                       "&& cd /opt/kazoo && git checkout 4.0 && make" %clone & make kazoo
                  ,"service iptables save && service iptables stop && chkconfig iptables off " ++
                       "&& sed -i 's/^SELINUX=.*$/SELINUX=disabled/g' /etc/selinux/config" %disable firewall and SELinux
                  ,"ln -s /opt/kazoo/core/sup/priv/sup /usr/bin/sup" %sup
                  ,"echo kazoo.nikitakz.local > /etc/localhost"      %FQDN (FIXME
                  ,"echo '127.0.0.1	kazoo.nikitakz.siplabs' >> /etc/localhost"      %FQDN (FIXME)
                  ]).

-define(TESTS, ["curl localhost:15984"]).

-record(kazoo_config, {cookie
                      ,rabbit_ip
}).

install(ConnectionRef, Options)->
    lists:zip(?COMMANDS, [ssh_lib:ssh_call(ConnectionRef, Cmd, ?DEFAULT_TIMEOUT, Options) || Cmd <- ?COMMANDS]).

test(ConnectionRef, Options)->
    lists:zip(?TESTS, [ssh_lib:ssh_call(ConnectionRef, Cmd, ?DEFAULT_TIMEOUT, Options) || Cmd <- ?TESTS]).

configure(ConnectionRef, Options, #kazoo_config{cookie = Cookie
                                               ,rabbit_ip = RabbitIP})->
    Configure = ["sed -i 's/change_me/" ++ Cookie ++ "/g' /etc/kazoo/config.ini"
                ,"sed -i 's|uri = \"amqp://guest:guest@127.0.0.1:5672\"|uri = \"amqp://guest:guest@"++RabbitIP++":5672\"|g' /etc/kazoo/config.ini"],
    lists:zip(Configure, [ssh_lib:ssh_call(ConnectionRef, Cmd, ?DEFAULT_TIMEOUT, Options) || Cmd <- Configure]);
configure(ConnectionRef, Options, Config)->
    configure(ConnectionRef, Options, makeKZConfig(Config)).

makeKZConfig(#config{cookie = A})->
    #kazoo_config{cookie = A}.
