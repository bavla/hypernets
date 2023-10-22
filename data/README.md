# Datasets

| Network | Nodes | nNodes | Links | nLinks | Structure |
| :---         |     :---       |      :---:   |     :---       |      :---:   |      :---:   |
| [Simple example](https://raw.githubusercontent.com/bavla/hypernets/main/data/ex.json)   | nodes    | 5  | links  | 3     | [str](https://github.com/bavla/hypernets/blob/main/data/str/ex.md)     |
| [Zoo](https://raw.githubusercontent.com/bavla/hypernets/main/data/Zoo.json)   | properties    | 15  | animals  | 101     | [str](https://github.com/bavla/hypernets/blob/main/data/str/Zoo.md)     |
| [Cooking](https://raw.githubusercontent.com/bavla/hypernets/main/data/Zoo.json)   | ingredients    | 6759  | recipes  | 39774     | [str](https://github.com/bavla/hypernets/blob/main/data/str/Cooking.md)     |
| [Contacts-high school](https://raw.githubusercontent.com/bavla/hypernets/main/data/contact-high-school.json)   | students    | 327  | contacts  | 172035   | [str](https://github.com/bavla/hypernets/blob/main/data/str/contact-high-school.md)     |
| [FB resources](https://raw.githubusercontent.com/bavla/hypernets/main/data/FB_resources.json)   | resources    | 293  | countries  | 237   | [str](https://github.com/bavla/hypernets/blob/main/data/str/FB_resources.md)     |



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
