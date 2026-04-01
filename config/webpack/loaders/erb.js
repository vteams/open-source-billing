const path = require('path');
const railsBin = path.join(__dirname, '..', '..', '..', 'bin', 'rails');

module.exports = {
  test: /\.erb$/,
  enforce: 'pre',
  exclude: /node_modules/,
  use: [{
    loader: 'rails-erb-loader',
    options: {
      runner: '/home/dev/.rvm/rubies/ruby-2.7.1/bin/ruby ' + railsBin + ' runner',
      env: { RAILS_ENV: process.env.RAILS_ENV || 'staging' }
    }
  }]
}