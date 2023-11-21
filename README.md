# TERT_1_kinematics
This set of scripts is meant to analyze the track data from epithelial cells closing a wound during a scratch assay. It imports track data from Trackmate LAP icy tracker, containing the tracks, objects IDs and splitting events. 
The main script is Caluculate_Speed_Master.m, it calls for importTrackMateTracks_LAP_icy.m which can read the XML files from Trackmate.
After saving the XML file, filter_tracks_for_first_frame.m is used to remove all objects that only entered the field of view later in the recording. This makes sure only objects in the close proximity of the wound will be considered in the analysis.
Here a .m file will be saved which then will be used later during analysis.
Afterwards Caluculate_Speed_Master.m extracts splitting events and calculates the speed of the objects. The number of splitting events is saved as a TXT file, and the speed as an Excel sheet.
