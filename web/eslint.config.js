module.exports = [
  {
    files: ["**/*.js"],
    ignores: ["node_modules/**"],
    rules: {
      "no-unused-vars": "warn",
      "no-undef": "error",
      "no-console": "off",
      "eqeqeq": "error",
      "no-var": "warn",
    },
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: "commonjs",
      globals: {
        require: "readonly",
        module: "readonly",
        exports: "readonly",
        process: "readonly",
        __dirname: "readonly",
        console: "readonly",
        fetch: "readonly",
        describe: "readonly",
        it: "readonly",
      },
    },
  },
];
