# Data and code for 'Biogeography of crop progenitors and wild plant resources in the terminal Pleistocene and Early Holocene of West Asia, 14.7–8.3 ka'

[![DOI](https://zenodo.org/badge/197202238.svg)](https://doi.org/10.5281/zenodo.14629984)

This research compendium contains the data and code accompanying our paper:

> Roe, Joe and Amaia Arranz-Otaegui, in prep. Biogeography of crop progenitors 
> and wild plant resources in the terminal Pleistocene and Early Holocene of 
> West Asia, 14.7–8.3 ka

It is a [Quarto manuscript](https://quarto.org/docs/manuscripts/) written in 
Markdown with embedded R code.

To rerender the manuscript (in PDF format), use `quarto render paper.qmd`.  
Executing the R code requires that R and the packages listed at the top of 
`paper.qmd` are installed.

## GBIF data

The GBIF occurrence data used in the published analysis can be accessed at <https://www.gbif.org/occurrence/download/0007320-250811113504898>. Download and copy this data to `analysis/data/derived_data/gbif/` to reproduce the analysis as-published.

If no GBIF data download is present, the script will reacquire it based on the given filters, but since GBIF is constantly updated, the result will probably differ.

Reacquiring data from GBIF via R requires credentials to be given as environment variables, which will be [automatically loaded](https://github.com/gaborcsardi/dotenv) from `/.env` if present. See rgbif's vignette, [Set Up Your GBIF Username and Password](https://docs.ropensci.org/rgbif/articles/gbif_credentials.html) for details.

## Large raster data

This analysis uses a number of large, remote raster files that cannot be conveniently packaged here in their original forms.
These include data from [Paleoclim](http://www.paleoclim.org), [SoilGrids](https://www.isric.org/explore/soilgrids), and [OpenTopography](https://opentopography.org) (SRTM DEM).
Please see the respective source repositories for license and usage information for this data.

Where possible, the cropped versions of these datasets used in the analysis are cached in the respective folders `analysis/data/derived_data/`.
The code used to acquire this data is found under `analysis/data/` and can be used to regenerated these files as long as the external APIs used are still working.

Reacquiring data from OpenTopography requires an API key specified in the environment variable `OPENTOPO_KEY`, which will be [automatically loaded](https://github.com/gaborcsardi/dotenv) from `/.env` if present.

## Citation

Preliminary results were presented at the 18th conference of the International Workgroup for Palaeoethnobotany (IWGP), Lecce, 3–8 June, 2019.

* Arranz-Otaegui, A., Roe, J., Pantos, G. A., Santana, J., Araus-Cabrera, J. L., Le Roux, P., & Richter, T. 2019. *Locally available or imported? Identifying the provenance of Natufian plant food and fuel resources at Shubayqa 1 (northeastern Jordan)*. Presented at the 18th conference of the International Workgroup for Palaeoethnobotany (IWGP), Lecce, 3–8 June.
