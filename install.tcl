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

source "project_specs.tcl"
set executable_filename "${project_name}"
set install_destination "/usr/local/bin"
set executable_filepath "${install_destination}/${executable_filename}"
file copy -force $source_filename $executable_filepath
exec chmod +x $executable_filepath
puts "Installed ${executable_filename} to ${install_destination}."
puts "To run, enter \"${executable_filename}\"."
