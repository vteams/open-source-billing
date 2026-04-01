const path = require('path');
const appRoot = path.join(__dirname, '..', '..', '..');
const rubyBin = '/home/dev/.rvm/rubies/ruby-2.7.1/bin/ruby';
const railsBin = path.join(appRoot, 'bin', 'rails');

module.exports = {
  test: /\.erb$/,
  enforce: 'pre',
  exclude: /node_modules/,
  use: [{
    loader: 'rails-erb-loader',
    options: {
      runner: rubyBin + ' ' + railsBin + ' runner',
      env: { RAILS_ENV: process.env.RAILS_ENV || 'staging' }
    }
  }]
}