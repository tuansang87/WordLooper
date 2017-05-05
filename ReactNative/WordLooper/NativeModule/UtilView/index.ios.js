'use strict';

var React = require('react');
var ReactNative = require('react-native');

var {
  requireNativeComponent,
  NativeModules: {
    UtilsViewwManager
  }
} = ReactNative;

var { PropTypes } = React;


var RCTUtilsView = requireNativeComponent('UtilsView', UtilsView);


/**
 * Renders a native UtilsView.
 */
var UtilsView = React.createClass({

  statics: {
    fecthAudioLinkForWord(word) {
      UtilsViewwManager.fecthAudioLinkForWord(word , this._viewHandle);
    },
    test(word) {
      alert(word);
      UtilsViewwManager.test(word);
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
        onSubmit={this.props.onAudioLinkDetectedCallback}
      />
    );

  },

  _viewHandle: null,
  componentDidMount() {
    this._viewHandle = ReactNative.findNodeHandle(this.refs['RCTUtilsView']);
  },

});




module.exports = UtilsView;