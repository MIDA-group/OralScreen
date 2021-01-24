# Oral Cell Data Preparation

[TOC]

## Dependencies

- [NDPITools](https://www.imnc.in2p3.fr/pagesperso/deroulers/software/ndpitools/) (choose NDPITools software version, independent of ImageJ)
- [Install MATLAB Engine API for Python](https://ww2.mathworks.cn/help/matlab/matlab_external/install-the-matlab-engine-for-python.html?lang=en) 
- Other packages for python

## Explanation

[`data_preparation.sh`](./data_preparation.sh) includes the steps to prepare all nucleus patches for classification. 

<details>
<summary>Explanations of main steps</summary>

1. `ndpisplit` uses [NDPITools](https://www.imnc.in2p3.fr/pagesperso/deroulers/software/ndpitools/) to split the NDPI files into smaller pieces. 
	
    This should generate 512 jpg images of size 6496*3360px for each slide, indexing from `i01j01` to `i32j16`. (It takes about 1h to split one whole slide.)
2. [`predict_mask.py`](./predict_mask.py) is used to infer fuzzy prediction masks for nucleus locations.
3. ImageJ macro script [`particle_analysis_fixedDirectory.ijm`](./particle_analysis_fixedDirectory.ijm) (or [`particle_analysis.ijm`](./particle_analysis.ijm)) is called to run blob analysis and extract the detected nucleus coordinates to CSV files.
4. [`extract_patch.py`](./extract_patch.py) is used to cut out nuclei **at all z-levels** (according to the detected nucleus coordinates in CSV files).
5. [`select_focus.py`](./select_focus.py) is used to select the most focused patch for each nucleus location.
   
    Or alternatively, `./select_focus_parallel.sh N` does this step using N processes in parallel.
</details>

## Usage

1. Clone this repository to the directory of the NDPI files.

2. There are two options for this step:

    1. Edit the path for `inputFolder` and `outputFolder` in `particle_analysis_fixedDirectory.ijm` : 
        ```
        inputFolder="/PATH_TO/OralCellDataPreparation/PredMasks/";
        outputFolder="/PATH_TO/OralCellDataPreparation/CSVResults/";
        ```
        
    2. Or alternatively, replace 
    
        ```bash
        ImageJ --headless -macro particle_analysis_fixedDirectory.ijm
        ```
        
        with
        
        ```bash
        ImageJ -macro particle_analysis.ijm
        ```
        in `data_preparation.sh`. Then the path for `inputFolder` and `outputFolder` will need to be selected when prompted.

3. Run

   ```bash
   cd OralCellDataPreparation
   ./data_preparation.sh
   ```
   
   The focused patches will be generated in `/PATH_TO/OralCellDataPreparation/Patches/Z_focused/`.
   
   Or replace 
   
   ```bash
   nohup python3 select_focus.py >./nohup.out 2>./nohup.err &
   ```
   
   with
   
   ```bash
   ./select_focus_parallel.sh N
   ```
   
   to run in parallel, where input argument N is the number of processes.
   
   The progress bar is redirected in `/PATH_TO/OralCellDataPreparation/debugging/*.err`, together with the error messages.

## Known Problems

- There might be some "imread error". This is due to trying to read some corrupted images. They are handled by being ignored.

