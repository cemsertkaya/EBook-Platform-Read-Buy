//
//  FirebaseSingleton.swift
//  EBOOKAPP
//
//  Created by Cem Sertkaya on 2.02.2021.
//

import Foundation
import Firebase

class singleton
{
    
    private static var  uniqueInstance:singleton? = nil
    private var db = Firestore.firestore()
    private var usersDatabase:CollectionReference?
    private var booksDatabase:CollectionReference?
    
    private init()
    {
        self.db = Firestore.firestore()
        self.usersDatabase = self.db.collection("Users")
        self.booksDatabase = self.db.collection("Books")
    }
    
    public static func instance() -> singleton
    {
        if uniqueInstance == nil
        {
            uniqueInstance = singleton()
        }
        return uniqueInstance!
    }
    
    func getDb() -> Firestore
    {
        return singleton.uniqueInstance!.db
    }
    
    func getUsersDatabase() -> CollectionReference
    {
        return singleton.uniqueInstance!.usersDatabase!
    }
    
    func getBooksDatabase() -> CollectionReference
    {
        return singleton.uniqueInstance!.booksDatabase!
    }
    
    
}

class FirebaseUtil
{
    static func getUserDataAndCreateCore(userId : String, isActive : Bool)
    {
        var newUser = CurrentUser()
        let docRef = singleton.instance().getUsersDatabase().document(userId)
        docRef.getDocument
        {
           (document, error) in
           if let document = document, document.exists
           {
               let dataDescription = document.data()
               let age  = dataDescription?["age"] as! String
               let country  = dataDescription?["country"] as! String
               let email  = dataDescription?["email"] as! String
               let gender  = dataDescription?["gender"] as! String
               let userId  = dataDescription?["userId"] as! String
               newUser = CurrentUser(userId: userId, email: email, age: age, country: country, gender: gender, isActive: isActive)
               CoreDataUtil.createUserCoreData(user: newUser)
           }
        }
    }
    
}
