-module(couchdb).
-include("../include/config.hrl").
-export([install/2, test/2, configure/3]).

-define(DEFAULT_TIMEOUT, 60000).
-define(COUCH_DEPS, ["autoconf", "autoconf-archive", "openssl", "gcc"
                    ,"libcurl", "python2", "automake", "ncurses-devel"
                    ,"curl-devel", "erlang-asn1", "erlang-erts"
                    ,"erlang-os_mon", "erlang-xmerl", "erlang-eunit"
                    ,"help2man", "js-devel", "libicu-devel", "libtool"
                    ,"perl-Test-Harness", "erlang-18.3","util-linux"
                    ,"js-1.8.5-7.el6.x86_64"]). %nodejs

-define(COMMANDS, [%% "curl -o /etc/yum.repos.d/2600hz.repo http://repo.2600hz.com/2600hz.repo -s" %add 2600 repo
                  %% ,
                   "yum -y install epel-release" %add epel repo
                  ,"curl -o /etc/yum.repos.d/erlang_solutions.repo http://packages.erlang-solutions.com/rpm/centos/erlang_solutions.repo" %add erlang_solutions repo
                  ,"rpm -Uvh http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el7.rf.x86_64.rpm " ++
                       "&& rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt" %rpmforge repo
                  %% ,"curl -s --location https://rpm.nodesource.com/setup_6.x | bash -" %nodejs_v6 (TODO: try epel)
                  ,"yum -y install " ++ lists:flatten(lists:join(" ", ?COUCH_DEPS)) %install deps
                   %% ,"service iptables save && service iptables stop && chkconfig iptables off" %disable firewall (FIXME: Centos7 have no firewall)
                  ,"sed -i 's/^SELINUX=.*$/SELINUX=disabled/g' /etc/selinux/config" %disable SELinux
                   
                   %% ,"curl http://ftp.mozilla.org/pub/mozilla.org/js/js185-1.0.0.tar.gz | tar zx"
                   %% ,"cd js-1.8.5/js/src && ./configure && make && make install"
                  ,"git clone https://github.com/apache/couchdb.git ~/couchdb"
                  ,"cd couchdb && make clean && ./configure && sed -i 's/^with_docs =.*$/with_docs = 0/g' install.mk && make build && mv rel/couchdb /opt"
                  ,"adduser --no-create-home couchdb --home /opt/couchdb"
                  ,"chown -R couchdb:couchdb /opt/couchdb"]
        ++ ["echo '"++X++"' >> /etc/systemd/system/couchdb.service" || X <- ["[Unit]"
                                                                   ,"Description=CouchDB Server"
                                                                   ,""
                                                                   ,"[Service]"
                                                                   ,"User=couchdb"
                                                                   ,"Type=forking"
                                                                   ,"PermissionsStartOnly=true"
                                                                   ,"ExecStart=/opt/couchdb/bin/couchdb -b -o /dev/null -e /dev/null"
                                                                   ,"ExecStop=/opt/couchdb/bin/couchdb -d"
                                                                   ,""
                                                                   ,"[Install]"
                                                                   ,"WantedBy=multi-user.target"]]
       ++ ["systemctl enable couchdb"]).






-define(TESTS, ["systemctl restart couchdb"
               ,"curl http://localhost:5984"]).

-record(couchdb_config, {bind_address = "0.0.0.0" :: string()
                        ,slaves_server_list = [] :: list()
                        ,hostname               :: string()
}).

install(ConnectionRef, Options)->
    lists:zip(?COMMANDS, [ssh_lib:ssh_call(ConnectionRef, Cmd, ?DEFAULT_TIMEOUT, Options) || Cmd <- ?COMMANDS]).
    
test(ConnectionRef, Options)->
    lists:zip(?TESTS, [ssh_lib:ssh_call(ConnectionRef, Cmd, ?DEFAULT_TIMEOUT, Options) || Cmd <- ?TESTS]).

configure(ConnectionRef, Options, #couchdb_config{bind_address = BindAddress
                                                 ,slaves_server_list = SlavesServerList
                                                 ,hostname = HostName
                                    })->
    Configure = ["echo '127.0.0.1	"++HostName++"' >> /etc/localhost"      %FQDN
                ,"echo '"++HostName++"' > /etc/hostname"
                ,"sed -i 's/^bind_address =.*$/bind_address = " ++ BindAddress ++ "/g' /opt/couchdb/etc/default.ini"
                ]
        ++ ["curl -X PUT 127.0.0.1:5986/nodes/couchdb" ++ X ++ " -d {}" || X<-SlavesServerList],
    lists:zip(Configure, [ssh_lib:ssh_call(ConnectionRef, Cmd, ?DEFAULT_TIMEOUT, Options) || Cmd <- Configure]);
configure(ConnectionRef, Options, Config)->
    configure(ConnectionRef, Options, makeCDBConfig(Config)).

makeCDBConfig(#config{cookie = A})->
    #couchdb_config{}.
