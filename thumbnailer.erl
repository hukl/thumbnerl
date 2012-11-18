-module(thumbnailer).

-compile([export_all]).

-define(PHANTOM_CMD,  "/usr/local/bin/phantomjs rasterize.js ").
-define(PHANTOM_PATH, "/Users/hukl/Projekte/thumbnailer/assets/").
-define(CONVERT_CMD,  "/usr/local/bin/convert ").

-define(FETCH_CMD(URL, FileName), os:cmd(
    "/usr/local/bin/phantomjs rasterize.js " ++
    URL ++
    " /Users/hukl/Projekte/thumbnailer/assets/" ++
    FileName ++
    ".jpg"
)).


%x(#{IMAGE_MAGICK} #{(path + '.jpg')} -resize 500x500 #{path}_500.jpg)
%x(#{IMAGE_MAGICK} #{(path + '.jpg')} -resize 300x300 #{path}_300.jpg)
%x(#{IMAGE_MAGICK} #{(path + '.jpg')} -resize 200x200 #{path}_200.jpg)


fetch_url(Url) ->
    FileName = erlang:integer_to_list(random:uniform(100000)),

    Operations = [
        fun() ->
            ?FETCH_CMD(Url, FileName)
        end,
        fun() ->
            os:cmd(
                ?CONVERT_CMD ++ ?PHANTOM_PATH ++ FileName ++ ".jpg -resize 500x500 "
                ++ ?PHANTOM_PATH ++ FileName ++ "_500.jpg"
            )
        end
    ],

    process_url(Operations).


process_url([]) ->
    ok;


process_url([Fun|Rest]) ->
    try
        Result = Fun(),
        error_logger:info_msg("~p~n", [Result])
    catch
        Error:Message ->
            error_logger:info_msg("~p: ~p", [Error, Message])
    end,

    process_url(Rest).