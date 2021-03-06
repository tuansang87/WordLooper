/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { Component } from 'react';
var ReactNative = require('react-native');
var AsyncStorage = require('AsyncStorage');
import RNAudioStreamer from 'react-native-audio-streamer';
// var Drive = require('./google-drive.js'); 
import Button from 'apsl-react-native-button'

import {
  StyleSheet,
  Text,
  TextInput,
  // Button,
  View,
  Image,
  TouchableOpacity,
  TouchableHighlight,
  WebView,
  Platform

} from 'react-native';

var UtilsView = require('./NativeModule/UtilView/index.ios.js');
import CheckBox from 'react-native-checkbox';

const kWordPlayholder = 'input your word';
const WEBVIEW_REF = 'webview';
const LOOP_MODE_ALL_REF = 'all';
const LOOP_MODE_IMAGE_REF = 'image';
const WORD_INPUT_REF = 'word_input';

const HOST_INPUT_REF = 'host_input';
const USER_INPUT_REF = 'user_name_input';

const LOOP_TYPE = { 'all': 1, 'image': 2, 'new': 3 };
const TRANSLATE_TYPE = { 'en': 1, 'vn': 2, 'other': 3 };
const LOOP_DIRECTION_TYPE = { 'back': 0, 'forward': 1 };
const LOOP_INTERVAL_TIME = 5000;

const STORAGE_CACHED_WORDS = 'cached_words'
const STORAGE_LOOP_MODE = 'loop_mode'
const STORAGE_CURRENT_PLAY_INDEX = 'current_play_index'
const STORAGE_LOOP_DIRECTION = 'direction'
const STORAGE_HOST = 'host'
const STORAGE_USER = 'user'

var lastPlayWord = null;
var myTimer = null;

export default class MainView extends Component {
  componentWillUnmount() {
    // console.warn('componentWillUnmount');
    if (this.state.cached_words != null
      && typeof (this.state.cached_words) != 'undefined') {
      AsyncStorage.setItem(STORAGE_CACHED_WORDS, JSON.stringify(this.state.cached_words), (err) => {
        if (err) {
          // console.warn(JSON.stringify(err));
        }
      });
    }

  };

  componentDidMount() {

    this.setState({ translate_mode: TRANSLATE_TYPE.en });
    AsyncStorage.getItem(STORAGE_CACHED_WORDS, (err, result) => {
      if (result != null && typeof (result) != 'undefined') {
        let words = JSON.parse(result);
        this.setState({ cached_words: words });
      } else {
        this.setState({ cached_words: [] });
      } 
    });

    AsyncStorage.getItem(STORAGE_LOOP_MODE, (err, result) => {
      this.setState({ loop_mode: (result != null ? result : LOOP_TYPE.all) });
    });

    AsyncStorage.getItem(STORAGE_LOOP_DIRECTION, (err, result) => {
      this.setState({ direction: (result != null ? result : LOOP_DIRECTION_TYPE.forward) });
    });

    AsyncStorage.getItem(STORAGE_CURRENT_PLAY_INDEX, (err, result) => {
      this.setState({ current_play_index: (result != null ? result : 0) })
    });

    AsyncStorage.getItem(STORAGE_HOST, (err, result) => {
      this.setState({ host: (result != null ? result : '') });
      this.updateFileUrlIfNeeded();
    });

    AsyncStorage.getItem(STORAGE_USER, (err, result) => {
      this.setState({ username: (result != null ? result : '') });
      this.updateFileUrlIfNeeded();
    });





  };

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
      // for mobile only
      , host: ''
      , username: ''
      , file_url: ''
    };

  };


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

  cachedWord = (word) => {
    var cached = null;
    if (this.state.cached_words) {
      for (var i = 0; i < this.state.cached_words.length; i++) {
        var wordI = this.state.cached_words[i];
        if (wordI["word"] == word) {
          cached = wordI;
          break;
        }
      }
    }
    return cached;
  };

  playCurentWord = () => {
    var word = this.state.word;
    if (Platform.OS == 'ios') {
      UtilsView.fecthAudioLinkForWord(word, true);
    } else {
      // handle for android here
      var cached = this.cachedWord(word);
      if (cached != null) {
        this.playSoundFromCachedWord(cached);
      }
    }
  };

  onNewWordEndEditing = () => {
    if (this.state.word.indexOf('https') == 0) {
      this.setState({ word_uri: this.state.word });
    } else {
      if (Platform.OS == 'ios') {
        UtilsView.fecthAudioLinkForWord(this.state.word, true);
      } else {
        // handle for android here
        var cached = this.cachedWord(this.state.word);
        if (cached != null) {
          this.playSoundFromCachedWord(cached);
        }
      }

    }

  };

  onWordSearchingChanged = (word) => {
    this.setState({ word: word, should_loop_cached_words: false });
    this.loadDefinition(word, this.state.loop_mode, this.state.translate_mode);

  };

  loadDefinition = (word, loop_mode, translate_mode) => {
    var url = '';
    if (translate_mode == TRANSLATE_TYPE.vn && loop_mode != LOOP_TYPE.image) {
      url = "http://translate.google.com/?tl=vi#auto/vi/" + word;
    } else {
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
    }

    this.setState({ word_uri: url });

  };

  goBack = () => {
    this.refs[WEBVIEW_REF].goBack();
  };

  goForward = () => {
    this.refs[WEBVIEW_REF].goForward();
  };


  onPressTranslateModeEng = () => {
    this.setState({ translate_mode: TRANSLATE_TYPE.en });
    this.loadDefinition(this.state.word, this.state.loop_mode, TRANSLATE_TYPE.en);
    console.log('eng');
  };

  onPressTranslateModeVni = () => {
    this.setState({ translate_mode: TRANSLATE_TYPE.vn });
    this.loadDefinition(this.state.word, this.state.loop_mode, TRANSLATE_TYPE.vn);
    console.log('vn');
  };

  onPressLoopModeAll = () => {
    this.setState({ loop_mode: LOOP_TYPE.all });
    this.loadDefinition(this.state.word, LOOP_TYPE.all, this.state.translate_mode);
    console.log('all');
  };

  onPressLoopModeImage = () => {
    this.setState({ loop_mode: LOOP_TYPE.image });

    this.loadDefinition(this.state.word, LOOP_TYPE.image, this.state.translate_mode);
    console.log('image');
  };


  onDownload = () => {
    // handle here
    this.updateFileUrlIfNeeded();
  };


  onLoadCachedWords = () => {
    this.props.navigation.navigate('CachedView', {
      'words': this.state.cached_words,
      callback: this.playCachedWord
    });

  };

  onUpload = () => {
    // handle here  
  };

  playSoundFromCachedWord = (word) => {
    var link = word.audio;
    if (link && link != '') {
      RNAudioStreamer.setUrl(link);
      RNAudioStreamer.play();
    }
  };

  onAudioLinkDetectedCallback = (event) => {
    let link = event.nativeEvent.link;
    UtilsView.playSound(link);
  };

  onLoadCachedWordsCallback = (event) => {
    /*
    let data = event.nativeEvent;
    let words = data.words;
    // console.log(JSON.stringify(words));
    // be continue
    this.setState({ cached_words: words });
    if (words.length) {
      this.doLoopForCacedWords();
    }
    */
  };

  doLoopForCacedWords = () => {
    if (myTimer) {
      clearTimeout(myTimer);

    }
    myTimer = null;

    myTimer = setTimeout(() => {
      if (this.state.should_loop_cached_words == true) {
        var index = this.state.current_play_index;
        let cachedCnt = this.state.cached_words.length;
        if (cachedCnt > 0) {
          if (index <= 0 && this.state.direction == LOOP_DIRECTION_TYPE.back) {
            index = cachedCnt - 1;
          } else if (index >= cachedCnt) {
            index = 0;
          }
          console.log(index);
          //updated next played index 
          if (this.state.direction == LOOP_DIRECTION_TYPE.back) {
            this.state.current_play_index = index - 1;
          } else {
            this.state.current_play_index = index + 1;
          }

          this.playCachedWordAtIndex(index);
          this.doLoopForCacedWords();
        } else {
          this.state.current_play_index = 0;
        }
        AsyncStorage.setItem(STORAGE_CURRENT_PLAY_INDEX, (this.state.current_play_index + ''), (err) => {
          if (err) {
            // console.warn(JSON.stringify(err));
          }
        });
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

    this.loadDefinition(word, this.state.loop_mode, this.state.translate_mode);
    if (data.audio != null && data.audio.length != '') {
      this.playSoundFromCachedWord(data);
    } else {
      if (Platform.OS == 'ios') {
        UtilsView.fecthAudioLinkForWord(word, true);
      } else {
        // handle for android here
        // do nothing
      }
    }
  }

  loopBack = () => {
    this.setState({ direction: 0 });
    AsyncStorage.setItem(STORAGE_LOOP_DIRECTION, '0', (err) => {
      if (err) {
        // console.warn(JSON.stringify(err));
      }
    });
  };

  loopForward = () => {
    this.setState({ direction: 1 });
    AsyncStorage.setItem(STORAGE_LOOP_DIRECTION, '1', (err) => {
      if (err) {
        // console.warn(JSON.stringify(err));
      }
    });
  };

  onCheckLoop = (checked) => {
    let updated = !checked;
    this.setState({ should_loop_cached_words: updated });
  };

  onResetBtn = () => {
    this.setState({ current_play_index: 0 });
    AsyncStorage.setItem(STORAGE_CURRENT_PLAY_INDEX, '0', (err) => {
      if (err) {
        alert('Opp! Cannot fetch the latest words from MAC server!')
        // console.warn(JSON.stringify(err));
      }
    });
  };

  downloadFileIfAvailable = (fileUrl) => {

    if (fileUrl && fileUrl != '') {
      fetch(fileUrl)
        .then((response) => response.json())
        .then((responseJson) => {
          var words = responseJson.words;
          this.setState({ cached_words: words });
          AsyncStorage.setItem(STORAGE_CACHED_WORDS, JSON.stringify(words), (err) => {
            if (err) {
              // console.warn(JSON.stringify(err));
            }
          });

          if (words.length) {
            this.doLoopForCacedWords();
          }
        })
        .catch((error) => {
          // console.warn(error);
        });
    }
  };

  updateFileUrlIfNeeded = () => {
    var host = this.state.host;
    var user = this.state.username;
    if (host && user && host != '' && user != '') {

      AsyncStorage.setItem(STORAGE_HOST, host, (err) => {
        if (err) {
          // console.warn(JSON.stringify(err));
        }
      });

      AsyncStorage.setItem(STORAGE_USER, user, (err) => {
        if (err) {
          // console.warn(JSON.stringify(err));
        }
      });
      var fileUrl = 'http://' + host + '/~' + user + '/wordlooper.json';
      // console.warn(fileUrl);
      this.setState({ file_url: fileUrl });
      this.downloadFileIfAvailable(fileUrl);
    }
  };

  onHostOrUserEndEditing = () => {

    this.updateFileUrlIfNeeded();
  };

  onHostChangedText = (text) => {
    this.setState({ host: text });
  };

  onUserChangedText = (text) => {
    this.setState({ username: text });
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
        <View style={styles.fileServerContainer}>
          <Text style={styles.lookup}> Host: </Text>
          <TextInput
            ref={HOST_INPUT_REF}
            autoCapitalize='none'
            onEndEditing={this.onHostOrUserEndEditing}
            style={styles.host_txt}
            onChangeText={this.onHostChangedText}
            placeholder='your host'
            value={this.state.host}
          />
          <Text style={styles.lookup}> User: </Text>
          <TextInput
            ref={USER_INPUT_REF}
            autoCapitalize='none'
            onEndEditing={this.onHostOrUserEndEditing}
            style={styles.user_txt}
            onChangeText={this.onUserChangedText}
            placeholder='username'
            value={this.state.username}
          />
        </View>
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
          <View style={{ width: 40 }}>
            <Button
              ref={LOOP_MODE_ALL_REF}
              onPress={() => this.onPressTranslateModeEng()}

              style={{
                height: 30,
                borderRadius: 0,
                borderWidth: 0,
                backgroundColor: this.state.translate_mode == TRANSLATE_TYPE.en ? "green" : "gray"
              }}
              color={this.state.translate_mode == TRANSLATE_TYPE.en ? "green" : "gray"}
              title='En'
              raised={true}
              backgroundColor='#F00'
            >
              <Text style={{ color: 'white' }}>{'En'}</Text>
            </Button>

          </View>
          <View style={{ left: 4, width: 50 }}>


            <Button
              ref={LOOP_MODE_IMAGE_REF}
              onPress={() => this.onPressTranslateModeVni()}
              style={{
                height: 30,
                borderRadius: 0,
                borderWidth: 0,
                backgroundColor: this.state.translate_mode == TRANSLATE_TYPE.vn ? "green" : "gray"
              }}
              title='Vi'
              color={this.state.translate_mode == TRANSLATE_TYPE.vn ? "blue" : "gray"}
              raised={true}
              backgroundColor='#F00'
            >
              <Text style={{ color: 'white' }}>{'Vi'}</Text>
            </Button>
          </View >

          <View style={styles.loopContainer ,{left: 8, width: 50
  }
}>
  <Button
            ref={LOOP_MODE_ALL_REF}
            onPress={() => this.onPressLoopModeAll()}
            style={{
              height: 30,
              borderRadius: 0,
              borderWidth: 0,
              backgroundColor: this.state.loop_mode == LOOP_TYPE.all ? "green" : "gray"
            }}

            color={this.state.loop_mode == LOOP_TYPE.all ? "blue" : "gray"}
            title='All'
            raised={true}
            backgroundColor='#F00' >
            <Text style={{ color: 'white' }}>{'All'}</Text>
          </Button >

        </View >
        <View style={{ left: 12, width: 60 }}>


          <Button
            ref={LOOP_MODE_IMAGE_REF}
            onPress={() => this.onPressLoopModeImage()}
            style={{
              height: 30,
              borderRadius: 0,
              borderWidth: 0,
              backgroundColor: this.state.loop_mode == LOOP_TYPE.image ? "green" : "gray"
            }}

            title='Image'
            color={this.state.loop_mode == LOOP_TYPE.image ? "blue" : "gray"}
            raised={true}
            backgroundColor='#F00' >
            <Text style={{ color: 'white' }}>{'Image'}</Text>
          </Button >
        </View >

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
      </View >

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
        <View style={{
          marginLeft: 4,
          width: 40,
          height
          : 30
        }}>
          <Button title='<'
            style={{
              height: 30,
              borderRadius: 0,
              borderWidth: 0,
              backgroundColor: this.state.direction == LOOP_DIRECTION_TYPE.back ? "green" : "gray"

            }}
            color={this.state.direction == LOOP_DIRECTION_TYPE.back ? "blue" : "gray"}
            width
            onPress={this.loopBack}
          >
            <Text style={{ color: 'white' }}>{'<'}</Text>
          </Button>
        </View>

        <View style={{
          marginLeft: 4,
          width: 40,
          height
          : 30
        }}>
          <Button title='>'
            style={{
              height: 30,
              borderRadius: 0,
              borderWidth: 0,
              backgroundColor: this.state.direction == LOOP_DIRECTION_TYPE.forward ? "green" : "gray"
            }}
            color={this.state.direction == LOOP_DIRECTION_TYPE.forward ? "blue" : "gray"}

            onPress={this.loopForward}>

            <Text style={{ color: 'white' }}>{'>'}</Text>
          </Button>

        </View>


        <TouchableOpacity
          onPress={this.onResetBtn}
          style={{
            position: 'absolute', right: 10, padding: 0,
            width: 50, height: 40, alignItems: 'center'
          }}>
          <Text style={{ paddingTop: 10 }} >Reset</Text>
        </TouchableOpacity>


        <View
          style={styles.checkBoxContainer}>
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

      </View >
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
    height: 60,
    flexDirection: 'row',
    backgroundColor: '#F5FCFF',
    paddingTop: 20,
    marginBottom: 0
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
    bottom: 0,
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
    left: 8,
    // right: 20,
    alignItems: 'center'
  },
  upload_btn: { opacity: 0.0, position: 'absolute', right: 50, margin: 5, width: 30, height: 40, alignItems: 'center' },
  download_btn: { position: 'absolute', right: 10, margin: 5, width: 30, height: 40, alignItems: 'center' },
  loop_mode_btn: { width: 50, height: 30, backgroundColor: 'blue', alignItems: 'center' },

  bottomToolbarContainer: {
    height: 40,
    flexDirection: 'row',
    marginBottom: 0,
    marginRight: 0,
    marginLeft: 0,
    backgroundColor: '#F5FCFF',
    overflow: 'hidden'

  }
  , fileServerContainer: {
    height: 40, //(Platform.OS == 'ios') ? 0 : 40,
    flexDirection: 'row',
    marginBottom: 0,
    marginRight: 0,
    marginLeft: 0,
    backgroundColor: '#F5FCFF',
    overflow: 'hidden',
    opacity: 1  // (Platform.OS == 'ios') ? 0 : 1

  }, user_txt: {
    height: 40,
    width: 100,
    marginRight: 10,
    padding: 8,
    borderWidth: 1,
  }, host_txt: {
    height: 40,
    flex: 1,
    paddingLeft: 8,
    borderWidth: 1,
  }, checkBoxContainer: {
    position: 'absolute', right: 60, padding: 0,
    width: 70, height: 40, alignContent: 'center'
  }
});


module.exports = MainView;