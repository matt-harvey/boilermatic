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

set project_name "boilermatic"
set version_major 1
set version_minor 0
set version_patch 0
set this_version_is_closed 0
set version "${version_major}.${version_minor}.${version_patch}"
if {!$this_version_is_closed} {
    set version "${version}-working"
}
set source_filename "${project_name}.tcl"
set package_name "${project_name}-${version}"
