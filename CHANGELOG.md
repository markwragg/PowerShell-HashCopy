# Change Log

## [1.0.57] - 2023-07-02

* [Feature] `Compare-FileHash` now has the same `-Exclude` parameter that was added to `Copy-FileHash` for excluding one or more files from the comparison.

## [1.0.56] - 2023-06-28

* [Feature] `Copy-FileHash` now has an `-Exclude` parameter that can be used to exclude one or more files from being copied. Thanks [@shayki5](https://github.com/shayki5)!

## [1.0.55] - 2020-02-25

* [Feature] `Copy-FileHash` now has a `-Mirror` parameter that can be used to remove any files from the Destination folder that are not in the Source path ([#5](https://github.com/markwragg/PowerShell-HashCopy/issues/5)). This has had limited testing so use with caution, always check `-WhatIf` first.

## [1.0.54] - 2020-02-21

* [Feature] `Copy-FileHash` can now accept an array of file paths rather than just directory paths. Thanks [@Marc05](https://github.com/Marc05)!

## [1.0.53] - 2019-09-09

* Testing new deployment pipeline.
