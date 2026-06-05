-module(call_handler).
-behaviour(cowboy_handler).

-export([init/2]).

init(Req0, State) ->
    Method = cowboy_req:method(Req0),
    Id = cowboy_req:binding(id, Req0),
    handle_request(Method, Id, Req0, State).

handle_request(<<"GET">>, Id, Req0, State) ->
    io:format("Get ~p ~n", [Id]),
    case ets:lookup(clients_uri, Id) of
        [Uri] ->
            io:format("URI ~p~n", [Uri]),
            sip_client:call(Uri),
            Req = cowboy_req:reply(200,
                #{<<"content-type">> => <<"application/json">>},
                jsx:encode(#{<<"Ok">> => <<"User founded">>}),
                Req0
            );
        [] ->
            Req = cowboy_req:reply(404,
                #{<<"content-type">> => <<"application/json">>},
                jsx:encode(#{<<"error">> => <<"User not found">>}),
                Req0
            )
    end,
    {ok, Req, State}.


