getData <- function(project, dataset) 
{
    if (project=="US" & dataset=="hearings") {
      as.data.frame(read.csv(text=getURL("http://comparativeagendas.s3.amazonaws.com/datasetfiles/congressional_hearings.csv")))
     } else {
    print("No dataset found matching those parameters.")
    }
}

#getData <- function(project, dataset) 
#{
#    print("test")
#    print(project)
#    print(dataset)
#}