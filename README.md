Attributable
============
Allows you to easily define getters/setters for attributes on your class
and invoke callbacks when those attributes change.

Usage
-----

A simple example may look like this:

    class Button extends Object with Attributable {

      final List attribute_names = ['caption', 'color', 'enabled'];

      final Map attribute_callbacks = {
        'default' : (attr_name, self) => print("Attribute $attr_name now has a new value: ${self.attributes[attr_name]}"), 
        'caption' : (attr_name, self) => print("Caption is now '${self.caption}'"), 
        'enabled' : (attr_name, self) => print("Enabled is now set to '${self.enabled}'") 
      };

      // Don't forget noSuchMethod() definition here (see below) or it won't work!

    }

The `default` callback is invoked if no other callback for the given attribute is defined.
Obviously, you may omit it, so nothing happens when your attribute changes.

So now we can create instances of our class and set attributes on them:

    main() {

      var button = new Button();

      button.caption = "New caption"; // => Caption is now 'New caption' 
      button.enabled = true;          // => Enabled is now set to 'true' 
      button.color   = 'green';       // => Attribute color now has a new value: green

    }

There's also a method which allows updating many attributes all at once:

    button.updateAttributes({ 'caption': 'New caption', 'color': 'green'});

Needless to say, callbacks will also be invoked for the attributes listed.
The `updateAttributes()` is slightly more powerful, see documenation to learn more.

IMPORTANT: at this point, in order for this to work, it is not enough to simply mix this
abstract class into your class, you also have to define `noSuchMethod()` callback
manually in your class, so that it looks something like the following:

    noSuchMethod(Invocation i) {  
      var result = prvt_noSuchGetterOrSetter(i);
      if(result)
        return result;
      else
        super(i);
    }

The Invocation object gets passed into the `prvt_noSuchGetterOrSetter(i)`
which then checks if any attribute with such a name is defined on the class.
If not, then we return control to your class and it gets to call its original
`noSuchMethod()` method, which, most likely, will generate an exception.
Of course, if your class has its own `noSuchMethod()` functionality, you'd have
take it into account and construct the method accordingly.

See `/example/button.dart` for an example (you can run it from the terminal).
