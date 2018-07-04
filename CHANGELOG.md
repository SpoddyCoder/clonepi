## 1.3.0 (4th July 2018)

FEATURES:

 - added --version switch

IMPROVEMENTS:

 - moved WAIT_BEFORE_UNMOUNT from config to --wait-before-unmount switch as more convenient (potential breaking change)
 - additional check that PATH is not set before setting it via EXPORT_PATH, enable it by default in conf (potential breaking change)
 - removed most shorthand switches because they are potentially confusing & therefore dangerous (they were undocumented for this reason and therefore this is not considered a potential breaking change)
 - documentation

BUG FIXES:


## 1.2.2 (4th July 2018)

FEATURES:


IMPROVEMENTS:


BUG FIXES:

 - added missed conf var


## 1.2.1 (4th July 2018)

FEATURES:

 - added EXPORT_PATH config var - makes running from cron easy

IMPROVEMENTS:


BUG FIXES:


## 1.2.0 (3rd July 2018)

FEATURES:


IMPROVEMENTS:

 - moved EXIT_ON_WARNING from config to --ignore-warnings switch as more convenient (potential breaking change)
 - run output
 - documentation
 - reversed CHANGELOG order to list latest first

BUG FIXES:

 - removed erroneous exit


## 1.1.0 (3rd July 2018)

FEATURES:

 - added --script mode

IMPROVEMENTS:

 - changed rsync switch names to avoid confusion as to their purpose (potential breaking change)
 - documentation

BUG FIXES:

 - fixed silly typo in run output


## 1.0.3 (2nd July 2018)

FEATURES:

 - UUID device lookup

IMPROVEMENTS:

 - documentation

BUG FIXES:



## 1.0.2 (18th June 2017)

FEATURES:

 - Initial release

IMPROVEMENTS:


BUG FIXES:


