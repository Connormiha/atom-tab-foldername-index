## 3.2.2
Minor fixes after eslint  
Add Travis for ci  
Add eslint, coffeelint  
Fix some broken tests after Atom 1.21  

## 3.2.1
Bugfix: Fix work on Windows.[`#7`][]  

[`#7`]: https://github.com/Connormiha/atom-tab-foldername-index/pull/7

## 3.2.0
Bugfix: Italic font style after opening tab. (After 3.1.0)  

## 3.1.0
Feature: Add support for file-icons package [`#6`][]  
Feature: Adding setting that allows users to specify the number of folders they wish to display [`#5`][]  

[`#6`]: https://github.com/Connormiha/atom-tab-foldername-index/pull/6
[`#5`]: https://github.com/Connormiha/atom-tab-foldername-index/pull/5

## 3.0.0
Added feature: styled tabs with equal names.  
For example: when opened 2 and more files with same name but from different folders it will styled always(even if name doesn't match pattern index.* ).

## 2.0.3
Minor bug fixes

## 2.0.2
Fix reset style after drag'n drop tab from other panel

## 2.0.1
Minor fix with disabled mode

## 2.0.0
Fixed bug with opening image file  
Add support for split panel when opened equal tabs

## 1.0.1
Minor fixes

## 1.0.0
Migrate from CoffeeScript to ES2015
Some changes for index.* detected

## 0.3.2
Minor optimizations

## 0.3.1
Minor optimizations

## 0.3.0
Add support for `__init__.py`, `__init__.php` files.  
Change detecting for `index`. Now ignore filename with several dots (example `index.htmltemplate.js`), But `index.test.*`, `index.spec.*` still work

## 0.2.5
Add VCS coloring if this enabled in Tabs package

## 0.2.4
bugfix: folder with a long name is truncated

## 0.2.3
hotfix: temporary fix for error message when close tabs

## 0.2.2
hotfix: wrong render tab after file rename, if packages was toggled to disable (by menu)

## 0.2.1
Minor fixes

## 0.2.0
Typo fixes  
Implements deactivate

## 0.1.0 - First Release
