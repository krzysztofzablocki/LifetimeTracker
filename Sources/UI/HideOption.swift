//
//  HideOption.swift
//  LifetimeTracker-iOS
//
//  Created by Thanh Duc Do on 29.08.18.
//  Copyright © 2018 LifetimeTracker. All rights reserved.
//

enum HideOption {
    case untilMoreIssue
    case untilNewIssueType
    case always
    case none

    func shouldUIBeShown(oldModel: BarDashboardViewModel, newModel: BarDashboardViewModel) -> Bool {
        switch self {
        case .untilMoreIssue:
            if oldModel.leaksCount < newModel.leaksCount {
                return true
            }
            return false
        case .untilNewIssueType:
            var oldGroupModelTitleSet =  Set<String>()
            for oldGroupModel in oldModel.sections {
                oldGroupModelTitleSet.insert(oldGroupModel.groupName)
            }

            for newGroupModel in newModel.sections {
                if !oldGroupModelTitleSet.contains(newGroupModel.groupName) && newGroupModel.entries.count > newGroupModel.entries.capacity {
                    return true
                } else if let oldGroupModel = oldModel.sections.first(where: { (groupModel: GroupModel) -> Bool in
                    groupModel.groupName == newGroupModel.groupName
                }) {
                    if oldGroupModel.groupCount<=oldGroupModel.groupMaxCount && newGroupModel.groupCount>newGroupModel.groupMaxCount {
                        return true
                    }
                }
            }
            return false
        default:
            return false
        }
    }
}
