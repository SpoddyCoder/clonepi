## 1.7.0 (24th November 2018)

FEATURES:

 - added --services switch to automatically stop + start systemctl services

IMPROVEMENTS:

BUG FIXES:

 - fixed pre-sync hook not being called if the dest disk needs initialising


## 1.6.2 (19th July 2018)

FEATURES:

IMPROVEMENTS:

 - made installer more self-aware

BUG FIXES:

 - fixed bug where re-cloning loop device immediately after finishing previous clone could result in file not found error


## 1.6.1 (19th July 2018)

FEATURES:

 - optional trim of source disk for optimum compressed file output size

IMPROVEMENTS:

 - installer exit on update, to allow for updates to itself
 - run output
 - documentation

BUG FIXES:

 - fixed empty clone image file created even if not confirmed by user


## 1.6.0 (17th July 2018)

FEATURES:

 - optional gzip compression on clone to file

IMPROVEMENTS:

 - moved clone to file init to main clone process so it can be confirmed
 - hook-pre-sync & hook-post-sync switch params can be seperated by space to allows autopath completion
 - documentation
 - dev helpers

BUG FIXES:


## 1.5.3 (14th July 2018)

FEATURES:

IMPROVEMENTS:

 - formatting on help

BUG FIXES:


## 1.5.2 (14th July 2018)

FEATURES:

 - installer now checks config files versions and backs-up + updates them as necessary

IMPROVEMENTS:

 - installer outputs commands for installing missing dependencies
 - README

BUG FIXES:


## 1.5.1 (14th July 2018)

FEATURES:

IMPROVEMENTS:

 - show loop device deletion command on associated warning

BUG FIXES:

 - stop hook checks throwing error


## 1.5.0 (8th July 2018)

FEATURES:

IMPROVEMENTS:

 - moved pre & post sync hooks to switches, to allow for more flexible use (potential breaking change)

BUG FIXES:


## 1.4.3 (7th July 2018)

FEATURES:

IMPROVEMENTS:

 - include device/file being cloned to in --script mode output - v useful for cron logs!

BUG FIXES:

 - README typo in --ignore-warnings switch name


## 1.4.2 (7th July 2018)

FEATURES:

IMPROVEMENTS:

 - documentation
 - run output

BUG FIXES:


## 1.4.1 (7th July 2018)

FEATURES:

 - quiet mode, reduce run output to important messages & errors only

IMPROVEMENTS:

 - run output

BUG FIXES:

 - occasional fsyncing i/o errors when querying file image


## 1.4.0 (7th July 2018)

FEATURES:

 - clone to file

IMPROVEMENTS:

 - run output
 - warning handling

BUG FIXES:

 - timestamp at end of run changed for consistency


## 1.3.1 (4th July 2018)

FEATURES:


IMPROVEMENTS:

 - further refinement to EXPORT_PATH handling

BUG FIXES:


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


