%% @author Slava Yurin <v.yurin@office.ngs.ru>
%% @doc Plugin for rebar and dialyzer
-module(dierl).

-export([dialyze/2, 'plt-build'/2, 'plt-check'/2]).

-include("rebar.hrl").

-type warning() :: {atom(), {string(), integer()}, any()}.

%% ===================================================================
%% Public API
%% ===================================================================

%% @doc Perform static analysis on the contents of the ebin directory.
-spec dialyze(rebar_config:config(), file:filename()) -> ok.
dialyze(Config, File) ->
	IsAppDir = File /= undefined andalso rebar_app_utils:is_app_src(File),
	dialyze(Config, File, IsAppDir).

%% @doc Perform static analysis on the contents of the ebin directory.
dialyze(Config, File, true) ->
    DialyzerOpts = rebar_config:get(Config, dialyzer_opts, []),
	PltList = get_plt_list(File, DialyzerOpts),

	% Check that all plt exist
	case lists:dropwhile(fun check_plt/1, PltList) of
		[] ->
            RawDialyzerOpts = case proplists:get_bool(src, DialyzerOpts) of
				true when length(PltList) == 1 ->
					[Plt] = PltList,
					[{files_rec, ["src"]}, {init_plt, Plt}, {from, src_code}];
				true ->
					[{files_rec, ["src"]}, {plts, PltList}, {from, src_code}];
				false when length(PltList) == 1 ->
					[Plt] = PltList,
					[{files_rec, ["ebin"]}, {init_plt, Plt}];
				false ->
					[{files_rec, ["ebin"]}, {plts, PltList}]
			end,
			RunOptions = case proplists:get_value(warnings, DialyzerOpts, []) of
				[] ->
					RawDialyzerOpts;
				Warnings ->
					[{warnings, Warnings} | RawDialyzerOpts]
			end,
			?INFO("Dialyzer options: ~p~n", [RunOptions]),
            try dialyzer:run(RunOptions) of
                [] ->
                    ok;
                DialyzerWarnings ->
					?INFO("Warn: ~p~n", [DialyzerWarnings]),
                    print_warnings(DialyzerWarnings)
            catch
                throw:{dialyzer_error, Reason} ->
                    ?ABORT("~s~n", [Reason])
            end;
		[ErrorPlt | _] ->
			% check_plt must exit with error
			ok
	end,
	ok;
dialyze(_, _, false) ->
	?INFO("DIalyzer skip not app dir~n", []),
	ok.

%% @doc Build the PLT.
-spec 'plt-build'(rebar_config:config(), file:filename()) -> ok.
'plt-build'(Config, File) ->
	IsAppDir = File /= undefined andalso rebar_app_utils:is_app_src(File),
	'plt-build'(Config, File, IsAppDir).

'plt-build'(Config, File, true) ->
	% Add local ebin dir
	true = code:add_path(filename:join(rebar_utils:get_cwd(), "ebin")),

    DialyzerOpts = rebar_config:get(Config, dialyzer_opts, []),
	Warnings = case get_plt_list(File, DialyzerOpts) of
		[Plt] ->
			?INFO("Build plt: ~s~n", [Plt]),
			Apps = rebar_app_utils:app_applications(File),
			dialyzer:run([
				{analysis_type, plt_build}
				, {files_rec, app_dirs(Apps)}
				, {output_plt, Plt}
				]);
		PltList ->
			Apps = rebar_app_utils:app_applications(File),
			AppName = rebar_app_utils:app_name(File),
			Plt = get_plt(AppName),
			build_simple_plt([AppName | Apps])
	end,
    case Warnings of
        [] ->
            ?INFO("The built PLT can be found in ~s~n", [Plt]);
        _ ->
            print_warnings(Warnings)
    end,
    ok;
'plt-build'(Config, File, false) ->
	?INFO("DIalyzer skip not app dir~n", []),
	ok.

%% @doc Check whether the PLT is up-to-date.
-spec 'plt-check'(rebar_config:config(), file:filename()) -> ok.
'plt-check'(Config, File) ->
	IsAppDir = File /= undefined andalso rebar_app_utils:is_app_src(File),
	'plt-check'(Config, File, IsAppDir).

'plt-check'(Config, File, true) ->
    DialyzerOpts = rebar_config:get(Config, dialyzer_opts, []),
	PltForCheck = case get_plt_list(File, DialyzerOpts) of
		[Plt] ->
			Plt;
		_ ->
			AppName = rebar_app_utils:app_name(File),
			get_plt(AppName)
	end,
    try dialyzer:run([{analysis_type, plt_check}, {init_plt, PltForCheck}]) of
        [] ->
            ?CONSOLE("The PLT ~s is up-to-date~n", [PltForCheck]);
        _ ->
            %% @todo Determine whether this is the correct summary.
            ?ABORT("The PLT ~s is not up-to-date~n", [PltForCheck])
    catch
        throw:{dialyzer_error, _Reason} ->
            ?ABORT("The PLT ~s is not valid.~n", [PltForCheck])
	end,
    ok;
'plt-check'(Config, File, false) ->
	?INFO("DIalyzer skip not app dir~n", []),
	ok.

%% ===================================================================
%% Internal functions
%% ===================================================================
%% @doc Get plt files
get_plt_list(File, DialyzerOpts) ->
    case proplists:get_value(plt, DialyzerOpts) of
        undefined ->
			Apps = rebar_app_utils:app_applications(File),
			[get_plt(AppName) || AppName <- Apps];
        "~/" ++ Plt ->
			[filename:join(os:getenv("HOME"), Plt)];
        Plt ->
			[Plt]
    end.

%% @doc Get plt file
get_plt(AppName) ->
	case os:getenv("REBAR_PLT_DIR") of
		false ->
			filename:join(os:getenv("HOME"), "." ++ atom_to_list(AppName) ++ ".plt");
		PltDir ->
			filename:join(PltDir, atom_to_list(AppName) ++ ".plt")
	end.

%% @doc Check PLT
check_plt(Plt) ->
	case dialyzer:plt_info(Plt) of
		{ok, _} ->
			true;
		{error, no_such_file} ->
			?ABORT("The PLT ~s does not exist.~n"
				"Please perform \"rebar plt-build\" to produce PLT.~n"
				"Be aware that this operation may take several minutes.~n",
				[Plt]);
		{error, read_error} ->
			?ABORT("Unable to read PLT ~n", [Plt]);
		{error, not_valid} ->
			?ABORT("The PLT ~s is not valid.~n", [Plt])
	end.

%% @doc Build simple plt
build_simple_plt([]) ->
	[];
build_simple_plt([AppName | AppNameTail]) ->
	Plt = get_plt(AppName),
	case dialyzer:plt_info(Plt) of
		{ok, _} ->
			ok;
		_ ->
			?INFO("Build plt: ~s~n", [Plt]),
			?INFO("Using dir: ~s~n", app_dirs([AppName])),
			dialyzer:run([
				{analysis_type, plt_build}
				, {files_rec, app_dirs([AppName])}
				, {output_plt, Plt}
				])
	end,
	build_simple_plt(AppNameTail).

%% @doc Obtain the library paths for the supplied applications.
-spec app_dirs(Apps::[atom()]) -> [file:filename()].
app_dirs(Apps) ->
    [filename:join(Path, "ebin")
     || Path <- [code:lib_dir(App) || App <- Apps], erlang:is_list(Path)].

%% @doc Render the warnings on the console.
-spec print_warnings(Warnings::[warning(), ...]) -> no_return().
print_warnings(Warnings) ->
    lists:foreach(fun(Warning) ->
                          ?CONSOLE("~s", [dialyzer:format_warning(Warning)])
                  end, Warnings),
    ?FAIL.
