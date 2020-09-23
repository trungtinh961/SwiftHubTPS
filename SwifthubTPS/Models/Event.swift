//
//  Event.swift
//  SwifthubTPS
//
//  Created by TPS on 9/4/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import Foundation
import ObjectMapper

enum EventType: String {
    case fork = "ForkEvent"
    case commitComment = "CommitCommentEvent"
    case create = "CreateEvent"
    case delete = "DeleteEvent"
    case issueComment = "IssueCommentEvent"
    case issues = "IssuesEvent"
    case member = "MemberEvent"
    case organizationBlock = "OrgBlockEvent"
    case `public` = "PublicEvent"
    case pullRequest = "PullRequestEvent"
    case pullRequestReviewComment = "PullRequestReviewCommentEvent"
    case push = "PushEvent"
    case release = "ReleaseEvent"
    case star = "WatchEvent"
    case unknown = ""
    case received = "received_events"
    case performed = "events"

}

/// Each event has a similar JSON schema, but a unique payload object that is determined by its event type.
struct Event: Mappable {

    var actor: User?
    var createdAt: Date?
    var id: String?
    var repository: Repository?
    var type: EventType = .unknown

    var payload: Payload?

    init?(map: Map) {}
    init() {}

    mutating func mapping(map: Map) {
        actor <- map["actor"]
        createdAt <- (map["created_at"], ISO8601DateTransform())
        id <- map["id"]
        repository <- map["repo"]
        type <- map["type"]

        payload = Mapper<Payload>().map(JSON: map.JSON)

        if let fullname = repository?.name {
            let parts = fullname.components(separatedBy: "/")
            repository?.name = parts.last
            repository?.owner = User()
            repository?.owner?.login = parts.first
            repository?.fullname = fullname
        }
    }
}

extension Event: Equatable {
    static func == (lhs: Event, rhs: Event) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Event {
    var title: String {
        var actionText: String = ""
        switch self.type {
        case .fork:
            actionText = "forked"
        case .create:
            let payload = self.payload as? CreatePayload
            actionText = ["created", (payload?.refType.rawValue ?? ""), (payload?.ref ?? ""), "in"].joined(separator: " ")
        case .delete:
            let payload = self.payload as? DeletePayload
            actionText = ["deleted", (payload?.refType.rawValue ?? ""), (payload?.ref ?? ""), "in"].joined(separator: " ")
        case .issueComment:
            let payload = self.payload as? IssueCommentPayload
            actionText = ["commented on issue", "#\(payload?.issue?.number ?? 0)", "at"].joined(separator: " ")
        case .issues:
            let payload = self.payload as? IssuesPayload
            actionText = [(payload?.action ?? ""), "issue", "in"].joined(separator: " ")
        case .member:
            let payload = self.payload as? MemberPayload
            actionText = [(payload?.action ?? ""), "\(payload?.member?.login ?? "")", "as a collaborator to"].joined(separator: " ")
        case .pullRequest:
            let payload = self.payload as? PullRequestPayload
            actionText = [(payload?.action ?? ""), "pull request", "#\(payload?.number ?? 0)", "in"].joined(separator: " ")
        case .pullRequestReviewComment:
            let payload = self.payload as? PullRequestReviewCommentPayload
            actionText = ["commented on pull request", "#\(payload?.pullRequest?.number ?? 0)", "in"].joined(separator: " ")
        case .push:
            let payload = self.payload as? PushPayload
            actionText = ["pushed to", payload?.ref ?? "", "at"].joined(separator: " ")
        case .release:
            let payload = self.payload as? ReleasePayload
            actionText = [payload?.action ?? "", "release", payload?.release?.name ?? "", "in"].joined(separator: " ")
        case .star:
            actionText = "starred"
        default: break
        }
        return [self.actor?.login ?? "", actionText, self.repository?.fullname ?? ""].joined(separator: " ")
    }
    
    var body: String {
        switch self.type {
        case .issueComment:
            let payload = self.payload as? IssueCommentPayload
            return payload?.comment?.body ?? ""
        case .issues:
            let payload = self.payload as? IssuesPayload
            return payload?.issue?.title ?? ""
        case .pullRequest:
            let payload = self.payload as? PullRequestPayload
            return payload?.pullRequest?.title ?? ""
        case .pullRequestReviewComment:
            let payload = self.payload as? PullRequestReviewCommentPayload
            return payload?.comment?.body ?? ""
        case .release:
            let payload = self.payload as? ReleasePayload
            return payload?.release?.body ?? ""
        default: return ""
        }
    }
    
    var badgeImage: String {
        switch self.type {
        case .fork:
            return ImageName.icon_cell_badge_fork.rawValue
        case .create:
            let payload = self.payload as? CreatePayload
            switch payload?.refType {
            case .repository:
                return ImageName.icon_cell_badge_repository.rawValue
            case .branch:
                return ImageName.icon_cell_badge_branch.rawValue
            case .tag:
                return ImageName.icon_cell_badge_tag.rawValue
            case .none:
                return ImageName.icon_cell_badge_repository.rawValue
            }
        case .delete:
            let payload = self.payload as? DeletePayload
            switch payload?.refType {
            case .repository:
                return ImageName.icon_cell_badge_repository.rawValue
            case .branch:
                return ImageName.icon_cell_badge_branch.rawValue
            case .tag:
                return ImageName.icon_cell_badge_tag.rawValue
            default:
                return ImageName.icon_cell_badge_repository.rawValue
            }
        case .issueComment:
            return ImageName.icon_cell_badge_comment.rawValue
        case .issues:
            return ImageName.icon_cell_badge_issue.rawValue
        case .member:
            return ImageName.icon_cell_badge_collaborator.rawValue
        case .pullRequest:
            return ImageName.icon_cell_badge_pull_request.rawValue
        case .pullRequestReviewComment:
            return ImageName.icon_cell_badge_comment.rawValue
        case .push:
            return ImageName.icon_cell_badge_push.rawValue
        case .release:
            return ImageName.icon_cell_badge_tag.rawValue
        case .star:
            return ImageName.icon_cell_badge_star.rawValue
        default:
            return ImageName.icon_cell_badge_repository.rawValue
        }
    }
}


class Payload: StaticMappable {
    
    required init?(map: Map) {}
    init() {}

    func mapping(map: Map) {}

    static func objectForMapping(map: Map) -> BaseMappable? {
        var type: EventType = .unknown
        type <- map["type"]
        switch type {
        case .fork: return ForkPayload()
        case .create: return CreatePayload()
        case .delete: return DeletePayload()
        case .issueComment: return IssueCommentPayload()
        case .issues: return IssuesPayload()
        case .member: return MemberPayload()
        case .pullRequest: return PullRequestPayload()
        case .pullRequestReviewComment: return PullRequestReviewCommentPayload()
        case .push: return PushPayload()
        case .release: return ReleasePayload()
        case .star: return StarPayload()
        default: return Payload()
        }
    }
}

class ForkPayload: Payload {

    var repository: Repository?

    override func mapping(map: Map) {
        super.mapping(map: map)

        repository <- map["payload.forkee"]
    }
}

enum CreateEventType: String {
    case repository
    case branch
    case tag
}

class CreatePayload: Payload {

    var ref: String?
    var refType: CreateEventType = .repository
    var masterBranch: String?
    var description: String?
    var pusherType: String?

    override func mapping(map: Map) {
        super.mapping(map: map)

        ref <- map["payload.ref"]
        refType <- map["payload.ref_type"]
        masterBranch <- map["payload.master_branch"]
        description <- map["payload.description"]
        pusherType <- map["payload.pusher_type"]
    }
}

enum DeleteEventType: String {
    case repository
    case branch
    case tag
}

class DeletePayload: Payload {

    var ref: String?
    var refType: DeleteEventType = .repository
    var pusherType: String?

    override func mapping(map: Map) {
        super.mapping(map: map)

        ref <- map["payload.ref"]
        refType <- map["payload.ref_type"]
        pusherType <- map["payload.pusher_type"]
    }
}

class IssueCommentPayload: Payload {

    var action: String?
    var issue: Issue?
    var comment: Comment?

    override func mapping(map: Map) {
        super.mapping(map: map)

        action <- map["payload.action"]
        issue <- map["payload.issue"]
        comment <- map["payload.comment"]
    }
}

class IssuesPayload: Payload {

    var action: String?
    var issue: Issue?
    var repository: Repository?

    override func mapping(map: Map) {
        super.mapping(map: map)

        action <- map["payload.action"]
        issue <- map["payload.issue"]
        repository <- map["payload.forkee"]
    }
}

class MemberPayload: Payload {

    var action: String?
    var member: User?

    override func mapping(map: Map) {
        super.mapping(map: map)

        action <- map["payload.action"]
        member <- map["payload.member"]
    }
}

class PullRequestPayload: Payload {

    var action: String?
    var number: Int?
    var pullRequest: PullRequest?

    override func mapping(map: Map) {
        super.mapping(map: map)

        action <- map["payload.action"]
        number <- map["payload.number"]
        pullRequest <- map["payload.pull_request"]
    }
}

class PullRequestReviewCommentPayload: Payload {

    var action: String?
    var comment: Comment?
    var pullRequest: PullRequest?

    override func mapping(map: Map) {
        super.mapping(map: map)

        action <- map["payload.action"]
        comment <- map["payload.comment"]
        pullRequest <- map["payload.pull_request"]
    }
}

class PushPayload: Payload {

    var ref: String?
    var size: Int?
    var commits: [Commit] = []

    override func mapping(map: Map) {
        super.mapping(map: map)

        ref <- map["payload.ref"]
        size <- map["payload.size"]
        commits <- map["payload.commits"]
    }
}

class ReleasePayload: Payload {

    var action: String?
    var release: Release?

    override func mapping(map: Map) {
        super.mapping(map: map)

        action <- map["payload.action"]
        release <- map["payload.release"]
    }
}

class StarPayload: Payload {

    var action: String?

    override func mapping(map: Map) {
        super.mapping(map: map)

        action <- map["payload.action"]
    }
}
