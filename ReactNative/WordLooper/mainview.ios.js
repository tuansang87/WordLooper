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
import CheckBox from 'react-native-checkbox';

const kWordPlayholder = 'input your word';
const WEBVIEW_REF = 'webview';
const LOOP_MODE_ALL_REF = 'all';
const LOOP_MODE_IMAGE_REF = 'image';
const WORD_INPUT_REF = 'word_input';

const LOOP_TYPE = { 'all': 1, 'image': 2, 'new': 3 };
const LOOP_INTERVAL_TIME = 5000;

var lastPlayWord = null;
export default class MainView extends Component {
  constructor(props) {
    super(props);
    this.state = {
      word: ''
      , word_uri: 'https://www.bing.com/search?q=define+hello'
      , loop_mode: LOOP_TYPE.all
      , cached_words: []
      , current_play_index: 0
      , direction: 1 // 0 : back , 1 : forward
      , should_loop_cached_words: true
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

  };

  goBack = () => {
    this.refs[WEBVIEW_REF].goBack();
  };

  goForward = () => {
    this.refs[WEBVIEW_REF].goForward();
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

  };

  onDownload = () => {


    this.onSignInPress();
  };


  onLoadCachedWords = () => {
    this.props.navigation.navigate('CachedView', { 'words': this.state.cached_words ,
     callback : this.playCachedWord});
     
  };

  onUpload = () => {
    // handle here  
  };


  onAudioLinkDetectedCallback = (event) => {
    let link = event.nativeEvent.link;
    console.log(link);
    UtilsView.playSound(link);
  }
  onLoadCachedWordsCallback = (event) => {
    let data = event.nativeEvent;
    let words = data.words;
    console.log(JSON.stringify(words));
    // be continue
    this.setState({ cached_words: words });
    if (words.length) {
      this.doLoopForCacedWords();
    }

  }

  doLoopForCacedWords = () => {
    setTimeout(() => {
      if (this.state.should_loop_cached_words == true) {
        var index = this.state.current_play_index;
        let cachedCnt = this.state.cached_words.length;
        if (cachedCnt > 0) {
          if (index < 0) {
            index = cachedCnt - 1;
          } else if (index >= cachedCnt) {
            index = 0;
          }
          //updated next played index 
          if (this.state.direction == 0) {
            this.state.current_play_index = index - 1;
          } else {
            this.state.current_play_index = index + 1;
          }

          this.playCachedWordAtIndex(index);
          this.doLoopForCacedWords();
        } else {
          this.state.current_play_index = 0;
        }

      }

    }, LOOP_INTERVAL_TIME);

  };

  playCachedWordAtIndex = (index) => {
    let data = this.state.cached_words[index];
    this.playCachedWord(data);

  };
 
 
  playCachedWord = (data) => {
    var word = data.word;
    this.state.word = word;

    this.loadDefinition(word, this.state.loop_mode);

    UtilsView.fecthAudioLinkForWord(word, true);
  }

  loopBack = () => {
    this.state.direction = 0;
  };

  loopForward = () => {
    this.state.direction = 1;
  };

  onCheckLoop = (checked) => {
    let updated = !checked;

    this.setState({ should_loop_cached_words: updated });
  };

  onResetBtn = () => {
    this.setState({ current_play_index: 0 })
  };

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
              raised={true}
              backgroundColor='#F00'
            >
            </Button>

            <Button
              ref={LOOP_MODE_IMAGE_REF}
              onPress={() => this.onPressLoopModeImage()}
              style={styles.loop_mode_btn}
              title='Image'
              color={this.state.loop_mode == LOOP_TYPE.image ? "blue" : "black"}
              raised={true}
              backgroundColor='#F00'
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
        <View style={styles.bottomToolbarContainer}>
          <Button style={{
            backgroundColor: 'red', marginLeft: 0, width: 30, height
            : 30
          }} title='<'
            color="black"

            onPress={this.loopBack}
          />
          <Button style={{
            backgroundColor: 'red', marginLeft: 0, width: 30, height
            : 30
          }} title='>'
            color="black"

            onPress={this.loopForward}
          />
          <TouchableOpacity
            onPress={this.onResetBtn}
            style={{
              position: 'absolute', right: 10, padding: 0,
              width: 50, height: 40, alignItems: 'center'
            }}>
            <Text style={{ paddingTop: 10 }} >Reset</Text>
          </TouchableOpacity>


          <View
            style={{
              position: 'absolute', right: 60, padding: 0,
              width: 70, height: 40, alignContent: 'center'
            }}>
            <CheckBox
              label='Loop'
              checked={this.state.should_loop_cached_words}
              containerStyle={{ height: 30, top: 3 }}
              labelStyle={{ color: 'black', marginLeft: -5 }}
              onChange={this.onCheckLoop}
            />
          </View>


          <TouchableOpacity
            onPress={this.onLoadCachedWords}
            style={{
              position: 'absolute', right: 140, padding: 0,
              width: 50, height: 40, alignContent: 'center'
            }}>
            <Text style={{ paddingTop: 10 }} >Cached</Text>
          </TouchableOpacity>

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
    margin: 10,
    marginBottom: 40,
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
    marginRight: 10,
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
  loop_mode_btn: { width: 50, height: 30, backgroundColor: 'blue', alignItems: 'center' },

  bottomToolbarContainer: {
    height: 40,
    flexDirection: 'row',
    margin: 0,
    backgroundColor: '#F5FCFF',
    overflow: 'hidden'

  }
});


module.exports = MainView;