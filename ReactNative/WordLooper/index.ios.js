/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { Component } from 'react';
import {
  AppRegistry
} from 'react-native';

var CachedView = require('./cachedview');
var MainView = require('./mainview');


import {
  StackNavigator,
} from 'react-navigation';

const App = StackNavigator({
  Main: {screen: MainView},
  CachedView: {screen: CachedView},
});


AppRegistry.registerComponent('WordLooper', () => App);
