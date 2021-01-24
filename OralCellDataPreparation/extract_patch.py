# -*- coding: utf-8 -*-
import cv2
from tqdm import tqdm
import csv
from glob import glob
import os

#%%
z_offsets = ['z0', 'z400', 'z-400', 'z800', 'z-800', 'z1200', 'z-1200', 'z1600', 'z-1600', 'z2000', 'z-2000']
#%%
def generate_patch(w=80):
    """    
    Arguments:
    w -- window size for patches
    
    Returns:
    total_num -- total number of predicted nucleus patches
    """        
    total_num = 0
    # generate patches only for the sub-images with nuclei detected
    for csv_path in tqdm(glob('./CSVResults/*.csv')):
        # extract image name without extension, and separate without z value
        img_name = os.path.basename(csv_path)[:-len('.csv')]
        img_name_l = img_name[:img_name.rindex('z0')]
        img_name_r = img_name[img_name.rindex('z0') + len('z0'):]
        
        for z_offset in z_offsets:
            img_z_name = img_name_l + z_offset + img_name_r + '.jpg'
            img = cv2.imread('./JPEGImages/' + img_z_name)
            
            with open(csv_path) as f:
                f_csv = csv.reader(f)
                headers = next(f_csv)
                i = 0
                for row in f_csv:
                    center = [round(float(row[-2])), round(float(row[-1]))]
                    box = [center[0] - int(w/2), center[1] - int(w/2), 
                           center[0] + int(w/2), center[1] + int(w/2)]
                    cropped = img[box[1]:box[1]+w, box[0]:box[0]+w]    # [Ymin:Ymax , Xmin:Xmax]
                    cv2.imwrite("./Patches/Z_expanded/{}_{}_{}.jpg"
                                .format(img_name, '0'*(4 - len(str(i))) + str(i), z_offset), 
                                cropped, [int(cv2.IMWRITE_JPEG_QUALITY), 100])
                    i += 1
                total_num += (f_csv.line_num - 1)
                
    return total_num

#%%
if __name__ == '__main__':
    print('#'*30)
    print('Generating predicted patches at all Z level.')
    print('#'*30)
    total_num = generate_patch()