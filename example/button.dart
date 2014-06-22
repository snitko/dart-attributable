import '../lib/attributable.dart';

class Button extends Object with Attributable {

  // Define attributes so attributable knows which getters
  // and setters to create.
  final List attribute_names = ['caption', 'color', 'enabled'];

  // Every time an attribute changes, a callback is fired.
  final Map attribute_callbacks = {
    'default' : (attr_name, self) => print("Attribute $attr_name now has a new value: ${self.attributes[attr_name]}"), 
    'caption' : (attr_name, self) => print("Caption is now '${self.caption}'"), 
    'enabled' : (attr_name, self) => print("Enabled is now set to '${self.enabled}'") 
  };

  noSuchMethod(Invocation i) {
    var result = prvt_noSuchGetterOrSetter(i);
    if(result != false)
      return result;
    else
      super.noSuchMethod(i);
  }

}

main() {

  var button = new Button();

  button.caption = "New caption"; // => Caption is now 'New caption' 
  button.enabled = true;          // => Enabled is now set to 'true' 
  button.color   = 'green';       // => Attribute color now has a new value: green

}
