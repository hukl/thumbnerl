-module(thmb_nailer).

-compile([export_all]).

-define(PHANTOM_CMD, "/usr/local/bin/phantomjs rasterize.js ").
-define(ASSET_PATH,  "/Users/hukl/Projekte/thumbnailer/assets").
-define(CONVERT_CMD, "/usr/local/bin/convert ").

-define(FETCH_CMD(URL, Path), os:cmd(
    ?PHANTOM_CMD ++ URL ++ " " ++ Path ++ ".jpg"
)).

-define(CONVERT_CMD(Path, Size), os:cmd(
    ?CONVERT_CMD ++
    Path ++ ".jpg -resize " ++ Size ++ " " ++
    Path ++ "_" ++ string:substr(Size, 1, 3) ++ ".jpg"
)).


fetch_url(Url, Uuid) ->
    ImageDirPath = string:join([
        ?ASSET_PATH,
        string:substr(Uuid, 1, 3),
        string:substr(Uuid, 4, 3)],
        "/"
    ),

    ImagePath = string:join([ImageDirPath, Uuid], "/"),

    filelib:ensure_dir(ImageDirPath),

    Operations = [
        fun() -> ?FETCH_CMD(Url, ImagePath) end,
        fun() -> ?CONVERT_CMD(ImagePath, "500x500") end,
        fun() -> ?CONVERT_CMD(ImagePath, "300x300") end,
        fun() -> ?CONVERT_CMD(ImagePath, "200x200") end,
        fun() -> ?CONVERT_CMD(ImagePath, "100x100") end
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