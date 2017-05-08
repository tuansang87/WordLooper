'use strict';

import React, { Component } from 'react';
var ReactNative = require('react-native');
import {
    StyleSheet,
    ListView,
    View,
    Text,
    Button,
    TouchableOpacity

} from 'react-native';

export default class CachedView extends Component {
    constructor(props) {
        super(props);
        const ds = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });
        this.state = {
            dataSource: ds.cloneWithRows(
                this.props.navigation.state.params.words
            )
        };
    }

    static navigationOptions = {
        title: 'Cached Words'
    };
    deleteItem = () => {
        console.log('data');
    }

    playWord= (word) => {
       this.props.navigation.goBack();
       var callback = this.props.navigation.state.params.callback;
       if(callback != null && typeof(callback) != 'undefined') {
           callback(word);
       }
    };

    rowForData = (rowData) => {
        return <TouchableOpacity 
        onPress={() => this.playWord(rowData)}
         style={{ flex: 1,
        overflow :'hidden',
         backgroundColor: '#F5FCFF', flexDirection: 'row', height: 30 , paddingLeft : 10}}>
            <Text style={{
                color: 'black', backgroundColor: '#F5FCFF', width: 100
            }}>{rowData.word}</Text>
            <View style={{ opacity : 0, flex: 1, alignItems: 'flex-end', backgroundColor: '#F5FCFF' }}>
                <Button
                    color='black'
                    onPress={() => this.deleteItem()}
                    title='X'
                ></Button>
            </View>
            <View style={{backgroundColor:'black', width : 500, height : 1, bottom : 0
            ,position:'absolute'}}/>

        </TouchableOpacity>
    };

    render = () => {

        const passed_params = this.props.navigation.state.params;
        return (
            <View style={styles.container}>
                <View style={{ flex: 1, padding: 10 }}>
                    <ListView
                        dataSource={this.state.dataSource}
                        renderRow={this.rowForData}
                        on
                    />
                </View>
            </View>
        );
    };
};


const styles = StyleSheet.create({
    container: {
        flex: 1,
        flexDirection: 'column',
        backgroundColor: '#F5FCFF',
        // alignItems: 'center'
    }
});


module.exports = CachedView;
