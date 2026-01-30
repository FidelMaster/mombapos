module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  safelist: [
    'bg-primary-50', 'bg-primary-100', 'bg-primary-200', 'bg-primary-300',
    'bg-primary-400', 'bg-primary-500', 'bg-primary-600', 'bg-primary-700',
    'bg-primary-800', 'bg-primary-900', 'bg-primary-950',
    'bg-primary', 'hover:bg-primary-400', 'hover:bg-primary-500'
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#fff3ea',
          100: '#ffe3d0',
          200: '#ffc6a1',
          300: '#ff9e6d',
          400: '#fd6b12',
          500: '#eb4f00',
          600: '#bc3f00',
          700: '#953400',
          800: '#7a2d04',
          900: '#63260b',
          950: '#361102',
          DEFAULT: '#fd6b12',
        },
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
  ]
}
