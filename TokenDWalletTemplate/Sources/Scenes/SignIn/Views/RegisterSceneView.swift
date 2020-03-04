import RxCocoa
import RxSwift
import SnapKit
import UIKit

extension RegisterScene {
    
    class View: UIView {
        
        // MARK: - Public properties
        
        let marginInset: CGFloat = 20.0
        let separatorHeight: CGFloat = 1.0
        let fieldHeight: CGFloat = 69.0
        
        // MARK: - Private properties
        
        private var fields: [Field] = []
        private var fieldViews: [UIView] = []
        private var textFields: [FieldView] = []
        
        private let scrollView: UIScrollView = UIScrollView()
        private let titleLabel: UILabel = UILabel()
        private let fieldsContainerView: UIView = UIView()
        private let actionButton: UIButton = UIButton(type: .custom)
        private var subActionViews: [UIView] = []
        private let copyrightLabel: UILabel = UILabel()
        private let opaqueBackgroundImage = UIImageView()
        private let iconImage = UIImageView()
        
        private let disposeBag = DisposeBag()
        
        // MARK: - Callbacks
        
        var onScanQRAction: (() -> Void)?
        var onEditField: ((_ fieldPurpose: Model.Field.FieldPurpose, _ text: String?) -> Void)?
        var onFieldShouldReturn: ((_ fieldPurpose: Model.Field.FieldPurpose) -> Void)?
        var onActionButton: (() -> Void)?
        var onSubActionButton: ((_ buttonIndex: Int) -> Void)?
        var onAgreeOnTerms: ((_ checked: Bool) -> Void)?
        
        // MARK: -
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.customInit()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            
            self.customInit()
        }
        
        private func customInit() {
            self.backgroundColor = Theme.Colors.mainColor
            
            self.setupScrollView()
            self.setupTitle()
            self.setupCopyright()
            self.setupOpaqueBackgroundImage()
            self.setupIconImage()
            self.setupActionButton()
            self.setupLayout()
        }
        
        // MARK: - Public
        
        func set(title: String, fields: [Field], actionTitle: String?, subActions: [Model.SubActionViewModel]) {
            self.titleLabel.text = title
            self.setFields(fields)
            self.actionButton.setTitle(actionTitle, for: .normal)
            self.setSubActions(subActions)
        }
        
        func showErrorForField(_ purpose: Model.Field.FieldPurpose) {
            self.fieldForPurpose(purpose)?.showError()
        }
        
        func hideErrorForField(_ purpose: Model.Field.FieldPurpose) {
            self.fieldForPurpose(purpose)?.hideError()
        }
        
        func switchToField(_ purpose: Model.Field.FieldPurpose) {
            self.fieldForPurpose(purpose)?.textField.becomeFirstResponder()
        }
        
        // MARK: - Private
        
        private func fieldForPurpose(_ purpose: Model.Field.FieldPurpose) -> FieldView? {
            if let index = self.fields.index(where: { (field) -> Bool in
                switch field.fieldType {
                    
                case .scanServerInfo:
                    return false
                    
                case .text(let fieldPurpose):
                    return fieldPurpose == purpose
                }
            }) {
                return self.textFields[index]
            }
            return nil
        }
        
        private func setupScrollView() {
            self.scrollView.alwaysBounceVertical = true
            self.scrollView.keyboardDismissMode = .onDrag
        }
        
        private func setupTitle() {
            self.titleLabel.textAlignment = .center
            self.titleLabel.font = Theme.Fonts.largeTitleFont
            self.titleLabel.textColor = Theme.Colors.textOnMainColor
            self.titleLabel.text = Localized(.log_in)
        }
        
        private func setupCopyright() {
            self.copyrightLabel.textAlignment = .center
            self.copyrightLabel.font = Theme.Fonts.plainBoldTextFont
            self.copyrightLabel.textColor = Theme.Colors.textOnMainColor
            self.copyrightLabel.text = "Powered by HanseCoin & Distributed Lab"
        }
        
        private func setupIconImage() {
            self.iconImage.image = Assets.group33.image
            self.iconImage.contentMode = .scaleAspectFit
        }
        
        private func setupOpaqueBackgroundImage() {
            self.opaqueBackgroundImage.image = Assets.group36.image
        }
        
        private func setupActionButton() {
            SharedViewsBuilder.configureActionButton(
                self.actionButton,
                color: UIColor(red: 149/255, green: 36/255, blue: 80/255, alpha: 1.0))
            self.actionButton
                .rx
                .controlEvent(.touchUpInside)
                .asDriver()
                .drive(onNext: { [weak self] in
                    self?.endEditing(true)
                    self?.onActionButton?()
                })
                .disposed(by: self.disposeBag)
            self.actionButton.layer.cornerRadius = 20
            self.actionButton.layer.masksToBounds = true
        }
        
        private func setupLayout() {
            self.addSubview(self.scrollView)
            self.scrollView.addSubview(self.opaqueBackgroundImage)
            self.scrollView.addSubview(self.iconImage)
            self.scrollView.addSubview(self.titleLabel)
            self.scrollView.addSubview(self.fieldsContainerView)
            self.scrollView.addSubview(self.actionButton)
            self.scrollView.addSubview(self.copyrightLabel)
            
            let titleOffset: CGFloat = 30.0
            let buttonHeight: CGFloat = 44.0
            let fieldsOffset: CGFloat = 80.0
            
            self.scrollView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            self.titleLabel.snp.makeConstraints { (make) in
                make.leading.trailing.equalToSuperview()
                make.top.equalToSuperview().inset(titleOffset)
            }
            
            self.iconImage.snp.makeConstraints { (make) in
                make.leading.equalToSuperview().offset(20)
                make.centerY.equalTo(self.titleLabel.snp.centerY)
                make.width.equalTo(40)
            }
            
            self.fieldsContainerView.snp.makeConstraints { (make) in
                make.leading.trailing.equalToSuperview()
                make.top.equalTo(self.titleLabel.snp.bottom).offset(fieldsOffset)
                make.width.equalTo(self.snp.width)
            }
            self.actionButton.snp.makeConstraints { (make) in
                make.leading.trailing.equalToSuperview().inset(112)
                make.top.equalTo(self.fieldsContainerView.snp.bottom).offset(self.marginInset)
                make.height.equalTo(buttonHeight)
                make.bottom.equalToSuperview().priority(.medium)
            }
            
            self.copyrightLabel.snp.makeConstraints { (make) in
                make.leading.trailing.equalToSuperview()
                make.bottom.equalTo(self.snp.bottom).inset(40)
            }
            
            self.opaqueBackgroundImage.snp.makeConstraints { (make) in
                make.trailing.equalTo(25)
                make.top.equalTo(self.actionButton.snp.top)
            }
        }
        
        private func setupFieldView(_ fieldView: FieldView, field: Field) {
            fieldView.titleLabel.text = field.title
            
            fieldView.textField.text = field.text
            fieldView.textField.placeholder = field.placeholder
            fieldView.textField.keyboardType = field.keyboardType
            fieldView.textField.autocapitalizationType = field.autocapitalize
            fieldView.textField.autocorrectionType = field.autocorrection
            fieldView.textField.isSecureTextEntry = field.secureInput
            fieldView.textField.delegate = self
            fieldView.textEditingEnabled = field.editable
            
            switch field.fieldType {
                
            case .scanServerInfo:
                fieldView.actionType = .scanQr
                fieldView.actionButton.rx
                    .controlEvent(.touchUpInside)
                    .asDriver()
                    .drive(onNext: { [weak self] in
                        self?.onScanQRAction?()
                    })
                    .disposed(by: self.disposeBag)
                
            case .text(let purpose):
                switch purpose {
                    
                case .confirmPassword, .password:
                    fieldView.actionType = field.secureInput
                        ? .showPassword
                        : .hidePassword
                    
                    fieldView.actionButton.rx
                        .controlEvent(.touchUpInside)
                        .asDriver()
                        .drive(onNext: { [weak self] in
                            self?.changePasswordVisibility(
                                field: field,
                                actionType: fieldView.actionType
                            )
                        })
                        .disposed(by: self.disposeBag)
                    
                case .email:
                    break
                }
                
                fieldView.textField.rx
                    .text
                    .asDriver()
                    .drive(onNext: { [weak self] text in
                        self?.onEditField?(purpose, text)
                        self?.updateFieldText(field: field, text: text)
                    })
                    .disposed(by: self.disposeBag)
                fieldView.textField.rx
                    .controlEvent(.editingDidEndOnExit)
                    .asDriver()
                    .drive(onNext: { [weak self] in
                        self?.onFieldShouldReturn?(purpose)
                    })
                    .disposed(by: self.disposeBag)
            }
        }
        
        private func setupSeparator(_ separator: UIView) {
            separator.backgroundColor = .clear //Theme.Colors.separatorOnContentBackgroundColor
            separator.isUserInteractionEnabled = false
        }
        
        private func setFields(_ fields: [Field]) {
            for fieldView in self.fieldViews {
                fieldView.removeFromSuperview()
            }
            self.fieldViews.removeAll()
            self.textFields.removeAll()
            self.fields = []
            
            guard fields.count > 0 else { return }
            
            var prevField: FieldView?
            var prevSeparator: UIView = UIView()
            self.setupSeparator(prevSeparator)
            self.fieldsContainerView.addSubview(prevSeparator)
            self.fieldViews.append(prevSeparator)
            prevSeparator.snp.makeConstraints { (make) in
                make.leading.trailing.equalToSuperview().inset(self.marginInset)
                make.top.equalToSuperview()
                make.height.equalTo(self.separatorHeight)
            }
            let fields_indent: CGFloat = 18
            for field in fields {
                let textField = FieldView()
                self.setupFieldView(textField, field: field)
                
                self.fieldsContainerView.addSubview(textField)
                textField.snp.makeConstraints { (make) in
                    make.leading.trailing.equalToSuperview().inset(self.marginInset)
                    make.height.equalTo(self.fieldHeight)
                    if let prevField = prevField {
                        make.top.equalTo(prevField.snp.bottom).offset(ceil(self.separatorHeight) + fields_indent)
                    } else {
                        make.top.equalToSuperview().offset(ceil(self.separatorHeight) + 1.0)
                    }
                }
                prevField = textField
                self.textFields.append(textField)
                self.fieldViews.append(textField)
                
                let separator = UIView()
                self.setupSeparator(separator)
                self.fieldsContainerView.addSubview(separator)
                separator.snp.makeConstraints { (make) in
                    make.leading.trailing.equalTo(prevSeparator)
                    make.height.equalTo(self.separatorHeight)
                    make.top.equalTo(textField.snp.bottom).offset(1.0)
                }
                self.fieldViews.append(separator)
                prevSeparator = separator
            }
            
            prevSeparator.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview()
            }
            
            self.fields = fields
        }
        
        private func setSubActions(_ subActions: [Model.SubActionViewModel]) {
            for subActionView in self.subActionViews {
                subActionView.removeFromSuperview()
            }
            self.subActionViews.removeAll()
            
            guard subActions.count > 0 else { return }
            
            var prevView: UIView = self.actionButton
            for (index, subAction) in subActions.enumerated() {
                let subActionView: UIView
                
                switch subAction {
                    
                case .agreeOnTerms(let checked):
                    subActionView = self.getAgreeOnTermsView(checked: checked, index: index)
                    
                case .text(let title):
                    subActionView = self.getSubActionTextButton(title: title, index: index)
                }
                
                self.scrollView.addSubview(subActionView)
                subActionView.snp.makeConstraints { (make) in
                    make.leading.trailing.equalToSuperview().inset(self.marginInset)
                    make.height.equalTo(40.0)
                    make.top.equalTo(prevView.snp.bottom).offset(5.0)
                }
                self.subActionViews.append(subActionView)
                
                prevView = subActionView
            }
            
            prevView.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview().priority(.high)
            }
        }
        
        private func getSubActionTextButton(title: NSAttributedString, index: Int) -> UIButton {
            let subActionButton = UIButton(type: .system)
            subActionButton.setAttributedTitle(title, for: .normal)
            subActionButton
                .rx
                .controlEvent(.touchUpInside)
                .asDriver()
                .drive(onNext: { [weak self] in
                    self?.endEditing(true)
                    self?.onSubActionButton?(index)
                })
                .disposed(by: self.disposeBag)
            
            return subActionButton
        }
        
        private func getAgreeOnTermsView(checked: Bool, index: Int) -> UIView {
            let agreeOnTermsView = AgreeOnTermsView()
            
            agreeOnTermsView.onAgreeChecked = { [weak self] (checked) in
                self?.onAgreeOnTerms?(checked)
            }
            
            agreeOnTermsView.onAction = { [weak self] in
                self?.onSubActionButton?(index)
            }
            
            return agreeOnTermsView
        }
        
        private func changePasswordVisibility(
            field: View.Field,
            actionType: Model.Field.ActionType
            ) {
            
            guard var fieldToChange = self.fields.first(where: { (storedField) -> Bool in
                return storedField.fieldType == field.fieldType
            }), let index = self.fields.indexOf(fieldToChange) else {
                return
            }
            fieldToChange.secureInput = !fieldToChange.secureInput
            self.fields[index] = fieldToChange
            self.setFields(self.fields)
        }
        
        private func updateFieldText(
            field: View.Field,
            text: String?
            ) {
            
            guard var fieldToChange = self.fields.first(where: { (storedField) -> Bool in
                return storedField.fieldType == field.fieldType
            }), let index = self.fields.indexOf(fieldToChange) else {
                return
            }
            fieldToChange.text = text
            self.fields[index] = fieldToChange
        }
    }
}

// MARK: - UITextFieldDelegate

extension RegisterScene.View: UITextFieldDelegate {
    
}

// MARK: - Field

extension RegisterScene.View {
    struct Field: Equatable {
        let fieldType: RegisterScene.Model.Field.FieldType
        let title: String
        var text: String?
        let placeholder: String?
        let keyboardType: UIKeyboardType
        let autocapitalize: UITextAutocapitalizationType
        let autocorrection: UITextAutocorrectionType
        var secureInput: Bool
        let editable: Bool
        
        public static func == (
            lhs: RegisterScene.View.Field,
            rhs: RegisterScene.View.Field
            ) -> Bool {
            
            return lhs.fieldType == rhs.fieldType
        }
    }
}
