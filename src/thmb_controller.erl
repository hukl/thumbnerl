-module(thmb_controller).

-behaviour(gen_server).

-record(state, { udp_socket, address, port, jobs }).

-export([start_link/0, stop/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

start_link() ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

stop() ->
  gen_server:cast(?MODULE, stop).

init([]) ->
  {ok, Socket} = gen_udp:open(8789, [binary, {active,true}]),

  { ok, #state{
    udp_socket  = Socket,
    address     = {127,0,0,1},
    port        = 8789,
    options     = [
      {mode, binary}
    ],
    timeout     = 10000
   } }.

handle_call(_, _From, S) ->
  { reply, ok, S#state{ udp_socket = Socket } }.

handle_cast(stop, S) ->
  { stop, normal, S }.

handle_info({ssl_closed, _Port}, S) ->
  { noreply, S#state{ ssl_socket = undefined } };

handle_info({udp, _, _From, _Port, Msg = <<UriLength:16/big,Uri:UriLength/binary,UuidLength:16/big,Uuid:UuidLength/binary>>}, S) ->
  { noreply, S }.

terminate(_Reason, S) ->
  ssl:close(S#state.ssl_socket),
  whatever.

code_change(_OldVsn, S, _Extra) ->
  { ok, S }.
