clear all
%close all
%This script opends xml files generated using Trackmate LAP Icy tracker and
%filteres the tracks for the starting point. Here only cells will be
%considered that where tracked from the first frame on and not the ones
%that later moved into the frame.

%enter the path to the Icy.xml file here:
filename = ['D:\scratch_assay_NTERT\scratch_assay_Ntert_PSMa3_WRW4_10x_10min_1_1umpx_11012023\analysis\Pos'];

%for batch processing enter the number of the sample here:
for pos=[10]
    fil = ([filename num2str(pos) '\NC_Icy.xml']);
    %load tracks.mat
    [tracks] = importTrackMateTracks_LAP_icy(fil);
    tracksunfilt=length(tracks); 
    
    kkk=1;
        for k=1:tracksunfilt
          if tracks{1, k}{1,1}(1,1)==0 %%take into account all cells that where present and tracked in the first frame (t=0)
              
              tracedata{kkk,1}=tracks{1, k}{1,1}(:,2:3);%saves x position
              %tracedata{kkk,:,2}=tracks{1, k}{1,1}(1,3);%saves y position
              tracedata{kkk,2}=tracks{1, k}{1,2}(1,1);%saves track ID
              kkk=kkk+1;
          else
          end
        end
    %plot the filtered tracks to make sure everything worked ok:
        for bbb=1:(kkk-1)
            plot(tracedata{bbb,1}(:,1), tracedata{bbb,1}(:,2));hold on

        end
    clear md tracksunfilt 
    %save file containing filtered tracks:
    save ([filename num2str(pos) '/filtered_Tracks.mat'],'tracedata')
end 
          