-module(thmb_controller).

-behaviour(gen_server).

-record(state, { udp_socket, jobs }).

-export([start_link/0, stop/0]).

%% gen_server callbacks
-export([
    init/1, handle_call/3, handle_cast/2, handle_info/2,
    terminate/2, code_change/3]).


start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).


stop() ->
    gen_server:cast(?MODULE, stop).


init([]) ->
    {ok, Socket} = gen_udp:open(8789, [binary, {active,true}]),

    { ok, #state{udp_socket = Socket, jobs = []} }.


handle_call(Msg, _From, S) ->
    error_logger:info_msg("Handle Call: ~p~n", [Msg]),
    { reply, ok, S }.


handle_cast(stop, S) ->
    { stop, normal, S }.


handle_info({ssl_closed, _Port}, S) ->
    {ok, Socket} = gen_udp:open(8789, [binary, {active,true}]),
    { noreply, S#state{ udp_socket = Socket } };


handle_info({udp, _, _From, _Port, <<UriLen:16/big,Uri:UriLen/binary,UuidLen:16/big,Uuid:UuidLen/binary>>}, S) ->
    error_logger:info_msg("Uri: ~p~nUUID: ~p~n", [Uri, Uuid]),
    thmb_nailer:fetch_url(binary:bin_to_list(Uri), binary:bin_to_list(Uuid)),
    { noreply, S }.


terminate(_Reason, S) ->
  gen_udp:close(S#state.udp_socket),
  whatever.


code_change(_OldVsn, S, _Extra) ->
  { ok, S }.
