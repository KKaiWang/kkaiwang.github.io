## Load the package and read the file
if(!require(XML)){
      install.packages("XML", dep=TRUE);
      require(XML);
}
doc = xmlTreeParse('studentdata.xml');
root = xmlRoot(doc);

## Get the number of children of the root node
n = xmlSize(root);
print(n);

## Access the first child node of the root tag
student1 = root[[1]];
print(student1);

## Access each component of this node

## 1. Get node name
print( xmlName(student1) );

## 2. Get node attributes

### a. List all attributes of one node
print( xmlAttrs(student1) );

### b. Query specific attribute by name, 
###    assign NA as default value if this attribute does not exist
student1.attr = c();
student1.attr[1] = xmlGetAttr(student1, "SocialID", NA);
student1.attr[2] = xmlGetAttr(student1, "SchoolID", NA);
student1.attr[3] = xmlGetAttr(student1, "OfficeLocation", NA);
print( student1.attr );

### c. Get to the subchildren of student1 and extract their values
### The first subchild of student1
print( student1[[1]] );
### The above is not really what we desired,
### because we don't want the tag ``<name>'' to come along.
### Use ``xmlValue'' to strip the tag.
print( xmlValue(student1[[1]]) );
### or
print( xmlValue(student1[["name"]]) );
### Now, if we want the values of all children in one run
print( xmlSApply(student1, xmlValue) );

### d. Get node text without its children
### Look at student4
student4 = root[[4]];
### Want the words in the parenthesis but nothing else
### xmlValue with recursive turned off will work
print( xmlValue(student4, recursive=FALSE) );
### Alternatively, we can use xmlChildren
print( xmlChildren(student4) );
print( xmlChildren(student4)$text );

### e.  A more complicated example

### Goal: we want to extract some attributes and elements from the XML file
###       and compile them into a table.
### Variables that we want: attributes: SchoolID
###                         child tags: name, major, minor(if exist), hobby(if exist)

QueriedTable = t(as.data.frame(xmlSApply(
      root,
      function(x) list(
            SchoolID = as.integer( xmlGetAttr(x, "SchoolID") ),
            Name     = xmlValue(x[["name"]]),
            Major    = xmlValue(x[["major"]]),
            Minor    = xmlValue(x[["minor"]]),
            Hobby    = xmlValue(x[["hobby"]])
            )
      )
));
print( QueriedTable );

### f. Exercises
### Run the following code to load the file:
doc2 = xmlTreeParse('METriology.xml');
root2 = xmlRoot(doc2);
### Question 1: Return all listed locations in the game Mass Effect 1 as a vector or a list

### Question 2: Report all listed characters in all Mass Effect franchise. Take a union across all Mass Effect games.
### Hint for Question 2: use ``unlist'' to convert a nested list to a vector, and then use ``unique''.







