app <- ShinyDriver$new("/R/clean_cap_df/")
app$snapshotInit("mytest_clean")

app$uploadFile(file1 = "Data/perguntas_cap_pt.csv") # <-- This should be the path to the file, relative to the app's tests/ directory
app$setInputs(choice = "click")
# Input 'contents_rows_current' was set, but doesn't have an input binding.
# Input 'contents_rows_all' was set, but doesn't have an input binding.
# Input 'contents2_rows_current' was set, but doesn't have an input binding.
# Input 'contents2_rows_all' was set, but doesn't have an input binding.
app$setInputs(column1 = "title")
# Input 'contents2_rows_current' was set, but doesn't have an input binding.
# Input 'contents2_rows_all' was set, but doesn't have an input binding.
app$setInputs(column2 = "year")
# Input 'contents2_rows_current' was set, but doesn't have an input binding.
# Input 'contents2_rows_all' was set, but doesn't have an input binding.
app$setInputs(column3 = "major_code")
# Input 'contents2_rows_current' was set, but doesn't have an input binding.
# Input 'contents2_rows_all' was set, but doesn't have an input binding.
app$setInputs(column4 = "major_code")
# Input 'contents2_rows_current' was set, but doesn't have an input binding.
# Input 'contents2_rows_all' was set, but doesn't have an input binding.
app$setInputs(column4 = "")
app$setInputs(column4 = "major_code")
# Input 'contents2_rows_current' was set, but doesn't have an input binding.
# Input 'contents2_rows_all' was set, but doesn't have an input binding.
app$setInputs(column4 = "minor_code")
# Input 'contents2_rows_current' was set, but doesn't have an input binding.
# Input 'contents2_rows_all' was set, but doesn't have an input binding.
app$setInputs(check = "click")
# app$snapshotDownload("downloadwrong")
app$setInputs(title = "Try")
app$setInputs(id_text = "I")
app$setInputs(id_text = "ID")
app$setInputs(format = "HTML")
# app$snapshotDownload("downloadReport")
# app$snapshotDownload("downloadData")

