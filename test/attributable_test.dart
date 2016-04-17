import 'dart:mirrors';
import 'package:validatable/validatable.dart';
import '../lib/attributable.dart';

class DummyClass extends Object with Attributable, Validatable {

  List attribute_callbacks_called = [];

  final List attribute_names     = ['caption', 'title', 'attr1', 'attr2'];
  final List attribute_callbacks = {
    'default' : (attr_name, self) => self.attribute_callbacks_called.add('default'),
    'caption' : (attr_name, self) => self.attribute_callbacks_called.add('caption')
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

  var dummy;
  setUp(() {
    dummy = new DummyClass();
  });

  test('returns an attribute value when a getter is called', () {
    dummy.caption = 'New Caption';
    expect(dummy.caption, equals('New Caption'));
  });

  test('invokes a callback whenever an attribute is changed', () {
    dummy.caption = 'New Caption';
    expect(dummy.attribute_callbacks_called.contains('caption'), isTrue);
  });

  test('invokes a default callback if no custom callback for the attribute is defined', () {
    dummy.title   = 'New Title';
    expect(dummy.attribute_callbacks_called.contains('default'), isTrue);
  });

  test('keeps previous value of the attribute', () {
    dummy.title   = 'Title 1';
    dummy.title   = 'Title 2';
    expect(dummy._old_title, equals('Title 1'));
  });

  test('tells if new value is different from the old one', () {
    dummy.title   = 'Title 1';
    dummy.title   = 'Title 2';
    expect(dummy.hasAttributeChanged('title'), isTrue);
    dummy.title   = 'Title 2';
    expect(dummy.hasAttributeChanged('title'), isFalse);
  });

  test('updates attributes in bulk', () {
    var dummy = new DummyClass();
    dummy.updateAttributes({ 'caption' : 'new caption', 'title': 'new title'});
    expect(dummy.caption, equals('new caption'));
    expect(dummy.title,   equals('new title'));
  });

  test('while updating attributes in bulk, ignores those with a dot', () {
    var dummy = new DummyClass();
    // Doesn't raise an exception!
    dummy.updateAttributes({ 'some_associated_object.caption' : 'new caption'});
  });

  test('runs callbacks on attributes after updating them in bulk', () {
    var dummy = new DummyClass();
    dummy.updateAttributes({ 'caption' : 'new caption' });
    expect(dummy.attribute_callbacks_called.contains('caption'), isTrue);
  });

  test('doesn\'t run callbacks on attributes after updating them in bulk if closure evaluates to false', () {
    var dummy = new DummyClass();
    dummy.updateAttributes({ 'caption' : 'new caption' }, () => false);
    expect(dummy.attribute_callbacks_called.contains('caption'), isFalse);
  });

}
