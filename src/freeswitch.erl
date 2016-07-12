-module(freeswitch).
-include("../include/freeswitch.hrl").
-export([install/2]).

-define(DEFAULT_TIMEOUT, 60000).
-define(DEPS, ["git", "gcc-c++", "autoconf", "automake", "libtool",
                  "wget", "python", "ncurses-devel", "zlib-devel", "libjpeg-devel",
                  "openssl-devel", "e2fsprogs-devel", "sqlite-devel", "libcurl-devel",
                  "pcre-devel", "speex-devel", "ldns-devel", "libedit-devel",
                  "libxml2-devel", "libyuv-devel", "opus-devel", "libvpx-devel",
                  "libvpx2*", "libdb4*", "libidn-devel", "unbound-devel",
                  "libuuid-devel", "lua-devel", "libsndfile-devel", "yasm", "nasm",
                  "erlang-18.3"]).

-define(COMMANDS, ["curl -o /etc/yum.repos.d/2600hz.repo http://repo.2600hz.com/2600hz.repo -s" %add 2600 repo
                  ,"yum -y install epel-release" %add epel repo
                  ,"curl -o /etc/yum.repos.d/erlang_solutions.repo http://packages.erlang-solutions.com/rpm/centos/erlang_solutions.repo" %add erlang_solutions repo
                  ,"rpm -Uvh http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el7.rf.x86_64.rpm " ++
                       "&& rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt" %rpmforge repo
                  ,"rpm -Uvh http://files.freeswitch.org/freeswitch-release-1-6.noarch.rpm" %fs repo
                  ,"yum -y install " ++ lists:flatten(lists:join(" ", ?DEPS)) %install deps
                  %% ,"service iptables save && service iptables stop && chkconfig iptables off "%disable firewall (FIXME: Centos7 have no firewall)
                  ,"sed -i 's/^SELINUX=.*$/SELINUX=disabled/g' /etc/selinux/config" %disable SELinux
                  %% ,"echo kazoo.nikitakz.local > /etc/localhost"      %FQDN (FIXME)
                  %% ,"echo '127.0.0.1	kazoo.nikitakz.siplabs' >> /etc/localhost"      %FQDN (FIXME)
                  ,"yum install -y freeswitch-config-vanilla sox freeswitch-sounds* freeswitch-kazoo freeswitch-event-erlang-event"
                  ,"systemctl enable freeswitch && systemctl restart freeswitch"
                  ,"mkdir /etc/kazoo/logs -p"
                  ,"ln -s /var/log/freeswitch/freeswitch.log /etc/kazoo/logs"
                  ,"ln -s /etc/freeswitch /etc/kazoo/"
]).

install(ConnectionRef, Options)->
    lists:zip(?COMMANDS, [ssh_lib:ssh_call(ConnectionRef, Cmd, ?DEFAULT_TIMEOUT, Options) || Cmd <- ?COMMANDS]).
    
%% test(ConnectionRef, Options)->
%%     lists:zip(?COMMANDS, [ssh_lib:ssh_call(ConnectionRef, Cmd, ?DEFAULT_TIMEOUT, Options) || Cmd <- ?TESTS]).
