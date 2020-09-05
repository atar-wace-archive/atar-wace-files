#GO TO `ALL/` AND FIND `root.json` FOR THE RESULTING FILE FROM THIS PROCESS.

You need to run get.sh for all directories to get the exams files for each subject for each year.
You can also manually add subject files through the PATCH/ directory

Old WACE system:
`WACE_DRAFT_CC/get.sh`
`WACE_old_09-10_CC/get.sh`
`WACE_old_09-15/get.sh`
`WACE_old_arc/get.sh`
New ATAR system:
`ATAR_sample/get.sh`
`ATAR/get.sh`

Next, run `overlap-resolve-09-10.sh` to resolve overlaps for the CC and scsa domain sources
Run `standdir.sh` to make the subject names standard
Run `make-links.sh` If you are NOT on windows, you need to replace `cmd //c mklink` with a symbolic link command of your choice

Finally, to make `root.json` use `make-tree.sh`
`root.json` will be in the `ALL/` directory

#Removed files
These files were deleted manually to make git happy.
```
rm WACE_DRAFT_CC/earth_and_environmental_science/The\ sample\ examination\ paper\,\ marking\ guidelines\ and\ mapping-to-the-grid\ have\ been\ sent\ to\ schools.\ They\ will\ be\ available\ on\ the\ website\ from\ 1\ July.
rm WACE_DRAFT_CC/english/2007\ WACE\ exam\ information\
rm WACE_DRAFT_CC/english/Support\ material\ -\ General\ marking\ guidelines\
rm WACE_DRAFT_CC/english_as_an_additional_languagedialect/The\ sample\ examination\ paper\,\ marking\ guidelines\ and\ mapping-to-the-grid\ have\ been\ sent\ to\ schools.\ They\ will\ be\ available\ on\ the\ website\ from\ 1\ July.
rm WACE_DRAFT_CC/mathematics_methods/To\ provide\ feedback\ on\ draft\ exams\ go\ to\ the\ jury\ report\ and\ responses\ section\ below.
rm WACE_DRAFT_CC/mathematics_specialist/To\ provide\ feedback\ on\ draft\ exams\ go\ to\ the\ jury\ report\ and\ response\ section\ below.
```
No `.sort` files were removed, so even if you rebuilt the `root.json`, these items would still persist due to the `.sort.` files not being manually deleted here.