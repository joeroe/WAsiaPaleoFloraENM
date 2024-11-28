# BadiaPaleoFloraENM

This package presents ecological niche models (ENM) of paleoflora in the *Badia*, focusing on taxa known to be exploited by Epipalaeolithic foragers in the region c. 14,500 BP.

The analysis is a work in progress.
See `analysis/analysis.Rmd`.

## Usage


### Large raster data

This analysis uses a number of large, remote raster files that cannot be conveniently packaged here in their original forms.
These include data from [Paleoclim](http://www.paleoclim.org), [SoilGrids](https://www.isric.org/explore/soilgrids), and [OpenTopography](https://opentopography.org) (NASADEM).
Please see the respective source repositories for license and usage information for this data.

For reproducibility, the cropped versions of these datasets used in the analysis are cached in the respective folders `analysis/data/derived_data/`.
The code used to acquire this data is found under `analysis/data/` and can be used to regenerated these files as long as the external APIs used are still working.

Reacquiring data from OpenTopography requires an API key specified in the environment variable `OPENTOPO_KEY`, which will be [automatically loaded](https://github.com/gaborcsardi/dotenv) from `/.env` if present.

## Citation

Preliminary results were presented at the 18th conference of the International Workgroup for Palaeoethnobotany (IWGP), Lecce, 3–8 June, 2019.

* Arranz-Otaegui, A., Roe, J., Pantos, G. A., Santana, J., Araus-Cabrera, J. L., Le Roux, P., & Richter, T. 2019. *Locally available or imported? Identifying the provenance of Natufian plant food and fuel resources at Shubayqa 1 (northeastern Jordan)*. Presented at the 18th conference of the International Workgroup for Palaeoethnobotany (IWGP), Lecce, 3–8 June.
