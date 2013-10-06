-module(web_sup).
-behaviour(supervisor).
-export([start_link/0, init/1]).
-compile(export_all).
-include_lib ("n2o/include/wf.hrl").
-include("users.hrl").
-define(APP, n2o_sample).

start_link() -> supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->

    {ok, _} = cowboy:start_http(http, 100, [{port, 8000}],
                                           [{env, [{dispatch, dispatch_rules()}]}]),

    users:init(),

    {ok, {{one_for_one, 5, 10}, []}}.

dispatch_rules() ->
    cowboy_router:compile(
        [{'_', [
            {"/static/[...]", cowboy_static, [{directory, {priv_dir, ?APP, [<<"static">>]}},
                                                {mimetypes, {fun mimetypes:path_to_mimes/2, default}}]},
            {"/rest/:resource", n2o_cowboy_rest, []},
            {"/rest/:resource/:id", n2o_cowboy_rest, []},
            {"/ws/[...]", bullet_handler, [{handler, n2o_bullet}]},
            {'_', n2o_cowboy, []}
    ]}]).
