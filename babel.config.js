module.exports = function(api) {
  const validEnv = ['development', 'test', 'production'];
  const currentEnv = api.env();

  if (!validEnv.includes(currentEnv)) {
    throw new Error(
      `Please specify a valid 'NODE_ENV' or 'BABEL_ENV' environment variables. Valid values are "development", "test", and "production". Instead, received: ${currentEnv}.`
    );
  }

  return {
    presets: [
      api.env('test') && [
        '@babel/preset-env',
        {
          targets: {
            node: 'current'
          }
        }
      ],
      (api.env('production') || api.env('development')) && [
        '@babel/preset-env',
        {
          forceAllTransforms: true,
          useBuiltIns: 'entry',
          corejs: 3,
          modules: false,
          exclude: ['transform-typeof-symbol']
        }
      ]
    ].filter(Boolean),
    plugins: [
      'babel-plugin-macros',
      '@babel/plugin-syntax-dynamic-import',
      api.env('test') && 'babel-plugin-dynamic-import-node',
      '@babel/plugin-transform-destructuring',
      ['@babel/plugin-proposal-class-properties', { loose: true }],
      ['@babel/plugin-proposal-object-rest-spread', { useBuiltIns: true }],
      ['@babel/plugin-transform-runtime', { helpers: false, regenerator: true, corejs: false }],
      ['@babel/plugin-transform-regenerator', { async: false }]
    ].filter(Boolean)
  };
};