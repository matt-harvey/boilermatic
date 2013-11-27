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

# Convenience script for creating a source package.

source "project_specs.tcl"
set tarball_name "${package_name}.tar.gz"

set packaged_files [ \
    list \
    $source_filename \
    "install.tcl" \
    "package.tcl" \
    "project_specs.tcl" \
    "LICENSE" \
    "README" \
    "TODO" \
]

set tempdir $project_name
file mkdir $tempdir
foreach f $packaged_files {
    file copy $f $tempdir
}

exec tar -cvzf $tarball_name $tempdir

file delete -force $tempdir

