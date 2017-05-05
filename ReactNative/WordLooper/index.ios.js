/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { Component } from 'react';
import {
  AppRegistry,
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

const kWordPlayholder = 'input your word';
const WEBVIEW_REF = 'webview';
const LOOP_MODE_ALL_REF = 'all';
const LOOP_MODE_IMAGE_REF = 'image';
const WORD_INPUT_REF = 'word_input';

const LOOP_TYPE = { 'all': 1, 'image': 2, 'new': 3 };

var lastPlayWord = null;
export default class WordLooper extends Component {
  constructor(props) {
    super(props);
    this.state = {
      word: kWordPlayholder
      , word_uri: 'https://www.bing.com/search?q=define+hello'
      , loop_mode: LOOP_TYPE.all
    };
  }


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

  fecthAudioFileForWord = (word) => {

    if (word == null || word.length == 0) {
      return;
    }
    lastPlayWord = word;

    var self = this;
    // fetch('http://www.dictionary.com/browse/word', {
    //   method: 'GET'
    // }).then((resp) => {
    //   alert(JSON.stringify(resp));
    //   return resp;
    // })


    var request = new XMLHttpRequest();
    request.onreadystatechange = (e) => {
      if (request.readyState !== 4) {
        return;
      }

      if (request.status === 200) {
        var orgText = request.responseText;
        var length = orgText.length;
        var n = orgText.search('mwe_player_0');
        if (n > 0) {
          length -= n;
          var range = Math.min(n, 50000);
          orgText = orgText.substring(n, length);

          var text = '' + orgText.substring(0, range);

          // console.log('success', text);
          var beginTemplate = "<source src=\"//";
          var beginLinkRange = text.search(beginTemplate);
          beginLinkRange += beginTemplate.length;
          length = length - beginLinkRange;
          if (length > 0) {
            // alert('check ' + beginLinkRange);
            range = Math.min(length, 1000);
            text = '' + orgText.substring(beginLinkRange, range);
            // alert(text);

            var endLinkRange = text.search("\" type=");
            alert(endLinkRange);

            var link = text.substring(0, endLinkRange);
            if (link.length > 0) {
              link = 'https://' + link;

              alert(link);
            }
          }
        }

      } else {
        console.warn('error');
      }
    };
    var newLink = 'https://en.m.wiktionary.org/wiki/' + word.toLowerCase();

    request.open('GET', newLink);
    request.send();


    var options = {
      host: 'www.dictionary.com',
      path: '/browse/word?s=t'
    };

  };

  playCurentWord = () => {

    var word = this.state.word;

    this.fecthAudioFileForWord(word);
  };

  onWordSearchingChanged = (word) => {
    this.setState({ word: word });
    this.loadDefinition(word);
  };

  loadDefinition = (word) => {
    var url = '';
    switch (this.state.loop_mode) {
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
        url = 'https://www.bing.com/search?q=define+' + word + '&qs=n&FORM=HDRSC1';
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

  onPressLoopMode = (type) => {
    this.setState({ loop_mode: type });

    this.loadDefinition(this.state.word);

  };
  onDownload = () => {
  };
  onUpload = () => {
  };

  onReceiveMessage = (event) => {
    alert(' ', JSON.stringify(event.nativeEvent));
  };


  render() {
  

    var jsCode = "\
      setTimeout(() => {\
       window.postMessage(check : document.documentElement.outerHTML.toString());\
    } , 1000) \
    ";
    // jsCode = "";

    return (
      <View style={styles.container}>
        <View style={styles.lookupContainer}>
          <Text style={styles.lookup}>
            Lookup:
          </Text>
          <TextInput
            ref={WORD_INPUT_REF}
            style={styles.lookup_txt}
            onChangeText={(text) => this.onWordSearchingChanged(text)}
            placeholder={this.state.word}
          />

          <TouchableOpacity
            onPress={() => this.playCurentWord()}
            style={{ margin: 5, width: 30, height: 40, alignContent: 'center' }}
          >
            <Image style={styles.upload_img} source={require('./img/audio.png')} />
          </TouchableOpacity>

        </View>
        <View style={styles.topControlContainer}>
          <View style={styles.loopContainer}>
            <Button
              ref={LOOP_MODE_ALL_REF}
              onPress={() => this.onPressLoopMode(LOOP_TYPE.all)}
              style={styles.loop_mode_btn}
              color={this.state.loop_mode == LOOP_TYPE.all ? "blue" : "black"}
              title='All'
            >
            </Button>

            <Button
              ref={LOOP_MODE_IMAGE_REF}
              onPress={() => this.onPressLoopMode(LOOP_TYPE.image)}
              style={styles.loop_mode_btn}
              title='Image'
              color={this.state.loop_mode == LOOP_TYPE.image ? "blue" : "black"}
            >
            </Button>
          </View>

          <TouchableOpacity
            onPress={this.onDownload()}
            style={styles.download_btn} onPress={this.onPressLearnMore}>
            <Image style={styles.upload_img} source={require('./img/cloud-download.png')} />
          </TouchableOpacity>

          <TouchableOpacity
            onPress={this.onUpload()}
            style={styles.upload_btn} onPress={this.onPressLearnMore}>
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
            injectedJavaScript={jsCode}
            javaScriptEnabledAndroid={true}
            onMessage= {this.onReceiveMessage}
          />
        </View>

      </View>
    );
  }
}

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
    backgroundColor: 'red'

  },
  definitionContainer: {
    flexDirection: 'row',
    backgroundColor: '#F5FCFF',
    height: 40,
    top: 10,
    alignContent: 'center'
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
    alignContent: 'center'
  },
  loopContainer: {
    position: 'absolute',
    flexDirection: 'row',
    backgroundColor: '#F5FCFF',
    width: 200,
    // height: 40,
    left: 0,
    right: 20,
    alignContent: 'center'
  },
  upload_btn: { position: 'absolute', right: 50, margin: 5, width: 30, height: 40, alignContent: 'center' },
  download_btn: { position: 'absolute', right: 10, margin: 5, width: 30, height: 40, alignContent: 'center' },
  loop_mode_btn: { width: 50, height: 30, backgroundColor: 'blue', alignItems: 'center' }


});

AppRegistry.registerComponent('WordLooper', () => WordLooper);
