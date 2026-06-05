-module(sip_client).

-export([call/1]).

-include_lib("nkserver/include/nkserver_module.hrl").

call(TargetUri) ->
    io:format("sip_client: calling back to client ~p~n", [TargetUri]),
    {_, Real_uri} = TargetUri,
    nksip_uac:invite(sip_client, [Real_uri], [auto_2xx_ack]),
    ok.
