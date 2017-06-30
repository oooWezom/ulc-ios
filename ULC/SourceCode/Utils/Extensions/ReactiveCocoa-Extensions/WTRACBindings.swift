//
//  RACBindings.swift
//

// from https://github.com/mpurland/ReactiveBind/blob/master/ReactiveBind/ViewBinding.swift
// https://github.com/mpurland/ReactiveBind/blob/master/ReactiveBind/Binding.swift

import Foundation
import ReactiveCocoa
import UIKit
import enum Result.NoError

// http://stackoverflow.com/a/35206439/2238082
public typealias NoError = Result.NoError

// swiftlint:disable variable_name
// swiftlint:disable opening_brace

public enum ReactiveBindAssocationKey: String {
    case Hidden
    case Alpha
    case BackgroundColor
    case Text
    case AttributedText
    case Enabled
    case Highlighted
    case Selected
    case Image
    case Date
    case Slider
}

public struct ReactiveBindAssocationKeys {
    static var HiddenProperty = ReactiveBindAssocationKey.Hidden.rawValue
    static var AlphaProperty = ReactiveBindAssocationKey.Alpha.rawValue
    static var BackgroundColorProperty = ReactiveBindAssocationKey.BackgroundColor.rawValue
    static var TextProperty = ReactiveBindAssocationKey.Text.rawValue
    static var AttributedTextProperty = ReactiveBindAssocationKey.AttributedText.rawValue
    static var EnabledProperty = ReactiveBindAssocationKey.Enabled.rawValue
    static var HighlightedProperty = ReactiveBindAssocationKey.Highlighted.rawValue
    static var SelectedProperty = ReactiveBindAssocationKey.Selected.rawValue
    static var ImageProperty = ReactiveBindAssocationKey.Image.rawValue
    static var DateProperty = ReactiveBindAssocationKey.Date.rawValue
    static var SliderProperty = ReactiveBindAssocationKey.Slider.rawValue
}

public func lazyAssociatedProperty<T: AnyObject>(host: AnyObject, _ key: UnsafePointer<Void>, _ factory: () -> T) -> T {
    var associatedProperty = objc_getAssociatedObject(host, key) as? T

    if associatedProperty == nil {
        associatedProperty = factory()
        objc_setAssociatedObject(host, key, associatedProperty,
            objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    return associatedProperty!
}

public func lazyMutableProperty<T>(host: AnyObject, _ key: UnsafePointer<Void>, _ setter: T -> (), _ getter: () -> T)
    -> MutableProperty<T> {

    return lazyAssociatedProperty(host, key) {
        let property = MutableProperty<T>(getter())

        property.producer.startWithNext { newValue in
            setter(newValue)
        }

        return property
    }
}

public func lazyMutablePropertyDefaultValue<T>(host: AnyObject, _ key: UnsafePointer<Void>, _ defaultValue: () -> T)
    -> MutableProperty<T> {

    return lazyAssociatedProperty(host, key) {
        let property = MutableProperty<T>(defaultValue())
        return property
    }
}

public func lazyMutablePropertyOptional<T>(host: AnyObject, _ key: UnsafePointer<Void>,
    _ setter: T? -> (), _ getter: () -> T?) -> MutableProperty<T?> {

    return lazyAssociatedProperty(host, key) {
        let property = MutableProperty<T?>(getter())

        property.producer.startWithNext { newValue in
            setter(newValue)
        }

        return property
    }
}

extension UIView {
    public var rac_alpha: MutableProperty<CGFloat> {
        return lazyMutableProperty(self, &ReactiveBindAssocationKeys.AlphaProperty,
            { self.alpha = $0 }, { self.alpha  })
    }

    public var rac_hidden: MutableProperty<Bool> {
        return lazyMutableProperty(self, &ReactiveBindAssocationKeys.HiddenProperty,
            { self.hidden = $0 }, { self.hidden  })
    }

    public var rac_backgroundColor: MutableProperty<UIColor?> {
        return lazyMutableProperty(self, &ReactiveBindAssocationKeys.BackgroundColorProperty,
            { self.backgroundColor = $0 }, { self.backgroundColor  })
    }
}

extension UIBarItem {
    public var rac_enabled: MutableProperty<Bool> {
        return lazyMutableProperty(self, &ReactiveBindAssocationKeys.EnabledProperty,
            { self.enabled = $0 }, { self.enabled  })
    }
}

extension UIControl {
    public var rac_enabled: MutableProperty<Bool> {
        return lazyMutableProperty(self, &ReactiveBindAssocationKeys.EnabledProperty,
            { self.enabled = $0 }, { self.enabled  })
    }

    public var rac_highlighted: MutableProperty<Bool> {
        return lazyMutableProperty(self, &ReactiveBindAssocationKeys.HighlightedProperty,
            { self.highlighted = $0 }, { self.highlighted  })
    }

    public var rac_selected: MutableProperty<Bool> {
        return lazyMutableProperty(self, &ReactiveBindAssocationKeys.SelectedProperty,
            { self.selected = $0 }, { self.selected  })
    }
}

extension UILabel {
    public var rac_text: MutableProperty<String?> {
        return lazyMutableProperty(self, &ReactiveBindAssocationKeys.TextProperty,
            { self.text = $0 }, { self.text  })
    }

    public var rac_attributedText: MutableProperty<NSAttributedString?> {
        return lazyMutableProperty(self, &ReactiveBindAssocationKeys.AttributedTextProperty,
            { self.attributedText = $0 }, { self.attributedText  })
    }
}

extension UITextField {
    public var rac_text: MutableProperty<String> {
        return lazyAssociatedProperty(self, &ReactiveBindAssocationKeys.TextProperty) {
            self.rac_signalForControlEvents(UIControlEvents.EditingChanged).toSignalProducer().startWithResult { _ in
                let value = self.text ?? ""
                self.rac_text.value = value
            }

            let property = MutableProperty<String>(self.text ?? "")

            property.producer.startWithNext { newValue in
                self.text = newValue
            }

            return property
        }
    }
}

extension UITextField {
    // A property that represents the active status of whether the text field
    // is being edited (active) or not being edited (not active)
    public var rac_active: SignalProducer<Bool, NoError> {
        let property = MutableProperty<Bool>(false)

        rac_signalForControlEvents(UIControlEvents.EditingDidBegin).toSignalProducer().startWithResult { _ in
            Swift.debugPrint("text field: \(self) active")
            property.value = true
        }

        rac_signalForControlEvents(UIControlEvents.EditingDidEnd).toSignalProducer().startWithResult { _ in
            Swift.debugPrint("text field: \(self) inactive")
            property.value = false
        }

        return property.producer.skip(1).skipRepeats()
    }
}

extension UIImageView {
    public var rac_image: MutableProperty<UIImage?> {
        return lazyMutableProperty(self, &ReactiveBindAssocationKeys.ImageProperty,
            { self.image = $0 }, { self.image })
    }
}

extension UITableViewCell {
    public var rac_highlighted: MutableProperty<Bool> {
        return lazyMutableProperty(self, &ReactiveBindAssocationKeys.HighlightedProperty,
            { self.highlighted = $0 }, { self.highlighted  })
    }

    public var rac_selected: MutableProperty<Bool> {
        return lazyMutableProperty(self, &ReactiveBindAssocationKeys.SelectedProperty,
            { self.selected = $0 }, { self.selected  })
    }

    public var rac_prepareForReuseSignalProducer: SignalProducer<Void, NoError> {
        return rac_prepareForReuseSignal
            .toSignalProducer()
            .flatMapError({ _ in return SignalProducer<AnyObject?, NoError>.empty })
            .map({ _ in })
    }
}

extension UICollectionViewCell {
    public var rac_highlighted: MutableProperty<Bool> {
        return lazyMutableProperty(self, &ReactiveBindAssocationKeys.HighlightedProperty,
            { self.highlighted = $0 }, { self.highlighted  })
    }

    public var rac_selected: MutableProperty<Bool> {
        return lazyMutableProperty(self, &ReactiveBindAssocationKeys.SelectedProperty,
            { self.selected = $0 }, { self.selected  })
    }
}

extension NSObject {
    func rac_willDeallocSignalProducer() -> SignalProducer<(), NoError> {
        return rac_willDeallocSignal().toSignalProducer()
            .map { _ in () }
            .flatMapError { _ in SignalProducer<(), NoError>.empty  }
    }
}

extension UISearchBar: UISearchBarDelegate {
    public var rac_text: MutableProperty<String> {
        return lazyAssociatedProperty(self, &ReactiveBindAssocationKeys.TextProperty) {

            self.delegate = self
            self.rac_signalForSelector(#selector(UISearchBarDelegate.searchBar(_:textDidChange:)),
                fromProtocol: UISearchBarDelegate.self)
                .toSignalProducer()
                .takeUntil(self.rac_willDeallocSignalProducer())
                .startWithResult({ [weak self] _ in
                    self?.changed()

                    })

            let property = MutableProperty<String>(self.text ?? "")
            property.producer.startWithNext { newValue in
                self.text = newValue
            }
            return property
        }
    }

    func changed() {
        rac_text.value = self.text ?? ""
    }
}


extension UISlider {
    public var rac_value: MutableProperty<Float> {
        return lazyAssociatedProperty(self, &ReactiveBindAssocationKeys.SliderProperty) {

            self.addTarget(self, action: #selector(UISearchBar.changed),
                           forControlEvents: UIControlEvents.ValueChanged)

            let property = MutableProperty<Float>(self.value)
            property.producer.startWithNext { newValue in
                self.setValue(newValue, animated: true)
            }
            return property
        }
    }

    func changed() {
        rac_value.value = self.value
    }
}

extension UIDatePicker {
    public var rac_date: MutableProperty<NSDate> {
        return lazyAssociatedProperty(self, &ReactiveBindAssocationKeys.DateProperty) {

            self.addTarget(self, action: #selector(UISearchBar.changed),
                           forControlEvents: UIControlEvents.ValueChanged)

            let property = MutableProperty<NSDate>(self.date)
            property.producer.startWithNext { newValue in
                self.setDate(newValue, animated: true)
            }
            return property
        }
    }

    func changed() {
        rac_date.value = self.date
    }
}


// swiftlint:enable variable_name
// swiftlint:enable opening_brace
