# apple-watch

Analyses using Apple Watch data

## Prep data

Download the data from the Apple Health app on your iPhone. You can do this by going to the Health app, clicking on your profile picture in the top right corner, and selecting "Export All Health Data". This will create a zip file that you can share with yourself. Download the zip file and extract the contents. The important file in this extract is `export.xml`. I have this file saved in a folder `data/apple_health_export` in this repository. I have the `data` folder in the `.gitignore` file so that the data is not uploaded to this GitHub repository.

To convert the `export.xml` file to a CSV file, I found this [great resource](https://gist.github.com/hoffa/936db2bb85e134709cd263dd358ca309) with sample code. I've copied their parsing function to `convert_xml_to_csv.py` in this repository.

To see the xml data as json within the terminal, run the following command in the Terminal:

``` bash
python convert_xml_to_csv.py data/apple_health_export/export.xml
```

To convert the xml data to a csv file, run the following command in the Terminal:

``` bash
python convert_xml_to_csv.py data/apple_health_export/export.xml | jq -r '[.endDate, .type, .unit, .value] | @csv' > data/apple_health_export/export.csv
```

This requires the JSON parser `jq` to be installed. I [installed jq via Homebrew](https://stackoverflow.com/questions/37668134/how-to-install-jq-on-mac-on-the-command-line) on my Mac with: `brew install jq`.
