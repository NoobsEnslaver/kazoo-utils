-define(FREESWITCH_OPTIONS, [?FREESWITCH_AUTOLOAD_CONFIGS, ?FREESWITCH_CERTS
                            ,?FREESWITCH_CHATPLAN, ?FREESWITCH_DIALPLAN
                            ,?FREESWITCH_DIRECTORY, ?FREESWITCH_FREESWITCH_XML
                            ,?FREESWITCH_LANG, ?FREESWITCH_MIME_TYPE
                            ,?FREESWITCH_SCRIPTS,?FREESWITCH_SIP_PROFILES]).

-define(FREESWITCH_AUTOLOAD_CONFIGS, [?FAC_CONFERENCE_CONF_XML, ?FAC_CONSOLE_CONF_XML
                                     ,?FAC_EVENT_SOCKET_CONF_XML ,?FAC_HTTP_CACHE_CONF_XML
                                     ,?FAC_KAZOO_CONF_XML,?FAC_LOCAL_STREAM_CONF_XML
                                     ,?FAC_LOGFILE_CONF_XML,?FAC_MODULES_CONF_XML
                                     ,?FAC_POST_LOAD_MODULES_CONF_XML,?FAC_SHOUT_CONF_XML
                                     ,?FAC_SOFIA_CONF_XML,?FAC_SPANDSP_CONF_XML
                                     ,?FAC_SWITCH_CONF_XML,?FAC_SYSLOG_CONF_XML
                                     ,?FAC_TIMEZONES_CONF_XML]).

-define(FREESWITCH_CERTS, []).
-define(FREESWITCH_CHATPLAN, []).
-define(FREESWITCH_DIALPLAN, []).
-define(FREESWITCH_DIRECTORY, []).
-define(FREESWITCH_FREESWITCH_XML, []).
-define(FREESWITCH_LANG, [?FL_EN, ?FL_FR, ?FL_DE, ?FL_ES, ?FL_HE, ?FL_PT, ?FL_RU]).
-define(FREESWITCH_MIME_TYPE, []).
-define(FREESWITCH_SCRIPTS, [?FS_KAZOO_SYNC_SH]).
-define(FREESWITCH_SIP_PROFILES, [?FS_SIPINTERFACE_1_XML]).

-define(FL_EN, [?FLEN_DEMO, ?FLEN_DIR, ?FLEN_IVR, ?FLEN_VM, ?FLEN_EN_XML]).
-define(FL_FR, [?FLFR_DEMO, ?FLFR_DIR, ?FLFR_VM, ?FLFR_FR_XML]).
-define(FL_DE, [?FLDE_DEMO, ?FLDE_VM, ?FLDE_DE_XML]).
-define(FL_ES, [?FLES_DEMO, ?FLES_DIR, ?FLES_VM, ?FLES_ES_XML, ?FLES_MX_XML]).
-define(FL_HE, [?FLHE_DEMO, ?FLHE_DIR, ?FLHE_VM, ?FLHE_HE_XML]).
-define(FL_PT, [?FLPT_DEMO, ?FLPT_DIR, ?FLPT_VM, ?FLPT_PT_XML, ?FLPT_BR_XML]).
-define(FL_RU, [?FLRU_DEMO, ?FLRU_DIR, ?FLRU_VM, ?FLRU_RU_XML]).

-define(FLEN_DEMO, [?FLEND_DEMO_IVR_XML, ?FLEND_DEMO_XML, ?FLEND_FUNNIES_XML, ?FLEND_NEW_DEMO_IVR_XML]). %
-define(FLEN_DIR, [?FLEND_SOUNDS_XML, ?FLEND_TTS_XML]). %
-define(FLEN_IVR, [?FLEND_SOUNDS_XML]).                 %
-define(FLEN_VM, [?FLENV_SOUNDS_XML, ?FLENV_TTS_XML]).  %
%% -define(FLEN_EN_XML, []).

%% WORK HERE = /etc/kazoo/freeswitch/lang/es/
-define(FLFR_DEMO, []).                         %
-define(FLFR_DIR, []).                          %
-define(FLFR_VM, []).                           %
%% -define(FLFR_FR_XML, []).

-define(FLDE_DEMO, [?FLDED_DEMO_XML]).          %
-define(FLDE_VM, [?FLDEV_SOUNDS_XML, ?FLDEV_TTS_XML]). %
%% -define(FLDE_DE_XML, []).

-define(FLES_DEMO, []).                         %
-define(FLES_DIR, []).                          %
-define(FLES_VM, []).                           %
%% -define(FLES_ES_XML, []).
%% -define(FLES_MX_XML, []).

-define(FLHE_DEMO, []).                         %
-define(FLHE_DIR, []).                          %
-define(FLHE_VM, []).                           %
%% -define(FLHE_HE_XML, []).

-define(FLPT_DEMO, []).                         %
-define(FLPT_DIR, []).                          %
-define(FLPT_VM, []).                           %
%% -define(FLPT_PT_XML, []).
%% -define(FLPT_BR_XML, []).

-define(FLRU_DEMO, []).                         %
-define(FLRU_DIR, []).                          %
-define(FLRU_VM, []).                           %
%% -define(FLRU_RU_XML, []).
