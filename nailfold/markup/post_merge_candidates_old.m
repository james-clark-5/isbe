function [candidate_xy, candidate_scores] = post_merge_candidates_old(candidate_xy, candidate_scores, ...
    vessel_prob, dist_thresh, connect_thresh, n_connect_pts, do_plot)
%POST_MERGE_APEXES *Insert a one line summary here*
%   [vessels] = post_merge_apexes(vessels, vessel_prob, min_dist, patch_sz, connect_thresh, n_connect_pts)
%
% Inputs:
%      vessels - *Insert description of input variable here*
%
%      vessel_prob - *Insert description of input variable here*
%
%      min_dist - *Insert description of input variable here*
%
%      patch_sz - *Insert description of input variable here*
%
%      connect_thresh - *Insert description of input variable here*
%
%      n_connect_pts - *Insert description of input variable here*
%
%
% Outputs:
%      vessels - *Insert description of input variable here*
%
%
% Example:
%
% Notes:
%
% See also:
%
% Created: 16-Oct-2013
% Author: Michael Berks 
% Email : michael.berks@manchester.ac.uk 
% Phone : +44 (0)161 275 7669 
% Copyright: (C) University of Manchester 
curr_can = 1;
plot_num = 1;
patch_sz2 = ceil(dist_thresh / 2) + 1;
patch_sz = patch_sz2*2 + 1;


while curr_can <= size(candidate_xy,1) && size(candidate_xy,1) > 1

    %Find the nearest vessel
    idx = setdiff(1:size(candidate_xy,1), curr_can);           
    dists = sum(bsxfun(@minus, candidate_xy(idx,:), candidate_xy(curr_can,:)).^2,2);               
    [min_dist min_idx] = min(dists);                
    nearest_can = idx(min_idx);

    %Check that the nearest vessel a) is within the minimum
    %distance             
    if sqrt(min_dist) < dist_thresh

        %Get the two centres and their midpoint
        centre1 = candidate_xy(curr_can,:);
        centre2 = candidate_xy(nearest_can,:);
        centre_midpoint = (centre1 + centre2) / 2;

        %Sample a patch about the midpoint
        vessel_prob_patch = sample_window(vessel_prob, patch_sz, ...
            round(centre_midpoint(2)), round(centre_midpoint(1)));

        %Make the centres xy coords relative to the patch frame
        centre1 = centre1 - round(centre_midpoint) + patch_sz2;
        centre2 = centre2 - round(centre_midpoint) + patch_sz2;    

        %Work connectivity
        for i_con = fliplr(linspace(0, 1, n_connect_pts));

            con_mask = bwselect(vessel_prob_patch > i_con, centre1(1), centre1(2));
            if con_mask(round(centre2(2)), round(centre2(1)))                            
                break;
            end
        end
        connectedness = i_con;
        
        discarded = false(2,1);
        if connectedness > connect_thresh
            %Merge the vessels
            
            if nearest_can > curr_can          
                if candidate_scores(nearest_can) > candidate_scores(curr_can)
                    candidate_scores(curr_can,:) = candidate_scores(nearest_can,:);
                    candidate_xy(curr_can,:) = candidate_xy(nearest_can,:);
                    discarded(1) = 1;
                else
                    discarded(2) = 1;
                end
   
                %Delete nearest_can
                candidate_xy(nearest_can,:) = [];
                candidate_scores(nearest_can,:) = [];
            else
                if candidate_scores(curr_can) > candidate_scores(nearest_can)
                    candidate_scores(nearest_can,:) = candidate_scores(curr_can,:);
                    candidate_xy(nearest_can,:) = candidate_xy(curr_can,:);
                    discarded(2) = 1;
                else
                    discarded(1) = 1;
                end
   
                %Delete nearest_can
                candidate_xy(curr_can,:) = [];
                candidate_scores(curr_can,:) = [];
            end
                
        end
            
        if do_plot
            %Display
            if plot_num == 1
                figure;
            end
            subplot(3,4,plot_num); 
            imgray(vessel_prob_patch); 
            title([num2str(curr_can) ', ' num2str(nearest_can)]);
            xlabel(num2str(connectedness));

            plot(centre1(:,1), centre1(:,2), 'x', 'markersize', 20);
            plot(centre2(:,1), centre2(:,2), 'x', 'markersize', 20);
            
            %If we discarded either candidate circle the one we kept
            if discarded(1)
                plot(centre2(:,1), centre2(:,2), 'ro', 'markersize', 20);
            elseif discarded(2)
                plot(centre1(:,1), centre1(:,2), 'ro', 'markersize', 20);
            end

            if plot_num == 12
                plot_num = 1;
            else
                plot_num = plot_num + 1;
            end
        end
    end
    %Increment the vessel count
    curr_can = curr_can + 1;
end
