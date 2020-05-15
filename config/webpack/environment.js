const { environment } = require('@rails/webpacker')
const coffee =  require('./loaders/coffee')
const erb = require('./loaders/erb')
const webpack = require('webpack')
environment.loaders.append('erb', erb)
environment.loaders.append('coffee', coffee)
environment.plugins.append('Provide', new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery'
}))
environment.loaders.prepend('erb', erb)
module.exports = environment
