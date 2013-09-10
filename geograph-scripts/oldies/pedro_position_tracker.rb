# Selects at random a GPX route, and executes it from the beginning to the end.
require "#{Rails.root}/lib/actions_for_behaviors"
module Behaviors
  class RandomPositionTracker < Behaviors::RandomMover
    include ActionsForBehaviors

    def next_action
      behavior_progress
      action = nil
      if @agent.status == 'running'
        Madmass.logger.debug "==[#{self}] ---"
        if rand(10) != 0
          action = get_nearby_posts_action 
          Madmass.logger.debug "==[#{self}] getting nearby friends"
        else
          advance_pos
          if @current_route
            action = save_user_pos_action(@current_route[@position_in_route])
            Madmass.logger.debug "==[#{self}] saving my pos: #{@position_in_route} of #{@current_route.size}"
          else
            Madmass.logger.debug "==[#{self}] restarting another route"
          end
        end
      end
      return action
    end

  end

end

