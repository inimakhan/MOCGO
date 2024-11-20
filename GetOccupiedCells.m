
%__________________________________________________________________     %
%        MOCGO: Multi-objective Chaos Game Optimization (MOCGO)         %
%                                                                       %
%                                                                       %
%                  Developed in MATLAB R2023a (MacOs)                   %
%                                                                       %
%                      Author and programmer                            %
%                ---------------------------------                      %
%                Nima Khodadadi (ʘ‿ʘ)   University of Miami             %
%                         SeyedAli Mirjalili                            %
%                             e-Mail                                    %
%                ---------------------------------                      %
%                      Nima.khodadadi@miami.edu                         %
%                                                                       %
%                                                                       %
%                            Homepage                                   %
%                ---------------------------------                      %
%                    https://nimakhodadadi.com                          %
%                                                                       %
%                                                                       %
%                                                                       %
%                                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% ----------------------------------------------------------------------- %


function [occ_cell_index occ_cell_member_count]=GetOccupiedCells(pop)

    GridIndices=[pop.GridIndex];
    
    occ_cell_index=unique(GridIndices);
    
    occ_cell_member_count=zeros(size(occ_cell_index));

    m=numel(occ_cell_index);
    for k=1:m
        occ_cell_member_count(k)=sum(GridIndices==occ_cell_index(k));
    end
    
end