# Cooking

Original data obtained from the What's Cooking Kaggle competition:

https://www.kaggle.com/c/whats-cooking

Here nodes are ingredients, hyperedges corresponds to recipes and hyperedge
categories correspond to one of 20 different types of cuisine.

```
List of 5
 $ format: chr "hypernets"
 $ info  :List of 9
  ..$ network: chr "cat-edge-Cooking"
  ..$ title  : chr "ARB: cat-edge-Cooking dataset"
  ..$ by     : chr "Austin R. Benson"
  ..$ href   : chr [1:2] "https://www.cs.cornell.edu/~arb/data/" "https://www.kaggle.com/c/whats-cooking"
  ..$ creator: chr "V. Batagelj"
  ..$ date   : chr "Wed Oct 18 04:46:56 2023"
  ..$ nNodes : int 6759
  ..$ nLinks : int 39774
  ..$ simple : logi NA
 $ nodes :'data.frame': 6759 obs. of  1 variable:
  ..$ ID: chr [1:6759] "ginger paste" "sea salt" "shortbread" "chocolate" ...
 $ links :'data.frame': 39774 obs. of  3 variables:
  ..$ ID: chr [1:39774] "e1" "e2" "e3" "e4" ...
  ..$ T : int [1:39774] 16 9 4 6 6 19 17 20 7 20 ...
  ..$ E :List of 39774
  .. ..$ : int [1:9] 5930 3243 3671 252 2291 1910 4243 2095 5046
  .. ..$ : int [1:11] 1979 1810 4799 5176 3494 836 4905 5565 2454 3689 ...
  .. ..$ : int [1:12] 4905 2291 4799 2387 2440 5635 6530 3311 3013 4578 ...
  .. ..$ : int [1:4] 4910 5990 4215 4799
  .. ..$ : int [1:20] 3240 1327 345 4447 678 2524 3689 4335 4799 6428 ...
  .. .. [list output truncated]
 $ data  :List of 1
  ..$ cuisine: chr [1:20] "korean" "russian" "vietnamese" "filipino" ...
```
