[![MATLAB FEX](https://img.shields.io/badge/MATLAB%20FEX-mlapp2classdef-brightgreen.svg)](http://www.mathworks.com/matlabcentral/fileexchange/56237-mlapp2classdef) ![Minimum Version](https://img.shields.io/badge/Requires-R2009b%20%28v7.9%29-orange.svg)

# mlapp2classdef

MLAPP2CLASSDEF converts an App Designer GUI's class definition, packaged as a `*.mlapp` file, from XML to a standalone `*.m` class definition.

The class definition for an App Designer GUI is embedded in an XML file located in a subfolder of the packaged `*.mlapp` file, which can be accessed like a `*.zip` file. MLAPP2CLASSDEF strips the XML header & footer and saves the class definition to a `*.m` file located in the same path as the `*.mlapp` file.

## Syntax

`MLAPP2CLASSDEF()` prompts the user to select `*.mlapp` file(s) for processing. Selection of multiple files in the same directory is supported.

`MLAPP2CLASSDEF(pathToMLapp)` processes the files specified by the user. `pathToMLapp` can be a string for a single file or a cell array of strings for multiple files. Filepaths should be absolute.

`MLAPP2CLASSDEF(..., 'ReplaceAppUI', flag)` allows the user to specify whether to replace App Designer UI elements with their "regular" MATLAB equivalents (e.g. App Designer uses `uifigure` where MATLAB uses `figure`). `flag` is a boolean value whose default is `false`. To prompt the user to select a `*.mlapp` file with this syntax, pass an empty first argument (e.g. `MLAPP2CLASSDEF([], 'ReplaceAppUI', True)`).

### Examples

    % MATLAB prompts user for file(s) to process:
    mlapp2classdef()

    % Process single user specified file:
    myguipath = 'C:\myfolder\mygui.mlapp';  % A single cell is also supported
    mlapp2classdef(myguipath)

    % Process multiple user specified files:
    myguipaths = {'C:\myfolder\mygui.mlapp', 'C:\myfolder\mygui2.mlapp'};
    mlapp2classdef(myguipaths)

    % Prompt user for file(s), replacing UI elements:
    mlapp2classdef([], 'ReplaceAppUI', true)

    % Process multiple user specified files, replacing UI elements:
    myguipaths = {'C:\myfolder\mygui.mlapp', 'C:\myfolder\mygui2.mlapp'};
    mlapp2classdef(myguipaths, 'ReplaceAppUI', true)

# Current Limitations

MLAPP2CLASSDEF assumes that the targeted `*.mlapp` file is a GUI created by MATLAB's App Designer. Other packaged apps are not explicitly supported.

Structure of the packaged `*.mlapp` file is assumed to be a constant (e.g. `~\matlab\document.xml` is the path to the class definition XML)

Replacement of App Designer specific GUI elements with their "regular" MATLAB equivalents is a work in progress. See the below table for a description of UI element support.

UI Element    | App Designer Function | "Regular" MATLAB Function            | Conversion Supported | Caveats
:-----------: | :-------------------: | :----------------------------------: | :------------------: | :-----:
Figure        | `uifigure`            | `figure`                             | No                   | N/A    
Axes          | `uiaxes`              | `axes`                               | No                   | N/A    
Button        | `uibutton`            | `uicontrol('Style', 'pushbutton')`   | No                   | N/A    
Checkbox      | `uicheckbox`          | `uicontrol('Style', 'checkbox')`     | No                   | N/A    
Edit Box      | `uieditfield`         | `uicontrol('Style', 'edit')`         | No                   | N/A    
Text Label    | `uilabel`             | `uicontrol('Style', 'text')`         | No                   | N/A    
List Box      | `uilistbox`           | `uicontrol('Style', 'listbox')`      | No                   | N/A    
Radio Button  | `uiradiobutton`       | `uicontrol('Style', 'radiobutton')`  | No                   | N/A    
Slider        | `uislider`            | `uicontrol('Style', 'slider')`       | No                   | N/A    
Toggle Button | `uitogglebutton`      | `uicontrol('Style', 'togglebutton')` | No                   | N/A    
Spinner       | `uispinner`           | N/A                                  | No                   | N/A    
Text Area     | `uitextarea`          | N/A                                  | No                   | N/A    
Gauge         | `uigauge`             | N/A                                  | No                   | N/A    
Knob          | `uiknob`              | N/A                                  | No                   | N/A    
Lamp          | `uilamp`              | N/A                                  | No                   | N/A    
Switch        | `uiswitch`            | N/A                                  | No                   | N/A    
UI Alert      | `uialert`             | N/A                                  | No                   | N/A    
