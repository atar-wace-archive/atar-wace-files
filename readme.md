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