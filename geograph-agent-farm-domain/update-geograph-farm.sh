#!/bin/bash
mvn clean package
rm ../geograph-agent-farm/lib/cloud_tm/jars/*
cp target/geograph-farm-domain-1.0-SNAPSHOT.jar ../geograph-agent-farm/lib/cloud_tm/jars/
mvn -U dependency:copy-dependencies -DincludeGroupIds=pt.ist -DoutputDirectory=../geograph-agent-farm/lib/cloud_tm/jars/
cp src/main/dml/geograph-agent-farm.dml ../geograph-agent-farm/lib/cloud_tm/conf/

