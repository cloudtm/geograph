mvn clean package
mvn dependency:copy-dependencies -DincludeGroupIds=pt.ist -DoutputDirectory=/Users/vittorio/dev/geograph/lib/cloud_tm/jars/
cp target/geograph-domain-1.0-SNAPSHOT.jar /Users/vittorio/dev/geograph/lib/cloud_tm/jars/
