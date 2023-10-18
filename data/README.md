# Datasets

| Network | Nodes | nNodes | Links | nLinks | Structure |
| :---         |     :---       |      :---:   |     :---       |      :---:   |      :---:   |
| [Zoo](https://raw.githubusercontent.com/bavla/hypernets/main/data/Zoo.json)   | properties    | 15  | animals  | 101     | [str](https://github.com/bavla/hypernets/blob/main/data/str/Zoo.md)     |

In R, we can read a hypernets JSON file directly from the GitHub
```
> library(jsonlite)
> wdir <- "C:/test/data/hyper"
> setwd(wdir)
> hfile <- "https://raw.githubusercontent.com/bavla/hypernets/main/data/Cooking.json"
> HN <- fromJSON(hfile)
> str(HN)
```
Larger hypernets files are ZIPed. We can read them directly using [getZip](https://search.r-project.org/CRAN/refmans/Hmisc/html/getZip.html)
```
> library(jsonlite)
> library(Hmisc)
> wdir <- "C:/test/data/hyper"
> setwd(wdir)
> hfile <- "https://raw.githubusercontent.com/bavla/hypernets/main/data/Cooking.zip"
> H <- fromJSON(getZip(hfile))
> str(H)
```
