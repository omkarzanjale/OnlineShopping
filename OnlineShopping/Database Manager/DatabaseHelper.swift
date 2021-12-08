//
//  DatabaseHelper.swift
//  OnlineShopping
//
//  Created by Mac on 10/11/21.
//

import Foundation
import SQLite3

class DatabaseHelper {
    private var db: OpaquePointer?
    
    init() {
        self.db = createAndOpenDB()
        createUserTable()
        createCartTable()
        createOrderTable()
    }
    
    private func createAndOpenDB() -> OpaquePointer? {
        var db: OpaquePointer?
        let databaseName = "ShoppingDB.sqlite"
        do {
            let documentDir = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(databaseName)
            if sqlite3_open(documentDir.path, &db) == SQLITE_OK {
                print("Database created and opened successfully.")
                //print("Path: \(documentDir.path)")
                return db
            } else {
                print("Databse already present. DB opned sucessfully.")
                return db
            }
        } catch {
            print("Error : \(error.localizedDescription)")
        }
        return nil
    }
    
    private func createUserTable() {
        var createTableStatement: OpaquePointer?
        let query = "CREATE TABLE IF NOT EXISTS User(name TEXT, email TEXT PRIMARY KEY, contact TEXT, password TEXT)"
        if sqlite3_prepare_v2(db, query, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("User table successfully created.")
            } else {
                print("Unable to create User table or already exists!")
            }
        } else {
            print("Unable to prepare create user table query!!!")
        }
    }
    //
    //MARK: Success & failure closures
    //
    typealias successClosure = (_ title: String, _ message: String) -> ()
    typealias failureClosure = (_ title: String, _ message: String) -> ()
    //
    //MARK: Insert into User
    //
    func insertIntoUser(user: User, success: successClosure, failure: failureClosure) {
        var insertStatement: OpaquePointer?
        let query = "INSERT INTO User(name,email,contact,password) VALUES(?,?,?,?)"
        if sqlite3_prepare_v2(db, query, -1, &insertStatement, nil) == SQLITE_OK {
            let nameText = NSString(string: user.name).utf8String
            sqlite3_bind_text(insertStatement, 1, nameText, -1, nil)
            
            let emailText = NSString(string: user.email).utf8String
            sqlite3_bind_text(insertStatement, 2, emailText, -1, nil)
            
            let contactText = NSString(string: user.contact).utf8String
            sqlite3_bind_text(insertStatement, 3, contactText, -1, nil)
            
            let passwordText = NSString(string: user.password).utf8String
            sqlite3_bind_text(insertStatement, 4, passwordText, -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                sqlite3_finalize(insertStatement)
                success("Succeed","Account created successfully.")
            } else {
                failure("Failed","Account already exist with this email! please login.")
            }
        } else {
            print("Unable to prepare Insert user query!")
            failure("Failed","Something went wrong! try again.")
        }
    }
    //
    //MARK: get User With Email and password
    //
    func getUserWith(email: String, password: String) -> User? {
        var selectStatement: OpaquePointer?
        let query = "SELECT * FROM User WHERE email='\(email)' AND password='\(password)'"
        if sqlite3_prepare_v2(db, query, -1, &selectStatement, nil) == SQLITE_OK {
            while sqlite3_step(selectStatement) == SQLITE_ROW {
                guard let name_CStr = sqlite3_column_text(selectStatement, 0) else {
                    print("Unable to get name from database!")
                    return nil
                }
                let name = String(cString: name_CStr)
                
                guard let email_CStr = sqlite3_column_text(selectStatement, 1) else {
                    print("Unable to get email from database!")
                    return nil
                }
                let email = String(cString: email_CStr)
                
                guard let contact_CStr = sqlite3_column_text(selectStatement, 2) else {
                    print("Unable to get contact from database!")
                    return nil
                }
                let contact = String(cString: contact_CStr)
                
                guard let password_CStr = sqlite3_column_text(selectStatement, 3) else {
                    print("Unable to get password from database!")
                    return nil
                }
                let password = String(cString: password_CStr)
                
                let user = User(name: name, email: email, contact: contact, password: password)
                sqlite3_finalize(selectStatement)
                return user
            }
        } else {
            print("Unable to prepare select user query!")
        }
        return nil
    }
    //
    //MARK:Cart table
    //
    private func createCartTable() {
        var createStatement: OpaquePointer?
        let query = "CREATE TABLE IF NOT EXISTS Cart(cartid INTEGER PRIMARY KEY AUTOINCREMENT, productid INTEGER, email TEXT REFERENCES User(email) ON DELETE CASCADE ON UPDATE CASCADE)"
        if sqlite3_prepare_v2(db, query, -1, &createStatement, nil) == SQLITE_OK {
            if sqlite3_step(createStatement) == SQLITE_DONE {
                print("Cart table create successfully.")
            } else {
                print("Unable to create cart table!")
            }
        } else {
            print("Unable to prepare create cart table query!")
        }
    }
    //
    //MARK: add to cart
    //
    func addToCart(productId: Int, userEmail:String, success: successClosure, failure: failureClosure) {
        var insertStatement: OpaquePointer?
        let query = "INSERT INTO Cart(productid,email) VALUES(?,?)"
        if sqlite3_prepare_v2(db, query, -1, &insertStatement, nil) == SQLITE_OK {
            let idInt32 = Int32(productId)
            sqlite3_bind_int(insertStatement, 1, idInt32)
            
            let emailText = NSString(string: userEmail).utf8String
            sqlite3_bind_text(insertStatement, 2, emailText, -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Item added to Cart.")
                sqlite3_finalize(insertStatement)
                success("Succeed","Product added to Cart.")
            } else {
                print("Unable to add item in Cart!")
                failure("Failed","Unable to add in Cart!")
            }
        } else {
            print("Unable to prepare insert cart query!")
            failure("Failed","Something went wrong! try again.")
        }
    }
    //
    //MARK: get Cart Data For user
    //
    func getCartDataFor(userEmail: String) -> (productsId: [Int], cartsId: [Int])? {
        var selectStatement: OpaquePointer?
        var productsId = [Int]()
        var cartsId = [Int]()
        let query = "SELECT cartid,productid FROM Cart WHERE email = '\(userEmail)'"
        if sqlite3_prepare_v2(db, query, -1, &selectStatement, nil) == SQLITE_OK {
            while sqlite3_step(selectStatement) == SQLITE_ROW {
                let cartId = Int(sqlite3_column_int(selectStatement, 0))
                let productId = Int(sqlite3_column_int(selectStatement, 1))
                cartsId.append(cartId)
                productsId.append(productId)
            }
            sqlite3_finalize(selectStatement)
            return (productsId,cartsId)
        } else {
            print("Unable to prepare select cart query!")
        }
        return nil
    }
    //
    //MARK: delete Cart Product
    //
    func deleteCartProduct(cartId: Int, success: successClosure, failure: failureClosure) {
        var deleteStatement: OpaquePointer?
        let query = "DELETE FROM Cart WHERE cartid = '\(cartId)'"
        if sqlite3_prepare(db, query, -1, &deleteStatement, nil) == SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                success("Succeed","Product removed.")
            } else {
                failure("Warning","Unable to delete!Try again.")
            }
        } else {
            print("Unable to prepare delete query!")
            failure("Warning","Unable to delete!Try again.")
        }
    }
    //
    //MARK: Orders table
    //
    private func createOrderTable() {
        var createStatement: OpaquePointer?
        let query = "CREATE TABLE IF NOT EXISTS Orders(orderId INTEGER PRIMARY KEY AUTOINCREMENT, address TEXT, state TEXT, city TEXT, pinCode INTEGER, cashOnDelivery TEXT, upiApp TEXT, upiId TEXT, orderDate TEXT, orderTime TEXT, productId INTEGER, email TEXT REFERENCES User(email) ON DELETE CASCADE ON UPDATE CASCADE)"
        
        if sqlite3_prepare_v2(db, query, -1, &createStatement, nil) == SQLITE_OK {
            if sqlite3_step(createStatement) == SQLITE_DONE {
                print("orders table created successfully!")
            } else {
                print("unable to create orders table! or already exists.")
            }
        } else {
            print("Unable to prepare create orders query!")
        }
    }
    //
    //MARK: Insert into Order
    //
    func placeOrder(order: Order, success: successClosure, failure: failureClosure) {
        var insertStatement: OpaquePointer?
        let query = "INSERT INTO Orders(address,state,city,pinCode,cashOnDelivery,upiApp,upiId,orderDate,orderTime,productId,email) VALUES(?,?,?,?,?,?,?,?,?,?,?)"
        if sqlite3_prepare_v2(db, query, -1, &insertStatement, nil) == SQLITE_OK {
            let addressText = NSString(string: order.address).utf8String
            sqlite3_bind_text(insertStatement, 1, addressText, -1, nil)
            
            let stateText = NSString(string: order.state).utf8String
            sqlite3_bind_text(insertStatement, 2, stateText, -1, nil)
            
            let cityText = NSString(string: order.city).utf8String
            sqlite3_bind_text(insertStatement, 3, cityText, -1, nil)
            
            let pinCodeInt32 = Int32(order.pinCode)
            sqlite3_bind_int(insertStatement, 4, pinCodeInt32)
            
            let codString = String(order.cashOnDelivery)
            let cashOndeliveryText = NSString(string: codString).utf8String
            sqlite3_bind_text(insertStatement, 5, cashOndeliveryText, -1, nil)
            
            let upiAppText = NSString(string: order.upiApp).utf8String
            sqlite3_bind_text(insertStatement, 6, upiAppText, -1, nil)
            
            let upiIdText = NSString(string: order.upiId).utf8String
            sqlite3_bind_text(insertStatement, 7, upiIdText, -1, nil)
            
            let orderDateText = NSString(string: order.orderDate).utf8String
            sqlite3_bind_text(insertStatement, 8, orderDateText, -1, nil)
            
            let orderTimeText = NSString(string: order.orderTime).utf8String
            sqlite3_bind_text(insertStatement, 9, orderTimeText, -1, nil)
            
            let productIdInt32 = Int32(order.productId)
            sqlite3_bind_int(insertStatement, 10, productIdInt32)
            
            let customerEmailText = NSString(string: order.customerEmail).utf8String
            sqlite3_bind_text(insertStatement, 11, customerEmailText, -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Order placed.")
                success("Thank You","Order placed.")
            } else {
                print("Unable to place order!")
                failure("Failed","Try again!")
            }
        } else {
            print("Unable to prepare Insert order query!")
            failure("Failed","Try again!")
        }
    }
    
    func cancelOrder(orderDate: String,orderTime: String, success: successClosure) {
        //let lastRowId = sqlite3_last_insert_rowid(db)
        var deleteStatement: OpaquePointer?
        let query = "DELETE FROM Orders WHERE orderDate = '\(orderDate)' AND orderTime = '\(orderTime)'"
        if sqlite3_prepare_v2(db, query, -1, &deleteStatement, nil) == SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                success("Succeed","Order cancel successfully!")
                sqlite3_finalize(deleteStatement)
                print("Order cancel successfully!")
            } else {
                print("Unable to cancel order!")
            }
        } else {
            print("Unable to prepare delete order query!")
        }
    }
    
}
