var webpack = require('webpack');
const path = require('path');
const { environment } = require('@rails/webpacker')
const erb = require('./loaders/erb')
const coffee =  require('./loaders/coffee')

environment.loaders.prepend('erb', erb)
environment.loaders.append('coffee', coffee)
environment.loaders.prepend('erb', erb)
module.exports = environment
environment.plugins.prepend('Provide', new webpack.ProvidePlugin({
    $: "jquery",
    JQuery: "jquery",
    jquery: "jquery"
}))
