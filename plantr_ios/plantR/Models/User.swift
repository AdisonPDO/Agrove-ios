//
//  User.swift
//  plantR_ios
//
//  Created by Rabissoni on 21/01/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import Firebase

private enum UserConsts {
    static let RootNode = "users"
    static let Metadata = "metadata"
    static let Rank = "rank"
    static let GardenersGuest = "gardenersGuest"
    static let CurrentGardener = "currentGardener"
    static let Gardeners = "gardeners"
    static let ProfileImage = "profile.jpg"
    static let Images = "images"
    static let Invited = "invited"
    static let AddToOwners = "addToOwners"
}

protocol UserTransformer {
    func toUserModel(snap: DataSnapshot) -> UserModel
    func toUserMetadataModel(_ metaDict: [String: Any]) -> UserMetadataModel
    func toDictonary(_ userModel: UserModel) -> [String: Any]
    func toDictonary(_ userMetadataModel: UserMetadataModel) -> [String: Any]
}

class UserTransformerImpl: UserTransformer {

    private enum Consts {
        static let FirstName = "firstName"
        static let LastName = "lastName"
    }

    func toUserModel(snap: DataSnapshot) -> UserModel {
        let dict = snap.value as! [String: Any]
        let metaDict = dict[UserConsts.Metadata] as! [String: Any]
        let rank: Rank
        if let rankRawValue = dict[UserConsts.Rank] as? Int, let noOptionalRank = Rank(rawValue: rankRawValue) {
            rank = noOptionalRank
        } else {
            rank = .beginner
        }
        let gardenersGuest = dict[UserConsts.GardenersGuest] as? [String: Any]
        let currentGardener = dict[UserConsts.CurrentGardener] as? String ?? ""

        return UserModel(id: snap.key, metadata: toUserMetadataModel(metaDict), rank: rank, currentGardener: currentGardener, gardeners: Array((dict[UserConsts.Gardeners] as? [String: Any] ?? [:]).keys), gardenersGuest: Array((dict[UserConsts.GardenersGuest] as? [String: Any] ?? [:]).keys))
    }

    func toUserMetadataModel(_ metaDict: [String: Any]) -> UserMetadataModel {
        let firstName = metaDict[Consts.FirstName] as! String
        let lastName = metaDict[Consts.LastName] as! String
        return UserMetadataModel(firstName: firstName, lastName: lastName)
    }
    
    func toDictonary(_ userModel: UserModel) -> [String: Any] {
        return [
            UserConsts.Metadata: [
                toDictonary(userModel.metadata)
            ]
        ]
    }

    func toDictonary(_ userMetadataModel: UserMetadataModel) -> [String: Any] {
        return [
            Consts.FirstName: userMetadataModel.firstName,
            Consts.LastName: userMetadataModel.lastName
        ]
    }
}

protocol UserRepository {
    func getReference(for key: String) -> DatabaseReference
    func getMetadataReference(for key: String) -> DatabaseReference
    func getCurrentGardenerReference(for key: String) -> DatabaseReference
    func getGardenersReference(for key: String) -> DatabaseReference
    func getMetadataInvitedReference(for key: String) -> DatabaseReference
    func getMetadataAddToOwnersReference(for key: String) -> DatabaseReference
    func getGardenerGuestReference(for key: String) -> DatabaseReference
    func getStorageReference(for key: String) -> StorageReference
    func getImageProfile(for key: String) -> StorageReference
}

class UserRepositoryImpl: UserRepository {

    private var rootReference: DatabaseReference {
        return Database.database().reference(withPath: UserConsts.RootNode)
    }

    private var rootStorageReference: StorageReference {
        return Storage.storage().reference(withPath: UserConsts.RootNode)
    }

    func getReference(for key: String) -> DatabaseReference {
        return rootReference.child(key)
    }

    func getMetadataReference(for key: String) -> DatabaseReference {
        return getReference(for: key).child(UserConsts.Metadata)
    }

    func getCurrentGardenerReference(for key: String) -> DatabaseReference {
        return getReference(for: key).child(UserConsts.CurrentGardener)
    }
    
    func getGardenersReference(for key: String) -> DatabaseReference {
        return getReference(for: key).child(UserConsts.Gardeners)
    }

    func getMetadataInvitedReference(for key: String) -> DatabaseReference {
        return getMetadataReference(for: key).child(UserConsts.Invited)
    }

    func getMetadataAddToOwnersReference(for key: String) -> DatabaseReference {
        return getMetadataReference(for: key).child(UserConsts.AddToOwners)
    }

    func getGardenerGuestReference(for key: String) -> DatabaseReference {
        return getReference(for: key).child(UserConsts.GardenersGuest)
    }
    
    func getStorageReference(for key: String) -> StorageReference {
        return rootStorageReference.child(key)
    }

    func getImageProfile(for key: String) -> StorageReference {
        return getStorageReference(for: key).child(UserConsts.ProfileImage)
    }

}

struct UserModel {
    let id: String
    let metadata: UserMetadataModel
    let rank: Rank
    let currentGardener: String
    let gardeners: [String]
    let gardenersGuest: [String]
}

struct UserMetadataModel {
    let firstName: String
    let lastName: String
}
