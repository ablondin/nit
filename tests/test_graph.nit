# This file is part of NIT ( http://www.nitlanguage.org ).
#
# Copyright 2014 Alexandre Blondin Massé <alexandre.blondin.masse@gmail.com>
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

import digraph

var digraph = new SparseDigraph[String]

print("empty digraph: {digraph}")
digraph.add_vertex("a")
digraph.add_vertex("b")
digraph.add_vertex("d")
print("adding vertices a,b,d: {digraph}")

#print("test.has_suffix(\"t\") => {test.has_suffix("t")}")
#print("test.has_suffix(\"st\") => {test.has_suffix("st")}")
#print("test.has_suffix(\"est\") => {test.has_suffix("est")}")
#print("test.has_suffix(\"test\") => {test.has_suffix("test")}")
#print("test.has_suffix(\"bt\") => {test.has_suffix("bt")}")
#print("test.has_suffix(\"bat\") => {test.has_suffix("bat")}")
#print("test.has_suffix(\"foot\") => {test.has_suffix("foot")}")

