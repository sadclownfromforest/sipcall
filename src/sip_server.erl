-module(sip_server).

-export([ sip_route/5, sip_register/2, sip_invite/2]).

-include_lib("nkserver/include/nkserver_module.hrl").

sip_route(_Scheme, <<>>, <<"localhost">>, _Req, _Call) ->
    io:format("sip_server: sip_route(User = <<>>)~n"),
    process;

sip_route(_Scheme, User, _Domain, Req, _Call) ->
    io:format("sip_server: sip_route(User = ~p)~n", [User]),
    case nksip_request:is_local_ruri(Req) of
        true ->
            process;
        false ->
            proxy
    end.

%% скорее всего нужно использовать свойства регистратора, а не свои ets таблицы 
%% но регистрация, кажется, совершается в момент прослушивания twinkle порта на котором запущен sip сервер 
sip_register(Req, _Call) ->
    {ok, [{from_scheme, FromScheme}, {from_user, FromUser}, {from_domain, FromDomain}]} =
        nksip_request:get_metas([from_scheme, from_user, from_domain], Req),
    {ok, [{to_scheme, ToScheme}, {to_user, ToUser}, {to_domain, ToDomain}]} =
        nksip_request:get_metas([to_scheme, to_user, to_domain], Req),

    io:format("sip_server: sip_register(From ~p)~n", [FromUser]),
    case {FromScheme, FromUser, FromDomain} of
        {ToScheme, ToUser, ToDomain} ->
            io:format("REGISTER OK: ~p~n", [{ToUser, ToDomain}]),
            {reply, nksip_registrar:request(Req)};
        _ ->
            {reply, forbidden}
    end.

sip_invite(Req, _Call) ->
    {ok, [{from_user, FromUser}, {user, User}]} =
        nksip_request:get_metas([from_user, user], Req),

    io:format("sip_server: sip_invite(From ~p, User ~p)~n", [FromUser, User]),
            {ok, Body} = nksip_request:body(Req),
            case nksip_sdp:is_sdp(Body) of
                true ->
                    Contact = nksip_sipmsg:get_meta(contacts, Req),
                    io:format("phone saved ~p~n", [Contact]),
                    One_contact = hd(Contact),
                    ets:insert(clients_uri, {FromUser, One_contact}),
                    io:format("ets: ~p~n", [ets:tab2list(clients_uri)]),
                    {reply, {487, []}};
                false ->
                    io:format("phone not saved"),
                    {reply, forbidden}
    end.