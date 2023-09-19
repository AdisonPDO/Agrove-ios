//
//  TextField+Extension.swift
//  plantR_ios
//
//  Created by Boris Roussel on 07/12/2020.
//  Copyright © 2020 Agrove. All rights reserved.
//

import UIKit
import Foundation

extension UITextField{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
}

protocol DataPickerTextFieldDelegate {
    func didSelectRow(pickerView: UIPickerView, row: Int, component: Int, identifier : String, value : String)
}

class DataPickerTextField : UITextField {
    var dataValues                  : [String]      = []
    var pickerView          : UIPickerView  = UIPickerView()
    var pickerIdentifier    : String        = ""
    
    var pickerViewDelegate          : DataPickerTextFieldDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.inputView = self.pickerView
        self.keyboardAppearance = .dark
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        self.addTarget(self, action: #selector(textFieldEditingDidBegin), for: .editingDidBegin)
    }
    
    func removeTarget() {
        self.removeTarget(self, action: #selector(textFieldEditingDidBegin), for: .editingDidBegin)
        self.inputView = nil
        self.reloadInputViews()
    }
    
    @objc func textFieldEditingDidBegin() {
        if dataValues.count > 0 {
            if !self.text!.isEmpty && dataValues.contains(self.text!) {
                self.pickerView.reloadComponent(0)
                self.pickerView.selectRow( self.dataValues.firstIndex(of: self.text!)!, inComponent: 0, animated: true)
            } else {
                self.text = self.dataValues[0]
            }
        }
    }
    func setPickerData(_ newDataValues : [String]?, _ identifier : String) {
        self.pickerIdentifier = identifier
        self.dataValues       = newDataValues ?? []
    }
}

extension DataPickerTextField : UIPickerViewDelegate , UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.dataValues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.dataValues[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard isFirstResponder else {
            return
        }
        self.text = self.dataValues[row]
        self.pickerViewDelegate?.didSelectRow(pickerView: pickerView, row: row, component: component,
                                              identifier: self.pickerIdentifier, value: self.dataValues[row])
    }
}

protocol DatePickerTextFieldDelegate {
    func didUpdateSelectedDate(_ date : Date, _ dateToString : String)
}

class DatePickerTextField : UITextField {
    var datePickerView = UIDatePicker()
    var datePickerDelegate : DatePickerTextFieldDelegate?
    
    var withTime: Bool = false
    var timeOnly: Bool = false
    var dateOnly: Bool = false
    
    var isForEventSelection: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }

    func configure() {
        print(withTime, timeOnly, dateOnly)
        self.datePickerView.locale = Locale(identifier: "fr")
        self.datePickerView.datePickerMode = timeOnly ? .time : dateOnly ? .date : .dateAndTime
        self.keyboardAppearance = .dark
        self.inputView = self.datePickerView
        self.addTarget(self, action: #selector(datePickerTextFieldEditingDidEnd), for: .editingDidEnd)
    }
    
    func setMinMaxDate(date: Date) {
        datePickerView.minimumDate = Calendar.current.date(byAdding: .hour, value: -2, to: date)
        datePickerView.maximumDate = Calendar.current.date(byAdding: .hour, value: 6, to: date)
    }
    
    @objc func datePickerTextFieldEditingDidEnd() {
        let dateToString = withTime ? self.datePickerView.date.withTimeToString() : timeOnly ? self.datePickerView.date.timeToString() : self.datePickerView.date.toString()
        self.datePickerDelegate?.didUpdateSelectedDate(self.datePickerView.date, dateToString)
        self.text = dateToString
    }
}

extension Date {
    func convertDateFormater(date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss z"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return  dateFormatter.string(from: date!)
    }
    
    func stringForEvent() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr")
        formatter.dateFormat = "d MMM"
        return formatter.string(from: self)
    }
 
    func toDayNameAndNumber() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr")
        formatter.dateFormat = "EE dd MMM"
        return formatter.string(from: self).uppercased()
    }
    
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
//        formatter.dateFormat = "dd/MM/yyyy à HH:mm"
        return formatter.string(from: self)
    }

    func withTimeToString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr")
        formatter.dateFormat = "dd/MM/yyyy à HH:mm"
        return formatter.string(from: self)
    }

    func timeToString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }

}
