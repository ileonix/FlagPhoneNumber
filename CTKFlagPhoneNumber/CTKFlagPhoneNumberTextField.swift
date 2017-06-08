//                                                                  _______________________________________________
//                                                                 |                                               | |\
//                                                                 |                                               | ||
//  ____ _                           _                   _         |                                               |,""---:___
// / ___| |__  _ __ ___  _ __   ___ | |_ _ _  _   _  ___| | __     |                                               ||==  | .-.|
// | |  | '_ \| '_// _ \| '_ \ / _ \| __| '_/| | | |/ __| |/ /     |                                               ||==  | '-'-----.
// | |__| | | | | | (_) | | | | (_) | |_| |  | |_| | (__|   <      |_______________________________________________||    |~  |   -(|
// \____|_| |_|_|  \___/|_| |_|\___/ \__|_|   \__,_|\___|_|\_\     |_____________________________/<  _...==...____|    |   | ___ |
//                                                                  \\ .-.  .-. //            \|  \//.-.  .-.\\ --------"-"/.-.\_]
//                                                                  ` ( o )( o )'              '    ( o )( o )`"""""""""==`( o )
//                                                                     '-'  '-'                      '-'  '-'               '-'

//  Created by Aurélien GRIFASI on 07/06/2017.


import Foundation
import libPhoneNumber_iOS

extension Bundle {
	static func ctk_frameworkBundle() -> Bundle {
		let bundle = Bundle(for: CTKFlagPhoneNumberTextField.self)
		if let path = bundle.path(forResource: "CTKFlagPhoneNumber", ofType: "bundle") {
			return Bundle(path: path)!
		}
		else {
			return bundle
		}
	}
}

public class CTKFlagPhoneNumberTextField: UITextField, UITextFieldDelegate, MRCountryPickerDelegate {
	
	private var flagButton: UIButton!
	private lazy var countryPicker: MRCountryPicker = MRCountryPicker()
	private lazy var phoneUtil: NBPhoneNumberUtil = NBPhoneNumberUtil()
	
	var countryCode: String?
	var phoneCode: String?
	private var phoneNumber: String?
		
	private func initialize() {
		borderStyle = .roundedRect
		leftViewMode = UITextFieldViewMode.always
		keyboardType = .numberPad
		inputAccessoryView = getToolBar(self, title: "Done", selector: #selector(resetKeyBoard))
		delegate = self
		
		countryPicker.countryPickerDelegate = self
		countryPicker.showPhoneNumbers = true
		
		addTarget(self, action: #selector(displayNumberKeyBoard), for: .touchDown)
	}
	
	override public func draw(_ rect: CGRect) {
		initialize()
		
		leftView = UIView(frame: CGRect(x: 0, y: 0, width: 37, height: 29))
		
		flagButton = UIButton(frame: CGRect(x: 8, y: 0, width: 29, height: 29))
		flagButton.addTarget(self, action: #selector(displayCountryKeyboard), for: .touchUpInside)
		
		leftView?.addSubview(flagButton)
		
		countryPicker.setCountry(Locale.current.regionCode!)
	}
	
	override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
		return false
	}
	
	@objc private func displayNumberKeyBoard() {
		if inputView != nil {
			inputView = nil
			tintColor = .gray
			reloadInputViews()
		}
	}
	
	@objc private func displayCountryKeyboard() {
		if inputView == nil {
			inputView = countryPicker
			tintColor = .clear
			reloadInputViews()
		}
		becomeFirstResponder()
	}
	
	@objc private func resetKeyBoard() {
		inputView = nil
		resignFirstResponder()
	}
	
	public func getPhoneNumber() -> String? {
		if var number = phoneNumber {
			
			number = number.replacingOccurrences(of: "(", with: "")
			number = number.replacingOccurrences(of: ")", with: "")
			number = number.replacingOccurrences(of: " ", with: "")
			number = number.replacingOccurrences(of: "-", with: "")
			number = number.replacingOccurrences(of: "+", with: "")
			
			return number
		}
		return nil
	}
	
	
	// UITextFieldDelegate

	public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		
		if string == "" && textField.text == phoneCode {
			return false
		}
		
		if range.length > 0 {
			return true
		} else {
			let text = textField.text! + string
			do {
				let phoneNumber: NBPhoneNumber = try phoneUtil.parse(text, defaultRegion: countryCode)
				let formattedString: String = try phoneUtil.format(phoneNumber, numberFormat: .INTERNATIONAL)
				
				textField.text = formattedString
			}
			catch _ {
				return true
			}
			return false
		}
	}
	
	public func textFieldDidEndEditing(_ textField: UITextField) {
		self.phoneNumber = textField.text
	}
	

	// MRCountryPickerDelegate
	
	public func countryPhoneCodePicker(_ picker: MRCountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
		self.phoneCode = phoneCode
		self.countryCode = countryCode
		
		text = phoneCode
		
		//		flagButton.setImage(UIImage.getFlag(from: countryCode), for: .normal)
		flagButton.setImage(flag, for: .normal)
	}
}
