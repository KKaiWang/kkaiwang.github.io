## Load the RSQLite package (install it first if haven't yet)
#install.packages("RSQLite", dep=TRUE);
library("RSQLite");
## Make sure the file is under the working directory and then connect to it
driver = dbDriver("SQLite");
conn = dbConnect(driver, "baseball.db");
## Check the tables in a database
dbListTables(conn);
## Check the variables in a table
dbListFields(conn, "Teams");

#### Quiz 1
dt1 = dbGetQuery(conn,"SELECT * FROM Master WHERE birthYear>1979 AND birthYear<1990 
                 ORDER BY nameLast, nameFirst;")

#### Quiz 2
dt2 = dbGetQuery(conn, "SELECT yearID AS year, COUNT(teamID) AS NumberNetWinTeams FROM Teams 
                 WHERE W>L GROUP BY yearID HAVING yearID >= 1950 ORDER BY yearID;")

#### Example
dt3 = dbGetQuery(conn,"SELECT Schools.schoolID, schoolName, schoolCity, schoolState, playerID 
                 FROM Schools INNER JOIN SchoolsPlayers ON Schools.schoolID = SchoolsPlayers.schoolID 
                 WHERE schoolState = 'MI';")

#### Quiz 3
dt4 = dbGetQuery(conn,"SELECT Schools.schoolID, schoolName, COUNT(playerID) AS NumOfPlayers 
                 FROM Schools INNER JOIN SchoolsPlayers ON Schools.schoolID = SchoolsPlayers.schoolID 
                 WHERE schoolState = 'MI' GROUP BY Schools.schoolID ORDER BY NumOfPlayers DESC")