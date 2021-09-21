//
//  ViewController.swift
//  FirstMoney(YouTube)
//
//  Created by Nikita Kuzmich on 19.08.21.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    let localRealm = try! Realm()
    var spendingArray: Results<Spending>! 
    
    @IBOutlet weak var limitLabel: UILabel!
    @IBOutlet weak var howManyCanSpend: UILabel!
    @IBOutlet weak var spendByCheck: UILabel!
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var allSpending: UILabel!
    
    var stillTyping = false
    
    @IBOutlet var numberFromKeyboard: [UIButton]!{
        didSet {
            for button in numberFromKeyboard {
                button.layer.cornerRadius = 11
            }
        }
    }
    
    var categoryName = ""
    var displayValue: Int = 1
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spendingArray = localRealm.objects(Spending.self)
        leftLabels()
        allSpendin()
    
    }
    
    @IBAction func numberPressed(_ sender: UIButton) {
        guard let number = sender.currentTitle, let displayLabelText = displayLabel.text else {
            return
        }
        
        if number == "0" && displayLabelText == "0" {
            stillTyping = false
        }
        else {
            if stillTyping {
                if displayLabelText.count < 15 {
                    displayLabel.text = displayLabelText + number
                }
                
            } else {
                displayLabel.text = number
                stillTyping = true }
        }
        
    }
    
    @IBAction func resetButton(_ sender: UIButton) {
        displayLabel.text = "0"
        stillTyping = false
    }
    
    @IBAction func categoryPressed(_ sender: UIButton) {
        guard let displayLabelText = displayLabel.text, let value1 = Int(displayLabelText) else { return }
        categoryName = sender.currentTitle ?? ""
        displayValue = value1
        displayLabel.text = "0"
        stillTyping = false
        
        
        let value = Spending(value: ["\(categoryName)", displayValue])
        try? localRealm.write {
            localRealm.add(value)
            
        }
        leftLabels()
        allSpendin()
        tableView.reloadData()
        
    }
    
    @IBAction func limitPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Установить лимит", message: "Введите сумму и количество дней", preferredStyle: .alert)
        let alertInstall = UIAlertAction(title: "Установить", style: .default) { action in
            let tfSum = alertController.textFields?[0].text
            
            let tfDay = alertController.textFields?[1].text
            
            guard  tfDay != "" && tfSum != "" else { return }
            
            self.limitLabel.text = tfSum
            
            if let day = tfDay {
                let dateNow = Date()
                let lastDay: Date = dateNow.addingTimeInterval(60*60*24*Double(day)!)
                
                let limit = self.localRealm.objects(Limit.self)
                
                if limit.isEmpty == true {
                    let value = Limit(value: [self.limitLabel.text!, dateNow, lastDay])
                    try? self.localRealm.write {
                        self.localRealm.add(value)}
                    
                } else {
                    try? self.localRealm.write {
                        if let text = self.limitLabel.text {
                            limit[0].limitSome = text
                        }
                        limit[0].limitDate = dateNow as NSDate
                        limit[0].limitLastDate = lastDay as NSDate }
                }
            }
            self.leftLabels()
        }
        
        alertController.addTextField { (money) in
            money.placeholder = "Сумма"
            money.keyboardType = .asciiCapableNumberPad
            
        }
        alertController.addTextField { (day) in
            day.placeholder = "Количество дней"
            day.keyboardType = .asciiCapableNumberPad
            
        }
        let alertCancel = UIAlertAction(title: "Отмена", style: .default) { _ in }
        
        alertController.addAction(alertInstall)
        alertController.addAction(alertCancel)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func leftLabels() {
        let limit = self.localRealm.objects(Limit.self)
        
        guard limit.isEmpty == false else { return }
        
        limitLabel.text = limit[0].limitSome
        
        let calendar = Calendar.current
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        
        let firstDay = limit[0].limitDate as Date
        let lastDay = limit[0].limitLastDate as Date
        
        let firstComponents = calendar.dateComponents([.year, .month, .day], from: firstDay)
        let lastComponents = calendar.dateComponents([.year, .month, .day], from: lastDay)
        
        guard let firstYear1 = firstComponents.year, let firstMonth1 = firstComponents.month, let firstDay1 =  firstComponents.day, let lastYear1 = lastComponents.year, let lastMonth1 = lastComponents.month, let lastDay1 = lastComponents.day  else { return
        }
        
        let startDate = formatter.date(from: "\(firstYear1)/\(firstMonth1)/\(firstDay1) 00:00") as Any
        let endDate = formatter.date(from: "\(lastYear1)/\(lastMonth1)/\(lastDay1) 23:59") as Any
        
        let filtredLimit: Int = localRealm.objects(Spending.self).filter("self.date >= %@ && self.date <= %@", startDate, endDate).sum(ofProperty: "cost")
        
        spendByCheck.text = "\(filtredLimit)"
        
        if let limitLabelText = limitLabel.text, let a = Int(limitLabelText),
           let spendByCheckText = limitLabel.text, let b = Int(spendByCheckText) {
            howManyCanSpend.text = "\(a - b)"
        }
    }
    
    func allSpendin() { let allSpend: Int = localRealm.objects(Spending.self).sum(ofProperty: "cost")
        allSpending.text = "\(allSpend)" }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spendingArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? CustomTableViewCell else { return UITableViewCell() }
        
        
        let spending = spendingArray.reversed()[indexPath.row]
        
        cell.recordCategory.text = spending.category
        cell.recordCoast.text = "\(spending.cost)"
        switch spending.category {
        case "Еда": cell.recordImage.image = #imageLiteral(resourceName: "icons8-hamburger-100")
        case "Одежда": cell.recordImage.image = #imageLiteral(resourceName: "Одежда")
        case "Связь": cell.recordImage.image = #imageLiteral(resourceName: "Связь")
        case "Досуг": cell.recordImage.image = #imageLiteral(resourceName: "Досуг")
        case "Красота": cell.recordImage.image = #imageLiteral(resourceName: "Красота")
        case "Авто": cell.recordImage.image = #imageLiteral(resourceName: "Авто")
        default: cell.recordImage.image = #imageLiteral(resourceName: "Display2")
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title:  "Delete", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let editingRow = self.spendingArray.reversed()[indexPath.row]
            try? self.localRealm.write {
                self.localRealm.delete(editingRow)
                self.allSpendin()
                self.leftLabels()
                tableView.reloadData()}
            success(true)
        })
        deleteAction.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}





