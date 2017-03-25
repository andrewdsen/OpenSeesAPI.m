# OpenSeesAPI.m
OpenSees API for MATLAB

Quick start guide:
1. Add OpenSees API folder to your MATLAB path. For example, 
```
addpath ../OSAPI/
```
2. Create a database object. For example, 
```
db = database('MyModel', 'MyName', 'MyTCLFile')
```
3. Add nodes, materials, elements, etc. to the database object. For example,
```
db.addNode( MyNode )
db.addElement( MyElement )
```
4. Compile the database into a script using the `write` method. Note that this does not create the TCL file.
```
db.write;
```
5. Execute the script using `exec`. You need to make sure that *OpenSees* is on either MATLAB's path or your system's path. Specify your version of *OpenSees* as either `reg` for regular, `SP` for *OpenSeesSP*, or `MP` for *OpenSeesMP*. For example,
```
exec(db, 'SP');
```
