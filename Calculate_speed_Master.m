%% Load and Test compliance of xml file
% this script reads in the information of the Icy.xml file one can generate
% using Fiji Trackmate with LAP tracker recording the division events in a
% 'linklist'. The linklist contains all object IDs and links them to the
% new objects once it was split. So objects that split into two new ones
% (like a cell dividing) will aprear twice in the 'from' linke of the link
% list. This scripts extracts the ID list, counts how often each ID appears
% (Z) and then compares it to the ID list previously computed using
% 'filter_tracks_for_first_frame.m'. in the end the number of cells that
% where present in the first frame and split will be saved in a txt file
% under dir.
% last changed by Marie Muenkel 24.01.2023
clear all
    files = 'enter path to filtered tracks file here';
    for pos = [2,6,7,9,22,12,20,15]%for batch processing, eneter the sample number here
        file = [files num2str(pos) '/NC_Icy.xml'];%enter directory to xml track file here
        dir =  [files num2str(pos) '/division_events.txt']; %enter the directory here, where later the results are to be saved
        tracks = [files num2str(pos) '/filtered_tracks.mat'];%enter directory to filtered tracks .mat file here
        try
            doc = xmlread(file);
        catch %#ok<CTCH>
            error('Failed to read XML file %s.',file);
        end
        root = doc.getDocumentElement;
        if ~strcmp(root.getTagName, 'root')%MM
            error('MATLAB:importTrackMateTracks:BadXMLFile', ...
                'File does not seem to be a proper track file.')
        end
        %% read link list
        start = 1;
        iter_var = 1;
        motherIDs={};
        while iter_var == 1
            alllinks = root.getElementsByTagName('link');
            links = alllinks.item(start);
            try
                ID = links.getAttribute('from');
            catch
                break
                end
                motherIDs(start) = ID;
                start = start+1;
            end
            %% which mother IDs are in the list twice? those are the ones that had a splitting event
            [D,~,X] = unique(motherIDs(:));% X contains all IDs once only
            Y = hist(X,unique(X));%with hist we count how often that ID can be found,
            % 2 means it splt into two other IDs 1 means it didn't split
            Z = struct('name',D,'freq',num2cell(Y(:)));%save structure with the ID and its frequency
            %% check which IDs of the tracks are in the mother IDs to find out how many of the original first frame cells split
            load(tracks);%loads tracedata (column one contains the coordinates of one nucleus, column 2 contains the ID of the nucleus
            trackIDs = cell2mat(tracedata(:,2));% example this ID should be in track ID and in the list of double IDs (1 division and t0 are there)
            numberDiv = 0;%counter for division events
            for i = 1:length(trackIDs)
                Z1 = struct2cell(Z); % comma separated list expansion,
                allIDs= Z1(1, :)';
                % allIDs are the Ids from Z whith the information about the splitting events in the second columns
                %tf1 = allIDs == trackIDs(i) ;%lets fnd out if the IDs in Z belong to nuclei present in the first time frame
                % (I filtered all tracks for the first timeframe and saved the tracks in tracedata)
                index1 = find(cellfun(@strcmp,allIDs,repmat({char(trackIDs(i))},length(allIDs),1)));%return the index
                if ~isempty(index1)
                    if Z(index1).freq == 2
                        numberDiv = numberDiv + 1;
                    else
                            end
                else
                        end
            end
            T = table(numberDiv, length(trackIDs), 'VariableNames', { 'number of division events', 'number of cells'} );
            writetable(T, dir);
    end
%% calculate the spead over time
clear all
%here are the same input variables repeated, so both sections can be run
%independently
tracks = 'Directory to folder containing filtered track .mat files';
dir1 = 'directory where results should be saved';
tstep = 1; %speed betweeen consequtive time points tspet = 1
fcal = 1.1; % calibration factor um/px
fRate = 10; % min per frame
frametotal = 72;% number of frames
for pos = [12]
    load([tracks num2str(pos) '\filtered_Tracks.mat']);
    dir2 = [dir1 num2str(pos) '\meanSpeed.xlsx'];
    numTracks = length(tracedata);
    speed = zeros(numTracks, frametotal);
    for i = 1 : numTracks
        coord = tracedata{i, 1};%read in one track at a time
        % loop through frames
        for frame = 1: (length(coord)-1)
            tm1=[coord(frame, 1) coord(frame,2)]; % x-y coordinates at time point 1
            tm4=[coord(frame+tstep, 1) coord(frame+tstep,2)]; % x-y coordinates at time point 1+tstep (next time point)
            d=tm4-tm1; % Vectors connecting two successive points.
            framespeed = (sqrt(d(1)^2 + d(2)^2)*fcal/fRate);%um/min
            speed(i,frame)=framespeed;
        end
    end
    meanSpeed = zeros(1,frametotal);
    for frame = 1:frametotal
        allspeedFrame = speed(:,frame);
        v = nonzeros(allspeedFrame');
        meanSpeed(1,frame) = mean(v);
    end
    T = table(meanSpeed', 'VariableNames', { 'mean Speed of all cells per frame (um/min)'} );
    writetable(T, dir2);
    %clearvars tracks speed T meanspeed
end











