library attributable;
import 'dart:mirrors';

class NoSuchAttributeException implements Exception {
  String cause;
  NoSuchAttributeException(this.cause);
}

/**
  * Allows you to easily define getters/setters for attributes on your class
  * and invoke callbacks when those attributes change.
  *
  * Please see README for explanation and code samples and ../examples/ for 
  * an example of a class that employs attributable.
  */
abstract class Attributable {

  /// A Map of all the callbacks for the attributes that are invoked when an attribute changes.
  final Map  attribute_callbacks = {};

  /// Attributes names and values for them, stored as a map. Do not fuck with this
  /// property. Read from it, but don't write.
  final Map  attributes = {};

  /// Previous attribute values end up here. Useful to find out whether something has changed.
  final Map  old_attribute_values = {};

  /// This property defines which attributes get to be attributes: they will have defined
  /// getters and setters for them.
  final List attribute_names = [];

  /// Sometimes we want to set attributes to their default value.
  /// the #setDefaultAttributeValues does exactly for each attribute name and value listed
  /// in this property.
  final Map default_attribute_values = {};

  /**
   * Invokes a callback for a given attribute. If no callback for that specific attribute is defined,
   * invokes a callback named `default` (if that one is defined, of course).
   */
  invokeAttributeCallback(attr_name) {
    if(attribute_callbacks[attr_name] != null) {
      attribute_callbacks[attr_name](attr_name, reflect(this).reflectee);
    } else if(attribute_callbacks['default'] != null) {
      attribute_callbacks['default'](attr_name, reflect(this).reflectee);
    };
  }

  /**
   * Checks whether a given attribute had a previous value different from the current one.
   */
  hasAttributeChanged(attr_name) {
    if(!attribute_names.contains(attr_name))
      throw new Exception("No attribute `$attr_name` was found in $this");
    return !(attributes[attr_name] == old_attribute_values[attr_name]);
  }

  /**
   * Updates registered attributes with values provided, then run callbacks on them.
   * Optionally, one can provide a function to be run after the attributes are set. If this
   * function evalutes to false, no callbacks would be run (useful in validations).
   */
  updateAttributes(Map new_values, [func = null]) {

    if(new_values == null)
      return;

    var changed_attrs = [];

    new_values.forEach((k,v) { 
      if(attribute_names.contains(k)) {
        attributes[k] = v;
        changed_attrs.add(k);
      } else if(k.contains('.')) { /* do nothing */ 
      } else {
        throw Exception('$this doesn\'t have attribute \'$k\'');
      }
    });

    if(func == null || func()) {
      new_values.forEach((k,v) {
        invokeAttributeCallback(k);
      });
      return true;
    } else {
      return false;
    }

  }

  void setDefaultAttributeValues() {
    this.default_attribute_values.forEach((k,v) {
      if(this.attributes[k] == null)
        this.attributes[k] = v;
    });
  }

  /**
   * THIS IS A PRIVATE METHOD!
   * 
   * Catches getter and setter calls for non-existent instance variables
   * and then uses attributes[] List to get and set values.
   *
   * This method should be called from noSuchMethod() callback in the class
   * in which this mixin is included. It returns false if no attribute was found.
   * You can later check for the return value and decide what to do next in the
   * noSuchMethod() callback in your class.
  */
  prvt_noSuchGetterOrSetter(Invocation i) {
    
    var attr_name = MirrorSystem.getName(i.memberName).replaceFirst(new RegExp('='), '');

    var get_me_old_value = false;
    if(attr_name.contains(new RegExp(r'^_old_'))) {
      attr_name        = attr_name.replaceFirst(new RegExp(r'^_old_'), '');
      get_me_old_value = true;
    }

    if(!attribute_names.contains(attr_name)) { throw new NoSuchAttributeException("No attribute `$attr_name` was found in $this"); }

    if(i.isSetter) {
      old_attribute_values[attr_name] = attributes[attr_name];
      attributes[attr_name]           = i.positionalArguments[0];
      invokeAttributeCallback(attr_name);
      return true;
    } else {
      if(get_me_old_value)
        return old_attribute_values[attr_name];
      else
        return attributes[attr_name];
    }
  }


}
