
##### Querying database #####

if (!require("httr")) {
  install.packages("httr")
  library("httr")
}

url = 'https://beta.lobbyview.org/public/api/self_filed'

R <- POST(url = url, add_headers('Content-Type' = 'application/json'), 
          body = list('bvdid'='US360698440'), encode = "json", verbose())

##### Parsing json file #####

Company <- content(x = R, as = "parsed", type = "application/json")


##### Extracting data needed #####

Company_df <- data.frame(client_name = character(),
                         bvdid = character(),
                         naics = character(),
                         registrant = character(), 
                         year = numeric(),
                         issue_code = character(),
                         amount = numeric(),
                         report_type = character(),
                         stringsAsFactors=FALSE) 

report_types <- names(Company$results)
# loop through 'other' and 'self_filed'
for (report_type in report_types) {
  
  report <- Company$results[[report_type]]
  
  # loop through records in the report
  for (record in report) {
    
    client_name <- record$client_name
    bvdid <- record$client$bvdid
    naics <- record$client$naics
    registrant <- record$registrant
    year <- record$year
    
    num_issues <- length(record$issue_codes)
    
    # record total amount spent (if any)
    if (length(record$amount) == 0) {
      amount <- NA
    } else {
      # if there are issues reported
      if (num_issues > 0) {
        amount <- record$amount / num_issues
      } else {
        amount <- record$amount
      }
    }
    
    # loop through issues (if any)
    if (num_issues > 0) {
      for (issue_code in record$issue_codes) {
        Company_df <- rbind(Company_df, 
                            data.frame(client_name, bvdid, naics, 
                                       registrant, year, issue_code, 
                                       amount, report_type))
      }
    } else {
      Company_df <- rbind(Company_df, 
                          data.frame(client_name, bvdid, naics, 
                                     registrant, year, issue_code = 'None', 
                                     amount, report_type))
    } # end of issues

  }# end of records
  
} # end of reportss

head(Company_df)
dim(Company_df)
