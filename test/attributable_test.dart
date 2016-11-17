import "package:test/test.dart";
import "dart:mirrors";
import "../lib/attributable.dart";

class DummyClass extends Object with Attributable {

  List attribute_callbacks_called = [];

  final List attribute_names          = ['caption', 'title', 'attr1', 'attr2', 'attr3'];
  final Map default_attribute_values = { 'attr3' : 'default_value'};
  final Map  attribute_callbacks = {
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
    dummy.updateAttributes({ 'caption' : 'new caption' }, callback: () => false);
    expect(dummy.attribute_callbacks_called.contains('caption'), isFalse);
  });

  test("sets default values for attributes", () {
    dummy.setDefaultAttributeValues();
    expect(dummy.attr3, equals("default_value"));
  });

  test("throws error if attribute doesn't exist and someone tries to update it with updateAttributes()", () {
    expect(() => dummy.updateAttributes({ 'non_existent_attr' : 'new caption' }), throws);
  });

  test("doesn't throw error if attribute doesn't exist but `ingore_non_existent: true` is passed to updateAttributes()", () {
    expect(() => dummy.updateAttributes({ 'non_existent_attr' : 'new caption' }, ignore_non_existent: true), returnsNormally);
  });
  

}

