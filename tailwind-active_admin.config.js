// Nodeless ActiveAdmin v4 Tailwind config (ticket 12). Loaded by the
// tailwindcss-rails standalone CLI through the `@config` directive in
// app/assets/stylesheets/active_admin.css.
//
// ActiveAdmin ships its Tailwind plugin and view templates inside the gem, so
// we resolve them from `bundle show activeadmin` rather than an npm package
// under node_modules — this app has no node/yarn toolchain. CommonJS `require`
// is used (not ESM `import`) because the gem path is computed at runtime.
const { execSync } = require('child_process');

// Bundler's DEBUG output can prepend lines, so the gem path is the last one.
const activeAdminPath = execSync('bundle show activeadmin', { encoding: 'utf-8' })
  .trim()
  .split(/\r?\n/)
  .pop();

// plugin.js is an ES module, so require() hands back the namespace object; the
// plugin function lives on its default export.
const activeAdminPlugin = require(`${activeAdminPath}/plugin.js`);

module.exports = {
  content: [
    `${activeAdminPath}/vendor/javascript/flowbite.js`,
    `${activeAdminPath}/plugin.js`,
    `${activeAdminPath}/app/views/**/*.{arb,erb,html,rb}`,
    './app/admin/**/*.{arb,erb,html,rb}',
    './app/views/active_admin/**/*.{arb,erb,html,rb}',
    './app/views/admin/**/*.{arb,erb,html,rb}',
    './app/views/layouts/active_admin*.{erb,html}',
    './app/javascript/**/*.js'
  ],
  darkMode: 'selector',
  plugins: [activeAdminPlugin.default || activeAdminPlugin]
};
