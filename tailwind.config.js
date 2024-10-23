module.exports = {
  content: [
    './app/views/**/*.html.haml',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js'
  ],
  theme: {
    fontFamily: {
      'sans': 'Helvetica, Arial, sans-serif',
    }
  },
  plugins: [
    require('@tailwindcss/forms'),
  ],
}
