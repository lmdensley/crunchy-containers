#!/bin/bash

# Copyright 2015 Crunchy Data Solutions, Inc.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

asciidoc \
-b bootstrap \
-f ./demo.conf \
-o ./htmldoc/standalone.html \
-a toc2 \
-a footer \
-a toc-placement=right \
./standalone.asciidoc

asciidoctor-pdf ./standalone.asciidoc --out-file ./pdf/standalone.pdf

asciidoc \
-b bootstrap \
-f ./demo.conf \
-o ./htmldoc/openshift.html \
-a toc2 \
-a toc-placement=right \
./openshift.asciidoc

asciidoctor-pdf ./openshift.asciidoc --out-file ./pdf/openshift.pdf

asciidoc \
-b bootstrap \
-f ./demo.conf \
-o ./htmldoc/origin-install.html \
-a toc2 \
-a toc-placement=right \
./origin-install.asciidoc

asciidoctor-pdf ./origin-install.asciidoc --out-file ./pdf/origin-install.pdf

asciidoc \
-b bootstrap \
-f ./demo.conf \
-o ./htmldoc/metrics.html \
-a toc2 \
-a toc-placement=right \
./metrics.asciidoc

cd htmldoc
asciidoctor-pdf ../metrics.asciidoc --out-file ./pdf/metrics.pdf
