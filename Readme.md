[![MATLAB FEX](https://img.shields.io/badge/MATLAB%20FEX-mlapp2classdef-brightgreen.svg)](http://www.mathworks.com/matlabcentral/fileexchange/56237-mlapp2classdef) ![Minimum Version](https://img.shields.io/badge/Requires-R2009b%20%28v7.9%29-orange.svg)

# mlapp2classdef

MLAPP2CLASSDEF converts an App Designer GUI's class definition, packaged as a `*.mlapp` file, from XML to a standalone `*.m` class definition.

The class definition for an App Designer GUI is embedded in an XML file located in a subfolder of the packaged `*.mlapp` file, which can be accessed like a `*.zip` file. MLAPP2CLASSDEF strips the XML header & footer and saves the class definition to a `*.m` file located in the same path as the `*.mlapp` file.

## Syntax

`MLAPP2CLASSDEF()` prompts the user to select a single `*.mlapp` file for processing

`MLAPP2CLASSDEF(pathToMLapp)` processes the files specified by the user. `pathToMLapp` can be a string for a single file or a cell array of strings for multiple files. Filepaths should be absolute.

### Examples

    # MATLAB prompts user for file to processe
    mlapp2classdef()

    # Process single user specified file:
    myguipath = 'C:\myfolder\mygui.mlapp';
    mlapp2classdef(myguipath)

    # Process multiple user specified files:
    myguipaths = {'C:\myfolder\mygui.mlapp', 'C:\myfolder\mygui2.mlapp'};
    mlapp2classdef(myguipaths)

# Current Limitations

MLAPP2CLASSDEF assumes that the targeted `*.mlapp` file is a GUI created by MATLAB's App Designer. Other packaged apps are not explicitly supported.

Structure of the packaged `*.mlapp` file is assumed to be a constant (e.g. `~\matlab\document.xml` is the path to the class definition XML)
