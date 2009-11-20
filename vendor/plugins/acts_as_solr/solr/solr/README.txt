***REMOVED*** Licensed to the Apache Software Foundation (ASF) under one or more
***REMOVED*** contributor license agreements.  See the NOTICE file distributed with
***REMOVED*** this work for additional information regarding copyright ownership.
***REMOVED*** The ASF licenses this file to You under the Apache License, Version 2.0
***REMOVED*** (the "License"); you may not use this file except in compliance with
***REMOVED*** the License.  You may obtain a copy of the License at
***REMOVED***
***REMOVED***     http://www.apache.org/licenses/LICENSE-2.0
***REMOVED***
***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.


Example "Solr Home" Directory
=============================

This directory is provided as an example of what a "Solr Home" directory
should look like.

It's not strictly necessary that you copy all of the files in this
directory when setting up a new instance of Solr, but it is recommended.


Basic Directory Structure
-------------------------

The Solr Home directory typically contains the following subdirectories...

   conf/
        This directory is mandatory and must contain your solrconfig.xml
        and schema.xml.  Any other optional configuration files would also 
        be kept here.

   data/
        This directory is the default location where Solr will keep your
        index, and is used by the replication scripts for dealing with
        snapshots.  You can override this location in the solrconfig.xml
        and scripts.conf files. Solr will create this directory if it
        does not already exist.

   lib/
        This directory is optional.  If it exists, Solr will load any Jars
        found in this directory and use them to resolve any "plugins"
        specified in your solrconfig.xml or schema.xml (ie: Analyzers,
        Request Handlers, etc...)

   bin/
        This directory is optional.  It is the default location used for
        keeping the replication scripts.
