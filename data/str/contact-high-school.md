# Contacts - high school

This dataset is constructed from a contact network amongst high school students
in Marseilles, France, in December 2013. The contact network was downloaded from

http://www.sociopatterns.org/datasets/high-school-contact-and-friendship-networks/

We form simplices through cliques of simultaneous contacts. Specifically, for
every unique timestamp in the dataset, we construct a simplex for every maximal
clique amongst the contact edges that exist for that timestamp. Timestamps were
recorded in 20 second intervals.

```
List of 5
 $ format: chr "hypernets"
 $ info  :List of 10
  ..$ network: chr "contact-high-school"
  ..$ title  : chr "ARB: contact-high-school dataset"
  ..$ by     : chr "Rossana Mastrandrea, Julie Fournet, and Alain Barrat"
  ..$ ref    : chr "Mastrandrea, etal: Contact Patterns in a High School. PLOS ONE, 2015"
  ..$ href   : chr "https://www.cs.cornell.edu/~arb/data/contact-high-school/"
  ..$ creator: chr "V. Batagelj"
  ..$ date   : chr "Tue Oct 17 18:39:22 2023"
  ..$ nNodes : int 327
  ..$ nLinks : int 172035
  ..$ simple : logi NA
 $ nodes :'data.frame': 327 obs. of  1 variable:
  ..$ ID: chr [1:327] "v1" "v2" "v3" "v4" ...
 $ links :'data.frame': 172035 obs. of  3 variables:
  ..$ ID: chr [1:172035] "e1" "e2" "e3" "e4" ...
  ..$ T : int [1:172035] 1385982020 1385982020 1385982020 1385982020 1385982020 ...
  ..$ E :List of 172035
  .. ..$ : int [1:2] 2 1
  .. ..$ : int [1:2] 9 11
  .. ..$ : int [1:2] 40 39
  .. .. [list output truncated]
 $ data  : list()
```
