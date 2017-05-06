'use strict';

var React = require('react');
import ReactNative from 'react-native';

var {
  requireNativeComponent,
  NativeModules: {
    UtilsViewManager
  }
} = ReactNative;

var { PropTypes } = React;

var _viewHandle = 0; 
var RCTUtilsView = requireNativeComponent('UtilsView', UtilsView);


/**
 * Renders a native UtilsView.
 */
var UtilsView = React.createClass({

  statics: {
    fecthAudioLinkForWord(word,forcePlay) {
      console.log(forcePlay);
      if(word != null && typeof(word) != 'undefined' ) {
        
        UtilsViewManager.fecthAudioLinkForWord(word , forcePlay, _viewHandle);
      }
    },
    playSound(soundUrl) {
      UtilsViewManager.playSound(soundUrl, _viewHandle);
    }
  },
  propTypes: {
    // back and submit action
    onAudioLinkDetectedCallback: PropTypes.func

  },


  render() {

    return (
      <RCTUtilsView
        ref={'RCTUtilsView'}
        // back and submit action
        onAudioLinkDetectedCallback={this.props.onAudioLinkDetectedCallback}
      />
    );

  },

 
  componentDidMount() { 
    _viewHandle = ReactNative.findNodeHandle(this.refs['RCTUtilsView']);
     
  },

});




module.exports = UtilsView;
