//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!

    let db = Firestore.firestore()
    
    var messages: [Message] = []
//    MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = K.addName
        navigationItem.hidesBackButton = true
        
        setDelegate()
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        
        loadMessages()
//        keyboardIsHiden()

    }
    

    
    @IBAction func sendPressed(_ sender: UIButton?) {
        
        if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email {
            //            отправляем в облако
            db.collection(K.FStore.collectionName).addDocument(data: [
                K.FStore.senderField: messageSender,
                K.FStore.bodyField: messageBody,
                K.FStore.dateField: Date().timeIntervalSince1970
            ]) { error in
                if let error = error {
                    print("Ошибка сохранения данных \(error)")
                } else {
                    print("Seccessfully saved data")
                }
            }
        }
//        скрываем клавиатура
//        messageTextfield.resignFirstResponder()
    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
//            возврат в корневой контроллер
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
    
    private func setDelegate() {
        tableView.delegate = self
        tableView.dataSource = self
        messageTextfield.delegate = self
    }
    
    private func loadMessages() {
        
        db.collection(K.FStore.collectionName)
            .order(by: K.FStore.dateField)
            .addSnapshotListener { querySnapshot, error in
            
            self.messages = []
            
            if let error = error {
                print("Ошибка извлечения данный \(error)")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for document in snapshotDocuments {
                        let data = document.data()
                        guard let messageSender = data[K.FStore.senderField] as? String else { return }
                        guard let messageBody = data[K.FStore.bodyField] as? String else { return }
                        let newMessage = Message(sender: messageSender, body: messageBody)
                        self.messages.append(newMessage)
                        
//                        перзагрузка таблицы
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
// MARK: - Keyboard Settings
    /*
    private func keyboardIsHiden() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//            Поднимаем элементы на высоту клавиатуры
            view.frame.origin.y = -keyboardSize.height
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    */
    
}

// MARK: - Extensions TableView Delegate

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier , for: indexPath) as? MessageCell else { return UITableViewCell() }
        
        let message = messages[indexPath.row]
        cell.textLabel?.text = ("\(message.sender): \(message.body)")
        
        return cell
    }
}

// MARK: - Extensions TextField

extension ChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == messageTextfield {
            sendPressed(nil)
            return false
        }
        return true
    }
}
