/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,jsx}'],
  corePlugins: {
    preflight: false,
  },
  theme: {
    extend: {
      colors: {
        ag: {
          50: '#eff6ff',
          100: '#dbeafe',
          200: '#bfdbfe',
          500: '#3b82f6',
          600: '#1a73e8',
          700: '#1d4ed8',
          800: '#1e3a8a',
          900: '#0f2942',
        },
      },
    },
  },
  plugins: [],
};
