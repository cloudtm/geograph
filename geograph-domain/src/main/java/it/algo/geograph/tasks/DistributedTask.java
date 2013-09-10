package it.algo.geograph.tasks;

import java.util.concurrent.Callable;
import java.util.Set;
import java.util.Iterator;
import java.io.Serializable;
import it.algo.geograph.domain.*;

import pt.ist.fenixframework.Atomic;
import pt.ist.fenixframework.FenixFramework;
import eu.cloudtm.LocalityHints;

public class DistributedTask implements Callable<Integer>, Serializable {
    
    /** The serialVersionUID */
   private static final long serialVersionUID = 3496135215525904755L;
   private String landmarkType;
   private String landmarkCell;

   private int posts;
   private int postLikes;
   private int postComments;
   private int venues;
   private int venueLikes;
   private int venueComments;
   private int agentsInVenues;
   private int trackables;

   public DistributedTask(String landmarkType, String landmarkCell) {
      this.landmarkType = landmarkType;
      this.landmarkCell = landmarkCell;
   }

   protected void recursePostTree(KdNode node) {
      Location loc = node.getSample();
      Post post = loc.getPost();
      if (post != null) {
         this.posts += 1;
         this.postLikes += post.getLikes() != null ? post.getLikes() : 0;
         this.postComments += post.getComments() != null ? post.getComments().size() : 0;
      }
      if (node.getLeft() != null) recursePostTree(node.getLeft());
      if (node.getRight() != null) recursePostTree(node.getRight());
   }

   protected void recurseVenueTree(KdNode node) {
      Location loc = node.getSample();
      Venue venue = loc.getVenue();
      if (venue != null) {
         this.venues += 1;
         this.venueLikes += venue.getLikes() != null ? venue.getLikes() : 0;
         this.venueComments += venue.getComments() != null ? venue.getComments().size() : 0;
         this.agentsInVenues += venue.getAgents() != null ? venue.getAgents().size() : 0;
      }
      if (node.getLeft() != null) recurseVenueTree(node.getLeft());
      if (node.getRight() != null) recurseVenueTree(node.getRight());
   }

   protected void recurseTrackableTree(KdNode node) {
      Location loc = node.getSample();
      Trackable trackable = loc.getTrackable();
      if (trackable != null) {
         this.trackables += 1;
      }
      if (node.getLeft() != null) recurseTrackableTree(node.getLeft());
      if (node.getRight() != null) recurseTrackableTree(node.getRight());
   }

   private void clearCounters() {
      posts = 0;    postLikes = 0;  postComments = 0;
      venues = 0;   venueLikes = 0; venueComments = 0;
      agentsInVenues = 0;   trackables = 0;
   }

   @Override
   @Atomic
   public Integer call() throws Exception {
      System.out.println("Distributed Task with this landmark type [" + this.landmarkType + "] and this cell [" + this.landmarkCell + "]");
      if (this.landmarkType.equals("PostLandmark")) {
         PostLandmark plandmark = (PostLandmark) FenixFramework.getDomainRoot().getApp().getPostLandmarksByCell(this.landmarkCell);
         if (plandmark != null) {
            clearCounters();
            recursePostTree(plandmark.getKdRoot());
            LandmarkStats stats = new LandmarkStats();
            stats.setPosts(this.posts);
            stats.setPostLikes(this.postLikes);
            stats.setPostComments(this.postComments);
            plandmark.setStats(stats);
         }
      }
      if (this.landmarkType.equals("VenueLandmark")) {
         VenueLandmark vlandmark = (VenueLandmark) FenixFramework.getDomainRoot().getApp().getVenueLandmarksByCell(this.landmarkCell);
         if (vlandmark != null) {
            clearCounters();
            recurseVenueTree(vlandmark.getKdRoot());
            LandmarkStats stats = new LandmarkStats();
            stats.setVenues(this.venues);
            stats.setVenueLikes(this.venueLikes);
            stats.setVenueComments(this.venueComments);
            stats.setAgentsInVenues(this.agentsInVenues);
            vlandmark.setStats(stats);
         }
      }
      if (this.landmarkType.equals("TrackableLandmark")) {
         TrackableLandmark tlandmark = (TrackableLandmark) FenixFramework.getDomainRoot().getApp().getTrackableLandmarksByCell(this.landmarkCell);
         if (tlandmark != null) {
            System.out.println("TrackableLandmark [" + tlandmark.getCell() + "]");
            Set locations = tlandmark.getTrackableLocations();
            LandmarkStats stats = new LandmarkStats();
            System.out.println("  locations (trackables): " + locations.size());
            stats.setTrackables(locations.size());
            tlandmark.setStats(stats);
         }
      }

      return 0;
   }

}
