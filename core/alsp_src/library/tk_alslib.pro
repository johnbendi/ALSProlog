/*=============================================================*
 |		tk_alslib.pro
 |	Copyright (c) 1986-1996 Applied Logic Systems, Inc.
 |		Distribution rights per Copying ALS
 |
 |	Tcl/Tk-based GUI library routines
 |
 |	Author: Ken Bowen
 |	Creation Date: 1997
 *=============================================================*/


module tk_alslib.
use tcltk.

export init_tk_alslib/0.
export init_tk_alslib/1.
export init_tk_alslib/2.

export popup_select_items/2.
export popup_select_items/3.
export popup_select_items/4.

export extend_main_menubar/2.
export extend_main_menubar/3.
export extend_main_menubar/4.
export extend_menubar_cascade/2.
export extend_menubar_cascade/4.

/*------------------------------------------------------------*
 *------------------------------------------------------------*/
export list_tcl_eval/3.

list_tcl_eval([], Interp, _).
list_tcl_eval([L | CL], Interp, _)
	:-
	tcl_eval(Interp, L, R),
	list_tcl_eval(CL, Interp, _).

/*------------------------------------------------------------*
 *------------------------------------------------------------*/

init_tk_alslib
	:-
	init_tk_alslib(tcli,_).

init_tk_alslib(Shared)
	:-
	init_tk_alslib(tcli, Shared).

:-dynamic(tcl_interp_created/1).

init_tk_alslib(Interp,Shared)
	:-
	(all_procedures(tcltk,read_eval_results,2,_) ->
		true
		;
		consult(tcltk)
	),
	catch(tk_new(Interp),_,true),
	tcl_call(Interp, [wm,withdraw,'.'], _),
	builtins:sys_searchdir(ALSDIR),
	extendPath(ALSDIR, shared, Shared),
	tcl_call(Interp, [set,'ALSTCLPATH',Shared], _),
	sys_env(OS, _, _),
	(OS = macos ->
		tcl_call(Interp, 'source -rsrc als_tklib', _)
		;
		( pathPlusFile(Shared, 'als_tklib.tcl', ALSTKLIB),
		  tcl_call(Interp, [source, ALSTKLIB], _)
		)
	),
	(tcl_interp_created(Interp) ->
		true
		;
		(Interp \= shl_tcli -> 
			assert(tcl_interp_created(Interp))
			;
			true
		)
	).

export destroy_all_tcl_interpreters/0.
destroy_all_tcl_interpreters
	:-
	findall(Interp, (tcl_interp_created(Interp),
						Interp \= shl_tcli),		Interps),
	destroy_all_tcl_interpreters(Interps),
	abolish(tcl_interp_created,1),
	dynamic(tcl_interp_created/1).

destroy_all_tcl_interpreters([]).
destroy_all_tcl_interpreters([I | Interps])
	:-
	tcl_delete(I),
	unrecord_packages(I),
	destroy_all_tcl_interpreters(Interps).

:- dynamic(packages_loaded/2).
unrecord_packages(I)
	:-
	retract(packages_loaded(I,_)),
	fail.
unrecord_packages(_).

/*------------------------------------------------------------*
 |	fixup_for_tkwin_path/2
 |	fixup_for_tkwin_path(Atom, TclLabel)
 |	fixup_for_tkwin_path(+, -)
 |
 |	Adjusts incoming Atom to be possibly appropriate as the 
 |	name of a Tk window path by: 
 |	i) converting all uppercase chars to lower case;
 |	ii) converting blanks to "-" .
 *------------------------------------------------------------*/
export fixup_for_tkwin_path/2.
fixup_for_tkwin_path(Atom, TclLabel)
	:-
	atom_codes(Atom, LabelCs),
	fixup_for_tkwin_path0(LabelCs, TclLabelCs),
	atom_codes(TclLabel, TclLabelCs).

fixup_for_tkwin_path0([], []).
fixup_for_tkwin_path0([C | LabelCs], [NewC | TclLabelCs])
	:-
	((0'A =< C, C =< 0'Z) ->
		NewC is C + 32
		;
		(C = 0'   -> 
			NewC = 0'_
			;
			NewC = C
		)
	),
	fixup_for_tkwin_path0(LabelCs, TclLabelCs).

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%% 		POPUP SELECTION LISTS 			%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

/*------------------------------------------------------------*
 |	popup_select_items/2.
 |	popup_select_items(SourceList, ChoiceList)
 |	popup_select_items(+, -)
 |
 |	Calls popup_select_items(SourceList, Options, ChoiceList),
 |		filling in default Options
 *------------------------------------------------------------*/
popup_select_items(SourceList, ChoiceList)
	:-
	popup_select_items(tcli, SourceList, [], ChoiceList).

popup_select_items(SourceList, Options, ChoiceList)
	:-
	popup_select_items(tcli, SourceList, Options, ChoiceList).

/*------------------------------------------------------------*
 |	popup_select_items/3
 |	popup_select_items(SourceList, Options, ChoiceList)
 |	popup_select_items(+, +, -)
 |
 |	SourceList	= Prolog list of atoms;
 |	Options		= list option equations (see below); 
 |	ChoiceList	= list of items selected by user
 |
 |	Option equations:   Option = Value
 |	Options:
 |	  -	interp	- the Tcl/Tk interpreter to run under;
 |	  -	mode	- the listbox mode to utilize:
 |		* select at most 1 element; clicking a different element 
 |		  changes the selection:
 |			browse	- can drag thru selections with button 1 down;
 |			single	- no drag;
 |		* select multiple elements (including discontiguous groups):
 |			multiple - clicking button 1 on  an  element toggles its 
 |				selection state without affecting any other elements;
 |			extended - pressing button 1  on  an  element selects  it,  
 |				deselects everything else, and sets the anchor to the 
 |				element under the mouse;   dragging  the  mouse  with
 |				button  1 down extends the selection to include all the 
 |				elements between the anchor and the element  under  the  
 |				mouse, inclusive.
 |	  -	choice_widget_name - base widget name for the choice box.
 |	  -	title - the window title bar entry
 *------------------------------------------------------------*/
popup_select_items(Interp, SourceList, Options, ChoiceList)
	:-
	(dmember(choice_widget_name=BaseName, Options) -> true;
		BaseName = '.popup_select_widget'), 
	(dmember(mode=Mode, Options) -> true;
		Mode = browse),
	(dmember(title=Title, Options) -> true ;
		Title = 'List Selection'),
	mk_tcl_atom_list(SourceList, TclSourceList),
	tcl_call(Interp, [do_select_items,BaseName,Mode,Title,TclSourceList],ChoiceList).

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%% 				DIALOGS 				%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	/*----------------------------------------------------*
	 |	Note: available bitmaps for use in dialogs are:
	 |
	 |	question	?
	 |	questhead	? inside a sunken human head
	 |	warning		!
	 |	info		sunken i
	 |	hourglass	sunken hourglass
	 |	error		sunken european "forbidden" roadsign
	 *----------------------------------------------------*/

/*------------------------------------------------------------*
 |	info_dialog/1
 |	info_dialog(Msg)
 |	info_dialog(+)
 |
 |	info_dialog/2
 |	info_dialog(Msg, Title)
 |	info_dialog(+, +)
 |
 |	info_dialog/3
 |	info_dialog(Interp, Msg, Title)
 |	info_dialog(+, +, +)
 |
 |	Pops up a informational dialog (just an OK button)
 |	displaying the input message (Msg). Title is the dialog
 |	window title; it defaults to "Info"
 *------------------------------------------------------------*/

export info_dialog/1.
export info_dialog/2.
export info_dialog/3.

info_dialog(Msg)
	:-
	info_dialog(Msg, 'Info').

info_dialog(Msg, Title)
	:-
	info_dialog(tcli, Msg, Title).

info_dialog(Interp, Msg, Title)
	:-
	tcl_call(Interp, [tk_dialog, '.quit_dialog', Title, Msg, '', 0, 'OK'], _).

/*------------------------------------------------------------*
 |	yes_no_dialog/2
 |	yes_no_dialog(Msg, Answer)
 |	yes_no_dialog(+, -)
 |
 |	yes_no_dialog/3
 |	yes_no_dialog(Msg, Title, Answer)
 |	yes_no_dialog(+, +, -)
 |
 |	yes_no_dialog/4
 |	yes_no_dialog(Interp, Msg, Title, Answer)
 |	yes_no_dialog(+, +, +, -)
 |
 |	Pops up a yes-no dialog (with Yes/No buttons)
 |	displaying the input message (Msg). Title is the dialog
 |	window title; it defaults to "Info" The extended forms
 |	allow customization of the buttons:
 |
 |	yes_no_dialog/6
 |	yes_no_dialog(Interp, Msg, Title, YesLabel, NoLabel, Answer)
 |	yes_no_dialog(+, +, +, +, +, -)
 |
 |	Yes = label for the left (Yes; default) button
 |	No =  label for the right (No) button
 |
 |	Answer is either YesName or NoName
 *------------------------------------------------------------*/

export yes_no_dialog/2.
export yes_no_dialog/3.
export yes_no_dialog/4.
export yes_no_dialog/6.

yes_no_dialog(Msg, Answer)
	:-
	yes_no_dialog(Msg, 'Info', Answer).

yes_no_dialog(Msg, Title, Answer)
	:-
	yes_no_dialog(tcli, Msg, Title, Answer).

yes_no_dialog(Interp, Msg, Title, Answer)
	:-
	yes_no_dialog(Interp, Msg, Title, 'Yes', 'No', Answer).

yes_no_dialog(Interp, Msg, Title, YesLabel, NoLabel, Answer)
	:-
	tcl_call(Interp, [tk_dialog, '.quit_dialog', Title, Msg, 
						question, 0, YesLabel, NoLabel], InitAns),
	(InitAns =  0 -> Answer = YesLabel ; Answer = NoLabel).

/*------------------------------------------------------------*
 |	atom_input_dialog/2
 |	atom_input_dialog(Msg, Atom)
 |	atom_input_dialog(+, -)
 |
 |	atom_input_dialog/3
 |	atom_input_dialog(Msg, Title, Atom)
 |	atom_input_dialog(+, +, -)
 |
 |	atom_input_dialog/4
 |	atom_input_dialog(Interp, Msg, Title, Atom)
 |	atom_input_dialog(+, +, +, -)
 *------------------------------------------------------------*/
export atom_input_dialog/2.
export atom_input_dialog/3.
export atom_input_dialog/4.

atom_input_dialog(Msg, Atom)
	:-
	atom_input_dialog(Msg, 'Input', Atom).

atom_input_dialog(Msg, Title, Atom)
	:-
	atom_input_dialog(tcli, Msg, Title, Atom).

atom_input_dialog(Interp, Msg, Title, Atom)
	:-
	tcl_call(Interp, [do_popup_input, Msg, Title], InitResult),
	(atom(InitResult) ->
		Atom = InitResult
		;
		atomread(InitResult, Atom)
	).

/*------------------------------------------------------------*
 |	file_select_dialog/2
 |	file_select_dialog(Prompt, FileName)
 |	file_select_dialog(+, -)
 |
 |	file_select_dialog/4
 |	file_select_dialog(Interp, Prompt, Options, FileName)
 |	file_select_dialog(+, +, +, -)
 |
 |	Options:
 |		default = <Default file name>
 |		ext		= Ext to either add, or use for selection
 |		mode	= new/select/save_as (default = select)
 |		initialdir = 	initial dir in which to begin...
 *------------------------------------------------------------*/

export file_select_dialog/1.
export file_select_dialog/2.
export file_select_dialog/3.

file_select_dialog(FileName)
	:-
	file_select_dialog(tcli, [title='Select File'], FileName).

file_select_dialog(Options, FileName)
	:-
	file_select_dialog(tcli, Options, FileName).

file_select_dialog(Interp, Options, FileName)
	:-
	fselect_modes(Options, DefaultName, Ext, Mode, Title, IDir, FileTypes),

		%% Need to extend this to file types broadly, including the
		%% Mac special stuff;
	
	cont_file_select(Mode, DefaultName, Ext, IDir, Title, FileName, FileTypes, Interp).

fselect_modes(Options, DefaultName, Ext, Mode, Title, IDir, FileTypes)
	:-
	(dmember(initialdir=IDir, Options) -> true ; IDir = ''),
	(dmember(ext=Ext, Options) -> true ; Ext = ''),
	(dmember(title=Title, Options) -> true ; Title = 'Select File to Open'),
	(dmember(mode=Mode, Options) -> true ; Mode = select),
	(dmember(defaultname=DefaultName, Options) -> true ; DefaultName = default),
	fselect_ftypes(Options, FileTypes).
		
fselect_ftypes(Options, FileTypes)
	:-
	dmember(filetypes=FileTypes, Options),
	!.
fselect_ftypes(Options, FileTypes)
	:-
	FileTypes = [['All Files',['*']]].

cont_file_select(select, DefaultName, Ext, IDir, Title, FileName, FileTypes, Interp)
	:-!,
	tcl_call(Interp, 
			[tk_getOpenFile, '-title', Title,
				'-initialdir', IDir, '-filetypes', FileTypes], 
				FileName).
cont_file_select(save_as, DefaultName, Ext, IDir, Title, FileName, FileTypes, Interp)
	:-!,
	tcl_call(Interp, 
			[tk_getSaveFile, '-title', Title,
				'-defaultextension', Ext, '-initialfile', DefaultName,
				'-initialdir', IDir, '-filetypes', FileTypes], 
				FileName).


/*------------------------------------------------------------*
 |	create_image/2
 |	create_image(ImagePath, ImageName)
 |	create_image(+, +)
 |	create_image/3
 |	create_image(Interp, ImagePath, ImageName)
 |	create_image(+, +, +)
 |	
 |	display_image/1
 |	display_image(ImageName)
 |	display_image(+)
 |	display_image/3
 |	display_image(Interp, ImageName, Options)
 |	display_image(+, +, +)
 *------------------------------------------------------------*/

export create_image/2.
export create_image/3.

create_image(ImagePath, ImageName)
	:-
	create_image(tcli, ImagePath, ImageName).

create_image(Interp, ImagePath, ImageName)
	:-
	(var(ImageName) ->
		pathPlusFile(_, ImageFile, ImagePath),
		(filePlusExt(ImageBase, ImgExt, ImageFile) ->
			true
			;
			ImgExt = img,
			ImageBase = ImageFile
		),
		catenate([ImageBase,'_',ImgExt], ImageName)
		;
		true
	),
	tcl_call(Interp, [image,create,photo,ImageName,'-file',ImagePath], _).

export display_image/1.
export display_image/3.

display_image(ImageName)
	:-
	display_image(tcli, ImageName, []).

display_image(Interp, ImageName, Options)
	:-
	(dmember(win_name=WinName, Options) ->
		true
		;
		catenate('.w_',ImageName,WinName)
	),
	(dmember(width=Width, Options) -> true ; Width = 200),
	(dmember(height=Height, Options) -> true ; Height = 200),
	(dmember(x=X, Options) -> true ; X = 75),
	(dmember(y=Y, Options) -> true ; Y = 75),
	(dmember(border_width=BorderWidth, Options) -> true ; BorderWidth = 2),
	tcl_call(Interp, [display_image,ImageName,WinName,
						Width,Height,X,Y,BorderWidth], _).

export create_display_image/1.
export create_display_image/2.
export create_display_image/3.

create_display_image(ImagePath)
	:-
	create_image(ImagePath, ImageName),
	display_image(tcli, ImageName, []).

create_display_image(ImagePath, Options)
	:-
	create_image(ImagePath, ImageName),
	display_image(tcli, ImageName, Options).

create_display_image(Interp, ImagePath, Options)
	:-
	create_image(ImagePath, ImageName),
	display_image(Interp, ImageName, Options).

/****
export display_image/3.
export display_image/5.

display_image(ImageFile, ImageWidth, ImageHeight)
	:-
	display_image(tcli, '.', ImageFile, ImageWidth, ImageHeight).

display_image(Interp, ImageDir, ImageFile, ImageWidth, ImageHeight)
	:-
	(filePlusExt(ImageBase, ImgExt, ImageFile) ->
		true
		;
		ImgExt = img,
		ImageBase = ImageFile
	),
	tcl_call(Interp, 
		[display_file_image,ImageDir,ImageFile,ImageBase,'.foobar',
		 ImageWidth, ImageHeight, 2], _).
****/


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%	  ADDING ITEMS TO THE MENU BAR		%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

/*------------------------------------------------------------*
 |	extend_main_menubar/2
 |	extend_main_menubar(Label, MenuEntriesList)
 |	extend_main_menubar(+, +)
 |
 |	extend_menubar/3
 |	extend_menubar(MenubarPath, Label, MenuEntriesList)
 |	extend_menubar(+, +, +)
 |	
 |	extend_menubar/4
 |	extend_menubar(MenubarPath, Label, MenuEntriesList, Interp)
 |	extend_menubar(+, +, +, +)
 *------------------------------------------------------------*/
extend_main_menubar(Label, MenuEntriesList)
	:-
	extend_menubar('.topals.mmenb', Label, MenuEntriesList).

extend_menubar(MenubarPath, Label, MenuEntriesList)
	:-
	extend_menubar(MenubarPath, Label, MenuEntriesList, shl_tcli).

extend_menubar(MenubarPath, Label, MenuEntriesList, Interp)
	:-
	extend_menubar_cascade(MenubarPath, Label, MenuPath, Interp),
	list_extend_cascade(MenuEntriesList, MenuPath, Interp).

/*
extend_menubar_cascade(Label, MenuPath)
	:-
	extend_menubar_cascade('.topals.mmenb', Label, MenuPath, shl_tcli).
*/

extend_menubar_cascade(MenubarPath, Label, MenuPath, Interp)
	:-
	fixup_for_tkwin_path(Label, TclLabel),
	catenate([MenubarPath, '.', TclLabel], MenuPath),
	(tcl_call(Interp, [winfo,exists,MenuPath],'1') ->
		true
		;
		tcl_call(Interp, [menu,MenuPath,'-relief',raised],_)
	),
	tcl_call(Interp, [MenubarPath,add,cascade,'-label',Label,'-menu',MenuPath], _),
	tcl_call(Interp, [update],_).

list_extend_cascade([], MenuPath, Interp)
	:-
	tcl_call(Interp, [update],_).
list_extend_cascade([MenuEntry | MenuEntriesList], MenuPath, Interp)
	:-
	extend_cascade(MenuEntry, MenuPath, Interp),
	list_extend_cascade(MenuEntriesList, MenuPath, Interp).

export extend_cascade/3.

extend_cascade(cascade(Label,SubList), MenuPath, Interp)
	:-!,
	extend_menubar_cascade(MenuPath, Label, NewMenuPath, Interp),
	list_extend_cascade(SubList, NewMenuPath, Interp).

extend_cascade(Label + tcl(Call), MenuPath, Interp)
	:-!,
	tcl_call(Interp, [MenuPath,add,command,'-label',Label,'-command',Call],_).

extend_cascade(Label + (Mod:Goal), MenuPath, Interp)
	:-!,
	open(atom(Cmd), write, CmdS, []),
	Goal =.. [Functor | Args],
	printf(CmdS, 'prolog call %t %t ', [Mod, Functor]),
	mk_tcl_call_args(Args, CmdS),
	close(CmdS),
	tcl_call(Interp, [MenuPath,add,command,'-label',Label, '-command', Cmd], _).

extend_cascade(Label + Goal, MenuPath, Interp)
	:-!,
	open(atom(Cmd), write, CmdS, []),
	Goal =.. [Functor | Args],
	printf(CmdS, 'prolog call user %t ', [Functor]),
	mk_tcl_call_args(Args, CmdS),
	close(CmdS),
	tcl_call(Interp, [MenuPath,add,command,'-label',Label, '-command', Cmd], _).

extend_cascade(separator, MenuPath, Interp)
	:-!,
	tcl_call(Interp, [MenuPath,add,separator], _).

extend_cascade(Label, MenuPath, Interp)
	:-
	tcl_call(Interp, [MenuPath,add,command,'-label',Label], _).

mk_tcl_call_args([], CmdS).
mk_tcl_call_args([Arg | Args], CmdS)
	:-
	insert_tcl_call_arg(Arg, CmdS),
	mk_tcl_call_args(Args, CmdS).

insert_tcl_call_arg(Arg, CmdS)
	:-
	atom(Arg),
	printf(CmdS, '-atom "%t" ',[Arg]).

insert_tcl_call_arg(Arg, CmdS)
	:-
	number(Arg),
	printf(CmdS, '-number %t ',[Arg]).

insert_tcl_call_arg(Arg, CmdS)
	:-
	var(Arg),
	printf(CmdS, '-var %t ',[Arg]).

insert_tcl_call_arg(Arg, CmdS)
	:-
	Arg = [ _ | _ ],
	printf(CmdS, '-list %t ',[Arg]).

/*------------------------------------------------------------*
 *------------------------------------------------------------*/

export menu_entries_list/2.
export menu_entries_list/3.

menu_entries_list(MenuPath, EntriesList)
	:-
	menu_entries_list(tcli, MenuPath, EntriesList).

menu_entries_list(Interp, MenuPath, EntriesList)
	:-
	tcl_call(Interp, [menu_entries_list, MenuPath], EntriesList).

export path_to_main_menu_entry/2.

path_to_main_menu_entry(Index, SubMenuPath)
	:-
	path_to_menu_entry(shl_tcli, '.topals.mmenb', Index, SubMenuPath).

export path_to_menu_entry/3.
export path_to_menu_entry/4.

path_to_menu_entry(MenuPath, Index, SubMenuPath)
	:-
	path_to_menu_entry(tcli, MenuPath, Index, SubMenuPath).

path_to_menu_entry(Interp, MenuPath, Index, SubMenuPath)
	:-
	tcl_call(Interp, [MenuPath,entrycget,Index,'-menu'],SubMenuPath).

/*------------------------------------------------------------*
 *------------------------------------------------------------*/

add_to_main_menu_entry(Index, Entry)
	:-
	path_to_main_menu_entry(Index, MenuPath),
	extend_cascade(Entry, MenuPath, shl_tcli).

endmod.
