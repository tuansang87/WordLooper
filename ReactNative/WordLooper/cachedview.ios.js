'use strict';

import React, { Component } from 'react';
var ReactNative = require('react-native');
import {
    StyleSheet,
    ListView,
    View,
    Text,
    Button

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
    rowForData = (rowData) => {
        return <View style={{ flex: 1,
        overflow :'hidden',
         backgroundColor: '#F5FCFF', flexDirection: 'row', height: 30 }}>
            <Text style={{
                color: 'black', backgroundColor: '#F5FCFF', width: 100
            }}>{rowData}</Text>
            <View style={{ flex: 1, alignItems: 'flex-end', backgroundColor: '#F5FCFF' }}>
                <Button
                    color='black'
                    onPress={() => this.deleteItem()}
                    title='X'
                ></Button>
            </View>
            <View style={{backgroundColor:'black', width : 500, height : 1, bottom : 0
            ,position:'absolute'}}/>

        </View>
    };

    render = () => {

        const passed_params = this.props.navigation.state.params;
        return (
            <View style={styles.container}>
                <View style={{ flex: 1, padding: 10 }}>
                    <ListView
                        dataSource={this.state.dataSource}
                        renderRow={this.rowForData}
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
