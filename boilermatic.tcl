#!/usr/bin/env tclsh

###
# Copyright 2013 Matthew Harvey
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
###

##############################################################################
# Dependencies

package require Tk
package require Ttk


##############################################################################
# Platform specific formatting details are contained in this namespace.

namespace eval platform {

#   INTERFACE

    # No parameters.
    # Returns a list of alternating options/values to be used with Tk
    # (not Ttk) widgets to adjust background colour to account for certain
    # platform-specific peculiarities.
    # Expand returned list with {*} and pass to widget creation command.
    namespace export get_background_options

    # No parameters.
    # Returns a list of alternating options/values to be used with Tk text
    # widget to adjust for certain platform-specific peculiarities.
    # Expend returned list with {*} and pass to text widget creation command.
    namespace export get_text_widget_options

#   IMPLEMENTATION DETAILS

    variable background [list]
    variable text_widget_options [list]
    if {[string equal $tcl_platform(os) Darwin]} {
        # OSX
        variable darwin_background_color "#ececec"
        set background [list -background $darwin_background_color]
        set text_widget_options \
          [list -borderwidth 2 -relief sunken -highlightbackground \
          $darwin_background_color -highlightcolor $darwin_background_color]
        . configure {*}$background  ;# Yes that's a dot - the topmost window.
    }
    proc get_background_options {} {
        variable background
        return $background
    }
    proc get_text_widget_options {} {
        variable text_widget_options
        return $text_widget_options
    }
}

##############################################################################
# Standard widths and padding details are managed in this namespace.

namespace eval sizing {

#   INTERFACE

    # No parameters.
    # Returns an alternating option/value list specifying our standard width
    # for a "narrow" widget.
    # Expand returned list with {*} and pass to widget creation command.
    namespace export get_narrow_option

    # No parameters.
    # Returns an alternating option/value list specifying our standard width
    # for a "wide" widget.
    # Expand returned list with {*} and pass to widget creation command.
    namespace export get_wide_option

    # No parameters
    # Returns a list of alternating options/values specifying our standard
    # padding values for widgets passed to "grid" command.
    # Expand returned list with {*} and pass to grid command.
    namespace export get_padding_options

#   IMPLEMENTATION DETAILS

    variable narrow_width 8
    proc get_narrow_option {} {
        variable narrow_width
        return [list -width $narrow_width]
    }
    proc get_wide_option {} {
        variable narrow_width
        return [list -width [expr {$narrow_width * 3}]]
    }
    proc get_padding_options {} {
        return [list -padx 10 -pady 10]
    }
}

###############################################################################
# Options configured by the user via the contents of the .boilermatic directory
# are managed here in this namespace.

namespace eval configuration {

#   INTERFACE
    
    # Call to get the copyright notice string (which will include appropriate
    # comment-out symbols added).
    namespace export get_copyright_notice

    # Call to return the filepath of the copyright notice configuration
    # file (or empty string if this file not found).
    namespace export get_copyright_notice_filepath

#   IMPLEMENTATION DETAILS

    variable copyright_notice
    variable is_initialized 0

    proc get_config_dir {starting_dir} {
        set dir [file normalize $starting_dir]
        while {1} {
            set tmp [file dirname $dir]
            set conf_path [file join $dir ".boilermatic"]
            if {[file exists $conf_path] && [file isdirectory $conf_path]} {
                return $conf_path
            }
            if {[string equal $tmp $dir]} {
                # We're at root
                return ""
            }
            set dir $tmp
        }
    }
    proc get_copyright_notice_filepath {{starting_dir [pwd]}} {
        set dir [get_config_dir [file normalize $starting_dir]]
        if {[string equal $dir ""]} {
            return ""
        }
        set fp [file join $dir "copyright_notice"]
        if {[file exists $fp] && [file isfile $fp]} {
            return $fp
        }
        return ""
    }
    proc ensure_initialized {} {
        variable is_initialized
        if {!$is_initialized} {
            set copyright_notice_filepath [get_copyright_notice_filepath [pwd]]
            if {[string equal $copyright_notice_filepath ""]} {
                variable copyright_notice ""
            } else {
                variable copyright_notice ""
                set infile [open $copyright_notice_filepath r]
                set lines_read 0
                while {[gets $infile line] >= 0} {
                    incr lines_read
                    if {$lines_read == 1} {
                        append copyright_notice "/*\n" 
                    }
                    append copyright_notice " * ${line}\n"
                }
                if {$lines_read > 0} {
                    append copyright_notice " */\n"
                }
                close $infile
            }
            variable is_initialized 1
        }
    }
    proc get_copyright_notice {} {
        ensure_initialized
        variable copyright_notice
        return $copyright_notice
    }
}


##############################################################################
# Data associated with the various widgets is managed in this namespace.
# These data represent the "underlying data model" the details of which
# are configured by the user via the GUI.

namespace eval widget_contents {

#   INTERFACE
   
    # Call this procedure with no arguments to initialize data prior
    # to setting up the GUI.
    namespace export initialize

    # Call with no arguments to return name of the C++ class for which
    # code will be generated.
    namespace export get_class_name

    # Call with no arguments to return name of the C++ header file
    # to be created.
    namespace export get_header_name
    
    # Call with no arguments.
    # Returns 1 if user would like source (".cpp") file created; otherwise,
    # returns 0.
    namespace export get_whether_source_file_enabled

    # Call with no arguments to return name of C++ source (".cpp") file
    # to be created.
    namespace export get_source_file_name

    # Call with no arguments to return name of C++ preprocessor symbol
    # to be used as header guard for ordinary header.
    namespace export get_header_guard

    # Call with no arguments to return path of directory in which
    # C++ header will be saved.
    namespace export get_header_directory

    # Call with no arguments to return path of directory in which
    # C++ source file will be saved.
    namespace export get_source_file_directory

    # Call with no arguments to return a dict.
    # For each key/value pair in the dict, the "key"
    # is the text of the C++ special function declaration as it will appear in
    # the generated C++ source code, and the
    # "value" is an access specifier ("public", "protected" or "private").
    # The dict will only includes special member functions which for which the
    # user has requested code to be generated.
    namespace export get_special_member_function_details

    # Call with no arguments.
    # Returns a list of names of every special member function that may be
    # configured by the user via the GUI. The "names" for this purpose
    # are user-presentable strings, e.g. "Copy constructor".
    namespace export get_special_member_function_labels

    # Call with no arguments.
    # Returns as a list of strings the "implementation specifiers" from
    # which the user may select for each of the special member
    # functions: e.g. "Custom".
    namespace export get_implementation_specifiers

    # Call with no arguments.
    # Returns a list of access specifiers from the the user may
    # select for each of the special member functions.
    namespace export get_access_specifiers

    # Call with no arguments.
    # Returns 1 if the user has selected for the generated C++
    # destructor to be virtual, otherwise returns 0.
    namespace export get_whether_destructor_virtual

    # Call with no argumets.
    # Returns a list of strings, each of which describes a convention
    # for indenting C++ code, from which the user may select.
    namespace export get_indentation_styles

    # Call with no arguments.
    # Returns 1 if adding copyright notice; otherwise, returs 0
    namespace export get_whether_copyright_notice_enabled

    # Call with no arguments.
    # Returns the actual string which will effect the indentation
    # style currently selected by the user. E.g. "    " (four spaces).
    namespace export get_indentation_string

    # Call with no arguments.
    # Returns selected command for adding files to a version control system
    # (VCS), as a list; returns an empty list if VCS command not
    # selected.
    namespace export get_vcs_command

    # Call with no arguments to return a list of strings each of which
    # is the symbol for a C++ namespace to be generated.
    namespace export get_cpp_namespaces

    # Call with no arguments to set the text of the header guard symbol.
    # This is generated on the basis of the filename stem currently
    # stored in the GUI, together with random digits appended to ensure
    # the C++ header guard symbol will be (almost certainly) unique.
    namespace export configure_header_guard

#   RESTRICTED INTERFACE - TO BE ACCESSED BY ASSOCIATED WIDGETS ONLY

    variable class_name
    variable filename_stem
    variable header_guard
    variable source_file_enabled                     ;# boolean
    variable header_directory
    variable source_file_directory
    variable should_generate_special_member_function  ;# array
    variable access_specifiers                        ;# list
    variable implementation_spec                      ;# array
    variable access_spec                              ;# array
    variable destructor_is_virtual                    ;# boolean
    variable should_generate_copyright_notice          ;# boolean
    variable indentation_style                        ;# string
    variable vcs_command                              ;# list
    variable always_true                              ;# boolean - hack

    proc set_cpp_namespaces {text_widget_contents} {
        set raw_string $text_widget_contents
        set raw_list [split $raw_string \n]
        set tmp [list]
        foreach elem $raw_list {
            set trimmed_elem [string trim $elem]
            if {[string length $trimmed_elem] != 0} {
                lappend tmp $trimmed_elem
            }
        }
        variable cpp_namespace_list $tmp
    }


#   IMPLEMENTATION DETAILS
    
    variable cpp_namespace_list
    variable special_member_functions 
    variable implementation_specifiers
  
    proc initialize {} {
        expr {srand([clock seconds])}  ;# Seed random number generator
        variable class_name ""
        variable filename_stem ""
        variable header_guard ""
        variable source_file_enabled 1
        variable header_directory [pwd]
        variable source_file_directory [pwd]
        if {[file isdirectory [file join [pwd] src]]} {
            set source_file_directory [file join [pwd] src]
        }
        if {[file isdirectory [file join [pwd] include]]} {
            set header_directory [file join [pwd] include]
        }
        variable destructor_is_virtual 1
        variable special_member_functions \
          [  dict create \
                "Default constructor" {CLASS()} \
                "Copy constructor"    {CLASS(CLASS const& rhs)} \
                "Move constructor"    {CLASS(CLASS&& rhs)} \
                "Copy assignment"     {CLASS& operator=(CLASS const& rhs)} \
                "Move assignment"     {CLASS& operator=(CLASS&& rhs)} \
                "Destructor"          {~CLASS()} \
          ]
        variable implementation_specifiers {"default" "delete" "custom"}
        variable access_specifiers {"public" "protected" "private"}
        variable should_generate_special_member_function
        variable access_spec
        variable implementation_spec
        foreach smf [get_special_member_function_labels] {
            set should_generate_special_member_function($smf) 1
            set access_spec($smf) [lindex $access_specifiers 0]
            set implementation_spec($smf) \
              [lindex $implementation_specifiers 0]
        }
        variable cpp_namespace_list [list]
        variable should_generate_copyright_notice \
            [expr {![string equal [configuration::get_copyright_notice] ""]}]
        variable indentation_style "Tab"  ;#TODO Not cool
        variable vcs_command [list]
        variable always_true 1
    }
    proc get_header_extension {} {
        return "hpp"
    }
    proc get_source_file_extension {} {
        return "cpp"
    }
    proc get_class_name {} {
        variable class_name
        return [string trim $class_name]
    }
    proc get_header_name {} {
        variable filename_stem
        return "[string trim ${filename_stem}].[get_header_extension]"
    }
    proc get_whether_source_file_enabled {} {
        variable source_file_enabled
        return $source_file_enabled
    }
    proc get_source_file_name {} {
        variable filename_stem
        return "[string trim ${filename_stem}].[get_source_file_extension]"
    }
    proc get_header_guard {} {
        variable header_guard
        return [string trim $header_guard]
    }
    proc get_header_directory {} {
        variable header_directory
        return $header_directory
    }
    proc get_source_file_directory {} {
        variable source_file_directory
        return $source_file_directory
    }
    proc get_special_member_function_details {} {
        variable should_generate_special_member_function
        variable implementation_spec
        variable access_spec
        variable special_member_functions
        set ret [dict create]
        set cname [widget_contents::get_class_name]
        if {[string length $cname] == 0} {
            return $ret;
        }
        foreach {smf template} $special_member_functions {
            if {$should_generate_special_member_function($smf)} {
                regsub -all CLASS $template $cname declaration_text
                set spec $implementation_spec($smf)
                if {![string equal $spec "custom"]} {
                    append declaration_text " = $spec"
                }
                append declaration_text ";"
                if {[string equal $smf "Destructor"]} {
                    if {[widget_contents::get_whether_destructor_virtual]} {
                        set declaration_text "virtual $declaration_text"
                    }
                }
                dict append ret $declaration_text $access_spec($smf)
            }
            incr r
        }
        return $ret
    }
    proc get_special_member_function_labels {} {
        variable special_member_functions
        return [dict keys $special_member_functions]
    }
    proc get_implementation_specifiers {} {
        variable implementation_specifiers
        return $implementation_specifiers
    }
    proc get_access_specifiers {} {
        variable access_specifiers
        return $access_specifiers
    }
    proc get_whether_destructor_virtual {} {
        variable destructor_is_virtual
        return $destructor_is_virtual
    }
    proc get_indentation_map {} {
        set ret \
            [  dict create \
                "Tab"         "\t"\
                "2 spaces"    {  }\
                "4 spaces"    {    }\
                "8 spaces"    {        }\
            ]
        return $ret
    }
    proc get_indentation_styles {} {
        return [dict keys [get_indentation_map]]
    }
    proc get_whether_copyright_notice_enabled {} {
        variable should_generate_copyright_notice
        return $should_generate_copyright_notice
    }
    proc get_indentation_string {} {
        variable indentation_style
        dict get [get_indentation_map] $indentation_style
    }
    proc get_vcs_command {} {
        variable vcs_command
        return $vcs_command
    }
    proc get_cpp_namespaces {} {
        variable cpp_namespace_list
        return $cpp_namespace_list
    }
    proc configure_header_guard {} {
        variable header_guard
        variable filename_stem
        set header_guard [string trim $header_guard]
        set fname_stem $filename_stem
        if {[string equal $header_guard ""]} {
            if {![string equal $fname_stem ""]} {
                set tmp "GUARD_${fname_stem}_[get_header_extension]_"
                set rand_num [expr rand()]
                # Get rid of punctuation from the random number
                regsub -all {[^0-9]} $rand_num {} rand_num
                # Get rid of initial zero from random number
                if {[string equal [string range $rand_num 0 0] "0"]} {
                    set rand_num [string range $rand_num 1 end]
                }
                # Shorten rand_num if it's very long and we can shorten
                # it without losing too much randomness.
                set column_limit 80
                set expected_columns \
                  [string length "#ifndef ${tmp}${rand_num}"]
                if {$expected_columns > $column_limit} {
                    if {[string length $rand_num] > 8} {
                        set rand_num [string range $rand_num end-7 end]
                    }
                }
                append tmp $rand_num
                set header_guard $tmp
            }
        }
    }
    # Given a class name in Pascal case, returns an underscore-separated,
    # all-lower-case filename stem based on that class name.
    proc generate_filename_stem {class_name} {
        set filename_subelements [list]
        set current_subelement ""
        foreach c [split $class_name {}] {
            if {[string is upper $c]} {
                lappend filename_subelements $current_subelement
                if \
                  {([llength $current_subelement] > 0) && \
                   ([string range $current_subelement end end] == "_") \
                  } {
                    # Do nothing, as we don't want two underscores in a row
                } else {
                    lappend filename_subelements "_"
                }
                set current_subelement ""
            }
            append current_subelement [string tolower $c]
        }
        lappend filename_subelements $current_subelement
        set ret [join $filename_subelements {}]
        set ret [string trim $ret "_"]
        return $ret
    }
    proc configure_filename_stem {p_class_name} {
        variable filename_stem
        if {![string equal $p_class_name ""] && \
             [string equal $filename_stem ""]} {
            set filename_stem [generate_filename_stem $p_class_name]
        }
    }
}



##############################################################################
# Configuration of the graphical user interface is managed in this namespace.

namespace eval gui {

#   INTERFACE

    # Call with no arguments to create the main window and populate it
    # with all the widgets required for the application.
    # This procedure in turn will do all other initialization required
    # for the application.
    namespace export setup_widgets


#   IMPLEMENTATION DETAILS

    # Window manager configuration
    proc configure_main_window_title {title} {
        wm title . $title
    }

    # Procedure to create and position a label and correponding ttk::entry
    # widget.
    # Parameters:
    #   label_text - text of the label appearing next to the widget;
    #   associated_variable - variable bound to the contents of the ttk::entry
    #     widget.
    #   row_num - row number in which grid geometry manager will position
    #     the widget and its label.
    #
    # Returns the path of the new ttk::entry widget.
    proc setup_entry_widget {label_text associated_variable row_num} {
        set l [label ".${row_num}_entry_label" -text $label_text \
          {*}[platform::get_background_options]]
        set e [ttk::entry ".${row_num}_entry" -textvariable \
          $associated_variable {*}[sizing::get_wide_option] -cursor xterm]
        grid $l -row $row_num -column 0 {*}[sizing::get_padding_options] \
          -sticky e
        grid $e -row $row_num -column 1 {*}[sizing::get_padding_options] \
          -sticky we -columnspan 3
        return $e
    }

    # Here follow several procedures for creating a widget or set of widgets
    # and positioning them via the gridder on the main window. These
    # procedures generally follow a pattern where they must be passed a row
    # number - determining where they will be positioned on the grid - and
    # return a row number, being the next available row for further widgets
    # to be positioned.

    # Setup entry widget for class name; return the next available row number.
    proc setup_class_name_widget {row_num} {
        set path [setup_entry_widget "Class name" \
          widget_contents::class_name $row_num]
        focus $path  ;# Cursor starts here
        # Setting the class name entry should cause the value of filename_stem
        # to be configured, if not already.
        bind $path <FocusOut> {
            widget_contents::configure_filename_stem [string trim [%W get]]
            widget_contents::configure_header_guard
        }
        return [incr row_num]
    }

    # Setup entry widget for filename stem; return the next available row
    # number.
    proc setup_filename_stem_widget {row_num} {
        set path [setup_entry_widget "Filename stem" \
          widget_contents::filename_stem $row_num]
        # Setting the filename stem should cause the header guard symbol to be
        # configured if not already.
        bind $path <FocusOut> widget_contents::configure_header_guard
        return [incr row_num]
    }

    # Setup entry widget for header guard; return the next available row
    # number.
    proc setup_header_guard_widget {row_num} {
        set path [setup_entry_widget "Header guard" \
          widget_contents::header_guard $row_num]
        return [incr row_num]
    }

    # Returns widget paths to be used for a row of widgets for configuring
    # header or source file directory (pass "header" or "source_file" to
    # procedure).
    proc directory_ctrl_paths {file_type} {
        set ret [list]
        for {set i 0} {$i != 3} {incr i} {
            lappend ret .${file_type}_directory_widget_${i}
        }
        return $ret
    }

    # Toggle whether the widgets for controlling the source file saving
    # directory, are enabled or disabled.
    proc toggle_source_file_dir_widgets_enabled {} {
        if [::widget_contents::get_whether_source_file_enabled] {
            set s "normal"
        } else {
            set s "disabled"
        }
        foreach path [directory_ctrl_paths source_file] {
            $path configure -state $s
        }
    }

    # Setup widgets for selecting whether to create header and whether
    # to create source file.
    proc setup_file_creation_toggle_widgets {row_num} {
        # Setup widget for selecting whether or not to create a header
        # (".hpp" file). Note this is always selected and the user cannot
        # change this. It is provided for consistency with the source file
        # creation widget, which the user CAN toggle on or off.
        # Note the code in cpp_code_generation namespace just assumes this
        # will always be selected.
        ttk::checkbutton .header_creation_checkbutton \
          -text "Create header?" \
          -state disabled \
          -variable ::widget_contents::always_true
        grid .header_creation_checkbutton -row $row_num -column 1 \
          -sticky w {*}[sizing::get_padding_options]

        # Setup widget for selecting whether or not to create a source
        # (".cpp") file.
        ttk::checkbutton .source_file_creation_checkbutton \
          -text "Create source file?" \
          -variable ::widget_contents::source_file_enabled \
          -command "{*}[list gui::toggle_source_file_dir_widgets_enabled]"
        grid .source_file_creation_checkbutton -row $row_num -column 2 \
          -sticky w {*}[sizing::get_padding_options]

        return [incr row_num]
    }

    # Procedure to create a dialog box whereby the user chooses
    # a directory. The dialog box starts at the directory stored
    # in associated_variable, and the directory eventually chosen by the
    # user is stored back into associated_variable.
    proc configure_directory {associated_variable} {
        upvar #0 $associated_variable var
        set tmp [tk_chooseDirectory -initialdir $associated_variable]
        if {![string equal $tmp ""]} {
            set var $tmp
        }
    }
    
    # Create file-saving-location widgets and return the next available
    # row number.
    proc setup_directory_widgets {row_num} {
      proc create_directory_choice_ctrl \
          {paths label_text var row_num} {
            namespace import ::platform::get_background_options
            namespace import ::sizing::get_padding_options
            set l [label [lindex $paths 0] -text $label_text \
              {*}[get_background_options]]
            set t [label [lindex $paths 1] -textvariable $var \
              {*}[get_background_options]]
            set b [ttk::button [lindex $paths 2] \
              -text "Browse..." \
              -command "::gui::configure_directory $var"]
            grid $l -row $row_num -column 0 {*}[get_padding_options] \
              -sticky e
            grid $t -row $row_num -column 1 {*}[get_padding_options] \
              -sticky w -columnspan 2
            grid $b -row $row_num -column 3 {*}[get_padding_options] \
              -sticky we
        }
        create_directory_choice_ctrl \
            [directory_ctrl_paths header] \
            "Save header in directory" \
            widget_contents::header_directory \
            $row_num
        incr row_num
        create_directory_choice_ctrl \
            [directory_ctrl_paths source_file] \
            "Save source file in directory" \
            widget_contents::source_file_directory \
            $row_num
        incr row_num
        return [incr row_num]
    }

    # Set up widgets for user to configure generated C++ special member
    # functions.
    # Returns next available row
    proc setup_special_member_function_widgets {row_num} {
        foreach smf [widget_contents::get_special_member_function_labels] {
            label .label($smf) \
              -text $smf {*}[platform::get_background_options]
            ttk::checkbutton .checkbutton($smf) \
              -text "Declare?" -variable \
              ::widget_contents::should_generate_special_member_function($smf)
            ttk::combobox .implementation_combobox($smf) \
              -values [widget_contents::get_implementation_specifiers] \
              -textvariable ::widget_contents::implementation_spec($smf) \
              -state readonly
            ttk::combobox .access_combobox($smf) \
              -values [widget_contents::get_access_specifiers] \
              -textvariable ::widget_contents::access_spec($smf) \
              -state readonly

            grid .label($smf) -row $row_num -column 0 -sticky e \
              {*}[sizing::get_padding_options]
            grid .checkbutton($smf) -row $row_num -column 1 -sticky w \
              {*}[sizing::get_padding_options]
            grid .implementation_combobox($smf) -row $row_num -column 2 \
              -sticky w {*}[sizing::get_padding_options]
            grid .access_combobox($smf) -row $row_num -column 3 \
                -sticky w {*}[sizing::get_padding_options]

            # Unchecking the checkbutton means application will not create
            # C++ code for that special member function. The comboboxes for
            # that special member function therefore become
            # irrelevant and should be disabled. For the checkbutton for the
            # Destructor, for "Make destructor virtual?" checkbutton should be
            # disabled also. We do that here.
            .checkbutton($smf) configure -command \
                "{*}[list ::gui::refresh_combobox_states $smf \
                  [string equal $smf Destructor]]"

            incr row_num
        }
        return $row_num
    }

    # Create widget for user to configure whether the destructor should be
    # virtual.
    # Returns next available row.
    proc setup_destructor_virtuality_widget {row_num} {
        ttk::checkbutton .destructor_virtuality_checkbutton \
            -text "Make destructor virtual?" \
            -variable ::widget_contents::destructor_is_virtual
        grid .destructor_virtuality_checkbutton -row $row_num -column 1 \
            -sticky w {*}[sizing::get_padding_options]
        return [incr row_num]
    }

    # Create widget controlling C++ namespaces to be generated.
    # Returns next available row.
    proc setup_namespace_widget {row_num} {
        label .namespace_label_0 -text "Enclosing namespaces" \
          {*}[platform::get_background_options]
        grid .namespace_label_0 -row $row_num -column 0 -sticky ne \
          {*}[sizing::get_padding_options]
        label .namespace_label_1 -text "(one per line, outermost first)" \
          {*}[platform::get_background_options]
        grid .namespace_label_1 -row [expr {$row_num + 1}] -column 0 \
          -sticky ne {*}[sizing::get_padding_options]
        text .namespace_box -height 6 -width 40 \
          {*}[platform::get_text_widget_options] 
        grid .namespace_box -row $row_num -column 1 -columnspan 2 -rowspan 4 \
          -sticky we {*}[sizing::get_padding_options]
        bind .namespace_box <FocusOut> {
            widget_contents::set_cpp_namespaces [.namespace_box get -- 1.0 end]
        }
        return [incr row_num 5]
    }

    # Create widget for user to select whether to add copyright notice
    proc setup_copyright_notice_widget {row_num} {
        ttk::checkbutton .copyright_notice_checkbutton \
            -text "Generate copyright notice?" \
            -variable ::widget_contents::should_generate_copyright_notice
        grid .copyright_notice_checkbutton -row $row_num -column 1 \
            -columnspan 4 \
            -sticky w {*}[sizing::get_padding_options]
        if {![widget_contents::get_whether_copyright_notice_enabled]} {
            .copyright_notice_checkbutton state "disabled"
        }
        return [incr row_num]
    }

    # Create widget controlling indentation style. Returns next available row.
    proc setup_indentation_widget {row_num} {
        label .indentation_label -text "Indentation style" \
          {*}[platform::get_background_options]
        grid .indentation_label -row $row_num -column 0 -sticky e \
          {*}[sizing::get_padding_options]
        ttk::combobox .indentation_combobox -values \
          [widget_contents::get_indentation_styles] \
          -textvariable ::widget_contents::indentation_style -state readonly
        grid .indentation_combobox -row $row_num -column 1 -sticky w \
          {*}[sizing::get_padding_options]
        return [incr row_num]
    }

    # Create widgets controlling whether to add the newly created files to
    # version control, and if so, the shell command with which to to do (e.g.
    # "svn add" or etc.). Returns next available row.
    proc setup_vcs_widgets {row_num} {
        label .vcs_label -text "Add files to version control?" \
          {*}[platform::get_background_options]
        grid .vcs_label -row $row_num -column 0 -sticky e \
          {*}[sizing::get_padding_options]
        set vcs_widgets_data \
          [ dict create \
            ""          "Do not add" \
            "git add"   "Run \"git add\"" \
            "svn add"   "Run \"svn add\"" \
          ]
        set i 1
        foreach {command description} $vcs_widgets_data {
            set rb \
              [ ttk::radiobutton .vcs_radiobutton_${i} \
                -variable ::widget_contents::vcs_command \
                -value $command -text $description \
              ]
            grid $rb -row $row_num -column $i -sticky w \
              {*}[sizing::get_padding_options]
            incr i
        }
        return [incr row_num]
    }

    # Create buttons to cancel, and to proceed with generating code. Returns
    # next variable row.
    proc setup_cancel_and_generate_buttons {row_num} {
        ttk::button .cancel_button -text "Cancel" \
          {*}[sizing::get_narrow_option] -command exit
        grid .cancel_button -row $row_num -column 0 -sticky swe \
          {*}[sizing::get_padding_options]
        ttk::button .generate_button -text "Generate" \
          {*}[sizing::get_narrow_option] \
          -command {
            ::cpp_code_generation::generate \
              [widget_contents::get_class_name] \
              [widget_contents::get_header_guard] \
              [widget_contents::get_header_name] \
              [widget_contents::get_whether_source_file_enabled] \
              [widget_contents::get_header_directory] \
              [widget_contents::get_source_file_name] \
              [widget_contents::get_source_file_directory] \
              [widget_contents::get_special_member_function_details] \
              [widget_contents::get_cpp_namespaces] \
              [expr { \
                  [widget_contents::get_whether_copyright_notice_enabled]? \
                  [configuration::get_copyright_notice]: \
                  "" \
                } \
              ] \
              [widget_contents::get_indentation_string] \
              [widget_contents::get_vcs_command] \
        }
        grid .generate_button -row $row_num -column 3 -sticky swe \
          {*}[sizing::get_padding_options]
        return [incr row_num]
    }

    # Setup all the widget on the top window.
    proc setup_widgets {} {

        # Hide GUI till all widgets created
        wm withdraw .

        configure_main_window_title \
          "Boilermatic: C++ boilerplate code generator"
        widget_contents::initialize
        set widget_setup_procedures [\
            list setup_class_name_widget \
                 setup_filename_stem_widget \
                 setup_header_guard_widget \
                 setup_file_creation_toggle_widgets \
                 setup_directory_widgets \
                 setup_special_member_function_widgets \
                 setup_destructor_virtuality_widget \
                 setup_namespace_widget \
                 setup_copyright_notice_widget \
                 setup_indentation_widget \
                 setup_vcs_widgets \
                 setup_cancel_and_generate_buttons \
        ]
        set row 0
        foreach procedure $widget_setup_procedures {
            set row [$procedure $row]
        }

        # Make column 1 expand when window resized
        grid columnconfigure . 1 -weight 1

        # Make all the rows expand when window resized
        set max_row [lindex [grid size .] 1]
        for {set i 0} {$i != $max_row } {incr i} {
            grid rowconfigure . $i -weight 1
        }

        # Display GUI
        wm deiconify .
    }

    # Refresh states of comboboxes for a particular C++ special member
    # function passed to smf, according as whether each should be normal or
    # disabled. Pass 1 to refresh_destructor_virtuality_checkbutton_state if
    # we want to refresh the state of that too.
    proc refresh_combobox_states \
      {smf {refresh_destructor_virtuality_checkbutton_state 0}} {
        variable ::widget_contents::should_generate_special_member_function
        set s \
            [expr {$should_generate_special_member_function($smf)? \
            "!disabled": "disabled"}]
        .implementation_combobox($smf) state $s
        .access_combobox($smf) state $s
        if {$refresh_destructor_virtuality_checkbutton_state} {
            .destructor_virtuality_checkbutton state $s
        }
    }
}



##############################################################################
# Data validation procedures are contained in this namespace.

namespace eval validation {

#   INTERFACE
    
    # Validates a string purporting to be a valid C++ identifier (which
    # might be used as e.g. a class name or a preprocessor symbol).
    # Parameters:
    #   target - string being validated
    #   msg - a variable. If the target is invalid, a user-friendly error
    #     message will be placed in this variable; otherwise, it will be
    #     untouched.
    #   target_desc - a user-friendly descriptor of the nature of target,
    #     which will be incorporated into any error message placed in msg.
    #     E.g. "class name".
    # Returns 1 if target is valid, otherwise returns 0.
    namespace export validate_cpp_identifier

    # Validates a string purporting to be a valid filename.
    #   target - string being validated
    #   msg - a variable. If the target is invalid, a user-friendly error
    #     message will be placed in this variable; otherwise, it will be
    #     untouched.
    # Returns 1 if the target is valid, otherwise returns 0.
    # This function may assess as invalid strings that may actually be
    # accepted by certain platforms as valid filenames. It is conservative
    # however and errs on the side of rejecting filenames that might
    # be problematic (even if not strictly unusable) on some platforms.
    namespace export validate_filename

    # Validates a list of stings purporting to be valid C++ namespace
    # identifiers.
    # Parameters:
    #   target - a (Tcl) list of strings to be validated
    #   msg - a variable. If (any of the strings in the) the target is
    #     invalid, a user-friendly error
    #     message will be placed in this variable; otherwise, it will be
    #     untouched.
    # Returns 1 if all the strings in target are valid C++ namespace
    # identifiers, otherwise returns 0;
    # however, if target is not a (Tcl) list then this function may raise an
    # error, rather than returning 0.
    namespace export validate_cpp_namespaces


#   IMPLEMENTATION DETAILS

    proc validate_cpp_identifier {target msg target_desc {allow_empty 0}} {
        upvar 1 $msg m
        if {[string equal [string trim $target] ""]} {
            if {$allow_empty} {
                return 1
            }
            set m "[string toupper $target_desc 0 0] cannot be empty."
            return 0
        }
        if {[string length $target] > 128} {
            set m [string toupper $target_desc 0 0]
            append m \
              " is over 128 characters long. This may present problems."
        }
        set ret [regexp -nocase -- {^[a-z_][0-9a-z_]{0,127}$} $target]
        if {!$ret} {
            set m "Invalid ${target_desc}."
        }
        return $ret
    }

    proc validate_filename {target msg} {
        upvar 1 $msg m
        set prohibited_characters \
          [list "\0" "/" "\\" "?" ";" "%" ":" "|" "\"" "<" ">"]
        foreach prohibited_c $prohibited_characters {
            if {[string first $prohibited_c $target] != -1} {
                if {[string equal $c "\0"]} {
                    set m "The null character"
                } else {
                    set m "The character '$prohibited_c'"
                }
                append m " may be problematic in a filename."
                return 0
            }
        }
        set windows_reserved_filenames [list \
          con prn aux nul com1 com2 com3 com4 com5 com6 com7 com8 com9 \
          lpt1 lpt2 lpt3 lpt4 lpt5 lpt6 lpt7 lpt8 lpt9]

        foreach prohibited_fn $windows_reserved_filenames {
            if {[string equal $target $prohibited_fn]} {
                set m "\"$target\" may be a problematic filename\
                       as it is prohibited on Windows."
                return 0
            }
        }
        if {[string equal $target ".."]} {
            set m "\"$target\" should not be used as a filename."
            return 0
        }
        return 1
    }

    # target is a list of strings being prospective C++ namespace symbols.
    proc validate_cpp_namespaces {target msg} {
        upvar 1 $msg m
        foreach ns $target {
            if {![validate_cpp_identifier $ns m "namespace"]} {
                return 0
            }
        }
        return 1
    }
}



##############################################################################
# This namespace controls actual generation of the C++ code.

namespace eval cpp_code_generation {

#   INTERFACE

    # Procedure to generate the C++ files, and populate them with C++
    # boilerplate code, and optionally also add them to version control via
    # Parameters:
    #    p_class_name - name of C++ class to be generated
    #    p_header_guard - header guard preprocessor symbol
    #    p_header_name - name of header file to be generated
    #    p_header_directory - path to directory in which header will be saved
    #    p_source_file_name - name of C++ source (".cpp") file to be generated
    #    p_source_file_directory - path to directory in which source file will
    #      be saved
    #    p_special_member_function_details - dict containing details of C++
    #      special member functions that will be generated. In each key/value
    #      pair in the dict, the "key" is the text of the C++ declaration
    #      (not including indentation), and the "value" is an access
    #      specifier ("public", "protected" or "private").
    #    p_cpp_namespace_list - a (possibly empty) list each element of which
    #      is a string symbol for a C++ namespace in which the generated
    #      C++ class code will be enclosed. Namespaces should be listed
    #      in order from outermost to innermost.
    #   p_copyright_notice - a (possible empty) string to be placed at the top
    #      of each generated file.
    #    p_indentation_string - a string that will comprise the indentation
    #      for the generated C++ code, where indentation is required.
    #    p_vcs_command - a list, either empty, or else which expands to a shell
    #      command such as "svn add" to be run on each generated file
    namespace export generate


#   IMPLEMENTATION DETAILS

    # Generate the C++ files and populate them according to the user's
    # selections
    proc generate { \
        p_class_name \
        p_header_guard \
        p_header_name \
        p_source_file_enabled \
        p_header_directory \
        p_source_file_name \
        p_source_file_directory \
        p_special_member_function_details \
        p_cpp_namespace_list \
        p_copyright_notice \
        p_indentation_string \
        p_vcs_command } {  

        namespace import ::widget_contents::get_access_specifiers
        namespace import ::validation::validate_cpp_identifier
        namespace import ::validation::validate_filename
        namespace import ::validation::validate_cpp_namespaces

        set header_path [file join $p_header_directory $p_header_name]
        set source_file_path [file join $p_source_file_directory \
          $p_source_file_name]

        # Make sure fields are valid
        if { \
            ![validate_cpp_identifier $p_class_name msg "class name" 1] || \
            ![validate_filename $p_header_name msg] || \
            ($p_source_file_enabled && ![validate_filename $p_source_file_name msg]) || \
            ![validate_cpp_identifier $p_header_guard msg "header guard"] || \
            ![validate_cpp_namespaces $p_cpp_namespace_list msg] \
          } {
            tk_messageBox -message $msg
            return
        }
            
        # Make sure there will be no name clash with already existing files
        set ok_to_create_files 1
        set user_messages [list]
        set clashes 0
        if {[file exists $header_path]} {
            incr clashes
            lappend user_messages \
             "A file named \"${p_header_name}\" already exists\
              in directory ${p_header_directory}."
        }
        if {$p_source_file_enabled && [file exists $source_file_path]} {
            incr clashes
            lappend user_messages \
             "A file named \"${p_source_file_name}\" already exists\
              in directory $p_source_file_directory"
        }
        if {$clashes > 0} {
            lappend user_messages "New files have NOT been created."
            set ok_to_create_files 0
        }

        set files_added_to_vcs [list]
        set filepaths_created [list]

        set copyright_notice_ok 0
        if $ok_to_create_files {

            # Create the requested C++ header and source files
            set header [open $header_path a+]
            if {$p_source_file_enabled} {
                set source_file [open $source_file_path a+]
            }
    
            # Write boilerplate C++ code
            set copyright_notice_ok \
              [expr {![string equal $p_copyright_notice ""]}]
            if {$copyright_notice_ok} {
                puts $header $p_copyright_notice
            }
            puts $header \
              "#ifndef ${p_header_guard}\n#define ${p_header_guard}\n"
            if {$p_source_file_enabled} {
                if {$copyright_notice_ok} {
                    puts $source_file $p_copyright_notice
                }
                puts $source_file "#include \"${p_header_name}\"\n"
            }
            foreach element $p_cpp_namespace_list {
                set line "namespace ${element}\n\{"
                puts $header $line
                if {$p_source_file_enabled} {
                    puts $source_file $line
                }
            }
            puts $header {}
            if {$p_source_file_enabled} {
                puts $source_file "\n"
            }
            set indent $p_indentation_string

            if {[string length $p_class_name] != 0} {

                puts $header "class $p_class_name\n{"

                # Make a dictionary from access specifiers to
                # lists of special member functions
                set specifiers_to_smfs [dict create]
                foreach specifier [get_access_specifiers] {
                    dict set specifiers_to_smfs $specifier [list]
                }
                foreach {smf specifier} $p_special_member_function_details {
                    set smfs [dict get $specifiers_to_smfs $specifier]
                    lappend smfs $smf
                    dict set specifiers_to_smfs $specifier $smfs
                }

                # Write C++ code to file for access specifiers and
                # special member functions.
                foreach {specifier smf_list} $specifiers_to_smfs {
                    if {[llength $smf_list] != 0} {
                        puts $header "${specifier}:"
                        foreach smf $smf_list {
                            puts $header "${indent}${smf}"
                        }
                        puts $header {}
                    }
                } 
                puts $header "};  // class ${p_class_name}\n"
            }

            for \
              {set i [expr {[llength $p_cpp_namespace_list] - 1}]} \
              {$i != -1} \
              {incr i -1} {
                set line "\}  // namespace [lindex $p_cpp_namespace_list $i]"
                puts $header $line
                if {$p_source_file_enabled} {
                    puts $source_file $line
                }
            }
            puts $header "\n#endif  // ${p_header_guard}"

            # Flush and close files
            flush $header
            close $header
            lappend filepaths_created $header_path
            lappend user_messages \
              "New file $header_path has been created and populated."
            if {$p_source_file_enabled} { 
                flush $source_file
                close $source_file
                lappend filepaths_created $source_file_path
                lappend user_messages \
                  "New file $source_file_path has been created and populated."
            }

            # Add files to VCS if applicable
            if {[llength $p_vcs_command] != 0} {
                foreach filepath $filepaths_created {
                    set cmd [list {*}$p_vcs_command $filepath]
                    if {[catch {exec {*}$cmd} err_msg]} {
                        lappend user_messages \
                          "Error executing '$cmd': $err_msg"
                    } else {
                        lappend files_added_to_vcs $filepath
                        lappend user_messages \
                          "Added version control using \"${p_vcs_command}\": $filepath."
                    }
                }
            }
        }

        # Further messages to user
        set num_new_files_created [llength $filepaths_created]
        if {[llength $files_added_to_vcs] == 0} {
            lappend user_messages \
              "Files have NOT been added to version control."
        }
        if {!$copyright_notice_ok} {
            lappend user_messages \
              "Copyright notice has NOT been generated."
        }
        if {$num_new_files_created != 0} {
            set pl "s"
            if {$num_new_files_created == 1} {
                set pl ""
            }
            lappend user_messages \
                "Don't forget to tell your build system about the new file${pl}!"
        }
        
        # Report to user on actions taken
        tk_messageBox -message [join $user_messages "\n\n"]
        if $ok_to_create_files {
            exit
        }
    }

}


##############################################################################
# "Main"

namespace eval application {

#   INTERFACE

    # Call with no arguments to run the application.
    namespace export main

#   IMPLEMENTATION DETAILS
    
    proc main {} {
        gui::setup_widgets
    }
}


##############################################################################
# TRIGGER MAIN

application::main

