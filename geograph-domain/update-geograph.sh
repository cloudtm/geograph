#!/bin/bash
mvn clean package
rm ../geograph/lib/cloud_tm/jars/*
cp target/geograph-domain-1.0-SNAPSHOT.jar ../geograph/lib/cloud_tm/jars/
mvn -U dependency:copy-dependencies -DincludeGroupIds=pt.ist -DoutputDirectory=../geograph/lib/cloud_tm/jars/
cp src/main/dml/geograph.dml ../geograph/lib/cloud_tm/conf/
