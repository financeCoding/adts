// Copyright (c) 2012, Google Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// Author: Paul Brauner (polux@google.com)

library ast;

import 'package:persistent/persistent.dart';

_toString(x) => x.toString();

class Module {
  final Option<String> libraryName;
  final List<DataTypeDefinition> adts;
  final List<Class> classes;

  Module(this.libraryName, this.adts, this.classes);

  String toString() {
    return 'Module($libraryName, $adts, $classes)';
  }
}

class DataTypeDefinition {
  final String name;
  final List<String> variables;
  final List<Constructor> constructors;

  DataTypeDefinition(this.name, this.variables, this.constructors);

  String toString() {
    String args = variables.join(', ');
    String constrs = constructors.map(_toString).join(' | ');
    return "adt $name<$args> = $constrs";
  }
}

class Constructor {
  final String name;
  final List<Parameter> parameters;

  Constructor(this.name, this.parameters);

  Constructor subst(Map<String, TypeAppl> s) {
    return new Constructor(name, parameters.map((p) => p.subst(s)).toList());
  }

  String toString() {
    String params = parameters.map(_toString).join(', ');
    return "$name($params)";
  }
}

class Parameter {
  final String name;
  final TypeAppl type;

  Parameter(this.type, this.name);

  Parameter subst(Map<String, TypeAppl> s) {
    return new Parameter(type.subst(s), name);
  }

  String toString() => "$type $name";
}

class TypeAppl {
  final String name;
  final List<TypeAppl> arguments;

  TypeAppl(this.name, this.arguments);

  // Warning: the generator depends on this behavior
  String toString() {
    if (arguments.isEmpty) return name;
    else {
      String args = arguments.map(_toString).join(', ');
      return "$name<$args>";
    }
  }

  static bool _same(List xs, List ys) {
    if (xs.length != ys.length) return false;
    for (int i = 0; i < xs.length; i++) {
      if (xs[i] != ys[i]) return false;
    }
    return true;
  }


  TypeAppl subst(Map<String, TypeAppl> s) {
    return (s.containsKey(name) && arguments.isEmpty)
        ? s[name]
        : new TypeAppl(name, arguments.map((ty) => ty.subst(s)).toList());
  }

  bool operator ==(TypeAppl appl) {
    return (appl is TypeAppl)
        && name == appl.name
        && _same(arguments, appl.arguments);
  }

  int get hashCode => name.hashCode;
}

class Class {
  final String name;
  Map<String, Method> methods;

  Class(this.name, methods) {
    this.methods = {};
    for (final m in methods) {
      this.methods[m.name] = m;
    }
  }

  String toString() {
    return 'Class($name, $methods)';
  }
}


class Method {
  final String name;
  final String text;

  Method(this.name, this.text);

  toString() => 'Method($name, $text)';
}