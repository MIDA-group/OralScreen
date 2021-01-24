inputFolder="PredMasks/";
//inputFolder=getDirectory("Choose input folder of predicted masks");
outputFolder="CSVResults/";
//outputFolder=getDirectory("Choose output folder for the results");
list=getFileList(inputFolder);

run("Set Measurements...", "area centroid redirect=None decimal=3");

for(i=0; i<list.length; i++) {
	path=inputFolder+list[i];
	if(endsWith(path,".jpg")) {
		IJ.log("Processing ("+i+"/"+list.length+"): "+path);
		showProgress(i, list.length); 

		open(path);
		if(nImages>=1) {
			setAutoThreshold("Default dark no-reset");
			//run("Threshold...");
			run("Analyze Particles...", "display clear"); //can be adjusted to "clear previous results"
			//selectWindow("Results");
			//The following two lines removes the file extension
			i_img_name = indexOf(list[i], "_pred");
			img_name = substring(list[i], 0, i_img_name);
			saveAs("Results",outputFolder + img_name + ".csv");
			close();
		}
	}
}

