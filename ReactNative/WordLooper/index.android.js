 import React, { Component } from 'react';
import {
  AppRegistry
} from 'react-native';

var CachedView = require('./cachedview.ios');
var MainView = require('./mainview.ios');


import {
  StackNavigator,
} from 'react-navigation';

const App = StackNavigator({
  Main: {screen: MainView},
  CachedView: {screen: CachedView},
});


AppRegistry.registerComponent('WordLooper', () => App);

