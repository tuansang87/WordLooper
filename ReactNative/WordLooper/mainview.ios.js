/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { Component } from 'react';
var ReactNative = require('react-native');
// var Drive = require('./google-drive.js');
// import GoogleSignIn from 'react-native-google-sign-in';
import {
  StyleSheet,
  Text,
  TextInput,
  Button,
  View,
  Image,
  TouchableOpacity,
  TouchableHighlight,
  WebView

} from 'react-native';

var UtilsView = require('./NativeModule/UtilView/index.ios.js');
const kWordPlayholder = 'input your word';
const WEBVIEW_REF = 'webview';
const LOOP_MODE_ALL_REF = 'all';
const LOOP_MODE_IMAGE_REF = 'image';
const WORD_INPUT_REF = 'word_input';

const LOOP_TYPE = { 'all': 1, 'image': 2, 'new': 3 };

var lastPlayWord = null;
export default class MainView extends Component {
  constructor(props) {
    super(props);
    this.state = {
      word: ''
      , word_uri: 'https://www.bing.com/search?q=define+hello'
      , loop_mode: LOOP_TYPE.all
    };
  }

  static navigationOptions = {
    title: 'Word Looper'
  };

  onPressPlayAudio() {
    // handle here

  };

  getAutioFileFromSource = (res) => {
    var contentUrlStr = "<source src=";


  };

  getBody = (body, encoding) => {
    // if (this.statusCode >= 300) {
    //   var err = new Error('Server responded with status code ' + this.statusCode + ':\n' + this.body.toString(encoding));
    //   err.statusCode = this.statusCode;
    //   err.headers = this.headers;
    //   err.body = this.body;
    //   throw err;
    // }
    return encoding ? body.toString(encoding) : body;
  }


  playCurentWord = () => {
    var word = this.state.word;
    UtilsView.fecthAudioLinkForWord(word, true);
  };

  onNewWordEndEditing = () => {

    UtilsView.fecthAudioLinkForWord(this.state.word, true);
  };

  onWordSearchingChanged = (word) => {
    this.setState({ word: word });
    this.loadDefinition(word, this.state.loop_mode);
  };

  loadDefinition = (word, loop_mode) => {
    var url = '';

    switch (loop_mode) {
      case LOOP_TYPE.all:
        url = 'https://www.bing.com/search?q=define+' + word + '&qs=n&FORM=HDRSC1';
        break;
      case LOOP_TYPE.image:
        url = 'https://www.bing.com/images/search?q=define+' + word + '&qs=n&FORM=HDRSC2';
        break;
      case LOOP_TYPE.new:
        url = 'https://www.bing.com/news/search?q=define+' + word + '&qs=n&FORM=HDRSC4';
        break;
      default:
        // url = 'https://www.bing.com/search?q=define+' + word + '&qs=n&FORM=HDRSC1';
        break;
    }
    this.setState({ word_uri: url });
    this.reload();
  };

  goBack = () => {
    this.refs[WEBVIEW_REF].goBack();
  };

  goForward = () => {
    this.refs[WEBVIEW_REF].goForward();
  };

  reload = () => {
    if (this.refs[WEBVIEW_REF] != null && typeof (this.refs[WEBVIEW_REF]) != 'undefined') {
      this.refs[WEBVIEW_REF].reload();
    }

  };

  onPressLoopModeAll = () => {
    this.setState({ loop_mode: LOOP_TYPE.all });

    this.loadDefinition(this.state.word, LOOP_TYPE.all);
    console.log('all');
  };

  onPressLoopModeImage = () => {
    this.setState({ loop_mode: LOOP_TYPE.image });

    this.loadDefinition(this.state.word, LOOP_TYPE.image);
    console.log('image');
  };


  onSignInPress = () => {
    // await GoogleSignIn.configure({
    //   // iOS
    //   clientID: '665124887696-7rsi9dd3nuje7eboqc867rs5i6161cao.apps.googleusercontent.com',

    //   // iOS, Android
    //   // https://developers.google.com/identity/protocols/googlescopes
    //   scopes: ['https://www.googleapis.com/auth/drive',
    //     'https://www.googleapis.com/auth/drive.appdata',
    //     'https://www.googleapis.com/auth/drive.file'],
    //   // iOS, Android
    //   // https://developers.google.com/identity/sign-in/ios/api/interface_g_i_d_sign_in.html#ae214ed831bb93a06d8d9c3692d5b35f9
    //   serverClientID: 'com.googleusercontent.apps.665124887696-7rsi9dd3nuje7eboqc867rs5i6161cao',
    // });

    // const user = GoogleSignIn.signInPromise()
    // .then((user => console.warn(JSON.stringify(user))));

    // console.warn(JSON.stringify(user));

    //  await Drive.configureGoogleSignIn().then(()=> GoogleSignIn.signInPromise()).then
    //  (userProfile => this.props.dispatchGoogleDrive(userProfile.accessToken))
    //  .catch(err => console.warn('configureGoogleSignIn' , err));

    // await configureGoogleSignIn()
    //   .then(() => GoogleSignIn.signInPromise()
    //     // dispatch a redux-thunk with the accessToken once signed in
    //     .then(userProfile => this.props.dispatchGoogleDrive(userProfile.accessToken))
    //     .catch(err => console.log('configureGoogleSignIn', err))
  };

  onDownload = () => {
    // this.props.navigation.navigate('CachedView', {'words' : [
    //             'Sang', 'Check', 'James', 'Jimmy', 'Jackson', 'Jillian', 'Julie', 'Devin'
    //         ]});

    this.onSignInPress();
  };
  onUpload = () => {
  };


  onAudioLinkDetectedCallback = (event) => {
    let link = event.nativeEvent.link;
    console.log(link);
    UtilsView.playSound(link);
  }
  onLoadCachedWordsCallback = (event) => {
    let data = event.nativeEvent.data;
    let words = data.words;
    console.log(JSON.stringify(words));
    be continue
    if (words.length > 0) {
      let firstWord = words[0];
      var word = firstWord.word;
      this.state.word = word;
      this.loadDefinition(word, this.state.loop_mode);

      UtilsView.fecthAudioLinkForWord(word, true);
    }
  }
  render = () => {


    // var jsCode = "\
    //   setTimeout(() => {\
    //    window.postMessage(check : document.documentElement.outerHTML.toString());\
    // } , 3000) \
    // ";
    // jsCode = "";

    return (

      <View style={styles.container}>
        <View style={styles.lookupContainer}>
          <Text style={styles.lookup}>
            Lookup:
          </Text>
          <TextInput
            ref={WORD_INPUT_REF}
            autoCapitalize='none'
            onEndEditing={() => this.onNewWordEndEditing()}
            style={styles.lookup_txt}
            value={this.state.word}
            onChangeText={(text) => this.onWordSearchingChanged(text)}
            placeholder={this.state.word}
          />

          <TouchableOpacity
            onPress={() => this.playCurentWord()}
            style={{ margin: 5, width: 30, height: 40, alignItems: 'center' }}
          >
            <Image style={styles.upload_img} source={require('./img/audio.png')} />
          </TouchableOpacity>

        </View>
        <View style={styles.topControlContainer}>
          <View style={styles.loopContainer}>
            <Button
              ref={LOOP_MODE_ALL_REF}
              onPress={() => this.onPressLoopModeAll()}
              style={styles.loop_mode_btn}
              color={this.state.loop_mode == LOOP_TYPE.all ? "blue" : "black"}
              title='All'
            >
            </Button>

            <Button
              ref={LOOP_MODE_IMAGE_REF}
              onPress={() => this.onPressLoopModeImage()}
              style={styles.loop_mode_btn}
              title='Image'
              color={this.state.loop_mode == LOOP_TYPE.image ? "blue" : "black"}
            >
            </Button>
          </View>

          <TouchableOpacity
            onPress={this.onDownload}
            style={styles.download_btn}>
            <Image style={styles.upload_img} source={require('./img/cloud-download.png')} />
          </TouchableOpacity>

          <TouchableOpacity
            onPress={this.onUpload}
            style={styles.upload_btn}>
            <Image style={styles.upload_img} source={require('./img/cloud-upload.png')} />
          </TouchableOpacity>
        </View>

        <View style={styles.definitionContainer}>
          <Text style={styles.definitions}>
            Definitions:
          </Text>
          <TextInput
            style={styles.definitions_txt}
            onChangeText={(text) => this.onWordSearchingChanged(text)}
            placeholder={this.state.word}
          />
        </View>
        <View style={styles.webviewContainer}>
          <WebView
            ref={WEBVIEW_REF}
            source={{ uri: this.state.word_uri }}
            style={styles.webview}
          />
        </View>
        <UtilsView
          ref={'UtilsView'}
          onAudioLinkDetectedCallback={(event) => this.onAudioLinkDetectedCallback(event)}
          onLoadCachedWordsCallback={this.onLoadCachedWordsCallback}
        />
      </View>
    );
  };
};


const styles = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'column',
    backgroundColor: '#F5FCFF',
  },
  lookupContainer: {
    // flex: 1,
    height: 40,
    flexDirection: 'row',
    backgroundColor: '#F5FCFF',
    paddingTop: 20,
    marginBottom: 20
  },
  lookup: {
    fontSize: 14,
    height: 40,
    textAlign: 'left',
    margin: 10
  },
  lookup_txt: {
    height: 40,
    flex: 1,
    paddingLeft: 8,
    borderWidth: 1,
  },
  upload_img: {
    width: 30
    , height: 30
  },
  webviewContainer: {
    flex: 1,
    margin: 0,
    backgroundColor: '#F5FCFF',
    overflow: 'hidden'

  },
  webview: {
    flex: 1,
    marginTop: -94,
    backgroundColor: '#F5FCFF'

  },
  definitionContainer: {
    flexDirection: 'row',
    backgroundColor: '#F5FCFF',
    height: 40,
    top: 10,
    alignItems: 'center'
  },
  definitions: {
    fontSize: 14,
    height: 40,
    textAlign: 'left',
    padding: 10
  },
  definitions_txt: {
    height: 30,
    flex: 1,
    paddingLeft: 8,
    borderWidth: 1,
    top: 0
  },
  topControlContainer: {
    flexDirection: 'row',
    backgroundColor: '#F5FCFF',
    height: 40,
    top: 10,
    alignItems: 'center'
  },
  loopContainer: {
    position: 'absolute',
    flexDirection: 'row',
    backgroundColor: '#F5FCFF',
    width: 200,
    // height: 40,
    left: 0,
    right: 20,
    alignItems: 'center'
  },
  upload_btn: { position: 'absolute', right: 50, margin: 5, width: 30, height: 40, alignItems: 'center' },
  download_btn: { position: 'absolute', right: 10, margin: 5, width: 30, height: 40, alignItems: 'center' },
  loop_mode_btn: { width: 50, height: 30, backgroundColor: 'blue', alignItems: 'center' }


});


module.exports = MainView;