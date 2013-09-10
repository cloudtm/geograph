Cloudtm-jboss-modules
=====================

JBoss Modules for the Cloud-TM Platform to be installed in Torquebox.


1. Update the infinispan module
   > Copy the folder *modules/org/infinispan* in the same folder of the JBoss directory in your Torquebox installation.

2. Update the JGroups module
   > Copy the folder *modules/org/jgroups/main* in the same folder of the JBoss directory in your Torquebox installation.

3. Create the Clearspring module
   > Copy the folder *modules/com/clearspring* in the same folder of the JBoss directory in your Torquebox installation.

4. Add the Hibernate OGM module
   > Copy the folder *modules/org/hibernate* in the same folder of the JBoss directory in your Torquebox installation.

5. In your Torquebox directory edit the configuration file jboss/standalone/configuration/standalone-ha.xml and add the SEQUENCER
and tom.TOA protocols to the TCP and UDP stacks. The protocols must be between GMS and UFC, i.e.

  > &lt; protocol type='pbcast.GMS'&#47;&gt;

  > &lt; protocol type='SEQUENCER'&#47;&gt;

  > &lt; protocol type='tom.TOA'&#47;&gt;

  > &lt; protocol type='UFC'&#47;&gt;