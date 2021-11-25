#Purpose:
    #A template script to run all subjects BIDS conversion in independent jobs, via
    #submit_jobs.py with (by prepending s= 1 etc. to this script):
    #
    # python /imaging/camcan/sandbox/ek03/fixCC700/cc700_MEG/scripts/createBIDS_MNEBIDS/Cam-CAN-to-BIDS/Code/submitJobs.py /imaging/camcan/sandbox/ek03/fixCC700/cc700_MEG/scripts/createBIDS_MNEBIDS/Cam-CAN-to-BIDS/Code/run_convert_camcan_singleSubject_smt.py /imaging/ek03/tmp/tmpJobs 645 1 s

#SETUP
experiments = ('rest')
exp = experiments


import pathlib
#import tqdm
from datetime import datetime, timezone
from collections import Counter
import numpy as np
import pandas as pd
import mne
from mne_bids import BIDSPath, write_raw_bids
import glob
import os
#from mne_bids import write_meg_calibration, write_meg_crosstalk

#SETUP
mne.set_log_level(verbose=True)

input_dir = pathlib.Path(f'/imaging/camcan/sandbox/ek03/fixCC280/CC280_BIDS_MEG/{exp}/tmp')
output_dir = pathlib.Path(f'/imaging/camcan/sandbox/ek03/fixCC280/CC280_BIDS_MEG/{exp}/MNE-BIDS')

if not os.path.exists(output_dir):
    os.mkdir(output_dir)
    
participants = sorted([p.parts[-1] for p in input_dir.glob('sub-CC*')])

#restart_from = 'sub-CC620106'
restart_from = None
if restart_from is not None:
    idx = participants.index(restart_from)
    participants = participants[idx:]

#event_name_to_id_mapping = {'audiovis/300Hz': 1,
#                            'audiovis/600Hz': 2,
#                            'audiovis/1200Hz': 3,
#                            'catch/0': 4,
#                            'catch/1': 5,
#                            'audio/300Hz': 6,
#                            'audio/600Hz': 7,
#                            'audio/1200Hz': 8,
#                            'vis/checker': 9,
#                            'button': 99}

stim_chs = ('STI001', 'STI002', 'STI003', 'STI004')


#START
t_start = datetime.now()

for participant in participants:
    
    for files in glob.glob(f'{input_dir}/{participant}/*.fif'):
        #print(participant); print(files)
        print(f'\nConverting sub-{participant[4:]} ses-{exp}\n')
    
        raw = mne.io.read_raw_fif(files)
    
        # NO EVENTS IN REST
        anonDict = {
        "daysback": 35240,
        "keep_his": False}
        
        # Now actually convert to BIDS.
        bids_path = BIDSPath(subject=participant[4:], session=exp, task=exp, datatype='meg',
                             root=output_dir)
        write_raw_bids(raw, bids_path=bids_path,
                       anonymize=anonDict,
                       overwrite=True,
                       verbose=True)

    del bids_path, raw
    
    print('Finished conversion.')
    t_end = datetime.now()
    
    print(f'Process took {t_end - t_start}.')
    