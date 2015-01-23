// Playground - noun: a place where people can play

import Foundation
//
//let overallProgress = NSProgress(totalUnitCount: 100)
//let otherProgress = NSProgress(totalUnitCount: 100)
//
//overallProgress.becomeCurrentWithPendingUnitCount(50)
//
//let firstTaskProgress = NSProgress(totalUnitCount: 10)
//otherProgress.completedUnitCount = 5
//overallProgress.resignCurrent()
//firstTaskProgress.completedUnitCount = 5
//firstTaskProgress.fractionCompleted
//firstTaskProgress.becomeCurrentWithPendingUnitCount(5)
//let secondTaskProgress = NSProgress(totalUnitCount: 10)
////let thirdTaskProgress = NSProgress(totalUnitCount: 10)
////let forthTaskProgress = NSProgress(totalUnitCount: 10)
//firstTaskProgress.resignCurrent()
//secondTaskProgress.completedUnitCount = 5
//firstTaskProgress.fractionCompleted
//overallProgress.fractionCompleted
//otherProgress.completedUnitCount = 10
//secondTaskProgress.completedUnitCount = 10
//firstTaskProgress.fractionCompleted
//overallProgress.fractionCompleted
//NSProgress.currentProgress()
//
//overallProgress.fractionCompleted



let overallProgress = NSProgress(totalUnitCount: 100)

overallProgress.becomeCurrentWithPendingUnitCount(100)
let firstTaskProgress = NSProgress(totalUnitCount: 10)
//overallProgress.resignCurrent()
//overallProgress.becomeCurrentWithPendingUnitCount(100)
let secondTaskProgress = NSProgress(totalUnitCount: 10)
overallProgress.resignCurrent()

firstTaskProgress.completedUnitCount = 5
overallProgress.fractionCompleted
secondTaskProgress.completedUnitCount = 5
overallProgress.fractionCompleted
firstTaskProgress.completedUnitCount = 10
overallProgress.fractionCompleted