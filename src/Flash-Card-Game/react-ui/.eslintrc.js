module.exports = {
  env: {
    browser: true,
    es2021: true,
  },
  extends: [
    'plugin:react/recommended',
    'airbnb',
  ],
  parserOptions: {
    ecmaFeatures: {
      jsx: true,
    },
    ecmaVersion: 13,
    sourceType: 'module',
  },
  plugins: [
    'react',
  ],
  rules: {
    'react/prop-types': 'off',
    'jsx-a11y/no-autofocus': 'off',
    'no-alert': 'off',
    'array-callback-return': 'off',
    'no-unused-vars': 'off',
    'no-param-reassign': 'off',
  },
};
