library attributable;
import 'dart:mirrors';

/* If you'd like to have attributes in you class that can invoke callbacks when they change,
  this mixin is for you. However, it is not enough to just include it into the class.
   
  1. You also have to define noSuchMethod() callback in your class and call
  noSuchGetterOrSetter() from it, passing it the invocation object. Most likely you'd like
  something like this in your class:

  noSuchMethod(Invocation i) {  
    var result = prvt_noSuchGetterOrSetter(i);
    if(result)
      return result;
    else
      super(i);
  }

  2. You have to define attribute_callbacks and attributes Lists in you class

*/
abstract class Attributable {

  final Map  attribute_callbacks  = {};
  final Map  attributes           = {};
  final Map  old_attribute_values = {};
  final List attribute_names      = [];

  invokeAttributeCallback(attr_name) {
    if(attribute_callbacks[attr_name] != null) {
      attribute_callbacks[attr_name](attr_name, reflect(this).reflectee);
    } else if(attribute_callbacks['default'] != null) {
      attribute_callbacks['default'](attr_name, reflect(this).reflectee);
    };
  }

  hasAttributeChanged(attr_name) {
    if(!attribute_names.contains(attr_name))
      throw new Exception("No attribute `$attr_name` was found in $this");
    return !(attributes[attr_name] == old_attribute_values[attr_name]);
  }

  /* Updates all registered attributes and runs validations afterwards (if Validation mixin is included) */
  updateAttributes(Map new_values) {

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

    // This validatable piece is currently commented out
    // and should probably not be here. It should be up to the user of
    // the library to include it (probably using callbacks provided by
    // attributable).
    /*if(this is Validatable) {*/
      /*validate();*/
      /*if(valid)*/
        /*changed_attrs.forEach((attr_name) => invokeAttributeCallback(attr_name));*/
    /*}*/

  }


  /* Catches getter and setter calls for non-existent instance variables
     and then uses attributes[] List to get and set values.

     This method should be called from noSuchMethod() callback in the class
     in which this mixin is included. It returns false if no attribute was found.
     You can later check for the return value and decide what to do next in the
     noSuchMethod() callback in your class.
  */
  prvt_noSuchGetterOrSetter(Invocation i) {
    
    var attr_name = MirrorSystem.getName(i.memberName).replaceFirst(new RegExp('='), '');

    var get_me_old_value = false;
    if(attr_name.contains(new RegExp(r'^_old_'))) {
      attr_name        = attr_name.replaceFirst(new RegExp(r'^_old_'), '');
      get_me_old_value = true;
    }

    if(!attribute_names.contains(attr_name)) { return false; }

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
