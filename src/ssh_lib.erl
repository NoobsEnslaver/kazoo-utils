-module('ssh_lib').
-export([ssh_call/3, ssh_call/4, ssh_cast/2]).

-spec ssh_cast(ssh:ssh_connection_ref(), string())-> no_return().
ssh_cast(ConnectionRef, Command)->
    {'ok', ChannelId} = ssh_connection:session_channel(ConnectionRef, infinity),
    'success' = ssh_connection:exec(ConnectionRef, ChannelId, Command, infinity). %leaks

-spec ssh_call(ssh:ssh_connection_ref(), string(), non_neg_integer())-> {integer(), [binary()]}.
-spec ssh_call(ssh:ssh_connection_ref(), string(), non_neg_integer(), [tuple()])-> {integer(), [binary()]}.
ssh_call(ConnectionRef, Command, Timeout)->
    ssh_call(ConnectionRef, Command, Timeout, []).
ssh_call(ConnectionRef, Command, Timeout, Options)->
    IsVerbose = proplists:get_bool('verbose', Options),
    if IsVerbose -> io:format("Try ~s....", [utils:normalize(Command)]);
       true -> 'ok'
    end,
    {'ok', ChannelId} = ssh_connection:session_channel(ConnectionRef, Timeout),
    'success' = ssh_connection:exec(ConnectionRef, ChannelId, Command, Timeout),
    {ExitCode, Responce} = wait_for_response(ConnectionRef, ChannelId, {0, []}),
    if IsVerbose -> case ExitCode of
                        0 -> io:format("done~n");
                        _ -> io:format("error~nexit code: ~p~nResponse:~p~n", [ExitCode, Responce])
                    end;
       true -> 'ok'
    end,
    {ExitCode, Responce}.

-spec wait_for_response(ssh:ssh_connection_ref(), ssh:ssh_channel_id(), list())-> {integer(), [binary()]}.
wait_for_response(ConnectionRef, ChannelId, Acc) -> 
    receive
        {ssh_cm, ConnectionRef, Msg} ->
            case Msg of
                {closed, _ChannelId} -> Acc;
                {data, ChannelId, _DataCode, Data}->
                    NewAcc = setelement(2, Acc, element(2, Acc) ++ [Data]),
                    wait_for_response(ConnectionRef, ChannelId, NewAcc);
                {exit_status, _ChannelId, ExitStatus}->
                    NewAcc = setelement(1, Acc, ExitStatus),
                    wait_for_response(ConnectionRef, ChannelId, NewAcc);
                _ -> 
                    wait_for_response(ConnectionRef, ChannelId, Acc)
            end
    end.
