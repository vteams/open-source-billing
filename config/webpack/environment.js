var webpack = require('webpack');
const { environment } = require('@rails/webpacker')
const erb = require('./loaders/erb')
const coffee =  require('./loaders/coffee')

environment.loaders.prepend('erb', erb)
environment.loaders.append('coffee', coffee)
environment.loaders.prepend('erb', erb)
module.exports = environment
environment.plugins.append('Provide', new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery'
}))