Copying
-------

Copyright 2012-2013 Matthew Harvey

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.


Overview
--------

Boilermatic is small C++ code-generation tool with a graphical user
interface. It is intended to automate some of the repetitive tasks
associated with writing a new class in C++11, both to save time,
and to reduce the chance of programmer error. The application
assumes that each class will have its own header and (optionally)
source file.

Dependencies
------------

Boilermatic requires:

-	A Tcl interpreter
-	Tk
-	Ttk

Boilermatic has been tested with tclsh8.5 only; however, it is likely
to work with other Tcl interpreters.

Tk and Ttk are Tcl packages that are likely to be available on most
systems on which tclsh8.5 is installed.

Installation
------------

*On Unix-like systems:*

``cd`` into the source directory, and enter the following sequence of commands::

    chmod +x install.tcl
    sudo ./install.tcl

This will install Boilermatic to /usr/local/bin.
To install it to a different location, open "install.tcl" in a text editor
and change the ``install_destination`` variable to the desired location.

*On Windows:*

Manually copy the file "boilermatic.tcl" to a directory of your choosing.
Add this directory to your ``PATH`` if it is not there already.

You may need to associate the file "boilermatic.tcl" with wish or another Tcl
interpreter. You should then be able to run it either by entering
``boilermatic`` at the command line, or by double-clicking the script's icon
in Windows Explorer.


Usage
-----

To run the application, enter ``boilermatic`` at the command line.
It is generally most convenient if you run it from within the root
directory of your C++ project, as the suggested location for the generated C++
files will default to the current working directory ("."), or to "./include"
or "./src" if these directories exist, for saving the generated header and
source file, respectively.

The application will display a GUI dialog containing several text boxes and
other controls. These are intended to be reasonably self-explanatory for someone
who is familiar with C++11.

Starting at the top, enter into the *Class name* box the name of the class you
want to create. The *Filename stem* and *Header guard* boxes will then be
automatically populated based on the class name you entered. 

The *Filename stem* box will provide the name of the generated C++ file(s),
with ".hpp" and ".cpp" extensions added for the header and "source" file,
respectively.

If you just want the files created but with no class
declaration, you can leave *Class name* blank and just populate
*Filename stem* direclly. A suggested header guard will still be generated
based on the filename stem you enter.

The *Header guard* box provides the macro to be used in the header
guard. By default this is based on the filename stem, and has a pseudo-random
number appended to virtually eliminate the possibility of clashes with other
macros.

You can manually change both the filename stem and header guard to almost any
other string (although Boilermatic will reject some strings on the basis that,
e.g. they are not valid C++ identifiers).

By default, both a ".hpp" and a ".cpp" file will be generated. You can tell
Boilermatic to produce only a header, by unchecking *Create source file?*

Next choose the direoctories in which to save the generated header and source
file (or leave the default directories unchanged).

The rest of the GUI should be fairly self-explanatory. For each special
member function, decide whether you want to explicitly declare it, and
if so, whether you want to append ``= default`` or ``= delete``, or whether
you want write the function body yourself ("custom"). You can also
select whether to make the function public, protected or private. This
area of the GUI is intended to serve not only as a keystroke-saving
device, but also as a sort of checklist, so that when creating a new class, it
becomes an easy exercise to run through the special member functions in turn,
deciding for each one whether/how that function should be declared.

By default, the destructor will be declared ``virtual``; you
can uncheck the *Make destructor virtual?* box to make it non-virtual.

If you want to declare the class within one or more namespaces, enter the
namespace names one row at a time in the *Enclosing namespaces* box.

You can then select your preferred indentation style.

If you want to run either ``git add`` or ``svn add``, passing each of the
newly generated files to this command in turn, check the corresponding box.

Finally, click *Cancel* to abort, or *Generate* to generate C++ files based
on your selections. A message box will display a summary of actions taken.


Contact
-------

boilermatic@matthewharvey.net
