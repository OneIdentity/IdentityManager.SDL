**One Identity open source projects are supported through [One Identity GitHub issues](https://github.com/OneIdentity/ars-ps/issues) and the [One Identity Community](https://www.oneidentity.com/community/). This includes all scripts, plugins, SDKs, modules, code snippets or other solutions. For assistance with any One Identity GitHub project, please raise a new Issue on the [One Identity GitHub project](https://github.com/OneIdentity/ars-ps/issues) page. You may also visit the [One Identity Community](https://www.oneidentity.com/community/) to ask questions.  Requests for assistance made through official One Identity Support will be referred back to GitHub and the One Identity Community forums where those requests can benefit all users.**

# One Identity Manager Software Distribution Module

## Preparing the environment

* Prepare the build structure by running the `prepare.ps1` script from an **administrative** command prompt.
  Use a version 7.1 delivery folder including MDK as parameter.

    ```powershell
    prepare.ps1 -delivery <Path to delivery>
    ```

* Install Devart dotConnect for Oracle, if the resulting EXEs should be run against Oracle databases.

## Building

* Open a Developer Command Prompt for VS 2017
* Build using [MSBuild](https://docs.microsoft.com/en-us/visualstudio/msbuild/msbuild):
    ```powershell
    msbuild SDL\Build.proj
    ```
* The results can be found in the `Delivery` folder.

Version numbers can be set globally in `SDL\GlobalVersion.cs`.

## Master database handling

### Install a master database

#### Create master database automatically

* Open a Developer Command Prompt for VS 2017
* Change to folder `SDL\Database\Scripts`
* Create the database, the `Initial Catalog` property of the connection string has to contain the name of the database to be created:
  ```powershell
  msbuild MasterDB.proj /T:CreateMasterDb /P:ConnStr="Data Source=server;Initial Catalog=db;User ID=user;Password=pwd" 
  ```

#### Create master database manually 

* Install a database with modules `ACN ADS APC ATT CAP CPL DPR HDS LDP MDK POL QBM QER RMB RMS RPS SDL TSB`
* Change field `DialogDatabase.ModuleOwner` to `SDL`
* Do the [Prepare](#prepare) step

### <a name="prepare">Prepare an existing master database for changes</a>

* Open a Developer Command Prompt for VS 2017
* Change to folder `SDL\Database\Scripts`
* Run imports and master migration
  ```powershell
  msbuild MasterDB.proj /T:Prepare /P:ConnStr="Data Source=server;Initial Catalog=db;User ID=user;Password=pwd" 
  ```

### Create SQL files for delivery

* Open a Developer Command Prompt for VS 2017
* Change to folder `SDL\Database\Scripts`
* Update the `ModuleInfo.xml` in `QBMModuleDef.ModuleInfoXML`, if the file has changed
  ```powershell
  msbuild MasterDB.proj /T:UpdateModuleInfo /P:ConnStr="Data Source=server;Initial Catalog=db;User ID=user;Password=pwd" 
  ```
* Dump the master database changes to files
  ```powershell
  msbuild MasterDB.proj /T:Dump /P:ConnStr="Data Source=server;Initial Catalog=db;User ID=user;Password=pwd" 
  ```
