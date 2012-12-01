-module(thumb_nailer).

-compile([export_all]).

-define(PHANTOM_CMD,  "/usr/local/bin/phantomjs rasterize.js ").
-define(PHANTOM_PATH, "/Users/hukl/Projekte/thumbnailer/assets/").
-define(CONVERT_CMD,  "/usr/local/bin/convert ").

-define(FETCH_CMD(URL, FileName), os:cmd(
    ?PHANTOM_CMD ++ URL ++ " " ++ ?PHANTOM_PATH ++ FileName ++ ".jpg"
)).

-define(CONVERT_CMD(Filename, Size), os:cmd(
    ?CONVERT_CMD ++
    ?PHANTOM_PATH ++
    Filename ++ ".jpg -resize " ++ Size ++ " " ++
    ?PHANTOM_PATH ++
    Filename ++ "_" ++ Size ++ ".jpg"
)).


fetch_url(Url) ->
    FileName = erlang:integer_to_list(random:uniform(100000)),

    Operations = [
        fun() -> ?FETCH_CMD(Url, FileName) end,
        fun() -> ?CONVERT_CMD(FileName, "500x500") end,
        fun() -> ?CONVERT_CMD(FileName, "300x300") end,
        fun() -> ?CONVERT_CMD(FileName, "200x200") end,
        fun() -> ?CONVERT_CMD(FileName, "100x100") end
    ],

    process_url(Operations).


process_url([]) ->
    ok;


process_url([Fun|Rest]) ->
    try
        Fun()
    catch
        Error:Message ->
            error_logger:info_msg("~p: ~p", [Error, Message])
    end,

    process_url(Rest).